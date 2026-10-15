import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_shell.dart';
import 'settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});
  @override
  Widget build(BuildContext context) => AppShell(
    selected: 3,
    child: Column(
      children: [
        PageHeader(title: 'preferences'.tr, subtitle: 'tagline'.tr),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 780),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _section(
                      context,
                      'appearance'.tr,
                      Obx(
                        () => Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final mode in ['system', 'light', 'dark'])
                              ChoiceChip(
                                label: Text(
                                  (mode == 'system' ? 'system_theme' : mode).tr,
                                ),
                                selected: controller.theme.value == mode,
                                onSelected: (_) =>
                                    unawaited(controller.setTheme(mode)),
                              ),
                          ],
                        ),
                      ),
                    ),
                    _section(
                      context,
                      'language'.tr,
                      Obx(
                        () => Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final entry in {
                              'en': 'English',
                              'hi': 'हिन्दी',
                              'gu': 'ગુજરાતી',
                            }.entries)
                              ChoiceChip(
                                label: Text(entry.value),
                                selected:
                                    controller.language.value == entry.key,
                                onSelected: (_) => unawaited(
                                  controller.setLanguage(entry.key),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      child: Obx(
                        () => SwitchListTile.adaptive(
                          title: Text('reduce_motion'.tr),
                          subtitle: Text('reduce_motion_subtitle'.tr),
                          value: controller.reduceMotion.value,
                          onChanged: (value) =>
                              unawaited(controller.setReduceMotion(value)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'about'.tr,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.copyright_outlined),
                            title: Text('attribution'.tr),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () =>
                                unawaited(Get.toNamed<void>(AppRoutes.credits)),
                          ),
                          const Divider(height: 1),
                          ExpansionTile(
                            leading: const Icon(Icons.shield_outlined),
                            title: Text('privacy'.tr),
                            childrenPadding: const EdgeInsets.fromLTRB(
                              20,
                              0,
                              20,
                              20,
                            ),
                            children: [
                              Text(
                                'privacy_detail'.tr,
                                style: const TextStyle(height: 1.7),
                              ),
                            ],
                          ),
                          const Divider(height: 1),
                          ExpansionTile(
                            leading: const Icon(Icons.menu_book_outlined),
                            title: Text('content_policy'.tr),
                            childrenPadding: const EdgeInsets.fromLTRB(
                              20,
                              0,
                              20,
                              20,
                            ),
                            children: [
                              Text(
                                'content_policy_detail'.tr,
                                style: const TextStyle(height: 1.7),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'AnatoMorph 1.0.0',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'education'.tr,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _section(BuildContext context, String title, Widget child) => Padding(
    padding: const EdgeInsets.only(bottom: 26),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 14),
        child,
      ],
    ),
  );
}
