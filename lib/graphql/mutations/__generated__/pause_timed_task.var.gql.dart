// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i1;

part 'pause_timed_task.var.gql.g.dart';

abstract class GPauseTimedTaskVars
    implements Built<GPauseTimedTaskVars, GPauseTimedTaskVarsBuilder> {
  GPauseTimedTaskVars._();

  factory GPauseTimedTaskVars(
          [void Function(GPauseTimedTaskVarsBuilder b) updates]) =
      _$GPauseTimedTaskVars;

  String get id;
  static Serializer<GPauseTimedTaskVars> get serializer =>
      _$gPauseTimedTaskVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GPauseTimedTaskVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GPauseTimedTaskVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GPauseTimedTaskVars.serializer,
        json,
      );
}
