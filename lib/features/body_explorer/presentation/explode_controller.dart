import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../settings/presentation/settings_controller.dart';

class ExplodeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late final AnimationController motion;
  final t = 1.0.obs;
  int _hapticBucket = 4;
  bool systemReduceMotion = false;

  @override
  void onInit() {
    super.onInit();
    motion = AnimationController(
      vsync: this,
      value: 1,
      lowerBound: 0,
      upperBound: 1,
    )..addListener(_changed);
  }

  bool get reduced =>
      systemReduceMotion || Get.find<SettingsController>().reduceMotion.value;
  void _changed() => t.value = motion.value;

  void scrub(double value) {
    motion.stop();
    motion.value = value.clamp(0.0, 1.0);
    final bucket = (value * 4).floor();
    if (bucket != _hapticBucket) {
      _hapticBucket = bucket;
      unawaited(HapticFeedback.selectionClick());
    }
  }

  void snap([double? target]) {
    final destination = target ?? (motion.value >= .5 ? 1.0 : 0.0);
    if (reduced) {
      motion.value = destination;
      return;
    }
    unawaited(
      motion
          .animateWith(
            SpringSimulation(
              const SpringDescription(mass: 1, stiffness: 280, damping: 30),
              motion.value,
              destination,
              0,
              tolerance: const Tolerance(distance: .001, velocity: .001),
            ),
          )
          .orCancel
          .catchError((Object _) {}),
    );
  }

  @override
  void onClose() {
    motion.removeListener(_changed);
    motion.dispose();
    super.onClose();
  }
}
