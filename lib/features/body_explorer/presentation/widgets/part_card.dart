import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/study_service.dart';
import '../../../settings/presentation/settings_controller.dart';
import '../../domain/anatomy_part.dart';

class AnatomyIcon extends StatelessWidget {
  const AnatomyIcon({
    required this.part,
    this.size = 82,
    this.hero = true,
    super.key,
  });
  final AnatomyPart part;
  final double size;
  final bool hero;
  @override
  Widget build(BuildContext context) {
    final illustration = SvgPicture.asset(
      part.svg,
      width: size,
      height: size,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    );
    return hero
        ? Hero(tag: 'part_${part.id}', child: illustration)
        : illustration;
  }
}

class PartCard extends StatelessWidget {
  const PartCard({
    required this.part,
    this.reveal = const AlwaysStoppedAnimation(1),
    super.key,
  });
  final AnatomyPart part;
  final Animation<double> reveal;

  @override
  Widget build(BuildContext context) {
    final name = part.name(Get.locale?.languageCode ?? 'en');
    final study = Get.find<StudyService>();
    return Semantics(
      button: true,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FadeTransition(
            opacity: reveal,
            child: Card(color: Theme.of(context).cardTheme.color),
          ),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () =>
                  unawaited(Get.toNamed<void>(AppRoutes.part(part.id))),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(child: AnatomyIcon(part: part)),
                    ),
                    const SizedBox(height: 8),
                    FadeTransition(
                      opacity: reveal,
                      child: Column(
                        children: [
                          Text(
                            name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            part.latin,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(fontStyle: FontStyle.italic),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: part.system.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  part.system.id.tr,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 1,
            top: 1,
            child: FadeTransition(
              opacity: reveal,
              child: Obx(
                () => IconButton(
                  tooltip: study.bookmarks.contains(part.id)
                      ? 'unsave'.tr
                      : 'save'.tr,
                  iconSize: 19,
                  icon: Icon(
                    study.bookmarks.contains(part.id)
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                  ),
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () async {
                    try {
                      await study.toggleBookmark(part.id);
                    } catch (_) {
                      SettingsController.saveError();
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
