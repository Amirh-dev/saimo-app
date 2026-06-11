// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart' as _i1;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i2;

part 'get_tasks.var.gql.g.dart';

abstract class GGetTasksVars
    implements Built<GGetTasksVars, GGetTasksVarsBuilder> {
  GGetTasksVars._();

  factory GGetTasksVars([Function(GGetTasksVarsBuilder b) updates]) =
      _$GGetTasksVars;

  _i1.GTime? get date;
  _i1.GTaskStatus? get status;
  String? get goalID;
  int? get limit;
  int? get offset;
  static Serializer<GGetTasksVars> get serializer => _$gGetTasksVarsSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GGetTasksVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GGetTasksVars? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GGetTasksVars.serializer,
        json,
      );
}
