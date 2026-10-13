// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:ferry_exec/ferry_exec.dart' as _i1;
import 'package:gql_exec/gql_exec.dart' as _i4;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i6;
import 'package:simo_learn/graphql/mutations/__generated__/verify_otp_for_registration.ast.gql.dart'
    as _i5;
import 'package:simo_learn/graphql/mutations/__generated__/verify_otp_for_registration.data.gql.dart'
    as _i2;
import 'package:simo_learn/graphql/mutations/__generated__/verify_otp_for_registration.var.gql.dart'
    as _i3;

part 'verify_otp_for_registration.req.gql.g.dart';

abstract class GVerifyOTPForRegistrationReq
    implements
        Built<GVerifyOTPForRegistrationReq,
            GVerifyOTPForRegistrationReqBuilder>,
        _i1.OperationRequest<_i2.GVerifyOTPForRegistrationData,
            _i3.GVerifyOTPForRegistrationVars> {
  GVerifyOTPForRegistrationReq._();

  factory GVerifyOTPForRegistrationReq(
          [void Function(GVerifyOTPForRegistrationReqBuilder b) updates]) =
      _$GVerifyOTPForRegistrationReq;

  static void _initializeBuilder(GVerifyOTPForRegistrationReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'VerifyOTPForRegistration',
    )
    ..executeOnListen = true;

  @override
  _i3.GVerifyOTPForRegistrationVars get vars;
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
  _i2.GVerifyOTPForRegistrationData? Function(
    _i2.GVerifyOTPForRegistrationData?,
    _i2.GVerifyOTPForRegistrationData?,
  )? get updateResult;
  @override
  _i2.GVerifyOTPForRegistrationData? get optimisticResponse;
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
  _i2.GVerifyOTPForRegistrationData? parseData(Map<String, dynamic> json) =>
      _i2.GVerifyOTPForRegistrationData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GVerifyOTPForRegistrationData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GVerifyOTPForRegistrationData,
      _i3.GVerifyOTPForRegistrationVars> transformOperation(
          _i4.Operation Function(_i4.Operation) transform) =>
      this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GVerifyOTPForRegistrationReq> get serializer =>
      _$gVerifyOTPForRegistrationReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GVerifyOTPForRegistrationReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GVerifyOTPForRegistrationReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GVerifyOTPForRegistrationReq.serializer,
        json,
      );
}
