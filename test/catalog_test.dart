import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:anatomorph/features/body_explorer/data/local_anatomy_repository.dart';
import 'package:anatomorph/features/body_explorer/domain/anatomy_part.dart';
import 'package:anatomorph/core/localization/app_translations.dart';

class TextBundle extends CachingAssetBundle {
  TextBundle(this.raw);
  final String raw;
  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(Uint8List.fromList(utf8.encode(raw)));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late String raw;
  setUpAll(
    () async => raw = await File('assets/data/parts.json').readAsString(),
  );

  test(
    'offline catalog includes every system, cited entries, and working quizzes',
    () {
      final parts = LocalAnatomyRepository.parse(raw);
      expect(parts, hasLength(20));
      expect(parts.map((p) => p.system).toSet(), BodySystem.values.toSet());
      expect(parts.expand((p) => p.quiz), hasLength(40));
      for (final part in parts) {
        expect(part.names.keys, containsAll(['en', 'hi', 'gu']));
        expect(File(part.svg).existsSync(), isTrue);
        if (part.model3d case final path?) {
          expect(File(path).existsSync(), isTrue);
        }
        for (final question in part.quiz) {
          expect(question.options[question.answer], isNotEmpty);
          expect(question.explanation, isNotEmpty);
        }
      }
    },
  );

  test('unknown schema, duplicate ids and invalid answers are rejected', () {
    Map<String, dynamic> data() => jsonDecode(raw) as Map<String, dynamic>;
    final schema = data()..['schemaVersion'] = 99;
    expect(
      () => LocalAnatomyRepository.parse(jsonEncode(schema)),
      throwsFormatException,
    );
    final duplicate = data();
    duplicate['parts'][1]['id'] = duplicate['parts'][0]['id'];
    expect(
      () => LocalAnatomyRepository.parse(jsonEncode(duplicate)),
      throwsFormatException,
    );
    final quiz = data();
    quiz['parts'][0]['quiz'][0]['answer'] = 100;
    expect(
      () => LocalAnatomyRepository.parse(jsonEncode(quiz)),
      throwsFormatException,
    );
  });

  test('all interface translations have the same key set', () {
    final translations = AppTranslations().keys;
    expect(translations['hi']!.keys.toSet(), translations['en']!.keys.toSet());
    expect(translations['gu']!.keys.toSet(), translations['en']!.keys.toSet());
  });

  test(
    'a damaged cache falls back to the bundled catalog and is refreshed',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'anatomorph-cache-',
      );
      Hive.init(directory.path);
      final cache = await Hive.openBox<dynamic>('cache');
      await cache.put('catalog', {
        'digest': sha256.convert(utf8.encode(raw)).toString(),
        'raw': 'damaged',
      });
      final repository = LocalAnatomyRepository(cache, bundle: TextBundle(raw));
      await repository.load();
      expect(repository.byId('heart')?.names['en'], 'Heart');
      expect(cache.get('catalog')['raw'], raw);
      await cache.close();
      await directory.delete(recursive: true);
    },
  );
}
