// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart' as _i1;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i2;

part 'verify_otp_for_registration.var.gql.g.dart';

abstract class GVerifyOTPForRegistrationVars
    implements
        Built<GVerifyOTPForRegistrationVars,
            GVerifyOTPForRegistrationVarsBuilder> {
  GVerifyOTPForRegistrationVars._();

  factory GVerifyOTPForRegistrationVars(
          [void Function(GVerifyOTPForRegistrationVarsBuilder b) updates]) =
      _$GVerifyOTPForRegistrationVars;

  _i1.GVerifyOTPInput get input;
  static Serializer<GVerifyOTPForRegistrationVars> get serializer =>
      _$gVerifyOTPForRegistrationVarsSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GVerifyOTPForRegistrationVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GVerifyOTPForRegistrationVars? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GVerifyOTPForRegistrationVars.serializer,
        json,
      );
}
