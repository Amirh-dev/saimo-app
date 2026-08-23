// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:ferry_exec/ferry_exec.dart' as _i1;
import 'package:gql_exec/gql_exec.dart' as _i4;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i6;
import 'package:simo_learn/graphql/queries/__generated__/statistics_dashboard.ast.gql.dart'
    as _i5;
import 'package:simo_learn/graphql/queries/__generated__/statistics_dashboard.data.gql.dart'
    as _i2;
import 'package:simo_learn/graphql/queries/__generated__/statistics_dashboard.var.gql.dart'
    as _i3;

part 'statistics_dashboard.req.gql.g.dart';

abstract class GStatisticsDashboardReq
    implements
        Built<GStatisticsDashboardReq, GStatisticsDashboardReqBuilder>,
        _i1.OperationRequest<_i2.GStatisticsDashboardData,
            _i3.GStatisticsDashboardVars> {
  GStatisticsDashboardReq._();

  factory GStatisticsDashboardReq(
          [void Function(GStatisticsDashboardReqBuilder b) updates]) =
      _$GStatisticsDashboardReq;

  static void _initializeBuilder(GStatisticsDashboardReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'StatisticsDashboard',
    )
    ..executeOnListen = true;

  @override
  _i3.GStatisticsDashboardVars get vars;
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
  _i2.GStatisticsDashboardData? Function(
    _i2.GStatisticsDashboardData?,
    _i2.GStatisticsDashboardData?,
  )? get updateResult;
  @override
  _i2.GStatisticsDashboardData? get optimisticResponse;
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
  _i2.GStatisticsDashboardData? parseData(Map<String, dynamic> json) =>
      _i2.GStatisticsDashboardData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GStatisticsDashboardData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GStatisticsDashboardData,
      _i3.GStatisticsDashboardVars> transformOperation(
          _i4.Operation Function(_i4.Operation) transform) =>
      this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GStatisticsDashboardReq> get serializer =>
      _$gStatisticsDashboardReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GStatisticsDashboardReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GStatisticsDashboardReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GStatisticsDashboardReq.serializer,
        json,
      );
}
