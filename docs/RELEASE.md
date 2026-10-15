# Release requirements

The code is designed for production development. A public medical learning
release requires the checks below; no claim of medical approval or measured
device performance is made by the source code.

## Content and assets

- Have a qualified anatomy educator review all 20 entries, 40 questions, labeled
  views, body positions, blood-supply/innervation descriptions and clinical notes.
  Record reviewer identity, date, and content version. Update the app's review
  status only after that review is complete.
- Hindi/Gujarati interface and structure names are included. Detailed English
  explanations and questions need professional translation and review before
  claiming complete Hindi/Gujarati medical content. The UI explicitly explains
  the English fallback.
- Review the GLB simplification against source meshes. These models are surface
  references and are not suitable for procedural planning.
- Preserve asset licenses, share-alike rights, attribution screens, source ledger
  and all font notices. Source references do not imply endorsement.

## Device validation

- Test on a physical mid-range Android device and an iPhone, with airplane mode,
  large accessibility text, TalkBack/VoiceOver, light/dark themes and each locale.
- Exercise body states 0%, 50%, 100%, spring release, filter changes, fast
  scrubbing, rotation/zoom/reset, 3D fallback, background/resume and low storage.
- Run `flutter run --profile` and use DevTools frame timings for UI/raster work.
  The target is no sustained frames above 16.7 ms at 60 Hz / 8.3 ms at 120 Hz.
  Profile memory through repeated detail opens; only one viewer is mounted at a
  time and its loopback server is disposed when the viewer is removed.
- Measure actual OS cold-start time against the <2 s goal. App boot timing alone
  is not OS cold-start measurement. Measure each split release APK; target <60 MB.
- Compare `model_viewer_plus` and `flutter_3d_controller` camera behavior on the
  same device/model before claiming the required hardware spike is complete.
  The implemented viewer uses model_viewer_plus because it bundles a local JS
  runtime and provides load/error events and accessible orbit/zoom controls.

## Packaging

- Set a bundle/application identifier owned by the publisher. The initial
  identifier is `com.anatomorph.study`; ownership is not established by this repo.
- Configure release signing using platform secrets/local ignored configuration.
  Never commit keystores, passwords or provisioning profiles. No signed store
  artifact is produced without the publisher's signing credentials.
- Android cleartext is permitted only for `127.0.0.1` and `localhost`, used by
  model_viewer_plus for bundled assets. Other destinations require normal TLS.
  Validate the local viewer on Android 24+.
- iOS uses a local-network ATS exception for the bundled viewer. Validate the
  WebView/local server on a real iPhone and run the Xcode archive on macOS.
- Linux/macOS/Windows fall back to the bundled 2D gallery. Web uses the local
  model-viewer script. Deploy the web release including `sw.js`; offline use
  begins after the first successful precache on HTTPS or local development.
- Publish accurate privacy/data safety statements: there are no accounts,
  analytics, ads or application content servers. Hive stores study data locally.
  External reference links use the device browser and need internet.

Optional Firebase content updates, Crashlytics, pronunciation audio, custom Rive
and Lottie artwork, gyroscope parallax and a full anatomy catalog are not enabled.
Do not introduce a service or collect student data without updating privacy and
content validation policies.
