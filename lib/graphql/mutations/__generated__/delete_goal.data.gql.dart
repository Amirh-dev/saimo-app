// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i1;

part 'delete_goal.data.gql.g.dart';

abstract class GDeleteGoalData
    implements Built<GDeleteGoalData, GDeleteGoalDataBuilder> {
  GDeleteGoalData._();

  factory GDeleteGoalData([void Function(GDeleteGoalDataBuilder b) updates]) =
      _$GDeleteGoalData;

  static void _initializeBuilder(GDeleteGoalDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  bool get deleteGoal;
  static Serializer<GDeleteGoalData> get serializer =>
      _$gDeleteGoalDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GDeleteGoalData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GDeleteGoalData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GDeleteGoalData.serializer,
        json,
      );
}
