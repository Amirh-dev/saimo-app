// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i1;

part 'get_me.data.gql.g.dart';

abstract class GGetMeData implements Built<GGetMeData, GGetMeDataBuilder> {
  GGetMeData._();

  factory GGetMeData([Function(GGetMeDataBuilder b) updates]) = _$GGetMeData;

  static void _initializeBuilder(GGetMeDataBuilder b) =>
      b..G__typename = 'Query';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GGetMeData_getMe get getMe;
  static Serializer<GGetMeData> get serializer => _$gGetMeDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GGetMeData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GGetMeData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GGetMeData.serializer,
        json,
      );
}

abstract class GGetMeData_getMe
    implements Built<GGetMeData_getMe, GGetMeData_getMeBuilder> {
  GGetMeData_getMe._();

  factory GGetMeData_getMe([Function(GGetMeData_getMeBuilder b) updates]) =
      _$GGetMeData_getMe;

  static void _initializeBuilder(GGetMeData_getMeBuilder b) =>
      b..G__typename = 'User';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  static Serializer<GGetMeData_getMe> get serializer =>
      _$gGetMeDataGetMeSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GGetMeData_getMe.serializer,
        this,
      ) as Map<String, dynamic>);

  static GGetMeData_getMe? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GGetMeData_getMe.serializer,
        json,
      );
}
