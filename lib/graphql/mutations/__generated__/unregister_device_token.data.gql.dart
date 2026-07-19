// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i1;

part 'unregister_device_token.data.gql.g.dart';

abstract class GUnregisterDeviceTokenData
    implements
        Built<GUnregisterDeviceTokenData, GUnregisterDeviceTokenDataBuilder> {
  GUnregisterDeviceTokenData._();

  factory GUnregisterDeviceTokenData(
          [Function(GUnregisterDeviceTokenDataBuilder b) updates]) =
      _$GUnregisterDeviceTokenData;

  static void _initializeBuilder(GUnregisterDeviceTokenDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  bool get unregisterDeviceToken;
  static Serializer<GUnregisterDeviceTokenData> get serializer =>
      _$gUnregisterDeviceTokenDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GUnregisterDeviceTokenData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GUnregisterDeviceTokenData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GUnregisterDeviceTokenData.serializer,
        json,
      );
}
