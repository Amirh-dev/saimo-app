// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart' as _i1;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i2;

part 'create_direct_chat.var.gql.g.dart';

abstract class GCreateDirectChatVars
    implements Built<GCreateDirectChatVars, GCreateDirectChatVarsBuilder> {
  GCreateDirectChatVars._();

  factory GCreateDirectChatVars(
          [void Function(GCreateDirectChatVarsBuilder b) updates]) =
      _$GCreateDirectChatVars;

  _i1.GCreateDirectChatInput get input;
  static Serializer<GCreateDirectChatVars> get serializer =>
      _$gCreateDirectChatVarsSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GCreateDirectChatVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GCreateDirectChatVars? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GCreateDirectChatVars.serializer,
        json,
      );
}
