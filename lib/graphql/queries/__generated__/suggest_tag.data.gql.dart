// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i1;

part 'suggest_tag.data.gql.g.dart';

abstract class GSuggestTagsData
    implements Built<GSuggestTagsData, GSuggestTagsDataBuilder> {
  GSuggestTagsData._();

  factory GSuggestTagsData([void Function(GSuggestTagsDataBuilder b) updates]) =
      _$GSuggestTagsData;

  static void _initializeBuilder(GSuggestTagsDataBuilder b) =>
      b..G__typename = 'Query';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  BuiltList<String> get suggestTags;
  static Serializer<GSuggestTagsData> get serializer =>
      _$gSuggestTagsDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GSuggestTagsData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSuggestTagsData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GSuggestTagsData.serializer,
        json,
      );
}
