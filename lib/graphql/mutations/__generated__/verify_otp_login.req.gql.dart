// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:ferry_exec/ferry_exec.dart' as _i1;
import 'package:gql_exec/gql_exec.dart' as _i4;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i6;
import 'package:simo_learn/graphql/mutations/__generated__/verify_otp_login.ast.gql.dart'
    as _i5;
import 'package:simo_learn/graphql/mutations/__generated__/verify_otp_login.data.gql.dart'
    as _i2;
import 'package:simo_learn/graphql/mutations/__generated__/verify_otp_login.var.gql.dart'
    as _i3;

part 'verify_otp_login.req.gql.g.dart';

abstract class GVerifyOTPAndLoginReq
    implements
        Built<GVerifyOTPAndLoginReq, GVerifyOTPAndLoginReqBuilder>,
        _i1.OperationRequest<_i2.GVerifyOTPAndLoginData,
            _i3.GVerifyOTPAndLoginVars> {
  GVerifyOTPAndLoginReq._();

  factory GVerifyOTPAndLoginReq(
          [Function(GVerifyOTPAndLoginReqBuilder b) updates]) =
      _$GVerifyOTPAndLoginReq;

  static void _initializeBuilder(GVerifyOTPAndLoginReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'VerifyOTPAndLogin',
    )
    ..executeOnListen = true;

  @override
  _i3.GVerifyOTPAndLoginVars get vars;
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
  _i2.GVerifyOTPAndLoginData? Function(
    _i2.GVerifyOTPAndLoginData?,
    _i2.GVerifyOTPAndLoginData?,
  )? get updateResult;
  @override
  _i2.GVerifyOTPAndLoginData? get optimisticResponse;
  @override
  String? get updateCacheHandlerKey;
  @override
  Map<String, dynamic>? get updateCacheHandlerContext;
  @override
  _i1.FetchPolicy? get fetchPolicy;
  @override
  bool get executeOnListen;
  @override
  _i2.GVerifyOTPAndLoginData? parseData(Map<String, dynamic> json) =>
      _i2.GVerifyOTPAndLoginData.fromJson(json);

  static Serializer<GVerifyOTPAndLoginReq> get serializer =>
      _$gVerifyOTPAndLoginReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GVerifyOTPAndLoginReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GVerifyOTPAndLoginReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GVerifyOTPAndLoginReq.serializer,
        json,
      );
}
