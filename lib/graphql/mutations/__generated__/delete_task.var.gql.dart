// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i1;

part 'delete_task.var.gql.g.dart';

abstract class GDeleteTaskVars
    implements Built<GDeleteTaskVars, GDeleteTaskVarsBuilder> {
  GDeleteTaskVars._();

  factory GDeleteTaskVars([void Function(GDeleteTaskVarsBuilder b) updates]) =
      _$GDeleteTaskVars;

  String get id;
  static Serializer<GDeleteTaskVars> get serializer =>
      _$gDeleteTaskVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GDeleteTaskVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GDeleteTaskVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GDeleteTaskVars.serializer,
        json,
      );
}
