// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i1;

part 'verify_otp_login.data.gql.g.dart';

abstract class GVerifyOTPAndLoginData
    implements Built<GVerifyOTPAndLoginData, GVerifyOTPAndLoginDataBuilder> {
  GVerifyOTPAndLoginData._();

  factory GVerifyOTPAndLoginData(
          [Function(GVerifyOTPAndLoginDataBuilder b) updates]) =
      _$GVerifyOTPAndLoginData;

  static void _initializeBuilder(GVerifyOTPAndLoginDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GVerifyOTPAndLoginData_verifyOTPAndLogin get verifyOTPAndLogin;
  static Serializer<GVerifyOTPAndLoginData> get serializer =>
      _$gVerifyOTPAndLoginDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GVerifyOTPAndLoginData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GVerifyOTPAndLoginData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GVerifyOTPAndLoginData.serializer,
        json,
      );
}

abstract class GVerifyOTPAndLoginData_verifyOTPAndLogin
    implements
        Built<GVerifyOTPAndLoginData_verifyOTPAndLogin,
            GVerifyOTPAndLoginData_verifyOTPAndLoginBuilder> {
  GVerifyOTPAndLoginData_verifyOTPAndLogin._();

  factory GVerifyOTPAndLoginData_verifyOTPAndLogin(
      [Function(GVerifyOTPAndLoginData_verifyOTPAndLoginBuilder b)
          updates]) = _$GVerifyOTPAndLoginData_verifyOTPAndLogin;

  static void _initializeBuilder(
          GVerifyOTPAndLoginData_verifyOTPAndLoginBuilder b) =>
      b..G__typename = 'AuthPayload';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get accessToken;
  String get refreshToken;
  GVerifyOTPAndLoginData_verifyOTPAndLogin_user get user;
  static Serializer<GVerifyOTPAndLoginData_verifyOTPAndLogin> get serializer =>
      _$gVerifyOTPAndLoginDataVerifyOTPAndLoginSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GVerifyOTPAndLoginData_verifyOTPAndLogin.serializer,
        this,
      ) as Map<String, dynamic>);

  static GVerifyOTPAndLoginData_verifyOTPAndLogin? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GVerifyOTPAndLoginData_verifyOTPAndLogin.serializer,
        json,
      );
}

abstract class GVerifyOTPAndLoginData_verifyOTPAndLogin_user
    implements
        Built<GVerifyOTPAndLoginData_verifyOTPAndLogin_user,
            GVerifyOTPAndLoginData_verifyOTPAndLogin_userBuilder> {
  GVerifyOTPAndLoginData_verifyOTPAndLogin_user._();

  factory GVerifyOTPAndLoginData_verifyOTPAndLogin_user(
      [Function(GVerifyOTPAndLoginData_verifyOTPAndLogin_userBuilder b)
          updates]) = _$GVerifyOTPAndLoginData_verifyOTPAndLogin_user;

  static void _initializeBuilder(
          GVerifyOTPAndLoginData_verifyOTPAndLogin_userBuilder b) =>
      b..G__typename = 'User';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  static Serializer<GVerifyOTPAndLoginData_verifyOTPAndLogin_user>
      get serializer => _$gVerifyOTPAndLoginDataVerifyOTPAndLoginUserSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GVerifyOTPAndLoginData_verifyOTPAndLogin_user.serializer,
        this,
      ) as Map<String, dynamic>);

  static GVerifyOTPAndLoginData_verifyOTPAndLogin_user? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GVerifyOTPAndLoginData_verifyOTPAndLogin_user.serializer,
        json,
      );
}
