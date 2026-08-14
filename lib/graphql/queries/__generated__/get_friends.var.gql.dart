// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i1;

part 'get_friends.var.gql.g.dart';

abstract class GGetFriendsVars
    implements Built<GGetFriendsVars, GGetFriendsVarsBuilder> {
  GGetFriendsVars._();

  factory GGetFriendsVars([void Function(GGetFriendsVarsBuilder b) updates]) =
      _$GGetFriendsVars;

  int? get limit;
  int? get offset;
  static Serializer<GGetFriendsVars> get serializer =>
      _$gGetFriendsVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GGetFriendsVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GGetFriendsVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GGetFriendsVars.serializer,
        json,
      );
}
