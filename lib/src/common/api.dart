import 'dart:io';

import 'package:dio/dio.dart';
import 'package:icomoon_download/src/common/font.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

/// Service to interact with Icomoon API.
///
/// This service is used to get the selection.json and the TTF file from Icomoon.
class IconmoonDownloadApi {
  final _dio = Dio(BaseOptions(baseUrl: 'https://i.icomoon.io/public/'));

  final bool isTemp;
  final String hostId;
  final String projectName;

  /// * [isTemp] is used to determine if the project is a temporary project.
  /// * [hostId] is the host id of the project.
  /// * [projectName] is the name of the project.
  IconmoonDownloadApi(this.isTemp, this.hostId, this.projectName);

  /// Returns the selection.json of the project.
  Future<Map<String, dynamic>> getSelection() async {
    final selectionResponse = await _dio.get(
      '${isTemp ? "temp" : ""}/$hostId/$projectName/selection.json',
    );

    return selectionResponse.data;
  }

  /// Returns the TTF file of the font.
  /// * [fontName] is the name of the font.
  Future<List<int>?> getTTF(String fontName) async {
    final ttf = await _dio.get<List<int>>(
      '${isTemp ? "temp" : ""}/$hostId/$projectName/$fontName.ttf',
      options: Options(responseType: ResponseType.bytes),
    );

    return ttf.data;
  }

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
  Future<File> createFile(String path) async {
    final rootDirectory = Directory.current.path;
    final filePath = join(rootDirectory, path);
    final file = File(filePath);
    await file.create(recursive: true);
    return file;
  }
}
