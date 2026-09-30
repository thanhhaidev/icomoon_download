# icomoon_download

[![pub package](https://img.shields.io/pub/v/icomoon_download.svg)](https://pub.dartlang.org/packages/icomoon_download)

A tool to download icomoon icons from icomoon.io and generate a dart file to use in Flutter (using [icomoon_generator](https://pub.dartlang.org/packages/icomoon_generator) package). Please note that this package is not affiliated with icomoon.io. It's just a tool to help you download and use icomoon icons in Flutter.

## Font generation

### Install via dev dependency

```shell
$ flutter pub add --dev icomoon_download

# And it's ready to go:
$ dart run icomoon_download:generate <project-name> <host-id> <output-class-file> [options]
```

### or [Globally activate][] the package:

[globally activate]: https://dart.dev/tools/pub/cmd/pub-global

```shell
$ dart pub global activate icomoon_download

# And it's ready to go:
$ icomoon_download <project-name> <host-id> <output-class-file> [options]
```

Example: https://i.icomoon.io/public/temp/12345/MyProject/selection.json <- `project-name` is `MyProject`, `host-id` is `12345` and `--no-is-temp` option (default) is used.
Required positional arguments:

- `<project-name>`
  Name of the project.
- `<host-id>`
  Host ID of the project.
- `<output-class-file>`
  Path to the output class file. Should have .dart extension.

Flutter class options:

- `-c` or `--class-name=<name>`
  Name for a generated class.
- `-p` or `--package=<name>`
  Name of a package that provides a font. Used to provide a font through package dependency.
- `--[no-]format`
  Format dart generated code.

Other options:

- `--[no-]-is-temp`
  Using free version of icomoon.
- `-s` or `--output-selection-file=<path>`
  Output file for the downloaded IcoMoon JSON. This supports both the legacy
  `selection.json` format and the current `.icomoon.json` format. If not
  provided, the file is saved as `selection.json` in the current working
  directory.
- `--family-name=<name>`
  Font family name used in generated `IconData`. Defaults to the matching
  Flutter font family.
- `--font-file-name=<name>`
  Font asset file name used in generated documentation. Defaults to the
  downloaded TTF asset name.
- `-z` or `--config-file=<path>`
  Path to icomoon_download yaml configuration file.
  pubspec.yaml and icomoon_download.yaml files are used by default.
- `-v` or `--verbose`
  Display every logging message.
- `-h` or `--help`
  Shows usage information.

_Usage example:_

Updated Flutter project's pubspec.yaml:

```yaml
flutter:
  fonts:
    - family: Icomoon
      fonts:
        - asset: fonts/icomoon.ttf
```

```shell
$ icomoon_download MyProject 12345 lib/my_icons.dart --class-file=MyIcons --output-selection-file=selection.json -v
```

## Config file

icomoon*download's configuration can also be placed in yaml file.
Add \_icomoon_download* section to either `pubspec.yaml` or `icomoon_download.yaml` file:

```yaml
icomoon_download:
  project_name: MyProject
  host_id: "123456"
  is_temp: true

  output_selection_file: fonts/selection.json
  output_class_file: lib/ui/icons.dart

  class_name: UiIcons
  family_name: Icomoon
  font_file_name: icomoon.ttf
  format: true

  verbose: false
```

`project_name`, `host_id` and `output_class_file` keys are required.
It's possible to specify any other config file by using `--config-file` option.

The `family_name` and `font_file_name` options are useful when a project
contains multiple IcoMoon exports. Keep each export's JSON, TTF, generated
class, and Flutter font family paired.

## Current IcoMoon JSON format

The downloader first requests the current IcoMoon endpoint
`<project>.icomoon.json` and falls back to the legacy `selection.json`
endpoint when necessary. The downloaded JSON is passed to
`icomoon_generator` 2.0.0, which supports both `glyphs[].extras` (current
IcoMoon) and `icons[].properties` (legacy IcoMoon) formats.

For current temporary projects, the downloader checks both current font
export paths, `/<revision>/font/fonts/Untitled.ttf` and
`/0/font/fonts/Untitled.ttf`, before trying legacy TTF paths.

For revision-based exports, provide the revision from the IcoMoon URL with
`--revision=<revision>` or the `revision` configuration key. The downloader
does not hard-code a revision.

For current IcoMoon projects, keep the matching TTF and JSON from the same
project. When the JSON does not contain a font name, the downloader uses the
single Flutter font declared in `pubspec.yaml`; projects with multiple fonts
can set `family_name` explicitly.

## Contributing

Any suggestions, issues, pull requests are welcomed.

## License

[MIT](https://github.com/thanhhaidev/icomoon_download/blob/master/LICENSE)
