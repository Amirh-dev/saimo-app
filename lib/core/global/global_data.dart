import 'global_data_model.dart';

class GlobalData {
  GlobalData._();

  static final GlobalData instance = GlobalData._();

  List<ParentTagModel> parentTags = [];

  void setParentTags(List<ParentTagModel> tags) {
    parentTags = tags;
  }

  void clear() {
    parentTags.clear();
  }
}