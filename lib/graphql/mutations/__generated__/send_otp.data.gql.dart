// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i1;

part 'send_otp.data.gql.g.dart';

abstract class GSendOTPData
    implements Built<GSendOTPData, GSendOTPDataBuilder> {
  GSendOTPData._();

  factory GSendOTPData([void Function(GSendOTPDataBuilder b) updates]) =
      _$GSendOTPData;

  static void _initializeBuilder(GSendOTPDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GSendOTPData_sendOTP get sendOTP;
  static Serializer<GSendOTPData> get serializer => _$gSendOTPDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GSendOTPData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSendOTPData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GSendOTPData.serializer,
        json,
      );
}

abstract class GSendOTPData_sendOTP
    implements Built<GSendOTPData_sendOTP, GSendOTPData_sendOTPBuilder> {
  GSendOTPData_sendOTP._();

  factory GSendOTPData_sendOTP(
          [void Function(GSendOTPData_sendOTPBuilder b) updates]) =
      _$GSendOTPData_sendOTP;

  static void _initializeBuilder(GSendOTPData_sendOTPBuilder b) =>
      b..G__typename = 'SendOTPPayload';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  bool get success;
  String get message;
  int get expiresInSeconds;
  bool get isRegistered;
  static Serializer<GSendOTPData_sendOTP> get serializer =>
      _$gSendOTPDataSendOTPSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GSendOTPData_sendOTP.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSendOTPData_sendOTP? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GSendOTPData_sendOTP.serializer,
        json,
      );
}
