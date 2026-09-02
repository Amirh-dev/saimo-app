// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart' as _i2;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i1;

part 'start_timed_task.data.gql.g.dart';

abstract class GStartTimedTaskData
    implements Built<GStartTimedTaskData, GStartTimedTaskDataBuilder> {
  GStartTimedTaskData._();

  factory GStartTimedTaskData(
          [void Function(GStartTimedTaskDataBuilder b) updates]) =
      _$GStartTimedTaskData;

  static void _initializeBuilder(GStartTimedTaskDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GStartTimedTaskData_startTimedTask get startTimedTask;
  static Serializer<GStartTimedTaskData> get serializer =>
      _$gStartTimedTaskDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GStartTimedTaskData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GStartTimedTaskData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GStartTimedTaskData.serializer,
        json,
      );
}

abstract class GStartTimedTaskData_startTimedTask
    implements
        Built<GStartTimedTaskData_startTimedTask,
            GStartTimedTaskData_startTimedTaskBuilder> {
  GStartTimedTaskData_startTimedTask._();

  factory GStartTimedTaskData_startTimedTask(
      [void Function(GStartTimedTaskData_startTimedTaskBuilder b)
          updates]) = _$GStartTimedTaskData_startTimedTask;

  static void _initializeBuilder(GStartTimedTaskData_startTimedTaskBuilder b) =>
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
  static Serializer<GStartTimedTaskData_startTimedTask> get serializer =>
      _$gStartTimedTaskDataStartTimedTaskSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GStartTimedTaskData_startTimedTask.serializer,
        this,
      ) as Map<String, dynamic>);

  static GStartTimedTaskData_startTimedTask? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GStartTimedTaskData_startTimedTask.serializer,
        json,
      );
}
