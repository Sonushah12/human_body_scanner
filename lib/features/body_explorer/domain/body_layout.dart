import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'anatomy_part.dart';

abstract class BodyLayout {
  const BodyLayout();
  int get columns;
  double get gap => 14;

  static BodyLayout forWidth(double width) => width >= 1100
      ? const BodyLayoutDesktop()
      : width >= 650
      ? const BodyLayoutTablet()
      : const BodyLayoutPhone();

  double cardWidth(double width) => (width - gap * (columns - 1)) / columns;
  double cardHeight(double width, double textScale) =>
      math.max(212, 140 + 72 * textScale);
  double gridHeight(double width, int count, double textScale) =>
      ((count / columns).ceil() * (cardHeight(width, textScale) + gap) - gap)
          .clamp(0, double.infinity);

  Rect gridRect(double width, int index, double textScale) {
    final w = cardWidth(width);
    final h = cardHeight(width, textScale);
    return Rect.fromLTWH(
      (index % columns) * (w + gap),
      (index ~/ columns) * (h + gap),
      w,
      h,
    );
  }
}

class BodyLayoutPhone extends BodyLayout {
  const BodyLayoutPhone();
  @override
  int get columns => 2;
}

class BodyLayoutTablet extends BodyLayout {
  const BodyLayoutTablet();
  @override
  int get columns => 4;
}

class BodyLayoutDesktop extends BodyLayout {
  const BodyLayoutDesktop();
  @override
  int get columns => 6;
}

@immutable
class PartPose {
  const PartPose(this.center, this.scale, this.rotation);
  final Offset center;
  final double scale;
  final double rotation;
}

abstract final class BodyGeometry {
  /// Every property derives from assembly t. Quadratic arcs and depth-based
  /// intervals have exact, deterministic endpoints for scrubbing and tests.
  static PartPose pose({
    required AnatomyPart part,
    required Rect bodyRect,
    required Rect gridRect,
    required double t,
    required int index,
  }) {
    final separation = (1 - t).clamp(0.0, 1.0);
    final delay = (part.depthOrder.clamp(0, 6) / 6) * .28;
    final progress = Curves.easeInOutCubic.transform(
      ((separation - delay) / (1 - delay)).clamp(0.0, 1.0),
    );
    final start = Offset(
      bodyRect.left + bodyRect.width * part.bodyPosition.dx,
      bodyRect.top + bodyRect.height * part.bodyPosition.dy,
    );
    final end = gridRect.center;
    final control = Offset(
      (start.dx + end.dx) / 2 + (index.isEven ? -1 : 1) * bodyRect.width * .18,
      math.min(start.dy, end.dy) - bodyRect.height * .12,
    );
    final center =
        start * math.pow(1 - progress, 2).toDouble() +
        control * (2 * (1 - progress) * progress) +
        end * (progress * progress);
    final assemblyScale = (bodyRect.width * part.bodyScale / gridRect.width)
        .clamp(.08, .75);
    return PartPose(
      center,
      assemblyScale + (1 - assemblyScale) * progress,
      math.sin(progress * math.pi) * (index.isEven ? 1 : -1) * .14,
    );
  }
}
