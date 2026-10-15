import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce/hive.dart';

import '../domain/anatomy_part.dart';
import '../domain/anatomy_repository.dart';

class LocalAnatomyRepository implements AnatomyRepository {
  LocalAnatomyRepository(this._cache, {AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  final Box<dynamic> _cache;
  final AssetBundle _bundle;
  List<AnatomyPart> _parts = const [];
  Map<String, AnatomyPart> _index = const {};

  @override
  List<AnatomyPart> get parts => _parts;

  @override
  AnatomyPart? byId(String id) => _index[id];

  static List<AnatomyPart> parse(String raw) {
    final json = jsonDecode(raw) as Map<String, dynamic>;
    if (json['schemaVersion'] != 1) {
      throw const FormatException('Unsupported content schema');
    }
    final parts = (json['parts'] as List)
        .map(
          (part) =>
              AnatomyPart.fromJson(Map<String, dynamic>.from(part as Map)),
        )
        .toList(growable: false);
    final ids = <String>{};
    final questions = <String>{};
    for (final part in parts) {
      if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(part.id) ||
          !ids.add(part.id) ||
          part.names['en']?.isNotEmpty != true ||
          part.sources.isEmpty ||
          part.quiz.isEmpty) {
        throw const FormatException('Invalid or duplicate anatomy entry');
      }
      for (final question in part.quiz) {
        if (!questions.add(question.id)) {
          throw const FormatException('Duplicate question identifier');
        }
      }
      for (final source in part.sources) {
        if (Uri.tryParse(source.url)?.scheme != 'https') {
          throw const FormatException('Reference must use HTTPS');
        }
      }
    }
    if (parts.isEmpty) throw const FormatException('Empty anatomy catalog');
    return List.unmodifiable(parts);
  }

  @override
  Future<void> load() async {
    final raw = await _bundle.loadString('assets/data/parts.json');
    final digest = sha256.convert(utf8.encode(raw)).toString();
    // Only a cache matching the bundled digest is trusted. A corrupt/stale
    // cache never supersedes the versioned offline catalog.
    final cached = _cache.get('catalog');
    String? candidate;
    if (cached is Map &&
        cached['digest'] == digest &&
        cached['raw'] is String) {
      final stored = cached['raw'] as String;
      if (sha256.convert(utf8.encode(stored)).toString() == digest) {
        candidate = stored;
      }
    }
    _parts = parse(candidate ?? raw);
    _index = Map.unmodifiable({for (final part in _parts) part.id: part});
    if (candidate == null) {
      await _cache.put('catalog', {'digest': digest, 'raw': raw});
    }
  }
}
