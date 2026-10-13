// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i1;

part 'register.data.gql.g.dart';

abstract class GRegisterData
    implements Built<GRegisterData, GRegisterDataBuilder> {
  GRegisterData._();

  factory GRegisterData([void Function(GRegisterDataBuilder b) updates]) =
      _$GRegisterData;

  static void _initializeBuilder(GRegisterDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GRegisterData_register get register;
  static Serializer<GRegisterData> get serializer => _$gRegisterDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GRegisterData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRegisterData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GRegisterData.serializer,
        json,
      );
}

abstract class GRegisterData_register
    implements Built<GRegisterData_register, GRegisterData_registerBuilder> {
  GRegisterData_register._();

  factory GRegisterData_register(
          [void Function(GRegisterData_registerBuilder b) updates]) =
      _$GRegisterData_register;

  static void _initializeBuilder(GRegisterData_registerBuilder b) =>
      b..G__typename = 'AuthPayload';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get accessToken;
  String get refreshToken;
  GRegisterData_register_user get user;
  static Serializer<GRegisterData_register> get serializer =>
      _$gRegisterDataRegisterSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GRegisterData_register.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRegisterData_register? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GRegisterData_register.serializer,
        json,
      );
}

abstract class GRegisterData_register_user
    implements
        Built<GRegisterData_register_user, GRegisterData_register_userBuilder> {
  GRegisterData_register_user._();

  factory GRegisterData_register_user(
          [void Function(GRegisterData_register_userBuilder b) updates]) =
      _$GRegisterData_register_user;

  static void _initializeBuilder(GRegisterData_register_userBuilder b) =>
      b..G__typename = 'User';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  static Serializer<GRegisterData_register_user> get serializer =>
      _$gRegisterDataRegisterUserSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GRegisterData_register_user.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRegisterData_register_user? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GRegisterData_register_user.serializer,
        json,
      );
}
