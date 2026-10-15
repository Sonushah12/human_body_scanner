import 'anatomy_part.dart';

abstract interface class AnatomyRepository {
  List<AnatomyPart> get parts;
  AnatomyPart? byId(String id);
  Future<void> load();
}
