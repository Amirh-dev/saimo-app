// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i1;

part 'parent_tags.var.gql.g.dart';

abstract class GParentTagsVars
    implements Built<GParentTagsVars, GParentTagsVarsBuilder> {
  GParentTagsVars._();

  factory GParentTagsVars([void Function(GParentTagsVarsBuilder b) updates]) =
      _$GParentTagsVars;

  static Serializer<GParentTagsVars> get serializer =>
      _$gParentTagsVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GParentTagsVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GParentTagsVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GParentTagsVars.serializer,
        json,
      );
}
