import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../domain/anatomy_part.dart';
import '../domain/anatomy_repository.dart';
import 'explode_controller.dart';

class PartsController extends GetxController {
  PartsController(this.repository);
  final AnatomyRepository repository;
  final selectedSystem = Rxn<BodySystem>();
  final query = ''.obs;
  final visible = <AnatomyPart>[].obs;
  final searchField = TextEditingController();
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    visible.assignAll(repository.parts);
  }

  void search(String value) {
    query.value = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 140), _filter);
    if (value.trim().isNotEmpty) Get.find<ExplodeController>().snap(0);
  }

  void selectSystem(BodySystem? system) {
    selectedSystem.value = system;
    _filter();
    Get.find<ExplodeController>().snap(0);
  }

  void clear() {
    _debounce?.cancel();
    query.value = '';
    searchField.clear();
    selectedSystem.value = null;
    _filter();
  }

  void _filter() {
    final term = query.value.trim().toLowerCase();
    visible.assignAll(
      repository.parts.where(
        (part) =>
            (selectedSystem.value == null ||
                part.system == selectedSystem.value) &&
            (term.isEmpty ||
                part.latin.toLowerCase().contains(term) ||
                part.names.values.any(
                  (name) => name.toLowerCase().contains(term),
                )),
      ),
    );
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchField.dispose();
    super.onClose();
  }
}
