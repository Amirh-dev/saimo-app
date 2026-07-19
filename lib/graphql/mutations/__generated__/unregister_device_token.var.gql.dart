// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i1;

part 'unregister_device_token.var.gql.g.dart';

abstract class GUnregisterDeviceTokenVars
    implements
        Built<GUnregisterDeviceTokenVars, GUnregisterDeviceTokenVarsBuilder> {
  GUnregisterDeviceTokenVars._();

  factory GUnregisterDeviceTokenVars(
          [Function(GUnregisterDeviceTokenVarsBuilder b) updates]) =
      _$GUnregisterDeviceTokenVars;

  String get token;
  static Serializer<GUnregisterDeviceTokenVars> get serializer =>
      _$gUnregisterDeviceTokenVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GUnregisterDeviceTokenVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GUnregisterDeviceTokenVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GUnregisterDeviceTokenVars.serializer,
        json,
      );
}
