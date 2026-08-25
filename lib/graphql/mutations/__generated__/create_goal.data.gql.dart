// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart' as _i2;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i1;

part 'create_goal.data.gql.g.dart';

abstract class GCreateGoalData
    implements Built<GCreateGoalData, GCreateGoalDataBuilder> {
  GCreateGoalData._();

  factory GCreateGoalData([void Function(GCreateGoalDataBuilder b) updates]) =
      _$GCreateGoalData;

  static void _initializeBuilder(GCreateGoalDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GCreateGoalData_createGoal get createGoal;
  static Serializer<GCreateGoalData> get serializer =>
      _$gCreateGoalDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GCreateGoalData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GCreateGoalData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GCreateGoalData.serializer,
        json,
      );
}

abstract class GCreateGoalData_createGoal
    implements
        Built<GCreateGoalData_createGoal, GCreateGoalData_createGoalBuilder> {
  GCreateGoalData_createGoal._();

  factory GCreateGoalData_createGoal(
          [void Function(GCreateGoalData_createGoalBuilder b) updates]) =
      _$GCreateGoalData_createGoal;

  static void _initializeBuilder(GCreateGoalData_createGoalBuilder b) =>
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
  static Serializer<GCreateGoalData_createGoal> get serializer =>
      _$gCreateGoalDataCreateGoalSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GCreateGoalData_createGoal.serializer,
        this,
      ) as Map<String, dynamic>);

  static GCreateGoalData_createGoal? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GCreateGoalData_createGoal.serializer,
        json,
      );
}
