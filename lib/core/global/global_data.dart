import 'dart:async';

import 'global_data_model.dart';

class GlobalData {
  GlobalData._();

  static final GlobalData instance = GlobalData._();

  List<ParentTagModel> parentTags = [];
  Timer globalTimer = Timer(const Duration(), () {});
  int globalTotalSeconds = 0;
  int globalRemainingSeconds = 0;

  void setParentTags(List<ParentTagModel> tags) {
    parentTags = tags;
  }


  void clear() {
    parentTags.clear();
  }
}
