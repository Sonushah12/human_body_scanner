import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../body_explorer/domain/anatomy_part.dart';
import '../../../body_explorer/presentation/widgets/part_card.dart';

class AnatomyGallery extends StatelessWidget {
  const AnatomyGallery({required this.part, super.key});
  final AnatomyPart part;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (var index = 0; index < part.images.length; index++)
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    index == 0 ? 'front_view'.tr : 'back_view'.tr,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: InteractiveViewer(
                      minScale: 1,
                      maxScale: 4,
                      child: Image.asset(
                        part.images[index],
                        cacheWidth: 512,
                        fit: BoxFit.contain,
                        semanticLabel:
                            '${part.name(Get.locale?.languageCode ?? 'en')} — ${index == 0 ? 'front_view'.tr : 'back_view'.tr}',
                        errorBuilder: (context, error, stack) =>
                            AnatomyIcon(part: part, size: 200, hero: false),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'render_note'.tr,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      if (part.images.isEmpty)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                AnatomyIcon(part: part, size: 220, hero: false),
                const SizedBox(height: 16),
                Text(
                  'schematic'.tr,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      const SizedBox(height: 12),
      Text(part.attribution, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}
