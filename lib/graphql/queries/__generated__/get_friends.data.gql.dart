// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart' as _i2;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i1;

part 'get_friends.data.gql.g.dart';

abstract class GGetFriendsData
    implements Built<GGetFriendsData, GGetFriendsDataBuilder> {
  GGetFriendsData._();

  factory GGetFriendsData([Function(GGetFriendsDataBuilder b) updates]) =
      _$GGetFriendsData;

  static void _initializeBuilder(GGetFriendsDataBuilder b) =>
      b..G__typename = 'Query';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  BuiltList<GGetFriendsData_getFriends> get getFriends;
  static Serializer<GGetFriendsData> get serializer =>
      _$gGetFriendsDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GGetFriendsData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GGetFriendsData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GGetFriendsData.serializer,
        json,
      );
}

abstract class GGetFriendsData_getFriends
    implements
        Built<GGetFriendsData_getFriends, GGetFriendsData_getFriendsBuilder> {
  GGetFriendsData_getFriends._();

  factory GGetFriendsData_getFriends(
          [Function(GGetFriendsData_getFriendsBuilder b) updates]) =
      _$GGetFriendsData_getFriends;

  static void _initializeBuilder(GGetFriendsData_getFriendsBuilder b) =>
      b..G__typename = 'Friendship';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  _i2.GFriendshipStatus get status;
  String get requesterID;
  String get receiverID;
  _i2.GUUID get userLowID;
  _i2.GUUID get userHighID;
  GGetFriendsData_getFriends_requester get requester;
  GGetFriendsData_getFriends_receiver get receiver;
  static Serializer<GGetFriendsData_getFriends> get serializer =>
      _$gGetFriendsDataGetFriendsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GGetFriendsData_getFriends.serializer,
        this,
      ) as Map<String, dynamic>);

  static GGetFriendsData_getFriends? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GGetFriendsData_getFriends.serializer,
        json,
      );
}

abstract class GGetFriendsData_getFriends_requester
    implements
        Built<GGetFriendsData_getFriends_requester,
            GGetFriendsData_getFriends_requesterBuilder> {
  GGetFriendsData_getFriends_requester._();

  factory GGetFriendsData_getFriends_requester(
          [Function(GGetFriendsData_getFriends_requesterBuilder b) updates]) =
      _$GGetFriendsData_getFriends_requester;

  static void _initializeBuilder(
          GGetFriendsData_getFriends_requesterBuilder b) =>
      b..G__typename = 'User';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  String? get fullName;
  String get username;
  static Serializer<GGetFriendsData_getFriends_requester> get serializer =>
      _$gGetFriendsDataGetFriendsRequesterSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GGetFriendsData_getFriends_requester.serializer,
        this,
      ) as Map<String, dynamic>);

  static GGetFriendsData_getFriends_requester? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GGetFriendsData_getFriends_requester.serializer,
        json,
      );
}

abstract class GGetFriendsData_getFriends_receiver
    implements
        Built<GGetFriendsData_getFriends_receiver,
            GGetFriendsData_getFriends_receiverBuilder> {
  GGetFriendsData_getFriends_receiver._();

  factory GGetFriendsData_getFriends_receiver(
          [Function(GGetFriendsData_getFriends_receiverBuilder b) updates]) =
      _$GGetFriendsData_getFriends_receiver;

  static void _initializeBuilder(
          GGetFriendsData_getFriends_receiverBuilder b) =>
      b..G__typename = 'User';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  String? get fullName;
  String get username;
  static Serializer<GGetFriendsData_getFriends_receiver> get serializer =>
      _$gGetFriendsDataGetFriendsReceiverSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GGetFriendsData_getFriends_receiver.serializer,
        this,
      ) as Map<String, dynamic>);

  static GGetFriendsData_getFriends_receiver? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GGetFriendsData_getFriends_receiver.serializer,
        json,
      );
}
