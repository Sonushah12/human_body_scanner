import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_shell.dart';
import '../../body_explorer/domain/anatomy_part.dart';
import '../../body_explorer/presentation/widgets/part_card.dart';
import '../../settings/presentation/settings_controller.dart';
import 'detail_controller.dart';
import 'widgets/gallery.dart';
import 'widgets/viewer_3d.dart';

class DetailView extends GetView<DetailController> {
  const DetailView({super.key});
  @override
  Widget build(BuildContext context) {
    final part = controller.part;
    if (part == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(
          icon: Icons.help_outline,
          title: 'not_found'.tr,
          description: 'not_found_description'.tr,
          action: FilledButton(
            onPressed: () =>
                unawaited(Get.offAllNamed<void>(AppRoutes.explore)),
            child: Text('back_atlas'.tr),
          ),
        ),
      );
    }
    final reduced =
        MediaQuery.disableAnimationsOf(context) ||
        Get.find<SettingsController>().reduceMotion.value;
    return Scaffold(
      appBar: AppBar(
        title: Text(part.name(Get.locale?.languageCode ?? 'en')),
        actions: [
          Obx(
            () => IconButton(
              tooltip: controller.bookmarked ? 'unsave'.tr : 'save'.tr,
              icon: Icon(
                controller.bookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border,
              ),
              onPressed: controller.toggleBookmark,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1360),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 950;
                final content = Column(
                  children: [
                    if (!wide) _heading(context, part),
                    _tabs(context),
                    Expanded(
                      child: Obx(
                        () => SingleChildScrollView(
                          key: ValueKey(controller.tab.value),
                          padding: const EdgeInsets.all(24),
                          child: _content(context, part, reduced),
                        ),
                      ),
                    ),
                  ],
                );
                if (!wide) return content;
                return Row(
                  children: [
                    SizedBox(
                      width: constraints.maxWidth * .34,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 24, 12, 24),
                        child: Column(
                          children: [
                            _heading(context, part),
                            const SizedBox(height: 20),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: part.images.isEmpty
                                    ? AnatomyIcon(
                                        part: part,
                                        size: 250,
                                        hero: false,
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.asset(
                                          part.images.first,
                                          cacheWidth: 512,
                                          semanticLabel: part.names['en'],
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              part.modelNote,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const VerticalDivider(width: 32),
                    Expanded(child: content),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, AnatomyPart part, bool reduced) {
    final child = _tab(context, part);
    return reduced
        ? child
        : child.animate().fadeIn(duration: 240.ms).slideY(begin: .025, end: 0);
  }

  Widget _heading(BuildContext context, AnatomyPart part) => Padding(
    padding: const EdgeInsets.all(20),
    child: Row(
      children: [
        AnatomyIcon(part: part, size: 78),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                part.name(Get.locale?.languageCode ?? 'en'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                part.latin,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 10),
              StatusPill(label: part.system.id.tr, icon: part.system.icon),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _tabs(BuildContext context) => Obx(
    () => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          for (var i = 0; i < 5; i++)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(
                  ['overview', 'model', 'images', 'clinical', 'quiz'][i].tr,
                ),
                selected: controller.tab.value == i,
                onSelected: (_) => controller.tab.value = i,
              ),
            ),
        ],
      ),
    ),
  );

  Widget _tab(
    BuildContext context,
    AnatomyPart part,
  ) => switch (controller.tab.value) {
    1 => Viewer3d(part: part),
    2 => AnatomyGallery(part: part),
    3 => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StatusPill(label: 'review_pending'.tr, icon: Icons.info_outline),
        const SizedBox(height: 20),
        for (var i = 0; i < part.clinicalNotes.length; i++)
          _block(context, '${'clinical'.tr} ${i + 1}', part.clinicalNotes[i]),
        _references(context, part),
      ],
    ),
    4 => EmptyState(
      icon: Icons.school_outlined,
      title: 'quiz_intro'.tr,
      description: 'quiz_intro_subtitle'.tr,
      action: FilledButton.icon(
        onPressed: () =>
            unawaited(Get.toNamed<void>('${AppRoutes.quiz}?part=${part.id}')),
        icon: const Icon(Icons.arrow_forward),
        label: Text('start_quiz'.tr),
      ),
    ),
    _ => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StatusPill(label: 'review_pending'.tr, icon: Icons.info_outline),
        const SizedBox(height: 18),
        if (Get.locale?.languageCode != 'en') ...[
          Text(
            'english_content'.tr,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 18),
        ],
        Text(
          part.overview,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.7),
        ),
        const SizedBox(height: 24),
        _block(context, 'function'.tr, part.function),
        _block(context, 'location'.tr, part.location),
        _block(context, 'blood_supply'.tr, part.bloodSupply),
        _block(context, 'innervation'.tr, part.innervation),
        _references(context, part),
      ],
    ),
  };

  Widget _block(BuildContext context, String title, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.65),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _references(BuildContext context, AnatomyPart part) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 12),
      Text('sources'.tr, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 10),
      Text('source_note'.tr, style: Theme.of(context).textTheme.bodySmall),
      for (final source in part.sources)
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(source.title, style: const TextStyle(fontSize: 13)),
          subtitle: Text(source.section),
          trailing: const Icon(Icons.open_in_new, size: 18),
          onTap: () => unawaited(openReference(source.url)),
        ),
      Text(part.attribution, style: Theme.of(context).textTheme.bodySmall),
      TextButton(
        onPressed: () => unawaited(Get.toNamed<void>(AppRoutes.credits)),
        child: Text('attribution'.tr),
      ),
      const SizedBox(height: 10),
      Text('education'.tr, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}
