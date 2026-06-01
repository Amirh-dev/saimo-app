// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:ferry_exec/ferry_exec.dart' as _i1;
import 'package:gql_exec/gql_exec.dart' as _i4;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i6;
import 'package:simo_learn/graphql/mutations/__generated__/verify_otp_register.ast.gql.dart'
    as _i5;
import 'package:simo_learn/graphql/mutations/__generated__/verify_otp_register.data.gql.dart'
    as _i2;
import 'package:simo_learn/graphql/mutations/__generated__/verify_otp_register.var.gql.dart'
    as _i3;

part 'verify_otp_register.req.gql.g.dart';

abstract class GVerifyOTPAndRegisterReq
    implements
        Built<GVerifyOTPAndRegisterReq, GVerifyOTPAndRegisterReqBuilder>,
        _i1.OperationRequest<_i2.GVerifyOTPAndRegisterData,
            _i3.GVerifyOTPAndRegisterVars> {
  GVerifyOTPAndRegisterReq._();

  factory GVerifyOTPAndRegisterReq(
          [Function(GVerifyOTPAndRegisterReqBuilder b) updates]) =
      _$GVerifyOTPAndRegisterReq;

  static void _initializeBuilder(GVerifyOTPAndRegisterReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'VerifyOTPAndRegister',
    )
    ..executeOnListen = true;

  @override
  _i3.GVerifyOTPAndRegisterVars get vars;
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
  _i2.GVerifyOTPAndRegisterData? Function(
    _i2.GVerifyOTPAndRegisterData?,
    _i2.GVerifyOTPAndRegisterData?,
  )? get updateResult;
  @override
  _i2.GVerifyOTPAndRegisterData? get optimisticResponse;
  @override
  String? get updateCacheHandlerKey;
  @override
  Map<String, dynamic>? get updateCacheHandlerContext;
  @override
  _i1.FetchPolicy? get fetchPolicy;
  @override
  bool get executeOnListen;
  @override
  _i2.GVerifyOTPAndRegisterData? parseData(Map<String, dynamic> json) =>
      _i2.GVerifyOTPAndRegisterData.fromJson(json);

  static Serializer<GVerifyOTPAndRegisterReq> get serializer =>
      _$gVerifyOTPAndRegisterReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GVerifyOTPAndRegisterReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GVerifyOTPAndRegisterReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GVerifyOTPAndRegisterReq.serializer,
        json,
      );
}
