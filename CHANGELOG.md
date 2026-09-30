## 1.1.0

- Update `icomoon_generator` to `2.0.0`, adding support for both legacy
  IcoMoon v1 (`icons[].properties`) and current IcoMoon v2
  (`glyphs[].extras`) selection formats.
- Download IcoMoon v2 `.icomoon.json` files first and fall back to v1
  `selection.json` files for legacy projects.
- Support v2 temporary-project font exports at both
  `/0/font/fonts/Untitled.ttf` and revision-based
  `/<revision>/font/fonts/Untitled.ttf` paths, while preserving legacy TTF
  paths.
- Resolve the matching Flutter font asset when v2 JSON does not include a
  font name, including projects with multiple configured font families.
- Add `family_name`/`--family-name` and `font_file_name`/`--font-file-name`
  options for generated Flutter classes.
- Update the Flutter example to generate and display v1 and v2 icon sets
  side by side.

## 1.0.0

- Done with the first stable version
- Fix lint whereNotNull() -> nonNulls
- Min Dart SDK >= 3.0.0

## 0.0.3

- Add logger for CLI
- Update README.md

## 0.0.2

- Add Documentation for `common` package
- Add Public APIs

## 0.0.1

- Initial release
