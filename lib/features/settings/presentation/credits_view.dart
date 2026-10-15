import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_shell.dart';
import '../../body_explorer/domain/anatomy_repository.dart';
import 'credits_controller.dart';

class CreditsView extends GetView<CreditsController> {
  const CreditsView({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('attribution'.tr)),
    body: SafeArea(
      child: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.failed.value) {
          return EmptyState(
            icon: Icons.error_outline,
            title: 'attribution'.tr,
            description: 'storage_error'.tr,
            action: FilledButton(
              onPressed: controller.load,
              child: Text('retry'.tr),
            ),
          );
        }
        final catalog = Get.find<AnatomyRepository>();
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 850),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'credits_title'.tr,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'credits_subtitle'.tr,
                    style: const TextStyle(height: 1.6),
                  ),
                  const SizedBox(height: 28),
                  _credit(
                    context,
                    'BodyParts3D 3.0 · CC BY-SA 2.1 Japan',
                    'BodyParts3D, (c) The Database Center for Life Science licensed under CC Attribution-Share Alike 2.1 Japan.\n\nSTL conversion: Kevin Mattheus Moerman. AnatoMorph adaptations: assembly of constituent meshes, triangle reduction, uniform centering/scaling, coordinate rotation, illustrative colors, GLB export and orthographic WebP renders. These derivative assets retain CC BY-SA 2.1 Japan. The adult male reference does not represent every person or every variation.',
                    'https://github.com/Kevin-Mattheus-Moerman/BodyParts3D',
                  ),
                  TextButton(
                    onPressed: () => unawaited(
                      openReference(
                        'https://creativecommons.org/licenses/by-sa/2.1/jp/',
                      ),
                    ),
                    child: const Text('CC BY-SA 2.1 Japan'),
                  ),
                  ExpansionTile(
                    title: Text(
                      '${controller.assets.length} models · ${controller.assets.length * 2} images',
                    ),
                    children: [
                      for (final entry in controller.assets)
                        ListTile(
                          title: Text(
                            catalog
                                    .byId(entry['part'] as String)
                                    ?.name(Get.locale?.languageCode ?? 'en') ??
                                entry['part'] as String,
                          ),
                          subtitle: const Text(
                            'BodyParts3D 3.0 · CC BY-SA 2.1 Japan',
                          ),
                          trailing: const Icon(Icons.open_in_new, size: 18),
                          onTap: () => unawaited(
                            openReference(entry['sourceProject'] as String),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _credit(
                    context,
                    'Original summaries & schematic illustrations · MIT',
                    'AnatoMorph contributors. Introductory summaries, questions and schematic SVGs are original material. Source references are linked for further study. No OpenStax figures or textbook text are redistributed. Medical and language review remains pending.',
                    null,
                  ),
                  _credit(
                    context,
                    'Inter, Noto & Roboto fonts · SIL Open Font License 1.1',
                    'Inter: Rasmus Andersson and contributors. Noto Sans Devanagari and Noto Sans Gujarati: The Noto Project Authors. Roboto: The Roboto Project Authors. Fonts are bundled without modification; full notices are included.',
                    'https://github.com/google/fonts',
                  ),
                  _credit(
                    context,
                    'Google model-viewer · Apache 2.0',
                    'The 3D viewer uses the self-hosted Google model-viewer library through model_viewer_plus. Bundled models load locally; no remote viewer script is required.',
                    'https://github.com/google/model-viewer',
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'references'.tr,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('OpenStax Anatomy and Physiology 2e'),
                    subtitle: Text('source_note'.tr),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => unawaited(
                      openReference(
                        'https://openstax.org/details/books/anatomy-and-physiology-2e',
                      ),
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('BodyParts3D database publication'),
                    subtitle: const Text(
                      'Mitsuhashi et al. Nucleic Acids Research 37, D782–D785 (2009). DOI: 10.1093/nar/gkn613.',
                    ),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => unawaited(
                      openReference('https://doi.org/10.1093/nar/gkn613'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    onPressed: () => showLicensePage(
                      context: context,
                      applicationName: 'AnatoMorph',
                      applicationVersion: '1.0.0',
                    ),
                    icon: const Icon(Icons.description_outlined),
                    label: Text('software_licenses'.tr),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'education'.tr,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    ),
  );

  Widget _credit(
    BuildContext context,
    String title,
    String description,
    String? url,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(description, style: const TextStyle(height: 1.7)),
            if (url != null)
              TextButton.icon(
                onPressed: () => unawaited(openReference(url)),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: Text('sources'.tr),
              ),
          ],
        ),
      ),
    ),
  );
}
