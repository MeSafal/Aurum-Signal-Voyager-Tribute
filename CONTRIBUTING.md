# Contributing

Thanks for helping improve Aurum Signal.

## Before opening a PR

```bash
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --release
```

CI repeats the format check, analysis and tests, builds the web app and uploads
an APK artifact.

## Ground rules

- Keep the app offline. Do not add network calls at runtime.
- Never introduce flashing or strobing. Any timing change must keep the
  rhythm at or below 3 luminance changes per second and update the safety
  test in `test/morse_timeline_test.dart`.
- All copy must be original. Do not add Carl Sagan quotations, book text or
  copyrighted music.
- New media must come from a verified public source. Record the URL, size and
  licence in `docs/ASSETS.md` and the facts in `docs/SOURCES.md`.
- Keep the unofficial, not-affiliated notice and the Disclaimer page intact.
- If the Android application id changes, move `MainActivity.kt` to the matching
  package path and update its `package` declaration.
  `test/android_config_test.dart` enforces this.

## Generated files

Regenerate, do not hand-edit:

```bash
python3 tool/fetch_ephemeris.py
dart run tool/gen_audio.dart
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

Golden tests are refreshed with
`flutter test --update-goldens test/golden_test.dart`.
