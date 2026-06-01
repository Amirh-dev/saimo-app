// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:ferry_exec/ferry_exec.dart' as _i1;
import 'package:gql_exec/gql_exec.dart' as _i4;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i6;
import 'package:simo_learn/graphql/mutations/__generated__/send_otp.ast.gql.dart'
    as _i5;
import 'package:simo_learn/graphql/mutations/__generated__/send_otp.data.gql.dart'
    as _i2;
import 'package:simo_learn/graphql/mutations/__generated__/send_otp.var.gql.dart'
    as _i3;

part 'send_otp.req.gql.g.dart';

abstract class GSendOTPReq
    implements
        Built<GSendOTPReq, GSendOTPReqBuilder>,
        _i1.OperationRequest<_i2.GSendOTPData, _i3.GSendOTPVars> {
  GSendOTPReq._();

  factory GSendOTPReq([Function(GSendOTPReqBuilder b) updates]) = _$GSendOTPReq;

  static void _initializeBuilder(GSendOTPReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'SendOTP',
    )
    ..executeOnListen = true;

  @override
  _i3.GSendOTPVars get vars;
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
  _i2.GSendOTPData? Function(
    _i2.GSendOTPData?,
    _i2.GSendOTPData?,
  )? get updateResult;
  @override
  _i2.GSendOTPData? get optimisticResponse;
  @override
  String? get updateCacheHandlerKey;
  @override
  Map<String, dynamic>? get updateCacheHandlerContext;
  @override
  _i1.FetchPolicy? get fetchPolicy;
  @override
  bool get executeOnListen;
  @override
  _i2.GSendOTPData? parseData(Map<String, dynamic> json) =>
      _i2.GSendOTPData.fromJson(json);

  static Serializer<GSendOTPReq> get serializer => _$gSendOTPReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GSendOTPReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSendOTPReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GSendOTPReq.serializer,
        json,
      );
}
