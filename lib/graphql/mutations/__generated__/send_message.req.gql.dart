// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:ferry_exec/ferry_exec.dart' as _i1;
import 'package:gql_exec/gql_exec.dart' as _i4;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i6;
import 'package:simo_learn/graphql/mutations/__generated__/send_message.ast.gql.dart'
    as _i5;
import 'package:simo_learn/graphql/mutations/__generated__/send_message.data.gql.dart'
    as _i2;
import 'package:simo_learn/graphql/mutations/__generated__/send_message.var.gql.dart'
    as _i3;

part 'send_message.req.gql.g.dart';

abstract class GSendMessageReq
    implements
        Built<GSendMessageReq, GSendMessageReqBuilder>,
        _i1.OperationRequest<_i2.GSendMessageData, _i3.GSendMessageVars> {
  GSendMessageReq._();

  factory GSendMessageReq([void Function(GSendMessageReqBuilder b) updates]) =
      _$GSendMessageReq;

  static void _initializeBuilder(GSendMessageReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'SendMessage',
    )
    ..executeOnListen = true;

  @override
  _i3.GSendMessageVars get vars;
  @override
  _i4.Operation get operation;
  @override
  _i4.Request get execRequest => _i4.Request(
        operation: operation,
        variables: vars.toJson(),
        context: context ?? const _i4.Context(),
      );

  @override
  String? get requestId;
  @override
  @BuiltValueField(serialize: false)
  _i2.GSendMessageData? Function(
    _i2.GSendMessageData?,
    _i2.GSendMessageData?,
  )? get updateResult;
  @override
  _i2.GSendMessageData? get optimisticResponse;
  @override
  String? get updateCacheHandlerKey;
  @override
  Map<String, dynamic>? get updateCacheHandlerContext;
  @override
  _i1.FetchPolicy? get fetchPolicy;
  @override
  bool get executeOnListen;
  @override
  @BuiltValueField(serialize: false)
  _i4.Context? get context;
  @override
  _i2.GSendMessageData? parseData(Map<String, dynamic> json) =>
      _i2.GSendMessageData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GSendMessageData data) => data.toJson();

  @override
  _i1.OperationRequest<_i2.GSendMessageData, _i3.GSendMessageVars>
      transformOperation(_i4.Operation Function(_i4.Operation) transform) =>
          this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GSendMessageReq> get serializer =>
      _$gSendMessageReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GSendMessageReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSendMessageReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GSendMessageReq.serializer,
        json,
      );
}
