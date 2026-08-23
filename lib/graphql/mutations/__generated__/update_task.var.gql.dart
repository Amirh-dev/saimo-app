// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart' as _i1;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i2;

part 'update_task.var.gql.g.dart';

abstract class GUpdateTaskVars
    implements Built<GUpdateTaskVars, GUpdateTaskVarsBuilder> {
  GUpdateTaskVars._();

  factory GUpdateTaskVars([void Function(GUpdateTaskVarsBuilder b) updates]) =
      _$GUpdateTaskVars;

  String get id;
  _i1.GUpdateTaskInput get input;
  static Serializer<GUpdateTaskVars> get serializer =>
      _$gUpdateTaskVarsSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GUpdateTaskVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GUpdateTaskVars? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GUpdateTaskVars.serializer,
        json,
      );
}
