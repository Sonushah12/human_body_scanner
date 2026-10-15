import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_shell.dart';
import '../../body_explorer/domain/body_layout.dart';
import '../../body_explorer/presentation/widgets/part_card.dart';
import 'bookmarks_controller.dart';

class BookmarksView extends GetView<BookmarksController> {
  const BookmarksView({super.key});
  @override
  Widget build(BuildContext context) => AppShell(
    selected: 1,
    child: Column(
      children: [
        PageHeader(title: 'saved_title'.tr, subtitle: 'saved_description'.tr),
        Expanded(
          child: Obx(() {
            final parts = controller.parts;
            if (parts.isEmpty) {
              return EmptyState(
                icon: Icons.bookmark_add_outlined,
                title: 'empty_saved'.tr,
                description: 'empty_saved_description'.tr,
                action: FilledButton(
                  onPressed: () =>
                      unawaited(Get.offNamed<void>(AppRoutes.explore)),
                  child: Text('explore'.tr),
                ),
              );
            }
            return LayoutBuilder(
              builder: (context, constraints) {
                final layout = BodyLayout.forWidth(constraints.maxWidth - 48);
                return GridView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: parts.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: layout.columns,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    mainAxisExtent: layout.cardHeight(
                      constraints.maxWidth - 48,
                      MediaQuery.textScalerOf(context).scale(14) / 14,
                    ),
                  ),
                  itemBuilder: (context, i) => PartCard(part: parts[i]),
                );
              },
            );
          }),
        ),
      ],
    ),
  );
}
