// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i1;

part 'delete_goal.var.gql.g.dart';

abstract class GDeleteGoalVars
    implements Built<GDeleteGoalVars, GDeleteGoalVarsBuilder> {
  GDeleteGoalVars._();

  factory GDeleteGoalVars([void Function(GDeleteGoalVarsBuilder b) updates]) =
      _$GDeleteGoalVars;

  String get id;
  static Serializer<GDeleteGoalVars> get serializer =>
      _$gDeleteGoalVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GDeleteGoalVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GDeleteGoalVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GDeleteGoalVars.serializer,
        json,
      );
}
