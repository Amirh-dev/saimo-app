// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i1;

part 'verify_otp_register.data.gql.g.dart';

abstract class GVerifyOTPAndRegisterData
    implements
        Built<GVerifyOTPAndRegisterData, GVerifyOTPAndRegisterDataBuilder> {
  GVerifyOTPAndRegisterData._();

  factory GVerifyOTPAndRegisterData(
          [Function(GVerifyOTPAndRegisterDataBuilder b) updates]) =
      _$GVerifyOTPAndRegisterData;

  static void _initializeBuilder(GVerifyOTPAndRegisterDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GVerifyOTPAndRegisterData_verifyOTPAndRegister get verifyOTPAndRegister;
  static Serializer<GVerifyOTPAndRegisterData> get serializer =>
      _$gVerifyOTPAndRegisterDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GVerifyOTPAndRegisterData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GVerifyOTPAndRegisterData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GVerifyOTPAndRegisterData.serializer,
        json,
      );
}

abstract class GVerifyOTPAndRegisterData_verifyOTPAndRegister
    implements
        Built<GVerifyOTPAndRegisterData_verifyOTPAndRegister,
            GVerifyOTPAndRegisterData_verifyOTPAndRegisterBuilder> {
  GVerifyOTPAndRegisterData_verifyOTPAndRegister._();

  factory GVerifyOTPAndRegisterData_verifyOTPAndRegister(
      [Function(GVerifyOTPAndRegisterData_verifyOTPAndRegisterBuilder b)
          updates]) = _$GVerifyOTPAndRegisterData_verifyOTPAndRegister;

  static void _initializeBuilder(
          GVerifyOTPAndRegisterData_verifyOTPAndRegisterBuilder b) =>
      b..G__typename = 'AuthPayload';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get accessToken;
  GVerifyOTPAndRegisterData_verifyOTPAndRegister_user get user;
  static Serializer<GVerifyOTPAndRegisterData_verifyOTPAndRegister>
      get serializer =>
          _$gVerifyOTPAndRegisterDataVerifyOTPAndRegisterSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GVerifyOTPAndRegisterData_verifyOTPAndRegister.serializer,
        this,
      ) as Map<String, dynamic>);

  static GVerifyOTPAndRegisterData_verifyOTPAndRegister? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GVerifyOTPAndRegisterData_verifyOTPAndRegister.serializer,
        json,
      );
}

abstract class GVerifyOTPAndRegisterData_verifyOTPAndRegister_user
    implements
        Built<GVerifyOTPAndRegisterData_verifyOTPAndRegister_user,
            GVerifyOTPAndRegisterData_verifyOTPAndRegister_userBuilder> {
  GVerifyOTPAndRegisterData_verifyOTPAndRegister_user._();

  factory GVerifyOTPAndRegisterData_verifyOTPAndRegister_user(
      [Function(GVerifyOTPAndRegisterData_verifyOTPAndRegister_userBuilder b)
          updates]) = _$GVerifyOTPAndRegisterData_verifyOTPAndRegister_user;

  static void _initializeBuilder(
          GVerifyOTPAndRegisterData_verifyOTPAndRegister_userBuilder b) =>
      b..G__typename = 'User';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  static Serializer<GVerifyOTPAndRegisterData_verifyOTPAndRegister_user>
      get serializer =>
          _$gVerifyOTPAndRegisterDataVerifyOTPAndRegisterUserSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GVerifyOTPAndRegisterData_verifyOTPAndRegister_user.serializer,
        this,
      ) as Map<String, dynamic>);

  static GVerifyOTPAndRegisterData_verifyOTPAndRegister_user? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GVerifyOTPAndRegisterData_verifyOTPAndRegister_user.serializer,
        json,
      );
}
