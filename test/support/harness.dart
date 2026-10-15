import 'dart:io';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:anatomorph/core/storage/study_service.dart';
import 'package:anatomorph/core/storage/study_store.dart';
import 'package:anatomorph/features/body_explorer/data/local_anatomy_repository.dart';
import 'package:anatomorph/features/body_explorer/domain/anatomy_part.dart';
import 'package:anatomorph/features/body_explorer/domain/anatomy_repository.dart';
import 'package:anatomorph/features/settings/presentation/settings_controller.dart';

class FixtureCatalog implements AnatomyRepository {
  FixtureCatalog(this.parts);
  @override
  final List<AnatomyPart> parts;
  @override
  AnatomyPart? byId(String id) =>
      parts.where((part) => part.id == id).firstOrNull;
  @override
  Future<void> load() async {}
}

class TestHarness {
  TestHarness(this.directory, this.store, this.catalog, this.study);
  final Directory directory;
  final StudyStore store;
  final FixtureCatalog catalog;
  final StudyService study;

  static Future<TestHarness> open({bool memoryWrites = false}) async {
    Get.testMode = true;
    final directory = await Directory.systemTemp.createTemp(
      'anatomorph-tests-',
    );
    Hive.init(directory.path);
    final box = await Hive.openBox<dynamic>('study');
    final catalog = FixtureCatalog(
      LocalAnatomyRepository.parse(
        await File('assets/data/parts.json').readAsString(),
      ),
    );
    final store = memoryWrites ? MemoryStudyStore(box) : StudyStore(box);
    Get.put<AnatomyRepository>(catalog, permanent: true);
    Get.put(store, permanent: true);
    final study = Get.put(StudyService(store, catalog), permanent: true);
    Get.put(SettingsController(store), permanent: true);
    return TestHarness(directory, store, catalog, study);
  }

  Future<void> close() async {
    Get.reset();
    await Hive.close();
    await directory.delete(recursive: true);
  }
}

/// Widget fake time must not wait for native file I/O. Persistence is exercised
/// separately against real Hive boxes in study_store_test and the browser flow.
class MemoryStudyStore extends StudyStore {
  MemoryStudyStore(super.box);
  final _values = <String, dynamic>{};
  @override
  Future<void> put(String key, dynamic value) async {
    _values[key] = value;
  }

  @override
  List<String> strings(String key) =>
      (_values[key] as List?)?.whereType<String>().toList() ?? [];
  @override
  String string(String key, String fallback) =>
      _values[key] as String? ?? fallback;
  @override
  Map<String, dynamic> map(String key) =>
      Map<String, dynamic>.from(_values[key] as Map? ?? {});
}
