// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:ferry_exec/ferry_exec.dart' as _i1;
import 'package:gql_exec/gql_exec.dart' as _i4;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i6;
import 'package:simo_learn/graphql/mutations/__generated__/update_goal.ast.gql.dart'
    as _i5;
import 'package:simo_learn/graphql/mutations/__generated__/update_goal.data.gql.dart'
    as _i2;
import 'package:simo_learn/graphql/mutations/__generated__/update_goal.var.gql.dart'
    as _i3;

part 'update_goal.req.gql.g.dart';

abstract class GUpdateGoalReq
    implements
        Built<GUpdateGoalReq, GUpdateGoalReqBuilder>,
        _i1.OperationRequest<_i2.GUpdateGoalData, _i3.GUpdateGoalVars> {
  GUpdateGoalReq._();

  factory GUpdateGoalReq([void Function(GUpdateGoalReqBuilder b) updates]) =
      _$GUpdateGoalReq;

  static void _initializeBuilder(GUpdateGoalReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'UpdateGoal',
    )
    ..executeOnListen = true;

  @override
  _i3.GUpdateGoalVars get vars;
  @override
  _i4.Operation get operation;
  @override
  _i4.Request get execRequest => _i4.Request(
        operation: operation,
        variables: vars.toJson(),
        context: context ?? const _i4.Context(),
      );

  @override
  String? get requestId;
  @override
  @BuiltValueField(serialize: false)
  _i2.GUpdateGoalData? Function(
    _i2.GUpdateGoalData?,
    _i2.GUpdateGoalData?,
  )? get updateResult;
  @override
  _i2.GUpdateGoalData? get optimisticResponse;
  @override
  String? get updateCacheHandlerKey;
  @override
  Map<String, dynamic>? get updateCacheHandlerContext;
  @override
  _i1.FetchPolicy? get fetchPolicy;
  @override
  bool get executeOnListen;
  @override
  @BuiltValueField(serialize: false)
  _i4.Context? get context;
  @override
  _i2.GUpdateGoalData? parseData(Map<String, dynamic> json) =>
      _i2.GUpdateGoalData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GUpdateGoalData data) => data.toJson();

  @override
  _i1.OperationRequest<_i2.GUpdateGoalData, _i3.GUpdateGoalVars>
      transformOperation(_i4.Operation Function(_i4.Operation) transform) =>
          this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GUpdateGoalReq> get serializer =>
      _$gUpdateGoalReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GUpdateGoalReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GUpdateGoalReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GUpdateGoalReq.serializer,
        json,
      );
}
