import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:dart_style/dart_style.dart';
import 'package:icomoon_download/src/cli/arguments.dart';
import 'package:icomoon_download/src/cli/options.dart';
import 'package:icomoon_download/src/common/api.dart';
import 'package:icomoon_download/src/common/font.dart';
import 'package:icomoon_download/src/utils/logger.dart';
import 'package:icomoon_generator/icomoon_generator.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

final _argParser = ArgParser(allowTrailingOptions: true);
final formatter = DartFormatter(
  pageWidth: 80,
  languageVersion: DartFormatter.latestLanguageVersion,
);

void main(List<String> args) {
  defineOptions(_argParser);

  late final CliArguments parsedArgs;

  try {
    parsedArgs = parseArgsAndConfig(_argParser, args);
  } on CliArgumentException catch (e) {
    _usageError(e.message);
  } on CliHelpException {
    _printHelp();
  } on YamlException catch (e) {
    logger.e(e.toString());
    exit(66);
  }

  try {
    _run(parsedArgs);
  } on Object catch (e) {
    logger.e(e.toString());
    exit(65);
  }
}

void _run(CliArguments parsedArgs) async {
  final stopwatch = Stopwatch()..start();

  final isVerbose = parsedArgs.verbose ?? kDefaultVerbose;

  if (isVerbose) {
    logger.setFilterLevel(Level.trace);
  }

  try {
    final icomoonService = IconmoonDownloadApi(
      parsedArgs.isTemp ?? false,
      parsedArgs.hostId,
      parsedArgs.projectName,
      revision: parsedArgs.revision,
    );
    logger.i('Downloading IcoMoon font "${parsedArgs.projectName}"');
    final selectionData = await icomoonService.getSelection();
    final selection = Selection.fromJson(selectionData);

    if (selection.icons.isEmpty) {
      logger.e('No icons found in the selection file.');
      exit(1);
    }

    final fonts = icomoonService.getFontsFromPubspec();

    if (fonts.isEmpty) {
      logger.e('No fonts found in the pubspec.yaml file.');
      exit(1);
    }

    final font = _findFont(
      fonts,
      parsedArgs.familyName ?? selection.name,
    );
    final fontLabel = parsedArgs.familyName ??
        (selection.name.isNotEmpty ? selection.name : font.family);
    logger.i('Downloading TTF file for "$fontLabel"');
    final ttfFontName =
        selection.name.isNotEmpty ? selection.name : font.family;
    final ttf = await icomoonService.getTTF(ttfFontName);
    final ttfPath = font.assets.first;

    if (ttf == null) {
      logger.e('No TTF file found for the font "$fontLabel".');
      exit(1);
    }

    logger.i('Creating TTF file for "$fontLabel"');
    final ttfFile = await icomoonService.createFile(ttfPath);
    await ttfFile.writeAsBytes(ttf);
    logger.t('TTF file created: ${ttfFile.path}');

    logger.i('Creating selection file for "$fontLabel"');
    final hasSelectionFile = parsedArgs.selectionFile != null;
    if (hasSelectionFile && !parsedArgs.selectionFile!.existsSync()) {
      parsedArgs.selectionFile!.createSync(recursive: true);
      logger.t('Selection file does not exist - creating it.');
    } else if (hasSelectionFile) {
      logger.t(
          'Output file for a json selection already exists (${parsedArgs.selectionFile!.path}) - '
          'overwriting it');
    }
    if (hasSelectionFile) {
      parsedArgs.selectionFile!.writeAsStringSync(jsonEncode(selectionData));

      logger.t('Using selection file provided.');
    } else {
      logger.t('No selection file provided - using default location.');
      final selectionFile = await icomoonService.createFile('selection.json');
      if (selectionFile.existsSync()) {
        selectionFile.writeAsStringSync(jsonEncode(selectionData));

        logger.t('Selection file created.');
      }
    }
    logger.i('Selection file created: ${parsedArgs.selectionFile?.path}');

    logger.i('Generating Flutter class for "$fontLabel"');
    var classString = generateFlutterClass(
      iconsList: selection.icons,
      className: parsedArgs.className,
      package: parsedArgs.fontPackage,
      familyName: parsedArgs.familyName ?? font.family,
      fontFileName: parsedArgs.fontFileName ?? path.basename(ttfPath),
    );

    if (!parsedArgs.classFile.existsSync()) {
      parsedArgs.classFile.createSync(recursive: true);
    } else {
      logger.t(
          'Output file for a Flutter class already exists (${parsedArgs.classFile.path}) - '
          'overwriting it');
    }

    logger.i('Writing Flutter class to "${parsedArgs.classFile.path}"');

    if (parsedArgs.format ?? kDefaultFormat) {
      logger.t('Formatting Flutter class generation.');
      classString = formatter.format(classString);
    }

    parsedArgs.classFile.writeAsStringSync(classString);
    logger.i('Flutter class written to "${parsedArgs.classFile.path}"');
  } on Object catch (e) {
    logger.e(e.toString());
    exit(1);
  }

  logger.i('Generated in ${stopwatch.elapsedMilliseconds}ms');
}

Font _findFont(List<Font> fonts, String selectionName) {
  if (selectionName.isNotEmpty) {
    final matchingFonts = fonts
        .where(
            (font) => font.family.toLowerCase() == selectionName.toLowerCase())
        .toList();
    if (matchingFonts.length == 1) {
      return matchingFonts.single;
    }
  }

  if (fonts.length == 1) {
    return fonts.single;
  }

  throw StateError(
    'Unable to determine the font for the selection. '
    'Set family_name or use a pubspec.yaml with exactly one Flutter font.',
  );
}

void _printHelp() {
  _printUsage();
  exit(exitCode);
}

void _usageError(String error) {
  _printUsage(error);
  exit(64);
}

void _printUsage([String? error]) {
  final message = error ?? _kAbout;

  stdout.write('''
$message

$_kUsage
${_argParser.usage}
''');
  exit(64);
}

const _kAbout =
    'Download IcoMoon fonts and generate Flutter compatible font files.';

const _kUsage = '''
Usage:   icomoon_download <project-name> <host-id> <output-class-file> [options]

Example: icomoon_download my_project 123456 lib/my_icons.dart --output-selection-file=selection.json --class-name=MyIcons --package=my_icons
''';
