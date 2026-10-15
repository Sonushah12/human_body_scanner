import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/storage/study_store.dart';
import 'core/storage/study_service.dart';
import 'features/body_explorer/data/local_anatomy_repository.dart';
import 'features/body_explorer/domain/anatomy_repository.dart';
import 'features/settings/presentation/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _registerLicenses();
  try {
    await bootstrap();
    runApp(const AnatoMorphApp());
  } catch (error, stack) {
    // Never delete a user's boxes or substitute ephemeral storage on failure.
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'AnatoMorph startup',
      ),
    );
    runApp(const StartupRecovery());
  }
}

Future<void> bootstrap() async {
  await Hive.initFlutter();
  final prefs = await Hive.openBox<dynamic>('anatomorph_study_v1');
  final cache = await Hive.openBox<dynamic>('anatomorph_content_v1');
  final catalog = LocalAnatomyRepository(cache);
  await catalog.load();
  final store = StudyStore(prefs);
  Get.put<AnatomyRepository>(catalog, permanent: true);
  Get.put(store, permanent: true);
  Get.put(StudyService(store, catalog), permanent: true);
  Get.put(SettingsController(store), permanent: true);
}

void _registerLicenses() {
  for (final entry in {
    'BodyParts3D geometry and renders': 'BodyParts3D.txt',
    'Inter': 'Inter-OFL.txt',
    'Roboto': 'Roboto-OFL.txt',
    'Noto Sans Devanagari': 'NotoSansDevanagari-OFL.txt',
    'Noto Sans Gujarati': 'NotoSansGujarati-OFL.txt',
    'Original schematic artwork': 'Original-artwork.txt',
    'Google model-viewer': 'model-viewer.txt',
  }.entries) {
    LicenseRegistry.addLicense(() async* {
      final text = await rootBundle.loadString(
        'assets/licenses/${entry.value}',
      );
      yield LicenseEntryWithLineBreaks([entry.key], text);
    });
  }
}

class StartupRecovery extends StatefulWidget {
  const StartupRecovery({super.key});
  @override
  State<StartupRecovery> createState() => _StartupRecoveryState();
}

class _StartupRecoveryState extends State<StartupRecovery> {
  bool _retrying = false;
  Future<void> _retry() async {
    setState(() => _retrying = true);
    try {
      await bootstrap();
      runApp(const AnatoMorphApp());
    } catch (_) {
      if (mounted) setState(() => _retrying = false);
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.storage_outlined, size: 52),
                const SizedBox(height: 20),
                const Text(
                  'Your atlas could not be opened',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your existing study data has been preserved. Check free device storage, then try again.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _retrying ? null : _retry,
                  child: Text(_retrying ? 'Opening…' : 'Try again'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
