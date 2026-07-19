// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i1;

part 'register_device_token.data.gql.g.dart';

abstract class GRegisterDeviceTokenData
    implements
        Built<GRegisterDeviceTokenData, GRegisterDeviceTokenDataBuilder> {
  GRegisterDeviceTokenData._();

  factory GRegisterDeviceTokenData(
          [Function(GRegisterDeviceTokenDataBuilder b) updates]) =
      _$GRegisterDeviceTokenData;

  static void _initializeBuilder(GRegisterDeviceTokenDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  bool get registerDeviceToken;
  static Serializer<GRegisterDeviceTokenData> get serializer =>
      _$gRegisterDeviceTokenDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GRegisterDeviceTokenData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRegisterDeviceTokenData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GRegisterDeviceTokenData.serializer,
        json,
      );
}
