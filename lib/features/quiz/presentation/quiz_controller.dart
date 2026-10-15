import 'package:get/get.dart';
import '../../../core/storage/study_service.dart';
import '../../body_explorer/domain/anatomy_repository.dart';
import '../../settings/presentation/settings_controller.dart';
import '../domain/quiz_session.dart';

class QuizController extends GetxController {
  QuizController(this.catalog, this.study);
  final AnatomyRepository catalog;
  final StudyService study;
  final index = 0.obs;
  final selected = RxnInt();
  final answered = false.obs;
  final saving = false.obs;
  final complete = false.obs;
  final active = false.obs;
  final score = 0.obs;
  final questions = <StudyQuestion>[].obs;
  final mode = 'daily'.obs;
  bool invalidPart = false;

  StudyQuestion? get current =>
      questions.isEmpty ? null : questions[index.value];
  bool get isCorrect =>
      current != null && selected.value == current!.question.answer;

  @override
  void onInit() {
    super.onInit();
    final part = Get.parameters['part'];
    final requestedMode = Get.parameters['mode'];
    if (part != null) {
      invalidPart = catalog.byId(part) == null;
      start('part', partId: part);
    } else if (requestedMode != null) {
      start(requestedMode);
    }
  }

  void start(String selection, {String? partId}) {
    final now = DateTime.now();
    mode.value = ['daily', 'all', 'review', 'part'].contains(selection)
        ? selection
        : 'daily';
    final list = switch (mode.value) {
      'all' => QuizSession.all(catalog.parts),
      'review' => QuizSession.due(catalog.parts, study.progress, now),
      'part' => QuizSession.all(
        catalog.parts.where((part) => part.id == partId).toList(),
      ),
      _ => QuizSession.daily(catalog.parts, now),
    };
    questions.assignAll(list);
    index.value = 0;
    selected.value = null;
    answered.value = false;
    saving.value = false;
    complete.value = false;
    score.value = 0;
    active.value = true;
  }

  void choose(int value) {
    if (!answered.value && !saving.value) selected.value = value;
  }

  Future<void> submit() async {
    final item = current;
    if (item == null ||
        selected.value == null ||
        answered.value ||
        saving.value) {
      return;
    }
    saving.value = true;
    try {
      final correct = selected.value == item.question.answer;
      await study.recordAnswer(item.question.id, correct);
      if (isClosed) return;
      if (correct) score.value++;
      answered.value = true;
    } catch (_) {
      SettingsController.saveError();
    } finally {
      if (!isClosed) saving.value = false;
    }
  }

  void next() {
    if (!answered.value || saving.value) return;
    if (index.value + 1 == questions.length) {
      complete.value = true;
      return;
    }
    index.value++;
    selected.value = null;
    answered.value = false;
  }

  void restart() {
    index.value = 0;
    selected.value = null;
    answered.value = false;
    complete.value = false;
    score.value = 0;
  }
}
