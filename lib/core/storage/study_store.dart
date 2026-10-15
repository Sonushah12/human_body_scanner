import 'package:hive_ce/hive.dart';

class StudyStore {
  StudyStore(this.box);
  final Box<dynamic> box;
  Future<void> _tail = Future.value();

  List<String> strings(String key) {
    final value = box.get(key);
    return value is List ? value.whereType<String>().toList() : [];
  }

  String string(String key, String fallback) {
    final value = box.get(key);
    return value is String ? value : fallback;
  }

  Map<String, dynamic> map(String key) {
    final value = box.get(key);
    return value is Map
        ? {
            for (final entry in value.entries)
              if (entry.key is String) entry.key as String: entry.value,
          }
        : {};
  }

  /// Serialize read-modify-write transactions so fast repeated taps cannot
  /// lose a bookmark, recent item or quiz attempt. Return the real write error.
  Future<T> transaction<T>(Future<T> Function() operation) {
    final next = _tail.then((_) => operation());
    _tail = next.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return next;
  }

  Future<void> put(String key, dynamic value) => box.put(key, value);
}
