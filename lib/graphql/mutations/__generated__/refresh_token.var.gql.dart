// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart' as _i1;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i2;

part 'refresh_token.var.gql.g.dart';

abstract class GRefreshTokenVars
    implements Built<GRefreshTokenVars, GRefreshTokenVarsBuilder> {
  GRefreshTokenVars._();

  factory GRefreshTokenVars(
          [void Function(GRefreshTokenVarsBuilder b) updates]) =
      _$GRefreshTokenVars;

  _i1.GRefreshTokenInput get input;
  static Serializer<GRefreshTokenVars> get serializer =>
      _$gRefreshTokenVarsSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GRefreshTokenVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRefreshTokenVars? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GRefreshTokenVars.serializer,
        json,
      );
}
