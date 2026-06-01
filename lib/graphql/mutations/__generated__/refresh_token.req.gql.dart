// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:ferry_exec/ferry_exec.dart' as _i1;
import 'package:gql_exec/gql_exec.dart' as _i4;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i6;
import 'package:simo_learn/graphql/mutations/__generated__/refresh_token.ast.gql.dart'
    as _i5;
import 'package:simo_learn/graphql/mutations/__generated__/refresh_token.data.gql.dart'
    as _i2;
import 'package:simo_learn/graphql/mutations/__generated__/refresh_token.var.gql.dart'
    as _i3;

part 'refresh_token.req.gql.g.dart';

abstract class GRefreshTokenReq
    implements
        Built<GRefreshTokenReq, GRefreshTokenReqBuilder>,
        _i1.OperationRequest<_i2.GRefreshTokenData, _i3.GRefreshTokenVars> {
  GRefreshTokenReq._();

  factory GRefreshTokenReq([Function(GRefreshTokenReqBuilder b) updates]) =
      _$GRefreshTokenReq;

  static void _initializeBuilder(GRefreshTokenReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'RefreshToken',
    )
    ..executeOnListen = true;

  @override
  _i3.GRefreshTokenVars get vars;
  @override
  _i4.Operation get operation;
  @override
  _i4.Request get execRequest => _i4.Request(
        operation: operation,
        variables: vars.toJson(),
      );

  @override
  String? get requestId;
  @override
  @BuiltValueField(serialize: false)
  _i2.GRefreshTokenData? Function(
    _i2.GRefreshTokenData?,
    _i2.GRefreshTokenData?,
  )? get updateResult;
  @override
  _i2.GRefreshTokenData? get optimisticResponse;
  @override
  String? get updateCacheHandlerKey;
  @override
  Map<String, dynamic>? get updateCacheHandlerContext;
  @override
  _i1.FetchPolicy? get fetchPolicy;
  @override
  bool get executeOnListen;
  @override
  _i2.GRefreshTokenData? parseData(Map<String, dynamic> json) =>
      _i2.GRefreshTokenData.fromJson(json);

  static Serializer<GRefreshTokenReq> get serializer =>
      _$gRefreshTokenReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GRefreshTokenReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRefreshTokenReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GRefreshTokenReq.serializer,
        json,
      );
}
