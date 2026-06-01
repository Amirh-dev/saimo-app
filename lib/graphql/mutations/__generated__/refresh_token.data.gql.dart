// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i1;

part 'refresh_token.data.gql.g.dart';

abstract class GRefreshTokenData
    implements Built<GRefreshTokenData, GRefreshTokenDataBuilder> {
  GRefreshTokenData._();

  factory GRefreshTokenData([Function(GRefreshTokenDataBuilder b) updates]) =
      _$GRefreshTokenData;

  static void _initializeBuilder(GRefreshTokenDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GRefreshTokenData_refreshToken get refreshToken;
  static Serializer<GRefreshTokenData> get serializer =>
      _$gRefreshTokenDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GRefreshTokenData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRefreshTokenData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GRefreshTokenData.serializer,
        json,
      );
}

abstract class GRefreshTokenData_refreshToken
    implements
        Built<GRefreshTokenData_refreshToken,
            GRefreshTokenData_refreshTokenBuilder> {
  GRefreshTokenData_refreshToken._();

  factory GRefreshTokenData_refreshToken(
          [Function(GRefreshTokenData_refreshTokenBuilder b) updates]) =
      _$GRefreshTokenData_refreshToken;

  static void _initializeBuilder(GRefreshTokenData_refreshTokenBuilder b) =>
      b..G__typename = 'AuthPayload';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get accessToken;
  GRefreshTokenData_refreshToken_user get user;
  static Serializer<GRefreshTokenData_refreshToken> get serializer =>
      _$gRefreshTokenDataRefreshTokenSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GRefreshTokenData_refreshToken.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRefreshTokenData_refreshToken? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GRefreshTokenData_refreshToken.serializer,
        json,
      );
}

abstract class GRefreshTokenData_refreshToken_user
    implements
        Built<GRefreshTokenData_refreshToken_user,
            GRefreshTokenData_refreshToken_userBuilder> {
  GRefreshTokenData_refreshToken_user._();

  factory GRefreshTokenData_refreshToken_user(
          [Function(GRefreshTokenData_refreshToken_userBuilder b) updates]) =
      _$GRefreshTokenData_refreshToken_user;

  static void _initializeBuilder(
          GRefreshTokenData_refreshToken_userBuilder b) =>
      b..G__typename = 'User';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  static Serializer<GRefreshTokenData_refreshToken_user> get serializer =>
      _$gRefreshTokenDataRefreshTokenUserSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GRefreshTokenData_refreshToken_user.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRefreshTokenData_refreshToken_user? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GRefreshTokenData_refreshToken_user.serializer,
        json,
      );
}
