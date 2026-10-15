import 'dart:async';
import 'package:get/get.dart';

import '../../../core/storage/study_service.dart';
import '../../body_explorer/domain/anatomy_part.dart';
import '../../body_explorer/domain/anatomy_repository.dart';
import '../../settings/presentation/settings_controller.dart';

class DetailController extends GetxController {
  DetailController(this.catalog, this.study);
  final AnatomyRepository catalog;
  final StudyService study;
  AnatomyPart? part;
  final tab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    part = catalog.byId(Get.parameters['id'] ?? '');
    final id = part?.id;
    if (id != null) {
      unawaited(
        study
            .recordView(id)
            .catchError((Object _) => SettingsController.saveError()),
      );
    }
  }

  bool get bookmarked => part != null && study.bookmarks.contains(part!.id);
  Future<void> toggleBookmark() async {
    final id = part?.id;
    if (id == null) return;
    try {
      await study.toggleBookmark(id);
    } catch (_) {
      SettingsController.saveError();
    }
  }
}
