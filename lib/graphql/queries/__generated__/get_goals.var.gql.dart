// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i1;

part 'get_goals.var.gql.g.dart';

abstract class GGetGoalsVars
    implements Built<GGetGoalsVars, GGetGoalsVarsBuilder> {
  GGetGoalsVars._();

  factory GGetGoalsVars([void Function(GGetGoalsVarsBuilder b) updates]) =
      _$GGetGoalsVars;

  static Serializer<GGetGoalsVars> get serializer => _$gGetGoalsVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GGetGoalsVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GGetGoalsVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GGetGoalsVars.serializer,
        json,
      );
}
