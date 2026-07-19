// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:ferry_exec/ferry_exec.dart' as _i1;
import 'package:gql_exec/gql_exec.dart' as _i4;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i6;
import 'package:simo_learn/graphql/mutations/__generated__/unregister_device_token.ast.gql.dart'
    as _i5;
import 'package:simo_learn/graphql/mutations/__generated__/unregister_device_token.data.gql.dart'
    as _i2;
import 'package:simo_learn/graphql/mutations/__generated__/unregister_device_token.var.gql.dart'
    as _i3;

part 'unregister_device_token.req.gql.g.dart';

abstract class GUnregisterDeviceTokenReq
    implements
        Built<GUnregisterDeviceTokenReq, GUnregisterDeviceTokenReqBuilder>,
        _i1.OperationRequest<_i2.GUnregisterDeviceTokenData,
            _i3.GUnregisterDeviceTokenVars> {
  GUnregisterDeviceTokenReq._();

  factory GUnregisterDeviceTokenReq(
          [Function(GUnregisterDeviceTokenReqBuilder b) updates]) =
      _$GUnregisterDeviceTokenReq;

  static void _initializeBuilder(GUnregisterDeviceTokenReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'UnregisterDeviceToken',
    )
    ..executeOnListen = true;

  @override
  _i3.GUnregisterDeviceTokenVars get vars;
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
  _i2.GUnregisterDeviceTokenData? Function(
    _i2.GUnregisterDeviceTokenData?,
    _i2.GUnregisterDeviceTokenData?,
  )? get updateResult;
  @override
  _i2.GUnregisterDeviceTokenData? get optimisticResponse;
  @override
  String? get updateCacheHandlerKey;
  @override
  Map<String, dynamic>? get updateCacheHandlerContext;
  @override
  _i1.FetchPolicy? get fetchPolicy;
  @override
  bool get executeOnListen;
  @override
  _i2.GUnregisterDeviceTokenData? parseData(Map<String, dynamic> json) =>
      _i2.GUnregisterDeviceTokenData.fromJson(json);

  static Serializer<GUnregisterDeviceTokenReq> get serializer =>
      _$gUnregisterDeviceTokenReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GUnregisterDeviceTokenReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GUnregisterDeviceTokenReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GUnregisterDeviceTokenReq.serializer,
        json,
      );
}
