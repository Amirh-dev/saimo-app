// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart' as _i1;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i2;

part 'register_device_token.var.gql.g.dart';

abstract class GRegisterDeviceTokenVars
    implements
        Built<GRegisterDeviceTokenVars, GRegisterDeviceTokenVarsBuilder> {
  GRegisterDeviceTokenVars._();

  factory GRegisterDeviceTokenVars(
          [Function(GRegisterDeviceTokenVarsBuilder b) updates]) =
      _$GRegisterDeviceTokenVars;

  String get token;
  _i1.GDeviceTokenPlatform get platform;
  static Serializer<GRegisterDeviceTokenVars> get serializer =>
      _$gRegisterDeviceTokenVarsSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GRegisterDeviceTokenVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRegisterDeviceTokenVars? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GRegisterDeviceTokenVars.serializer,
        json,
      );
}
