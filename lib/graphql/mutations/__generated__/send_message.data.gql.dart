// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart' as _i2;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i1;

part 'send_message.data.gql.g.dart';

abstract class GSendMessageData
    implements Built<GSendMessageData, GSendMessageDataBuilder> {
  GSendMessageData._();

  factory GSendMessageData([Function(GSendMessageDataBuilder b) updates]) =
      _$GSendMessageData;

  static void _initializeBuilder(GSendMessageDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GSendMessageData_sendMessage get sendMessage;
  static Serializer<GSendMessageData> get serializer =>
      _$gSendMessageDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GSendMessageData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSendMessageData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GSendMessageData.serializer,
        json,
      );
}

abstract class GSendMessageData_sendMessage
    implements
        Built<GSendMessageData_sendMessage,
            GSendMessageData_sendMessageBuilder> {
  GSendMessageData_sendMessage._();

  factory GSendMessageData_sendMessage(
          [Function(GSendMessageData_sendMessageBuilder b) updates]) =
      _$GSendMessageData_sendMessage;

  static void _initializeBuilder(GSendMessageData_sendMessageBuilder b) =>
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
  GSendMessageData_sendMessage_replyTo? get replyTo;
  GSendMessageData_sendMessage_sender get sender;
  static Serializer<GSendMessageData_sendMessage> get serializer =>
      _$gSendMessageDataSendMessageSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GSendMessageData_sendMessage.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSendMessageData_sendMessage? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GSendMessageData_sendMessage.serializer,
        json,
      );
}

abstract class GSendMessageData_sendMessage_replyTo
    implements
        Built<GSendMessageData_sendMessage_replyTo,
            GSendMessageData_sendMessage_replyToBuilder> {
  GSendMessageData_sendMessage_replyTo._();

  factory GSendMessageData_sendMessage_replyTo(
          [Function(GSendMessageData_sendMessage_replyToBuilder b) updates]) =
      _$GSendMessageData_sendMessage_replyTo;

  static void _initializeBuilder(
          GSendMessageData_sendMessage_replyToBuilder b) =>
      b..G__typename = 'Message';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  String get content;
  String get senderID;
  _i2.GTime get createdAt;
  static Serializer<GSendMessageData_sendMessage_replyTo> get serializer =>
      _$gSendMessageDataSendMessageReplyToSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GSendMessageData_sendMessage_replyTo.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSendMessageData_sendMessage_replyTo? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GSendMessageData_sendMessage_replyTo.serializer,
        json,
      );
}

abstract class GSendMessageData_sendMessage_sender
    implements
        Built<GSendMessageData_sendMessage_sender,
            GSendMessageData_sendMessage_senderBuilder> {
  GSendMessageData_sendMessage_sender._();

  factory GSendMessageData_sendMessage_sender(
          [Function(GSendMessageData_sendMessage_senderBuilder b) updates]) =
      _$GSendMessageData_sendMessage_sender;

  static void _initializeBuilder(
          GSendMessageData_sendMessage_senderBuilder b) =>
      b..G__typename = 'User';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  static Serializer<GSendMessageData_sendMessage_sender> get serializer =>
      _$gSendMessageDataSendMessageSenderSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GSendMessageData_sendMessage_sender.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSendMessageData_sendMessage_sender? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GSendMessageData_sendMessage_sender.serializer,
        json,
      );
}
