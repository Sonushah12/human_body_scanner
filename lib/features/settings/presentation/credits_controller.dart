import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CreditsController extends GetxController {
  final assets = <Map<String, dynamic>>[].obs;
  final loading = false.obs;
  final failed = false.obs;

  @override
  void onInit() {
    super.onInit();
    unawaited(load());
  }

  Future<void> load() async {
    if (loading.value) return;
    loading.value = true;
    failed.value = false;
    try {
      final raw = await rootBundle.loadString(
        'assets/data/asset_manifest.json',
      );
      final json = jsonDecode(raw) as Map<String, dynamic>;
      assets.assignAll(
        (json['assets'] as List).map(
          (a) => Map<String, dynamic>.from(a as Map),
        ),
      );
    } catch (_) {
      failed.value = true;
    } finally {
      loading.value = false;
    }
  }
}
