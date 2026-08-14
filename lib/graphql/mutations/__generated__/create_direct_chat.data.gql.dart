// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i1;

part 'create_direct_chat.data.gql.g.dart';

abstract class GCreateDirectChatData
    implements Built<GCreateDirectChatData, GCreateDirectChatDataBuilder> {
  GCreateDirectChatData._();

  factory GCreateDirectChatData(
          [void Function(GCreateDirectChatDataBuilder b) updates]) =
      _$GCreateDirectChatData;

  static void _initializeBuilder(GCreateDirectChatDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GCreateDirectChatData_createDirectChat get createDirectChat;
  static Serializer<GCreateDirectChatData> get serializer =>
      _$gCreateDirectChatDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GCreateDirectChatData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GCreateDirectChatData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GCreateDirectChatData.serializer,
        json,
      );
}

abstract class GCreateDirectChatData_createDirectChat
    implements
        Built<GCreateDirectChatData_createDirectChat,
            GCreateDirectChatData_createDirectChatBuilder> {
  GCreateDirectChatData_createDirectChat._();

  factory GCreateDirectChatData_createDirectChat(
      [void Function(GCreateDirectChatData_createDirectChatBuilder b)
          updates]) = _$GCreateDirectChatData_createDirectChat;

  static void _initializeBuilder(
          GCreateDirectChatData_createDirectChatBuilder b) =>
      b..G__typename = 'Chat';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  static Serializer<GCreateDirectChatData_createDirectChat> get serializer =>
      _$gCreateDirectChatDataCreateDirectChatSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GCreateDirectChatData_createDirectChat.serializer,
        this,
      ) as Map<String, dynamic>);

  static GCreateDirectChatData_createDirectChat? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GCreateDirectChatData_createDirectChat.serializer,
        json,
      );
}
