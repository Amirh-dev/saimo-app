// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:ferry_exec/ferry_exec.dart' as _i1;
import 'package:gql_exec/gql_exec.dart' as _i4;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i6;
import 'package:simo_learn/graphql/queries/__generated__/get_me.ast.gql.dart'
    as _i5;
import 'package:simo_learn/graphql/queries/__generated__/get_me.data.gql.dart'
    as _i2;
import 'package:simo_learn/graphql/queries/__generated__/get_me.var.gql.dart'
    as _i3;

part 'get_me.req.gql.g.dart';

abstract class GGetMeReq
    implements
        Built<GGetMeReq, GGetMeReqBuilder>,
        _i1.OperationRequest<_i2.GGetMeData, _i3.GGetMeVars> {
  GGetMeReq._();

  factory GGetMeReq([void Function(GGetMeReqBuilder b) updates]) = _$GGetMeReq;

  static void _initializeBuilder(GGetMeReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'GetMe',
    )
    ..executeOnListen = true;

  @override
  _i3.GGetMeVars get vars;
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
  _i2.GGetMeData? Function(
    _i2.GGetMeData?,
    _i2.GGetMeData?,
  )? get updateResult;
  @override
  _i2.GGetMeData? get optimisticResponse;
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
  _i2.GGetMeData? parseData(Map<String, dynamic> json) =>
      _i2.GGetMeData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GGetMeData data) => data.toJson();

  @override
  _i1.OperationRequest<_i2.GGetMeData, _i3.GGetMeVars> transformOperation(
          _i4.Operation Function(_i4.Operation) transform) =>
      this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GGetMeReq> get serializer => _$gGetMeReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GGetMeReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GGetMeReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GGetMeReq.serializer,
        json,
      );
}
