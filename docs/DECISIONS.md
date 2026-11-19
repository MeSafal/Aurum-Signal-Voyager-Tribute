# Decisions

Decisions made while implementing the brief without blocking on the owner.

| Topic | Decision |
|---|---|
| Audio package | `audioplayers` 6.8.1 with `BytesSource`. Chosen over `flutter_soloud` for reliable Android/iOS/web behaviour with no extra native setup. The abstraction `AudioPlayback` keeps the intro widgets testable. |
| Visual clock | Anchored to the first `PlayerState.playing` event, not the tap time. A `Ticker` reads elapsed milliseconds, adds the stored latency offset, and drives glyphs, captions and haptics. No per-feature timers or delayed chains. |
| Morse length | `VOYAGER` is naturally 73u = 14.6 s with standard Morse. Y is `-.--` (dash dot dash dash), which is 13u including internal gaps. No artificial padding was added. `VGR` is 31u = 6.2 s. |
| Ephemeris | Daily geocentric vector table from JPL Horizons, linearly interpolated. At the milestone the estimate is 25,902,062,396 km vs NASA's 25,902,068,356 km — 0.00002% error, inside the 0.05% requirement. NASA's milestone figure is still shown in the intro regardless. Horizons timestamps are TDB; at daily sampling the offset is immaterial. |
| Planet diameters | Brief values are shown. NSSDCA mean-radius derivations differ by 2–4 km for Jupiter/Saturn; recorded in `SOURCES.md`. |
| Speed figure | The app avoids the unverified 16.9 km/s. It uses the verified 24 h light-time and NASA's ~17.0 km/s / ~61,000 kph where a speed is needed. |
| 3D model | The owner supplied `Voyager3D.glb` and later the NASA resource page. It is bundled and credited, although the optional v1 scope does not include a 3D viewer. |
| Repository URL | Taken from the `origin` remote and set in `VoyagerFacts.repositoryUrl` to `https://github.com/MeSafal/Aurum-Signal-Voyager-Tribute`. No push was attempted. |
| Package id | Set to the supplied placeholder `com.example.aurum_signal` on Android and iOS. `MainActivity.kt` was moved to the matching package after a launch crash; `test/android_config_test.dart` now guards namespace, applicationId, manifest activity and Kotlin package consistency. |
| Screenshots/GIFs | The gate screenshot was captured from the real web build with headless Chromium. A physical-device run is still needed for full Android/iOS captures and an intro GIF. |
| Web/APK deployment | CI is configured for GitHub Pages and produces an APK artifact. No push credentials were available, so nothing was pushed to a remote. |
| Notifications/permissions | None requested. No camera, torch, location or notification permission is used. |
