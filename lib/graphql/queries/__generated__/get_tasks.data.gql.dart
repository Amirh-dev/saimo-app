// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart' as _i2;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i1;

part 'get_tasks.data.gql.g.dart';

abstract class GGetTasksData
    implements Built<GGetTasksData, GGetTasksDataBuilder> {
  GGetTasksData._();

  factory GGetTasksData([void Function(GGetTasksDataBuilder b) updates]) =
      _$GGetTasksData;

  static void _initializeBuilder(GGetTasksDataBuilder b) =>
      b..G__typename = 'Query';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  BuiltList<GGetTasksData_getTasks> get getTasks;
  static Serializer<GGetTasksData> get serializer => _$gGetTasksDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GGetTasksData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GGetTasksData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GGetTasksData.serializer,
        json,
      );
}

abstract class GGetTasksData_getTasks
    implements Built<GGetTasksData_getTasks, GGetTasksData_getTasksBuilder> {
  GGetTasksData_getTasks._();

  factory GGetTasksData_getTasks(
          [void Function(GGetTasksData_getTasksBuilder b) updates]) =
      _$GGetTasksData_getTasks;

  static void _initializeBuilder(GGetTasksData_getTasksBuilder b) =>
      b..G__typename = 'Task';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  String get title;
  String? get shortDescription;
  String? get note;
  _i2.GTaskType get type;
  _i2.GTime get date;
  int? get durationM;
  bool get hasReminder;
  _i2.GTime? get reminderTime;
  String? get recurringDays;
  int get elapsedSeconds;
  _i2.GTaskStatus get status;
  GGetTasksData_getTasks_goal? get goal;
  BuiltList<GGetTasksData_getTasks_tags>? get tags;
  static Serializer<GGetTasksData_getTasks> get serializer =>
      _$gGetTasksDataGetTasksSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GGetTasksData_getTasks.serializer,
        this,
      ) as Map<String, dynamic>);

  static GGetTasksData_getTasks? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GGetTasksData_getTasks.serializer,
        json,
      );
}

abstract class GGetTasksData_getTasks_goal
    implements
        Built<GGetTasksData_getTasks_goal, GGetTasksData_getTasks_goalBuilder> {
  GGetTasksData_getTasks_goal._();

  factory GGetTasksData_getTasks_goal(
          [void Function(GGetTasksData_getTasks_goalBuilder b) updates]) =
      _$GGetTasksData_getTasks_goal;

  static void _initializeBuilder(GGetTasksData_getTasks_goalBuilder b) =>
      b..G__typename = 'Goal';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  String get title;
  static Serializer<GGetTasksData_getTasks_goal> get serializer =>
      _$gGetTasksDataGetTasksGoalSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GGetTasksData_getTasks_goal.serializer,
        this,
      ) as Map<String, dynamic>);

  static GGetTasksData_getTasks_goal? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GGetTasksData_getTasks_goal.serializer,
        json,
      );
}

abstract class GGetTasksData_getTasks_tags
    implements
        Built<GGetTasksData_getTasks_tags, GGetTasksData_getTasks_tagsBuilder> {
  GGetTasksData_getTasks_tags._();

  factory GGetTasksData_getTasks_tags(
          [void Function(GGetTasksData_getTasks_tagsBuilder b) updates]) =
      _$GGetTasksData_getTasks_tags;

  static void _initializeBuilder(GGetTasksData_getTasks_tagsBuilder b) =>
      b..G__typename = 'Tag';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  String get name;
  static Serializer<GGetTasksData_getTasks_tags> get serializer =>
      _$gGetTasksDataGetTasksTagsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GGetTasksData_getTasks_tags.serializer,
        this,
      ) as Map<String, dynamic>);

  static GGetTasksData_getTasks_tags? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GGetTasksData_getTasks_tags.serializer,
        json,
      );
}
