// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i1;

part 'verify_otp_for_registration.data.gql.g.dart';

abstract class GVerifyOTPForRegistrationData
    implements
        Built<GVerifyOTPForRegistrationData,
            GVerifyOTPForRegistrationDataBuilder> {
  GVerifyOTPForRegistrationData._();

  factory GVerifyOTPForRegistrationData(
          [void Function(GVerifyOTPForRegistrationDataBuilder b) updates]) =
      _$GVerifyOTPForRegistrationData;

  static void _initializeBuilder(GVerifyOTPForRegistrationDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GVerifyOTPForRegistrationData_verifyOTPForRegistration
      get verifyOTPForRegistration;
  static Serializer<GVerifyOTPForRegistrationData> get serializer =>
      _$gVerifyOTPForRegistrationDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GVerifyOTPForRegistrationData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GVerifyOTPForRegistrationData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GVerifyOTPForRegistrationData.serializer,
        json,
      );
}

abstract class GVerifyOTPForRegistrationData_verifyOTPForRegistration
    implements
        Built<GVerifyOTPForRegistrationData_verifyOTPForRegistration,
            GVerifyOTPForRegistrationData_verifyOTPForRegistrationBuilder> {
  GVerifyOTPForRegistrationData_verifyOTPForRegistration._();

  factory GVerifyOTPForRegistrationData_verifyOTPForRegistration(
      [void Function(
              GVerifyOTPForRegistrationData_verifyOTPForRegistrationBuilder b)
          updates]) = _$GVerifyOTPForRegistrationData_verifyOTPForRegistration;

  static void _initializeBuilder(
          GVerifyOTPForRegistrationData_verifyOTPForRegistrationBuilder b) =>
      b..G__typename = 'RegistrationVerificationPayload';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get registrationToken;
  int get expiresInSeconds;
  static Serializer<GVerifyOTPForRegistrationData_verifyOTPForRegistration>
      get serializer =>
          _$gVerifyOTPForRegistrationDataVerifyOTPForRegistrationSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GVerifyOTPForRegistrationData_verifyOTPForRegistration.serializer,
        this,
      ) as Map<String, dynamic>);

  static GVerifyOTPForRegistrationData_verifyOTPForRegistration? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GVerifyOTPForRegistrationData_verifyOTPForRegistration.serializer,
        json,
      );
}
