import 'package:get/get.dart';
import '../../../core/storage/study_service.dart';
import '../../body_explorer/domain/anatomy_part.dart';
import '../../body_explorer/domain/anatomy_repository.dart';

class BookmarksController extends GetxController {
  BookmarksController(this.catalog, this.study);
  final AnatomyRepository catalog;
  final StudyService study;
  List<AnatomyPart> get parts => catalog.parts
      .where((part) => study.bookmarks.contains(part.id))
      .toList(growable: false);
}
