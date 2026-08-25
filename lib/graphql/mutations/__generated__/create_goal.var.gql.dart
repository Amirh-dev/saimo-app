// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart' as _i1;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i2;

part 'create_goal.var.gql.g.dart';

abstract class GCreateGoalVars
    implements Built<GCreateGoalVars, GCreateGoalVarsBuilder> {
  GCreateGoalVars._();

  factory GCreateGoalVars([void Function(GCreateGoalVarsBuilder b) updates]) =
      _$GCreateGoalVars;

  _i1.GCreateGoalInput get input;
  static Serializer<GCreateGoalVars> get serializer =>
      _$gCreateGoalVarsSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GCreateGoalVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GCreateGoalVars? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GCreateGoalVars.serializer,
        json,
      );
}
