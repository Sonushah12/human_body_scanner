import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/storage/study_service.dart';
import '../../../core/widgets/app_shell.dart';
import '../domain/anatomy_part.dart';
import '../domain/anatomy_repository.dart';
import 'explode_controller.dart';
import 'parts_controller.dart';
import 'widgets/body_stack.dart';
import 'widgets/part_card.dart';

class ExplorerView extends GetView<PartsController> {
  const ExplorerView({super.key});

  @override
  Widget build(BuildContext context) {
    final motion = Get.find<ExplodeController>();
    motion.systemReduceMotion = MediaQuery.disableAnimationsOf(context);
    final wide = MediaQuery.sizeOf(context).width >= 1200;
    return AppShell(
      selected: 0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    key: const PageStorageKey('explorer-scroll'),
                    child: Column(
                      children: [
                        PageHeader(
                          title: 'atlas'.tr,
                          subtitle: 'atlas_subtitle'.tr,
                          trailing: MediaQuery.sizeOf(context).width > 420
                              ? StatusPill(label: 'offline'.tr)
                              : null,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: TextField(
                            controller: controller.searchField,
                            onChanged: controller.search,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText: 'search'.tr,
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: Obx(
                                () => controller.query.isEmpty
                                    ? const SizedBox.shrink()
                                    : IconButton(
                                        tooltip: 'clear_filters'.tr,
                                        onPressed: controller.clear,
                                        icon: const Icon(Icons.close),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height:
                              40 + MediaQuery.textScalerOf(context).scale(18),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Obx(
                              () => Row(
                                children: [
                                  _chip(context, null),
                                  for (final system in BodySystem.values) ...[
                                    const SizedBox(width: 8),
                                    _chip(context, system),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (!wide) _recentStructures(context),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
                          child: Obx(
                            () => controller.visible.isEmpty
                                ? EmptyState(
                                    icon: Icons.search_off,
                                    title: 'no_results'.tr,
                                    description: 'try_search'.tr,
                                    action: OutlinedButton(
                                      onPressed: controller.clear,
                                      child: Text('clear_filters'.tr),
                                    ),
                                  )
                                : BodyStack(
                                    parts: controller.visible.toList(
                                      growable: false,
                                    ),
                                    motion: motion,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (MediaQuery.viewInsetsOf(context).bottom == 0)
                  _slider(context, motion),
              ],
            ),
          ),
          if (wide) const SizedBox(width: 310, child: StudyDesk()),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, BodySystem? system) {
    final active = controller.selectedSystem.value == system;
    return FilterChip(
      selected: active,
      label: Text(system?.id.tr ?? 'all_systems'.tr),
      avatar: system == null
          ? const Icon(Icons.apps_rounded, size: 16)
          : Icon(system.icon, size: 16, color: system.color),
      onSelected: (_) => controller.selectSystem(system),
    );
  }

  Widget _recentStructures(BuildContext context) {
    final study = Get.find<StudyService>();
    final catalog = Get.find<AnatomyRepository>();
    return Obx(() {
      if (study.recent.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'recent'.tr,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  for (final id in study.recent.take(6))
                    if (catalog.byId(id) case final part?)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          materialTapTargetSize: MaterialTapTargetSize.padded,
                          avatar: AnatomyIcon(
                            part: part,
                            size: 24,
                            hero: false,
                          ),
                          label: Text(
                            part.name(Get.locale?.languageCode ?? 'en'),
                          ),
                          onPressed: () =>
                              unawaited(Get.toNamed<void>(AppRoutes.part(id))),
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _slider(BuildContext context, ExplodeController motion) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Obx(
          () => Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.layers_outlined, size: 19),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'explode'.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    '${(motion.t.value * 100).round()}%',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
              Semantics(
                label: 'slider_hint'.tr,
                child: Slider(
                  key: const ValueKey('explode-slider'),
                  value: motion.t.value,
                  onChanged: motion.scrub,
                  onChangeEnd: (_) => motion.snap(),
                  semanticFormatterCallback: (v) =>
                      '${(v * 100).round()}% ${'assembled'.tr}',
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => motion.snap(0),
                      child: Text('separated'.tr, textAlign: TextAlign.center),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () => motion.snap(1),
                      child: Text('assembled'.tr, textAlign: TextAlign.center),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class StudyDesk extends StatelessWidget {
  const StudyDesk({super.key});
  @override
  Widget build(BuildContext context) {
    final study = Get.find<StudyService>();
    final catalog = Get.find<AnatomyRepository>();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 38, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'study_desk'.tr,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          Card(
            color: Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: .5),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.auto_awesome_outlined, size: 30),
                  const SizedBox(height: 30),
                  Text(
                    'daily_quiz'.tr,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'daily_description'.tr,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => unawaited(
                      Get.toNamed<void>('${AppRoutes.quiz}?mode=daily'),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(child: Text('start_quiz'.tr)),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 26),
          Text('recent'.tr, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          Obx(
            () => study.recent.isEmpty
                ? Text(
                    'nothing_recent'.tr,
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                : Column(
                    children: [
                      for (final id in study.recent.take(4))
                        if (catalog.byId(id) case final part?)
                          Card(
                            child: ListTile(
                              leading: AnatomyIcon(
                                part: part,
                                size: 38,
                                hero: false,
                              ),
                              title: Text(
                                part.name(Get.locale?.languageCode ?? 'en'),
                                style: const TextStyle(fontSize: 13),
                              ),
                              subtitle: Text(
                                part.latin,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.chevron_right,
                                size: 18,
                              ),
                              onTap: () => unawaited(
                                Get.toNamed<void>(AppRoutes.part(id)),
                              ),
                            ),
                          ),
                    ],
                  ),
          ),
          const SizedBox(height: 30),
          Text('education'.tr, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
