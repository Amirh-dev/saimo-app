// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart' as _i2;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i1;

part 'get_goals.data.gql.g.dart';

abstract class GGetGoalsData
    implements Built<GGetGoalsData, GGetGoalsDataBuilder> {
  GGetGoalsData._();

  factory GGetGoalsData([void Function(GGetGoalsDataBuilder b) updates]) =
      _$GGetGoalsData;

  static void _initializeBuilder(GGetGoalsDataBuilder b) =>
      b..G__typename = 'Query';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  BuiltList<GGetGoalsData_getGoals> get getGoals;
  static Serializer<GGetGoalsData> get serializer => _$gGetGoalsDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GGetGoalsData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GGetGoalsData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GGetGoalsData.serializer,
        json,
      );
}

abstract class GGetGoalsData_getGoals
    implements Built<GGetGoalsData_getGoals, GGetGoalsData_getGoalsBuilder> {
  GGetGoalsData_getGoals._();

  factory GGetGoalsData_getGoals(
          [void Function(GGetGoalsData_getGoalsBuilder b) updates]) =
      _$GGetGoalsData_getGoals;

  static void _initializeBuilder(GGetGoalsData_getGoalsBuilder b) =>
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
  static Serializer<GGetGoalsData_getGoals> get serializer =>
      _$gGetGoalsDataGetGoalsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GGetGoalsData_getGoals.serializer,
        this,
      ) as Map<String, dynamic>);

  static GGetGoalsData_getGoals? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GGetGoalsData_getGoals.serializer,
        json,
      );
}
