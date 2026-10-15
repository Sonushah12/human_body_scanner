import 'package:get/get.dart';

import '../../features/body_explorer/domain/anatomy_repository.dart';
import 'study_store.dart';

class StudyService extends GetxService {
  StudyService(this.store, this.catalog);
  final StudyStore store;
  final AnatomyRepository catalog;
  final bookmarks = <String>{}.obs;
  final recent = <String>[].obs;
  final progress = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    bookmarks.addAll(
      store.strings('bookmarks').where((id) => catalog.byId(id) != null),
    );
    recent.assignAll(
      store.strings('recent').where((id) => catalog.byId(id) != null).take(12),
    );
    final questionIds = catalog.parts
        .expand((part) => part.quiz)
        .map((q) => q.id)
        .toSet();
    final stored = store.map('progress');
    progress.assignAll({
      for (final entry in stored.entries)
        if (questionIds.contains(entry.key) && _validRecord(entry.value))
          entry.key: entry.value,
    });
  }

  static bool _validRecord(dynamic value) {
    if (value is! Map) return false;
    final attempts = value['attempts'];
    final correct = value['correct'];
    final streak = value['streak'];
    return attempts is int &&
        attempts >= 0 &&
        correct is int &&
        correct >= 0 &&
        correct <= attempts &&
        streak is int &&
        streak >= 0 &&
        DateTime.tryParse(value['due']?.toString() ?? '') != null;
  }

  int get attempted => progress.values.whereType<Map>().fold(
    0,
    (total, record) => total + ((record['attempts'] as num?)?.toInt() ?? 0),
  );

  int get correct => progress.values.whereType<Map>().fold(
    0,
    (total, record) => total + ((record['correct'] as num?)?.toInt() ?? 0),
  );

  int get dueCount => progress.values.whereType<Map>().where((record) {
    final due = DateTime.tryParse(record['due']?.toString() ?? '');
    return due != null && !due.isAfter(DateTime.now());
  }).length;

  Future<void> toggleBookmark(String id) => store.transaction(() async {
    final next = Set<String>.of(bookmarks);
    next.contains(id) ? next.remove(id) : next.add(id);
    await store.put('bookmarks', next.toList());
    bookmarks.assignAll(next);
  });

  Future<void> recordView(String id) => store.transaction(() async {
    final next = [id, ...recent.where((item) => item != id)].take(12).toList();
    await store.put('recent', next);
    recent.assignAll(next);
  });

  Future<void> recordAnswer(
    String questionId,
    bool isCorrect, {
    DateTime? now,
  }) => store.transaction(() async {
    final time = now ?? DateTime.now();
    final previous = progress[questionId];
    final old = previous is Map ? previous : <String, dynamic>{};
    final streak = isCorrect ? ((old['streak'] as num?)?.toInt() ?? 0) + 1 : 0;
    final days = isCorrect ? [1, 3, 7, 14, 30][(streak - 1).clamp(0, 4)] : 0;
    final next = Map<String, dynamic>.of(progress);
    next[questionId] = {
      'attempts': ((old['attempts'] as num?)?.toInt() ?? 0) + 1,
      'correct': ((old['correct'] as num?)?.toInt() ?? 0) + (isCorrect ? 1 : 0),
      'streak': streak,
      'lastAttempt': time.toUtc().toIso8601String(),
      'due': time
          .add(days == 0 ? const Duration(minutes: 10) : Duration(days: days))
          .toUtc()
          .toIso8601String(),
    };
    await store.put('progress', next);
    progress.assignAll(next);
  });
}
