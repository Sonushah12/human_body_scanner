import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../domain/anatomy_part.dart';
import '../../domain/body_layout.dart';
import '../explode_controller.dart';
import 'part_card.dart';

class BodyStack extends StatelessWidget {
  const BodyStack({required this.parts, required this.motion, super.key});
  final List<AnatomyPart> parts;
  final ExplodeController motion;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
      final layout = BodyLayout.forWidth(MediaQuery.sizeOf(context).width);
      final gridHeight = layout.gridHeight(width, parts.length, textScale);
      final bodyHeight = math.min(
        600.0,
        math.max(430.0, constraints.maxWidth * 1.25),
      );
      final bodyWidth = math.min(bodyHeight * .52, width * .9);
      final bodyRect = Rect.fromLTWH(
        (width - bodyWidth) / 2,
        0,
        bodyWidth,
        bodyHeight,
      );
      final reveal = motion.motion.drive(
        Tween(begin: 1.0, end: 0.0).chain(
          CurveTween(curve: const Interval(0, .16, curve: Curves.easeOut)),
        ),
      );
      // Cards/SVG trees are cached as the animation's children. Only the small
      // positioning/transform wrappers are recreated during a scrub.
      final cards = [
        for (final part in parts)
          RepaintBoundary(
            key: ValueKey(part.id),
            child: PartCard(part: part, reveal: reveal),
          ),
      ];
      final silhouette = RepaintBoundary(
        child: SvgPicture.asset(
          'assets/svg/body.svg',
          fit: BoxFit.contain,
          colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.primary.withValues(alpha: .15),
            BlendMode.srcIn,
          ),
          excludeFromSemantics: true,
        ),
      );
      return RepaintBoundary(
        child: AnimatedBuilder(
          animation: motion.motion,
          child: silhouette,
          builder: (context, body) {
            final t = motion.motion.value;
            final separation = Curves.easeOutCubic.transform(1 - t);
            final height =
                bodyHeight +
                (math.max(bodyHeight, gridHeight) - bodyHeight) * separation;
            return SizedBox(
              height: height + 16,
              width: width,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fromRect(
                    rect: bodyRect,
                    child: FadeTransition(opacity: motion.motion, child: body),
                  ),
                  if (t > .95)
                    Positioned(
                      top: bodyHeight - 24,
                      left: 0,
                      right: 0,
                      child: Text(
                        'reference_atlas'.tr,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  for (var index = 0; index < parts.length; index++)
                    _piece(
                      parts[index],
                      index,
                      layout.gridRect(width, index, textScale),
                      bodyRect,
                      t,
                      cards[index],
                    ),
                ],
              ),
            );
          },
        ),
      );
    },
  );

  Widget _piece(
    AnatomyPart part,
    int index,
    Rect grid,
    Rect body,
    double t,
    Widget card,
  ) {
    final pose = BodyGeometry.pose(
      part: part,
      bodyRect: body,
      gridRect: grid,
      t: t,
      index: index,
    );
    return Positioned(
      left: pose.center.dx - grid.width / 2,
      top: pose.center.dy - grid.height / 2,
      width: grid.width,
      height: grid.height,
      child: IgnorePointer(
        ignoring: t > .05,
        child: ExcludeSemantics(
          excluding: t > .05,
          child: Transform.rotate(
            angle: pose.rotation,
            child: Transform.scale(scale: pose.scale, child: card),
          ),
        ),
      ),
    );
  }
}
