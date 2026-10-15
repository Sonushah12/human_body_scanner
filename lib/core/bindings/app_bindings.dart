import 'package:get/get.dart';
import '../../features/body_explorer/domain/anatomy_repository.dart';
import '../../features/body_explorer/presentation/explode_controller.dart';
import '../../features/body_explorer/presentation/parts_controller.dart';
import '../../features/bookmarks/presentation/bookmarks_controller.dart';
import '../../features/part_detail/presentation/detail_controller.dart';
import '../../features/quiz/presentation/quiz_controller.dart';
import '../../features/settings/presentation/credits_controller.dart';
import '../storage/study_service.dart';

class ExplorerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(ExplodeController.new);
    Get.lazyPut(() => PartsController(Get.find<AnatomyRepository>()));
  }
}

class DetailBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(
    () => DetailController(
      Get.find<AnatomyRepository>(),
      Get.find<StudyService>(),
    ),
  );
}

class BookmarksBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(
    () => BookmarksController(
      Get.find<AnatomyRepository>(),
      Get.find<StudyService>(),
    ),
  );
}

class QuizBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(
    () =>
        QuizController(Get.find<AnatomyRepository>(), Get.find<StudyService>()),
  );
}

class CreditsBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(CreditsController.new);
}
