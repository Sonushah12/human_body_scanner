# Validation results

Validated in the current cloud workspace with Flutter 3.44.4 / Dart 3.12.2.
This records current-instance evidence, not a published store release or a
successful restoration in a separate task.

| Check | Result |
|---|---|
| Dart formatting | Passed |
| Static analysis | No issues |
| Unit/widget suite | 18 tests passed, including Linux 2D fallback |
| Asset/catalog validation | 20 structures, 11 systems, 40 questions, 19 GLBs, 38 renders, 4 fonts |
| Model budget | Every GLB below 650 KB; at most 24k triangles |
| Content bundle | 10.66 MiB |
| Web release build | Passed; local renderer/viewer/font assets |
| Browser UI and real Hive persistence | Passed |
| Camera reset retaining the loaded viewer | Passed |
| Hindi interface and dark theme | Passed |
| Web offline reload and offline heart rendering | Passed |
| Browser page errors / external HTTP requests | 0 / 0 |
| Android release APK | Blocked by live network policy denying Flutter Maven artifacts at storage.googleapis.com |
| iOS archive, physical-device integration/profiling | Unrun; require macOS/Xcode and devices |
| Expert medical/translation review | Pending |

`BROWSER_VALIDATION.json` contains the functional browser check report. The
real-device `integration_test/study_flow_test.dart` is provided but has not been
executed as a native device integration test. The browser report is a separate
Playwright run against the actual release output using real IndexedDB/Hive.

The environment draft contains the required Flutter host addition, installation
commands, and restart/readiness instructions. Saving that draft does not apply
the live network policy or publish the environment. Review/save the changes and
publish through environment settings; retry native compilation once access is
active. Store signing and the requirements in `RELEASE.md` remain outstanding.
