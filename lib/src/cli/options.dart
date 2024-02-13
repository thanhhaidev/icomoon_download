import 'package:args/args.dart';

import 'arguments.dart';

void defineOptions(ArgParser argParser) {
  argParser
    ..addSeparator('Flutter class options:')
    ..addOption(
      kOptionNames[CliArgument.className]!,
      abbr: 'c',
      help: 'Name for a generated class.',
      valueHelp: 'name',
    )
    ..addOption(
      kOptionNames[CliArgument.fontPackage]!,
      abbr: 'f',
      help:
          'Name of a package that provides a font. Used to provide a font through package dependency.',
      valueHelp: 'name',
    )
    ..addFlag(
      kOptionNames[CliArgument.format]!,
      help: 'Formate dart generated code.',
      defaultsTo: kDefaultFormat,
    )
    ..addSeparator('Other options:')
    ..addFlag(
      kOptionNames[CliArgument.isTemp]!,
      help: 'Default is true. If true, using  free version of icomoon.',
      defaultsTo: kDefaultIsTemp,
    )
    ..addOption(
      kOptionNames[CliArgument.selectionFile]!,
      abbr: 's',
      help:
          'Output file for the selection.json. If not provided, the file is saved in the current working directory.',
      valueHelp: 'path',
    )
    ..addOption(
      kOptionNames[CliArgument.configFile]!,
      abbr: 'z',
      help:
          'Path to icomoon_download yaml configuration file. pubspec.yaml and icomoon_download.yaml files are used by default.',
      valueHelp: 'path',
    )
    ..addFlag(
      kOptionNames[CliArgument.verbose]!,
      abbr: 'v',
      help: 'Display every logging message.',
      defaultsTo: kDefaultVerbose,
      negatable: false,
    )
    ..addFlag(
      kOptionNames[CliArgument.help]!,
      abbr: 'h',
      help: 'Shows this usage information.',
      negatable: false,
    );
}
