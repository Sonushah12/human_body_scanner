import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_shell.dart';
import '../../body_explorer/presentation/widgets/part_card.dart';
import 'quiz_controller.dart';

class QuizView extends GetView<QuizController> {
  const QuizView({super.key});
  @override
  Widget build(BuildContext context) => AppShell(
    selected: 2,
    child: Column(
      children: [
        PageHeader(title: 'quiz_intro'.tr, subtitle: 'quiz_intro_subtitle'.tr),
        Expanded(
          child: Obx(
            () =>
                controller.active.value ? _session(context) : _landing(context),
          ),
        ),
      ],
    ),
  );

  Widget _landing(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 780),
        child: Column(
          children: [
            Obx(
              () => Wrap(
                spacing: 18,
                runSpacing: 12,
                children: [
                  _stat(
                    context,
                    controller.study.attempted.toString(),
                    'attempted'.tr,
                  ),
                  _stat(
                    context,
                    controller.study.attempted == 0
                        ? '—'
                        : '${(controller.study.correct / controller.study.attempted * 100).round()}%',
                    'accuracy'.tr,
                  ),
                  _stat(
                    context,
                    controller.study.dueCount.toString(),
                    'due_review'.tr,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _modeCard(
              context,
              Icons.auto_awesome_outlined,
              'daily_quiz'.tr,
              'daily_description'.tr,
              'daily',
            ),
            _modeCard(
              context,
              Icons.menu_book_outlined,
              'all_questions'.tr,
              'all_questions_description'.tr,
              'all',
            ),
            _modeCard(
              context,
              Icons.schedule,
              'due_review'.tr,
              'due_description'.tr,
              'review',
            ),
            const SizedBox(height: 24),
            Text(
              'review_pending'.tr,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text('education'.tr, style: Theme.of(context).textTheme.bodySmall),
            if (Get.locale?.languageCode != 'en') ...[
              const SizedBox(height: 16),
              Text('english_content'.tr),
            ],
          ],
        ),
      ),
    ),
  );

  Widget _stat(BuildContext context, String value, String label) => SizedBox(
    width: 180,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
    ),
  );

  Widget _modeCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    String mode,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => controller.start(mode),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(description),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.arrow_forward, size: 20),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _session(BuildContext context) {
    if (controller.questions.isEmpty) {
      return EmptyState(
        icon: Icons.check_circle_outline,
        title: controller.invalidPart ? 'not_found'.tr : 'no_due'.tr,
        description: controller.invalidPart
            ? 'not_found_description'.tr
            : 'no_due_description'.tr,
        action: FilledButton(
          onPressed: () => controller.active.value = false,
          child: Text('practice_again'.tr),
        ),
      );
    }
    if (controller.complete.value) {
      return EmptyState(
        icon: Icons.school_outlined,
        title: 'quiz_complete'.tr,
        description:
            '${'score'.tr}: ${controller.score} / ${controller.questions.length}',
        action: Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            FilledButton(
              onPressed: controller.restart,
              child: Text('practice_again'.tr),
            ),
            OutlinedButton(
              onPressed: () =>
                  unawaited(Get.offAllNamed<void>(AppRoutes.explore)),
              child: Text('back_atlas'.tr),
            ),
          ],
        ),
      );
    }
    final item = controller.current!;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 750),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${'question'.tr} ${controller.index.value + 1} ${'of'.tr} ${controller.questions.length}',
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => controller.active.value = false,
                    child: Text('quiz'.tr),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value:
                    (controller.index.value + 1) / controller.questions.length,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  AnatomyIcon(part: item.part, size: 56, hero: false),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      item.part.name(Get.locale?.languageCode ?? 'en'),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                item.question.question,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              for (var i = 0; i < item.question.options.length; i++)
                _option(
                  context,
                  i,
                  item.question.options[i],
                  item.question.answer,
                ),
              const SizedBox(height: 18),
              if (controller.answered.value)
                Semantics(
                  liveRegion: true,
                  child: Card(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withValues(alpha: .4),
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                controller.isCorrect
                                    ? Icons.check_circle_outline
                                    : Icons.lightbulb_outline,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                controller.isCorrect
                                    ? 'correct'.tr
                                    : 'incorrect'.tr,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item.question.explanation,
                            style: const TextStyle(height: 1.6),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const ValueKey('quiz-submit'),
                  onPressed:
                      controller.saving.value ||
                          controller.selected.value == null
                      ? null
                      : controller.answered.value
                      ? controller.next
                      : controller.submit,
                  child: controller.saving.value
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          controller.answered.value
                              ? controller.index.value + 1 ==
                                        controller.questions.length
                                    ? 'finish_quiz'.tr
                                    : 'next'.tr
                              : 'check_answer'.tr,
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'education'.tr,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _option(BuildContext context, int index, String text, int answer) {
    final selected = controller.selected.value == index;
    final checked = controller.answered.value;
    final correct = checked && index == answer;
    final wrong = checked && selected && !correct;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        selected: selected,
        child: Card(
          color: correct
              ? scheme.primaryContainer
              : wrong
              ? scheme.errorContainer
              : selected
              ? scheme.secondaryContainer
              : null,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: checked || controller.saving.value
                ? null
                : () => controller.choose(index),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    correct
                        ? Icons.check_circle
                        : wrong
                        ? Icons.cancel_outlined
                        : selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(text, style: const TextStyle(height: 1.4)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
