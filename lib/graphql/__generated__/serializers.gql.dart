// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart' show StandardJsonPlugin;
import 'package:ferry_exec/ferry_exec.dart';
import 'package:gql_code_builder_serializers/gql_code_builder_serializers.dart'
    show OperationSerializer;
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart'
    show
        GCreateGoalInput,
        GCreateTaskInput,
        GCursor,
        GGoalOrder,
        GGoalOrderField,
        GGoalStatus,
        GGoalWhereInput,
        GInterestWhereInput,
        GOrderDirection,
        GSendOTPInput,
        GTagWhereInput,
        GTaskOrder,
        GTaskOrderField,
        GTaskStatus,
        GTaskType,
        GTaskWhereInput,
        GTime,
        GUpdateGoalInput,
        GUpdateProfileInput,
        GUpdateTaskInput,
        GUserOrder,
        GUserOrderField,
        GUserRole,
        GUserStudyTime,
        GUserWhereInput,
        GVerifyOTPAndLoginInput,
        GVerifyOTPAndRegisterInput;
import 'package:simo_learn/graphql/queries/__generated__/get_me.data.gql.dart'
    show GGetMeData, GGetMeData_getMe;
import 'package:simo_learn/graphql/queries/__generated__/get_me.req.gql.dart'
    show GGetMeReq;
import 'package:simo_learn/graphql/queries/__generated__/get_me.var.gql.dart'
    show GGetMeVars;

part 'serializers.gql.g.dart';

final SerializersBuilder _serializersBuilder = _$serializers.toBuilder()
  ..add(OperationSerializer())
  ..addPlugin(StandardJsonPlugin());
@SerializersFor([
  GCreateGoalInput,
  GCreateTaskInput,
  GCursor,
  GGetMeData,
  GGetMeData_getMe,
  GGetMeReq,
  GGetMeVars,
  GGoalOrder,
  GGoalOrderField,
  GGoalStatus,
  GGoalWhereInput,
  GInterestWhereInput,
  GOrderDirection,
  GSendOTPInput,
  GTagWhereInput,
  GTaskOrder,
  GTaskOrderField,
  GTaskStatus,
  GTaskType,
  GTaskWhereInput,
  GTime,
  GUpdateGoalInput,
  GUpdateProfileInput,
  GUpdateTaskInput,
  GUserOrder,
  GUserOrderField,
  GUserRole,
  GUserStudyTime,
  GUserWhereInput,
  GVerifyOTPAndLoginInput,
  GVerifyOTPAndRegisterInput,
])
final Serializers serializers = _serializersBuilder.build();
