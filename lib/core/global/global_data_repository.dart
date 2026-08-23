import 'package:ferry/ferry.dart';
import 'package:flutter/cupertino.dart';

import '../../graphql/queries/__generated__/parent_tags.req.gql.dart';
import 'global_data.dart';
import 'global_data_model.dart';


class GlobalDataRepository {

  GlobalDataRepository(
      this._client,
      );


  final Client _client;


  Future<void> loadParentTags() async {

    final request = GParentTagsReq(
          (b) => b
        ..fetchPolicy = FetchPolicy.NetworkOnly,
    );


    final response = await _client.request(request).first;


    if (response.hasErrors || response.data == null) {
      debugPrint("Failed loading parent tags");
      return;
    }


    final tags = response.data!.parentTags;


    final models = tags.map(
          (tag) {
        return ParentTagModel(
          id: tag.id,
          name: tag.name,
          kind: tag.kind.name,
          moderationStatus: tag.moderationStatus.name,
        );
      },
    ).toList();


    GlobalData.instance.setParentTags(models);


    debugPrint(
      "GLOBAL TAGS COUNT: ${GlobalData.instance.parentTags.length}",
    );
  }
}