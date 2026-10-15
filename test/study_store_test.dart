import 'package:flutter_test/flutter_test.dart';
import 'package:anatomorph/core/storage/study_service.dart';
import 'package:anatomorph/core/storage/study_store.dart';
import 'support/harness.dart';

class FailingStore extends StudyStore {
  FailingStore(super.box);
  @override
  Future<void> put(String key, dynamic value) async =>
      throw StateError('disk full');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late TestHarness harness;
  setUp(() async => harness = await TestHarness.open());
  tearDown(() async => harness.close());

  test('queued bookmark toggles and views preserve every operation', () async {
    await Future.wait(
      List.generate(9, (_) => harness.study.toggleBookmark('heart')),
    );
    expect(harness.study.bookmarks, contains('heart'));
    expect(harness.store.strings('bookmarks'), ['heart']);
    await Future.wait(
      ['heart', 'brain', 'heart', 'liver'].map(harness.study.recordView),
    );
    expect(harness.study.recent, ['liver', 'heart', 'brain']);
  });

  test(
    'progress survives reconstruction and schedules correct and missed answers',
    () async {
      final now = DateTime.utc(2026, 10, 15, 10);
      await harness.study.recordAnswer('heart_1', true, now: now);
      expect(
        harness.study.progress['heart_1']['due'],
        now.add(const Duration(days: 1)).toIso8601String(),
      );
      await harness.study.recordAnswer('heart_1', true, now: now);
      expect(
        harness.study.progress['heart_1']['due'],
        now.add(const Duration(days: 3)).toIso8601String(),
      );
      await harness.study.recordAnswer('heart_1', false, now: now);
      final restored = StudyService(harness.store, harness.catalog)..onInit();
      expect(restored.attempted, 3);
      expect(restored.correct, 2);
      expect(restored.progress['heart_1']['streak'], 0);
      expect(
        restored.progress['heart_1']['due'],
        now.add(const Duration(minutes: 10)).toIso8601String(),
      );
    },
  );

  test(
    'failed writes do not claim a bookmark or answer was persisted',
    () async {
      final service = StudyService(
        FailingStore(harness.store.box),
        harness.catalog,
      )..onInit();
      await expectLater(service.toggleBookmark('heart'), throwsStateError);
      expect(service.bookmarks, isEmpty);
      await expectLater(
        service.recordAnswer('heart_1', true),
        throwsStateError,
      );
      expect(service.progress, isEmpty);
    },
  );

  test(
    'malformed stored progress is ignored without deleting user data',
    () async {
      await harness.store.put('progress', {
        'heart_1': {'attempts': 'broken'},
        'unknown': {'correct': 2},
      });
      final service = StudyService(harness.store, harness.catalog)..onInit();
      expect(service.attempted, 0);
      expect(harness.store.map('progress').keys, contains('heart_1'));
    },
  );
}
