// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:ferry_exec/ferry_exec.dart' as _i1;
import 'package:gql_exec/gql_exec.dart' as _i4;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i6;
import 'package:simo_learn/graphql/queries/__generated__/get_chat_messages.ast.gql.dart'
    as _i5;
import 'package:simo_learn/graphql/queries/__generated__/get_chat_messages.data.gql.dart'
    as _i2;
import 'package:simo_learn/graphql/queries/__generated__/get_chat_messages.var.gql.dart'
    as _i3;

part 'get_chat_messages.req.gql.g.dart';

abstract class GGetChatMessagesReq
    implements
        Built<GGetChatMessagesReq, GGetChatMessagesReqBuilder>,
        _i1
        .OperationRequest<_i2.GGetChatMessagesData, _i3.GGetChatMessagesVars> {
  GGetChatMessagesReq._();

  factory GGetChatMessagesReq(
      [Function(GGetChatMessagesReqBuilder b) updates]) = _$GGetChatMessagesReq;

  static void _initializeBuilder(GGetChatMessagesReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'GetChatMessages',
    )
    ..executeOnListen = true;

  @override
  _i3.GGetChatMessagesVars get vars;
  @override
  _i4.Operation get operation;
  @override
  _i4.Request get execRequest => _i4.Request(
        operation: operation,
        variables: vars.toJson(),
      );

  @override
  String? get requestId;
  @override
  @BuiltValueField(serialize: false)
  _i2.GGetChatMessagesData? Function(
    _i2.GGetChatMessagesData?,
    _i2.GGetChatMessagesData?,
  )? get updateResult;
  @override
  _i2.GGetChatMessagesData? get optimisticResponse;
  @override
  String? get updateCacheHandlerKey;
  @override
  Map<String, dynamic>? get updateCacheHandlerContext;
  @override
  _i1.FetchPolicy? get fetchPolicy;
  @override
  bool get executeOnListen;
  @override
  _i2.GGetChatMessagesData? parseData(Map<String, dynamic> json) =>
      _i2.GGetChatMessagesData.fromJson(json);

  static Serializer<GGetChatMessagesReq> get serializer =>
      _$gGetChatMessagesReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GGetChatMessagesReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GGetChatMessagesReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GGetChatMessagesReq.serializer,
        json,
      );
}
