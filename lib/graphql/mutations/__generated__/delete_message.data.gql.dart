// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart' as _i2;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i1;

part 'delete_message.data.gql.g.dart';

abstract class GDeleteMessageData
    implements Built<GDeleteMessageData, GDeleteMessageDataBuilder> {
  GDeleteMessageData._();

  factory GDeleteMessageData([Function(GDeleteMessageDataBuilder b) updates]) =
      _$GDeleteMessageData;

  static void _initializeBuilder(GDeleteMessageDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GDeleteMessageData_deleteMessage get deleteMessage;
  static Serializer<GDeleteMessageData> get serializer =>
      _$gDeleteMessageDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GDeleteMessageData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GDeleteMessageData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GDeleteMessageData.serializer,
        json,
      );
}

abstract class GDeleteMessageData_deleteMessage
    implements
        Built<GDeleteMessageData_deleteMessage,
            GDeleteMessageData_deleteMessageBuilder> {
  GDeleteMessageData_deleteMessage._();

  factory GDeleteMessageData_deleteMessage(
          [Function(GDeleteMessageData_deleteMessageBuilder b) updates]) =
      _$GDeleteMessageData_deleteMessage;

  static void _initializeBuilder(GDeleteMessageData_deleteMessageBuilder b) =>
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
  static Serializer<GDeleteMessageData_deleteMessage> get serializer =>
      _$gDeleteMessageDataDeleteMessageSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GDeleteMessageData_deleteMessage.serializer,
        this,
      ) as Map<String, dynamic>);

  static GDeleteMessageData_deleteMessage? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GDeleteMessageData_deleteMessage.serializer,
        json,
      );
}
