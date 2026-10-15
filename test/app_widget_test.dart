import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:anatomorph/app.dart';
import 'package:anatomorph/core/routes/app_routes.dart';
import 'package:anatomorph/features/body_explorer/presentation/explode_controller.dart';
import 'package:anatomorph/features/body_explorer/presentation/parts_controller.dart';
import 'package:anatomorph/features/settings/presentation/settings_controller.dart';
import 'support/harness.dart';

void main() {
  late TestHarness harness;
  setUp(() async => harness = await TestHarness.open(memoryWrites: true));
  tearDown(() async => harness.close());

  for (final size in [
    const Size(320, 568),
    const Size(768, 1024),
    const Size(1440, 900),
  ]) {
    testWidgets(
      'explorer renders assembly, mid-flight and grid at $size without layout errors',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(const AnatoMorphApp());
        await tester.pumpAndSettle();
        final motion = Get.find<ExplodeController>();
        for (final t in [1.0, .5, 0.0]) {
          motion.scrub(t);
          await tester.pump();
          final error = tester.takeException();
          if (error is FlutterError) debugPrint(error.toStringDeep());
          expect(error, isNull);
          expect(find.byKey(const ValueKey('explode-slider')), findsOneWidget);
        }
      },
    );
  }

  testWidgets(
    'search in Hindi returns matching names; no results can be cleared',
    (tester) async {
      await tester.pumpWidget(const AnatoMorphApp());
      await tester.pumpAndSettle();
      final parts = Get.find<PartsController>();
      parts.search('हृदय');
      await tester.pump(const Duration(milliseconds: 180));
      expect(parts.visible.map((p) => p.id), ['heart']);
      parts.search('no-such-structure');
      await tester.pump(const Duration(milliseconds: 180));
      expect(find.text('No matching structures'), findsOneWidget);
      parts.clear();
      await tester.pump();
      expect(parts.visible, hasLength(20));
    },
  );

  testWidgets('unknown structure routes show a recovery view', (tester) async {
    await tester.pumpWidget(const AnatoMorphApp());
    await tester.pumpAndSettle();
    unawaited(Get.toNamed<void>(AppRoutes.part('unknown')));
    await tester.pumpAndSettle();
    expect(find.text('Structure not found'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'a desktop without WebView uses the offline image gallery',
    (tester) async {
      await tester.pumpWidget(const AnatoMorphApp());
      await tester.pumpAndSettle();
      unawaited(Get.toNamed<void>(AppRoutes.part('heart')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('3D model'));
      await tester.pumpAndSettle();
      expect(find.text('A 3D model is not available here'), findsOneWidget);
      expect(find.byType(Image), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );

  testWidgets(
    'reduced motion keeps detail content visible at large text size',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      Get.find<SettingsController>().reduceMotion.value = true;
      await tester.pumpWidget(const AnatoMorphApp());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      unawaited(Get.toNamed<void>(AppRoutes.part('heart')));
      await tester.pumpAndSettle();
      expect(
        find.text(harness.catalog.byId('heart')!.overview),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
