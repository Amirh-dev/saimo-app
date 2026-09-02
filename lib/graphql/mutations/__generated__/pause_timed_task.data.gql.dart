// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart' as _i2;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i1;

part 'pause_timed_task.data.gql.g.dart';

abstract class GPauseTimedTaskData
    implements Built<GPauseTimedTaskData, GPauseTimedTaskDataBuilder> {
  GPauseTimedTaskData._();

  factory GPauseTimedTaskData(
          [void Function(GPauseTimedTaskDataBuilder b) updates]) =
      _$GPauseTimedTaskData;

  static void _initializeBuilder(GPauseTimedTaskDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GPauseTimedTaskData_pauseTimedTask get pauseTimedTask;
  static Serializer<GPauseTimedTaskData> get serializer =>
      _$gPauseTimedTaskDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GPauseTimedTaskData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GPauseTimedTaskData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GPauseTimedTaskData.serializer,
        json,
      );
}

abstract class GPauseTimedTaskData_pauseTimedTask
    implements
        Built<GPauseTimedTaskData_pauseTimedTask,
            GPauseTimedTaskData_pauseTimedTaskBuilder> {
  GPauseTimedTaskData_pauseTimedTask._();

  factory GPauseTimedTaskData_pauseTimedTask(
      [void Function(GPauseTimedTaskData_pauseTimedTaskBuilder b)
          updates]) = _$GPauseTimedTaskData_pauseTimedTask;

  static void _initializeBuilder(GPauseTimedTaskData_pauseTimedTaskBuilder b) =>
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
  static Serializer<GPauseTimedTaskData_pauseTimedTask> get serializer =>
      _$gPauseTimedTaskDataPauseTimedTaskSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GPauseTimedTaskData_pauseTimedTask.serializer,
        this,
      ) as Map<String, dynamic>);

  static GPauseTimedTaskData_pauseTimedTask? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GPauseTimedTaskData_pauseTimedTask.serializer,
        json,
      );
}
