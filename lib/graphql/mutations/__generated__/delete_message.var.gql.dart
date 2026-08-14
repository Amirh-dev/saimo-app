// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart' as _i1;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i2;

part 'delete_message.var.gql.g.dart';

abstract class GDeleteMessageVars
    implements Built<GDeleteMessageVars, GDeleteMessageVarsBuilder> {
  GDeleteMessageVars._();

  factory GDeleteMessageVars(
          [void Function(GDeleteMessageVarsBuilder b) updates]) =
      _$GDeleteMessageVars;

  _i1.GUUID get messageID;
  static Serializer<GDeleteMessageVars> get serializer =>
      _$gDeleteMessageVarsSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GDeleteMessageVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GDeleteMessageVars? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GDeleteMessageVars.serializer,
        json,
      );
}
