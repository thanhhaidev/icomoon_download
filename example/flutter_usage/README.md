# IcoMoon download example

This example demonstrates the same workflow as the
[`icomoon_generator` examples](https://github.com/thanhhaidev/icomoon_generator/tree/main/example/flutter_usage):
download one IcoMoon export, save its JSON and TTF, and generate a Flutter
icon class.

## IcoMoon v1

The legacy IcoMoon UI returns `icons[].properties` and uses
`selection.json`. Configure the example with the project URL values:

```yaml
icomoon_download:
  project_name: icomoon_generator
  host_id: "b90098d279"
  is_temp: true
  output_selection_file: fonts/selection_v1.json
  output_class_file: lib/ui/icons_v1.dart
  class_name: V1Icons
  family_name: IcomoonV1
  font_file_name: icomoon_v1.ttf
```

Declare the matching font in `pubspec.yaml`:

```yaml
flutter:
  fonts:
    - family: IcomoonV1
      fonts:
        - asset: fonts/icomoon_v1.ttf
```

In this example, the v1 configuration is stored in
`icomoon_download.v1.yaml`. Run it explicitly:

```shell
dart run icomoon_download:generator \
  --config-file=icomoon_download.v1.yaml
```

## IcoMoon v2

The current IcoMoon UI returns `glyphs[].extras` from
`<project>.icomoon.json`. The downloader requests this format first and
falls back to the v1 `selection.json` endpoint when the v2 file is not
available.

Use a separate output set for the v2 project:

```yaml
icomoon_download:
  project_name: icomoon-generator
  host_id: "536abd6d67"
  is_temp: true
  output_selection_file: fonts/selection_v2.json
  output_class_file: lib/ui/icons_v2.dart
  class_name: V2Icons
  family_name: IcomoonV2
  font_file_name: icomoon_v2.ttf
```

Declare the matching v2 font:

```yaml
flutter:
  fonts:
    - family: IcomoonV2
      fonts:
        - asset: fonts/icomoon_v2.ttf
```

Run the same command:

```shell
dart run icomoon_download:generator
```

The v2 JSON does not always contain a font name. When `family_name` is not
provided, the downloader uses the only Flutter font declared in
`pubspec.yaml`. If multiple fonts are declared, set `family_name` so the
matching TTF asset can be selected deterministically.

The `revision` value is supplied by the user from the IcoMoon export URL. The
v2 temporary project font is downloaded from either
`/<revision>/font/fonts/Untitled.ttf` or `/0/font/fonts/Untitled.ttf` and
written to the configured Flutter asset path (`fonts/icomoon_v2.ttf` in this
example). The v1 project uses the legacy `/icomoon.ttf` endpoint and writes
`fonts/icomoon_v1.ttf`.

## Keeping v1 and v2 together

Each export must keep its JSON, TTF, generated class, and font family paired:

```text
fonts/
├── selection_v1.json
├── icomoon_v1.ttf
├── selection_v2.json
└── icomoon_v2.ttf

lib/
├── ui/icons_v1.dart
└── ui/icons_v2.dart
```

Do not use the v1 TTF with v2 JSON/code points, or the v2 TTF with v1 JSON.
