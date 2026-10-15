import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:anatomorph/main.dart' as app;
import 'package:anatomorph/core/routes/app_routes.dart';
import 'package:anatomorph/core/storage/study_service.dart';
import 'package:anatomorph/features/quiz/presentation/quiz_controller.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('offline detail, durable bookmark, quiz answer and navigation', (
    tester,
  ) async {
    await app.main();
    await tester.pumpAndSettle();
    unawaited(Get.toNamed<void>(AppRoutes.part('heart')));
    await tester.pumpAndSettle();
    expect(find.text('Heart'), findsWidgets);
    final study = Get.find<StudyService>();
    if (!study.bookmarks.contains('heart')) await study.toggleBookmark('heart');
    expect(study.store.strings('bookmarks'), contains('heart'));
    unawaited(Get.toNamed<void>('${AppRoutes.quiz}?part=heart'));
    await tester.pumpAndSettle();
    final quiz = Get.find<QuizController>();
    quiz.choose(quiz.current!.question.answer);
    final before = study.attempted;
    await quiz.submit();
    await tester.pumpAndSettle();
    expect(find.text('Correct'), findsOneWidget);
    expect(study.attempted, before + 1);
    expect(study.store.map('progress'), contains(quiz.current!.question.id));
    unawaited(Get.offAllNamed<void>(AppRoutes.bookmarks));
    await tester.pumpAndSettle();
    expect(find.text('Heart'), findsWidgets);
  });
}
