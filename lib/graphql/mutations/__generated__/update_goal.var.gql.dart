// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart' as _i1;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i2;

part 'update_goal.var.gql.g.dart';

abstract class GUpdateGoalVars
    implements Built<GUpdateGoalVars, GUpdateGoalVarsBuilder> {
  GUpdateGoalVars._();

  factory GUpdateGoalVars([void Function(GUpdateGoalVarsBuilder b) updates]) =
      _$GUpdateGoalVars;

  String get id;
  _i1.GUpdateGoalInput get input;
  static Serializer<GUpdateGoalVars> get serializer =>
      _$gUpdateGoalVarsSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GUpdateGoalVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GUpdateGoalVars? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GUpdateGoalVars.serializer,
        json,
      );
}
