// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart' as _i2;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i1;

part 'complete_timed_task.data.gql.g.dart';

abstract class GCompleteTimedTaskData
    implements Built<GCompleteTimedTaskData, GCompleteTimedTaskDataBuilder> {
  GCompleteTimedTaskData._();

  factory GCompleteTimedTaskData(
          [void Function(GCompleteTimedTaskDataBuilder b) updates]) =
      _$GCompleteTimedTaskData;

  static void _initializeBuilder(GCompleteTimedTaskDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GCompleteTimedTaskData_completeTimedTask get completeTimedTask;
  static Serializer<GCompleteTimedTaskData> get serializer =>
      _$gCompleteTimedTaskDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GCompleteTimedTaskData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GCompleteTimedTaskData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GCompleteTimedTaskData.serializer,
        json,
      );
}

abstract class GCompleteTimedTaskData_completeTimedTask
    implements
        Built<GCompleteTimedTaskData_completeTimedTask,
            GCompleteTimedTaskData_completeTimedTaskBuilder> {
  GCompleteTimedTaskData_completeTimedTask._();

  factory GCompleteTimedTaskData_completeTimedTask(
      [void Function(GCompleteTimedTaskData_completeTimedTaskBuilder b)
          updates]) = _$GCompleteTimedTaskData_completeTimedTask;

  static void _initializeBuilder(
          GCompleteTimedTaskData_completeTimedTaskBuilder b) =>
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
  static Serializer<GCompleteTimedTaskData_completeTimedTask> get serializer =>
      _$gCompleteTimedTaskDataCompleteTimedTaskSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GCompleteTimedTaskData_completeTimedTask.serializer,
        this,
      ) as Map<String, dynamic>);

  static GCompleteTimedTaskData_completeTimedTask? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GCompleteTimedTaskData_completeTimedTask.serializer,
        json,
      );
}
