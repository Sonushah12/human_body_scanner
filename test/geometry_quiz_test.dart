import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:anatomorph/features/body_explorer/data/local_anatomy_repository.dart';
import 'package:anatomorph/features/body_explorer/domain/anatomy_part.dart';
import 'package:anatomorph/features/body_explorer/domain/body_layout.dart';
import 'package:anatomorph/features/quiz/domain/quiz_session.dart';

void main() {
  late List<AnatomyPart> parts;
  setUpAll(
    () async => parts = LocalAnatomyRepository.parse(
      await File('assets/data/parts.json').readAsString(),
    ),
  );

  test(
    'every part has exact assembled and grid endpoints and finite intermediate poses',
    () {
      const body = Rect.fromLTWH(50, 0, 260, 560);
      for (final width in [320.0, 768.0, 1280.0]) {
        final layout = BodyLayout.forWidth(width);
        for (var i = 0; i < parts.length; i++) {
          final part = parts[i];
          final grid = layout.gridRect(width, i, 1);
          final assembled = BodyGeometry.pose(
            part: part,
            bodyRect: body,
            gridRect: grid,
            t: 1,
            index: i,
          );
          expect(
            assembled.center.dx,
            closeTo(body.left + body.width * part.bodyPosition.dx, 1e-6),
          );
          final separated = BodyGeometry.pose(
            part: part,
            bodyRect: body,
            gridRect: grid,
            t: 0,
            index: i,
          );
          expect(separated.center, grid.center);
          expect(separated.scale, 1);
          for (var step = 0; step <= 100; step++) {
            final pose = BodyGeometry.pose(
              part: part,
              bodyRect: body,
              gridRect: grid,
              t: step / 100,
              index: i,
            );
            expect(
              pose.center.dx.isFinite &&
                  pose.center.dy.isFinite &&
                  pose.scale.isFinite,
              true,
            );
          }
        }
      }
    },
  );

  test(
    'phone, tablet and desktop grids do not overlap at enlarged text sizes',
    () {
      for (final width in [320.0, 768.0, 1280.0]) {
        final layout = BodyLayout.forWidth(width);
        final rects = [
          for (var i = 0; i < parts.length; i++) layout.gridRect(width, i, 2),
        ];
        for (var i = 0; i < rects.length; i++) {
          expect(rects[i].right, lessThanOrEqualTo(width + 1e-6));
          for (var j = i + 1; j < rects.length; j++) {
            expect(rects[i].overlaps(rects[j]), false);
          }
        }
      }
    },
  );

  test(
    'daily practice is stable for a date and review includes only due questions',
    () {
      final day = DateTime(2026, 10, 15);
      final ids = QuizSession.daily(
        parts,
        day,
      ).map((q) => q.question.id).toList();
      expect(ids, hasLength(5));
      expect(
        QuizSession.daily(parts, day).map((q) => q.question.id).toList(),
        ids,
      );
      final due = QuizSession.due(parts, {
        'heart_1': {
          'due': day.subtract(const Duration(hours: 1)).toIso8601String(),
        },
        'brain_1': {'due': day.add(const Duration(days: 1)).toIso8601String()},
      }, day);
      expect(due.map((q) => q.question.id), ['heart_1']);
    },
  );
}
