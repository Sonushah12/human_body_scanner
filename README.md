# AnatoMorph

A Flutter anatomy study app for students, implemented with **GetX state,
bindings, named routes, GetView screens and feature controllers**, and **Hive CE**
for local content caching, bookmarks, recent history, preferences and learning
progress. Hive CE is the maintained community edition of Hive.

## Included

- A scrubbable body-to-grid explorer with staggered quadratic paths, spring
  snapping, quarter-step haptics, Hero images and reduced-motion support.
- 20 introductory structures spanning all 11 system filters; local search also
  matches English, Hindi, Gujarati and Latin names.
- Overview, 3D, Images, Clinical and Practice tabs, with source links and credits.
- 19 bundled BodyParts3D GLBs, each below 650 KB / 24k triangles, and 38 derived
  WebP renders. Skin uses a labeled original schematic. Content assets total
  about 10.7 MiB; native APK size still needs a successful native release build.
- Lazy, local 3D viewing on Android/iOS/web, orbit/zoom, smooth camera reset,
  load/error reporting and a 2D fallback. Linux/macOS/Windows use the 2D gallery.
- Bookmarks and recent items on phone and desktop, daily five-question practice,
  a 40-question bank, explanations, local scores and scheduled review intervals.
- Material 3 light/dark/system themes, 2/4/6-column responsive layouts, large-text
  handling, semantic controls and at least 48 dp button targets.
- English/Hindi/Gujarati **interface and structure names** with bundled fonts.
  Detailed study explanations and questions are English; the UI states this
  fallback. Full medical translations need professional review.
- A self-hosted viewer script and versioned web offline cache. Native core
  content needs no network; web offline use starts after its first precache.

**Medical review is pending.** Summaries and questions are original educational
material with references, not a medically approved textbook. The body is
schematic and the model dataset represents one adult male reference.
See [release requirements](docs/RELEASE.md) before publishing to students.

## Run

Tested toolchain: **Flutter 3.44.4 / Dart 3.12.2**, OpenJDK 21, Android SDK 36,
Build Tools 36 and NDK 28.2.13676358. The native package identifier is initially
`com.anatomorph.study`; choose a publisher-owned identifier before store release.

```sh
flutter pub get --enforce-lockfile
flutter run
```

Select a connected Android/iOS device or a supported desktop target. macOS and
Xcode are required to compile/sign iOS. For web development use
`flutter run -d chrome`. No account, server, API key or Firebase project is needed.

In the prepared managed cloud workspace:

```sh
cd /workspace/human_body_scanner
source tools/cloud_env.sh
python3 tools/configure_gradle_proxy.py
flutter pub get --enforce-lockfile
```

The activation script places writable Flutter/Dart/Gradle state in `/workspace`,
suppresses tool telemetry, and selects the retained SDK/JDK. It keeps normal TLS
and artifact verification. Flutter was extracted from the published
`mobiledevops/flutter-sdk-image:3.44.4` SDK layers after verifying their OCI
SHA-256 digests, and its framework SHA was checked against Flutter's official
`3.44.4` tag. Android/JDK layers were similarly verified. Live processes do not
survive snapshots; startup instructions must run again in a new cloud task.

## Validate and build

```sh
python3 tools/validate_assets.py
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test
flutter build web --release --no-web-resources-cdn
python3 tools/finalize_web.py
flutter build apk --release --split-per-abi
```

For Dart commands in a managed cloud, use `dart --suppress-analytics ...` or the
activated `CI=true` setting. The standard analyzer state location is redirected
by the cloud activation script because the home filesystem is read-only.

`flutter test` executes 18 tests covering catalog validation, corrupt caches,
real Hive persistence/failures, queued writes, scheduling, animation geometry,
responsive rendering, search, invalid routes and reduced motion. Widget tests
use an in-memory store to avoid mixing native file I/O with widget fake time;
storage tests use actual Hive files. `integration_test/study_flow_test.dart` is
provided for real device/browser runners and must be reported separately when
run. Asset validation verifies hashes, licenses, GLB buffers and model budgets;
it does not certify anatomical accuracy.

The Android release configuration uses a publisher's ignored `android/key.properties`
if provided. It does not sign a release with a debug key. Store signing credentials,
physical-device profiling, iPhone validation and expert review remain release
requirements. The cloud Android build currently needs live access to
`storage.googleapis.com` for Flutter's Maven artifacts; this host is saved in
the environment draft and requires the environment's network settings to apply.

Web output is in `build/web`. Run the cache finalizer after every release build,
and deploy the entire output over HTTPS. The cache is content-addressed and
updates when the release changes. Source links open externally and need internet.

## Architecture

```text
lib/
  core/             bindings, routes, theme, translations, shared widgets, Hive
  features/
    body_explorer/  immutable domain models, repository, GetX controllers, layouts
    part_detail/    GetView detail screen, lazy viewer, lifecycle bridge, gallery
    bookmarks/      collection controller and view
    quiz/           session selection, controller, results and explanations
    settings/       preferences, privacy, source/asset attribution
assets/
  data/             versioned catalog and provenance manifests
  svg/              original schematics
  models/           licensed GLBs
  img/              licensed derived renders
  fonts/ licenses/  offline typefaces and notices
```

One assembly value drives positions/scales/rotations. Cards and SVG trees are
cached outside the frame builder; heavy rendering sits behind repaint boundaries.
Filtering is debounced and independent of frame updates. The repository validates
the bundled catalog and only accepts a Hive cache matching its SHA-256.
Read-modify-write operations are serialized; a failed save preserves previous
data. Startup failure offers recovery without deleting a student's boxes.

## Assets and content

Read [complete attributions](docs/ATTRIBUTIONS.md) and the in-app credit screen.
BodyParts3D 3.0 geometry/renders retain **CC BY-SA 2.1 Japan**; fonts retain
**SIL OFL 1.1**; original code, summaries, questions and schematics are **MIT**.
OpenStax is cited for study; its current noncommercial textbook license is not
used to redistribute figures or text. No noncommercial Z-Anatomy/Sketchfab assets
are bundled.

To intentionally rebuild assets outside normal dependency installation:

```sh
python3 -m pip install -r tools/asset_requirements.txt
python3 tools/import_bodyparts.py
python3 tools/seed_catalog.py
python3 tools/validate_assets.py
```

The import uses a pinned upstream commit and records each input/output digest,
mesh count, adaptation and license. Normal setup uses the committed assets and
does not regenerate them or alter source, manifests, tests or lockfiles.

Optional Firebase updates/analytics, pronunciation audio, gyroscope parallax,
custom Rive/Lottie animation assets and a complete anatomy corpus are not enabled.
