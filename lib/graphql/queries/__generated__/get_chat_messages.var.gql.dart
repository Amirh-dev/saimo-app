// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart' as _i1;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i2;

part 'get_chat_messages.var.gql.g.dart';

abstract class GGetChatMessagesVars
    implements Built<GGetChatMessagesVars, GGetChatMessagesVarsBuilder> {
  GGetChatMessagesVars._();

  factory GGetChatMessagesVars(
          [void Function(GGetChatMessagesVarsBuilder b) updates]) =
      _$GGetChatMessagesVars;

  _i1.GUUID get chatID;
  int? get limit;
  int? get offset;
  static Serializer<GGetChatMessagesVars> get serializer =>
      _$gGetChatMessagesVarsSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GGetChatMessagesVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GGetChatMessagesVars? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GGetChatMessagesVars.serializer,
        json,
      );
}
