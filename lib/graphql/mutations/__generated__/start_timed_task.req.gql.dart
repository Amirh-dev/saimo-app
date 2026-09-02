// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:ferry_exec/ferry_exec.dart' as _i1;
import 'package:gql_exec/gql_exec.dart' as _i4;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i6;
import 'package:simo_learn/graphql/mutations/__generated__/start_timed_task.ast.gql.dart'
    as _i5;
import 'package:simo_learn/graphql/mutations/__generated__/start_timed_task.data.gql.dart'
    as _i2;
import 'package:simo_learn/graphql/mutations/__generated__/start_timed_task.var.gql.dart'
    as _i3;

part 'start_timed_task.req.gql.g.dart';

abstract class GStartTimedTaskReq
    implements
        Built<GStartTimedTaskReq, GStartTimedTaskReqBuilder>,
        _i1.OperationRequest<_i2.GStartTimedTaskData, _i3.GStartTimedTaskVars> {
  GStartTimedTaskReq._();

  factory GStartTimedTaskReq(
          [void Function(GStartTimedTaskReqBuilder b) updates]) =
      _$GStartTimedTaskReq;

  static void _initializeBuilder(GStartTimedTaskReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'StartTimedTask',
    )
    ..executeOnListen = true;

  @override
  _i3.GStartTimedTaskVars get vars;
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
  _i2.GStartTimedTaskData? Function(
    _i2.GStartTimedTaskData?,
    _i2.GStartTimedTaskData?,
  )? get updateResult;
  @override
  _i2.GStartTimedTaskData? get optimisticResponse;
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
  _i2.GStartTimedTaskData? parseData(Map<String, dynamic> json) =>
      _i2.GStartTimedTaskData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GStartTimedTaskData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GStartTimedTaskData, _i3.GStartTimedTaskVars>
      transformOperation(_i4.Operation Function(_i4.Operation) transform) =>
          this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GStartTimedTaskReq> get serializer =>
      _$gStartTimedTaskReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GStartTimedTaskReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GStartTimedTaskReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GStartTimedTaskReq.serializer,
        json,
      );
}
