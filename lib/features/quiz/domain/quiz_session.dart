import 'dart:math';
import '../../body_explorer/domain/anatomy_part.dart';

class StudyQuestion {
  const StudyQuestion(this.part, this.question);
  final AnatomyPart part;
  final QuizQuestion question;
}

abstract final class QuizSession {
  static List<StudyQuestion> all(List<AnatomyPart> parts) => [
    for (final part in parts)
      for (final question in part.quiz) StudyQuestion(part, question),
  ];

  static List<StudyQuestion> daily(List<AnatomyPart> parts, DateTime date) {
    final questions = all(parts)
      ..sort((a, b) => a.question.id.compareTo(b.question.id));
    questions.shuffle(Random(date.year * 372 + date.month * 31 + date.day));
    return questions.take(5).toList(growable: false);
  }

  static List<StudyQuestion> due(
    List<AnatomyPart> parts,
    Map<String, dynamic> progress,
    DateTime now,
  ) {
    final questions = all(parts).where((item) {
      final record = progress[item.question.id];
      if (record is! Map) return false;
      final due = DateTime.tryParse(record['due']?.toString() ?? '');
      return due != null && !due.isAfter(now);
    }).toList();
    questions.sort(
      (a, b) => (progress[a.question.id]['due'] as String).compareTo(
        progress[b.question.id]['due'] as String,
      ),
    );
    return questions;
  }
}
