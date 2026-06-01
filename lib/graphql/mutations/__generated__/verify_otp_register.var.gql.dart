// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart' as _i1;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i2;

part 'verify_otp_register.var.gql.g.dart';

abstract class GVerifyOTPAndRegisterVars
    implements
        Built<GVerifyOTPAndRegisterVars, GVerifyOTPAndRegisterVarsBuilder> {
  GVerifyOTPAndRegisterVars._();

  factory GVerifyOTPAndRegisterVars(
          [Function(GVerifyOTPAndRegisterVarsBuilder b) updates]) =
      _$GVerifyOTPAndRegisterVars;

  _i1.GVerifyOTPAndRegisterInput get input;
  static Serializer<GVerifyOTPAndRegisterVars> get serializer =>
      _$gVerifyOTPAndRegisterVarsSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GVerifyOTPAndRegisterVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GVerifyOTPAndRegisterVars? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GVerifyOTPAndRegisterVars.serializer,
        json,
      );
}
