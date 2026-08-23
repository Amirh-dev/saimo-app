// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart' as _i2;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i1;

part 'update_task.data.gql.g.dart';

abstract class GUpdateTaskData
    implements Built<GUpdateTaskData, GUpdateTaskDataBuilder> {
  GUpdateTaskData._();

  factory GUpdateTaskData([void Function(GUpdateTaskDataBuilder b) updates]) =
      _$GUpdateTaskData;

  static void _initializeBuilder(GUpdateTaskDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GUpdateTaskData_updateTask get updateTask;
  static Serializer<GUpdateTaskData> get serializer =>
      _$gUpdateTaskDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GUpdateTaskData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GUpdateTaskData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GUpdateTaskData.serializer,
        json,
      );
}

abstract class GUpdateTaskData_updateTask
    implements
        Built<GUpdateTaskData_updateTask, GUpdateTaskData_updateTaskBuilder> {
  GUpdateTaskData_updateTask._();

  factory GUpdateTaskData_updateTask(
          [void Function(GUpdateTaskData_updateTaskBuilder b) updates]) =
      _$GUpdateTaskData_updateTask;

  static void _initializeBuilder(GUpdateTaskData_updateTaskBuilder b) =>
      b..G__typename = 'Task';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  _i2.GTime get createdAt;
  _i2.GTime get updatedAt;
  String get title;
  String? get shortDescription;
  String? get note;
  _i2.GTaskType get type;
  _i2.GTime get date;
  int? get durationM;
  int get elapsedSeconds;
  _i2.GTime? get timerStartedAt;
  _i2.GTime? get completedAt;
  bool get hasReminder;
  _i2.GTime? get reminderTime;
  String? get recurringDays;
  _i2.GTaskStatus get status;
  String get userID;
  String? get goalID;
  String? get subjectTagID;
  static Serializer<GUpdateTaskData_updateTask> get serializer =>
      _$gUpdateTaskDataUpdateTaskSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GUpdateTaskData_updateTask.serializer,
        this,
      ) as Map<String, dynamic>);

  static GUpdateTaskData_updateTask? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GUpdateTaskData_updateTask.serializer,
        json,
      );
}
