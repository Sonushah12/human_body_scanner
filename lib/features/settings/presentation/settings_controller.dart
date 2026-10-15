import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/storage/study_store.dart';

class SettingsController extends GetxController {
  SettingsController(this.store);
  final StudyStore store;
  final language = 'en'.obs;
  final theme = 'system'.obs;
  final reduceMotion = false.obs;

  ThemeMode get themeMode => switch (theme.value) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  @override
  void onInit() {
    super.onInit();
    final savedLanguage = store.string('language', 'en');
    language.value = ['en', 'hi', 'gu'].contains(savedLanguage)
        ? savedLanguage
        : 'en';
    theme.value = store.string('theme', 'system');
    reduceMotion.value = store.string('motion', 'full') == 'reduced';
  }

  Future<void> setLanguage(String value) async {
    if (!['en', 'hi', 'gu'].contains(value)) return;
    try {
      await store.put('language', value);
      language.value = value;
      await Get.updateLocale(Locale(value));
    } catch (_) {
      saveError();
    }
  }

  Future<void> setTheme(String value) async {
    try {
      await store.put('theme', value);
      theme.value = value;
      Get.changeThemeMode(themeMode);
    } catch (_) {
      saveError();
    }
  }

  Future<void> setReduceMotion(bool value) async {
    try {
      await store.put('motion', value ? 'reduced' : 'full');
      reduceMotion.value = value;
    } catch (_) {
      saveError();
    }
  }

  static void saveError() => Get.snackbar(
    'save_error'.tr,
    'storage_error'.tr,
    snackPosition: SnackPosition.BOTTOM,
  );
}
