// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i1;

part 'delete_task.data.gql.g.dart';

abstract class GDeleteTaskData
    implements Built<GDeleteTaskData, GDeleteTaskDataBuilder> {
  GDeleteTaskData._();

  factory GDeleteTaskData([void Function(GDeleteTaskDataBuilder b) updates]) =
      _$GDeleteTaskData;

  static void _initializeBuilder(GDeleteTaskDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  bool get deleteTask;
  static Serializer<GDeleteTaskData> get serializer =>
      _$gDeleteTaskDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GDeleteTaskData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GDeleteTaskData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GDeleteTaskData.serializer,
        json,
      );
}
