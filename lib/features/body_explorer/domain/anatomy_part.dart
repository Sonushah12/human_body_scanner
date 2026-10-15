import 'package:flutter/material.dart';

enum BodySystem {
  skeletal('skeletal', Color(0xFF9A805F), Icons.accessibility_new),
  muscular('muscular', Color(0xFFCD664F), Icons.fitness_center),
  nervous('nervous', Color(0xFFB88B27), Icons.psychology_outlined),
  cardiovascular('cardiovascular', Color(0xFFC95564), Icons.favorite_outline),
  respiratory('respiratory', Color(0xFF478DA8), Icons.air),
  digestive('digestive', Color(0xFFB87B43), Icons.restaurant_outlined),
  urinary('urinary', Color(0xFF8868AE), Icons.water_drop_outlined),
  endocrine('endocrine', Color(0xFF9874A3), Icons.bubble_chart_outlined),
  lymphatic('lymphatic', Color(0xFF5C946D), Icons.spa_outlined),
  integumentary('integumentary', Color(0xFFAA7C6C), Icons.fingerprint),
  reproductive('reproductive', Color(0xFFAF6F94), Icons.people_outline);

  const BodySystem(this.id, this.color, this.icon);
  final String id;
  final Color color;
  final IconData icon;

  static BodySystem parse(String value) => values.firstWhere(
    (system) => system.id == value,
    orElse: () => throw FormatException('Unknown body system: $value'),
  );
}

@immutable
class ContentSource {
  const ContentSource({
    required this.title,
    required this.url,
    required this.section,
  });
  final String title;
  final String url;
  final String section;

  factory ContentSource.fromJson(Map<String, dynamic> json) => ContentSource(
    title: json['title'] as String,
    url: json['url'] as String,
    section: json['section'] as String,
  );
}

@immutable
class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.answer,
    required this.explanation,
  });
  final String id;
  final String question;
  final List<String> options;
  final int answer;
  final String explanation;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final options = List<String>.unmodifiable(json['options'] as List);
    final answer = json['answer'] as int;
    if (options.length < 2 || answer < 0 || answer >= options.length) {
      throw const FormatException('Invalid quiz answer index');
    }
    return QuizQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      options: options,
      answer: answer,
      explanation: json['explanation'] as String,
    );
  }
}

@immutable
class AnatomyPart {
  const AnatomyPart({
    required this.id,
    required this.names,
    required this.latin,
    required this.system,
    required this.bodyPosition,
    required this.bodyScale,
    required this.depthOrder,
    required this.svg,
    required this.model3d,
    required this.images,
    required this.overview,
    required this.function,
    required this.location,
    required this.bloodSupply,
    required this.innervation,
    required this.clinicalNotes,
    required this.quiz,
    required this.sources,
    required this.attribution,
    required this.modelNote,
  });

  final String id;
  final Map<String, String> names;
  final String latin;
  final BodySystem system;
  final Offset bodyPosition;
  final double bodyScale;
  final int depthOrder;
  final String svg;
  final String? model3d;
  final List<String> images;
  final String overview;
  final String function;
  final String location;
  final String bloodSupply;
  final String innervation;
  final List<String> clinicalNotes;
  final List<QuizQuestion> quiz;
  final List<ContentSource> sources;
  final String attribution;
  final String modelNote;

  String name(String languageCode) => names[languageCode] ?? names['en']!;

  factory AnatomyPart.fromJson(Map<String, dynamic> json) {
    final position = json['bodyPosition'] as Map<String, dynamic>;
    final x = (position['x'] as num).toDouble();
    final y = (position['y'] as num).toDouble();
    final scale = (position['scale'] as num).toDouble();
    if (!x.isFinite ||
        !y.isFinite ||
        x < 0 ||
        x > 1 ||
        y < 0 ||
        y > 1 ||
        !scale.isFinite ||
        scale <= 0) {
      throw const FormatException('Invalid anatomical coordinates');
    }
    return AnatomyPart(
      id: json['id'] as String,
      names: Map<String, String>.unmodifiable(json['name'] as Map),
      latin: json['latin'] as String,
      system: BodySystem.parse(json['system'] as String),
      bodyPosition: Offset(x, y),
      bodyScale: scale,
      depthOrder: json['depthOrder'] as int,
      svg: json['svg'] as String,
      model3d: json['model3d'] as String?,
      images: List<String>.unmodifiable(json['images'] as List),
      overview: json['overview'] as String,
      function: json['function'] as String,
      location: json['location'] as String,
      bloodSupply: json['bloodSupply'] as String,
      innervation: json['innervation'] as String,
      clinicalNotes: List<String>.unmodifiable(json['clinicalNotes'] as List),
      quiz: List<QuizQuestion>.unmodifiable(
        (json['quiz'] as List).map(
          (q) => QuizQuestion.fromJson(Map<String, dynamic>.from(q as Map)),
        ),
      ),
      sources: List<ContentSource>.unmodifiable(
        (json['sources'] as List).map(
          (s) => ContentSource.fromJson(Map<String, dynamic>.from(s as Map)),
        ),
      ),
      attribution: json['attribution'] as String,
      modelNote: json['modelNote'] as String,
    );
  }
}
