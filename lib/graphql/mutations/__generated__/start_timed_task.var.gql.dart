// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i1;

part 'start_timed_task.var.gql.g.dart';

abstract class GStartTimedTaskVars
    implements Built<GStartTimedTaskVars, GStartTimedTaskVarsBuilder> {
  GStartTimedTaskVars._();

  factory GStartTimedTaskVars(
          [void Function(GStartTimedTaskVarsBuilder b) updates]) =
      _$GStartTimedTaskVars;

  String get id;
  static Serializer<GStartTimedTaskVars> get serializer =>
      _$gStartTimedTaskVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GStartTimedTaskVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GStartTimedTaskVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GStartTimedTaskVars.serializer,
        json,
      );
}
