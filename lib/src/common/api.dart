import 'dart:io';

import 'package:dio/dio.dart';
import 'package:icomoon_download/src/common/font.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

/// Service to interact with the IcoMoon public download API.
///
/// This service supports both the legacy IcoMoon endpoints and the current
/// endpoints, which expose a `.icomoon.json` file.
class IconmoonDownloadApi {
  final _dio = Dio(BaseOptions(baseUrl: 'https://i.icomoon.io/public/'));

  /// The project is temporary by default.
  final bool isTemp;

  /// The host id of the project.
  final String hostId;

  /// The name of the project.
  final String projectName;

  /// Optional revision used by current IcoMoon font export URLs.
  final String? revision;

  /// * [isTemp] is used to determine if the project is a temporary project.
  /// * [hostId] is the host id of the project.
  /// * [projectName] is the name of the project.
  IconmoonDownloadApi(this.isTemp, this.hostId, this.projectName,
      {this.revision});

  /// Returns the selection.json of the project.
  Future<Map<String, dynamic>> getSelection() async {
    final paths = [
      '${_projectPath()}/0/$projectName.icomoon.json',
      '${_projectPath()}/selection.json',
    ];

    for (var index = 0; index < paths.length; index++) {
      try {
        final response = await _dio.get<Map<String, dynamic>>(paths[index]);
        return response.data!;
      } on DioException catch (error) {
        final isLastPath = index == paths.length - 1;
        final canTryLegacyPath =
            error.response?.statusCode == 404 && !isLastPath;
        if (!canTryLegacyPath) {
          rethrow;
        }
      }
    }

    throw StateError('Unable to download the IcoMoon selection JSON.');
  }

  /// Returns the TTF file of the font.
  /// * [fontName] is the name of the font.
  Future<List<int>?> getTTF(String fontName) async {
    final paths = [
      if (revision != null && revision!.isNotEmpty)
        '${_projectPath()}/$revision/font/fonts/Untitled.ttf',
      '${_projectPath()}/0/font/fonts/Untitled.ttf',
      '${_projectPath()}/0/font/fonts/$fontName.ttf',
      '${_projectPath()}/$fontName.ttf',
      '${_projectPath()}/0/$projectName.ttf',
    ];

    for (var index = 0; index < paths.length; index++) {
      try {
        final response = await _dio.get<List<int>>(
          paths[index],
          options: Options(responseType: ResponseType.bytes),
        );
        return response.data;
      } on DioException catch (error) {
        final isLastPath = index == paths.length - 1;
        final canTryLegacyPath =
            error.response?.statusCode == 404 && !isLastPath;
        if (!canTryLegacyPath) {
          rethrow;
        }
      }
    }

    return null;
  }

  String _projectPath() => '${isTemp ? "temp/" : ""}$hostId/$projectName';

  /// Returns the fonts from the pubspec.yaml file of the project.
  List<Font> getFontsFromPubspec() {
    final file = getPubspecFile()!;
    final fileContent = file.readAsStringSync();
    final pubspecYaml = loadYaml(fileContent) as YamlMap;
    final pubspecFonts = pubspecYaml['flutter']['fonts'] as YamlList;
    final fonts = pubspecFonts
        .map(
          (font) => Font(
            font['family'],
            (font['fonts'] as YamlList)
                .map((x) => x['asset'] as String)
                .toList(),
          ),
        )
        .toList();

    return fonts;
  }

  /// Returns the pubspec.yaml file of the project.
  File? getPubspecFile() {
    var rootDirPath = Directory.current.path;
    var pubspecFilePath = join(rootDirPath, 'pubspec.yaml');
    var pubspecFile = File(pubspecFilePath);

    return pubspecFile.existsSync() ? pubspecFile : null;
  }

  /// Creates a file in the project.
  /// * [path] is the path of the file to create.
  Future<File> createFile(String path) async {
    final rootDirectory = Directory.current.path;
    final filePath = join(rootDirectory, path);
    final file = File(filePath);
    await file.create(recursive: true);
    return file;
  }
}
