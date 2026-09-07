// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i1;

part 'suggest_tag.var.gql.g.dart';

abstract class GSuggestTagsVars
    implements Built<GSuggestTagsVars, GSuggestTagsVarsBuilder> {
  GSuggestTagsVars._();

  factory GSuggestTagsVars([void Function(GSuggestTagsVarsBuilder b) updates]) =
      _$GSuggestTagsVars;

  String get title;
  static Serializer<GSuggestTagsVars> get serializer =>
      _$gSuggestTagsVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GSuggestTagsVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSuggestTagsVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GSuggestTagsVars.serializer,
        json,
      );
}
