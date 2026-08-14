// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart' as _i2;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i1;

part 'get_chat_messages.data.gql.g.dart';

abstract class GGetChatMessagesData
    implements Built<GGetChatMessagesData, GGetChatMessagesDataBuilder> {
  GGetChatMessagesData._();

  factory GGetChatMessagesData(
          [void Function(GGetChatMessagesDataBuilder b) updates]) =
      _$GGetChatMessagesData;

  static void _initializeBuilder(GGetChatMessagesDataBuilder b) =>
      b..G__typename = 'Query';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  BuiltList<GGetChatMessagesData_getChatMessages> get getChatMessages;
  static Serializer<GGetChatMessagesData> get serializer =>
      _$gGetChatMessagesDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GGetChatMessagesData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GGetChatMessagesData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GGetChatMessagesData.serializer,
        json,
      );
}

abstract class GGetChatMessagesData_getChatMessages
    implements
        Built<GGetChatMessagesData_getChatMessages,
            GGetChatMessagesData_getChatMessagesBuilder> {
  GGetChatMessagesData_getChatMessages._();

  factory GGetChatMessagesData_getChatMessages(
      [void Function(GGetChatMessagesData_getChatMessagesBuilder b)
          updates]) = _$GGetChatMessagesData_getChatMessages;

  static void _initializeBuilder(
          GGetChatMessagesData_getChatMessagesBuilder b) =>
      b..G__typename = 'Message';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  String get content;
  _i2.GMessageType get type;
  String get chatID;
  String get senderID;
  String? get replyToID;
  bool get isDeleted;
  _i2.GTime? get deletedAt;
  _i2.GTime get createdAt;
  _i2.GTime get updatedAt;
  GGetChatMessagesData_getChatMessages_replyTo? get replyTo;
  GGetChatMessagesData_getChatMessages_sender get sender;
  static Serializer<GGetChatMessagesData_getChatMessages> get serializer =>
      _$gGetChatMessagesDataGetChatMessagesSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GGetChatMessagesData_getChatMessages.serializer,
        this,
      ) as Map<String, dynamic>);

  static GGetChatMessagesData_getChatMessages? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GGetChatMessagesData_getChatMessages.serializer,
        json,
      );
}

abstract class GGetChatMessagesData_getChatMessages_replyTo
    implements
        Built<GGetChatMessagesData_getChatMessages_replyTo,
            GGetChatMessagesData_getChatMessages_replyToBuilder> {
  GGetChatMessagesData_getChatMessages_replyTo._();

  factory GGetChatMessagesData_getChatMessages_replyTo(
      [void Function(GGetChatMessagesData_getChatMessages_replyToBuilder b)
          updates]) = _$GGetChatMessagesData_getChatMessages_replyTo;

  static void _initializeBuilder(
          GGetChatMessagesData_getChatMessages_replyToBuilder b) =>
      b..G__typename = 'Message';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  String get content;
  String get senderID;
  _i2.GTime get createdAt;
  static Serializer<GGetChatMessagesData_getChatMessages_replyTo>
      get serializer => _$gGetChatMessagesDataGetChatMessagesReplyToSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GGetChatMessagesData_getChatMessages_replyTo.serializer,
        this,
      ) as Map<String, dynamic>);

  static GGetChatMessagesData_getChatMessages_replyTo? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GGetChatMessagesData_getChatMessages_replyTo.serializer,
        json,
      );
}

abstract class GGetChatMessagesData_getChatMessages_sender
    implements
        Built<GGetChatMessagesData_getChatMessages_sender,
            GGetChatMessagesData_getChatMessages_senderBuilder> {
  GGetChatMessagesData_getChatMessages_sender._();

  factory GGetChatMessagesData_getChatMessages_sender(
      [void Function(GGetChatMessagesData_getChatMessages_senderBuilder b)
          updates]) = _$GGetChatMessagesData_getChatMessages_sender;

  static void _initializeBuilder(
          GGetChatMessagesData_getChatMessages_senderBuilder b) =>
      b..G__typename = 'User';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  static Serializer<GGetChatMessagesData_getChatMessages_sender>
      get serializer => _$gGetChatMessagesDataGetChatMessagesSenderSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GGetChatMessagesData_getChatMessages_sender.serializer,
        this,
      ) as Map<String, dynamic>);

  static GGetChatMessagesData_getChatMessages_sender? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GGetChatMessagesData_getChatMessages_sender.serializer,
        json,
      );
}
