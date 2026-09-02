// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i1;

part 'complete_timed_task.var.gql.g.dart';

abstract class GCompleteTimedTaskVars
    implements Built<GCompleteTimedTaskVars, GCompleteTimedTaskVarsBuilder> {
  GCompleteTimedTaskVars._();

  factory GCompleteTimedTaskVars(
          [void Function(GCompleteTimedTaskVarsBuilder b) updates]) =
      _$GCompleteTimedTaskVars;

  String get id;
  static Serializer<GCompleteTimedTaskVars> get serializer =>
      _$gCompleteTimedTaskVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GCompleteTimedTaskVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GCompleteTimedTaskVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GCompleteTimedTaskVars.serializer,
        json,
      );
}
