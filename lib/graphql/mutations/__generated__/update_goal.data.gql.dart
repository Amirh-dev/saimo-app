// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart' as _i2;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i1;

part 'update_goal.data.gql.g.dart';

abstract class GUpdateGoalData
    implements Built<GUpdateGoalData, GUpdateGoalDataBuilder> {
  GUpdateGoalData._();

  factory GUpdateGoalData([void Function(GUpdateGoalDataBuilder b) updates]) =
      _$GUpdateGoalData;

  static void _initializeBuilder(GUpdateGoalDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GUpdateGoalData_updateGoal get updateGoal;
  static Serializer<GUpdateGoalData> get serializer =>
      _$gUpdateGoalDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GUpdateGoalData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GUpdateGoalData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GUpdateGoalData.serializer,
        json,
      );
}

abstract class GUpdateGoalData_updateGoal
    implements
        Built<GUpdateGoalData_updateGoal, GUpdateGoalData_updateGoalBuilder> {
  GUpdateGoalData_updateGoal._();

  factory GUpdateGoalData_updateGoal(
          [void Function(GUpdateGoalData_updateGoalBuilder b) updates]) =
      _$GUpdateGoalData_updateGoal;

  static void _initializeBuilder(GUpdateGoalData_updateGoalBuilder b) =>
      b..G__typename = 'Goal';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  _i2.GTime get createdAt;
  _i2.GTime get updatedAt;
  String get title;
  String? get note;
  _i2.GTime? get targetDate;
  _i2.GGoalStatus get status;
  String get userID;
  static Serializer<GUpdateGoalData_updateGoal> get serializer =>
      _$gUpdateGoalDataUpdateGoalSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GUpdateGoalData_updateGoal.serializer,
        this,
      ) as Map<String, dynamic>);

  static GUpdateGoalData_updateGoal? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GUpdateGoalData_updateGoal.serializer,
        json,
      );
}
