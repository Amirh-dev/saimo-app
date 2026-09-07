// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:ferry_exec/ferry_exec.dart' as _i1;
import 'package:gql_exec/gql_exec.dart' as _i4;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i6;
import 'package:simo_learn/graphql/queries/__generated__/suggest_tag.ast.gql.dart'
    as _i5;
import 'package:simo_learn/graphql/queries/__generated__/suggest_tag.data.gql.dart'
    as _i2;
import 'package:simo_learn/graphql/queries/__generated__/suggest_tag.var.gql.dart'
    as _i3;

part 'suggest_tag.req.gql.g.dart';

abstract class GSuggestTagsReq
    implements
        Built<GSuggestTagsReq, GSuggestTagsReqBuilder>,
        _i1.OperationRequest<_i2.GSuggestTagsData, _i3.GSuggestTagsVars> {
  GSuggestTagsReq._();

  factory GSuggestTagsReq([void Function(GSuggestTagsReqBuilder b) updates]) =
      _$GSuggestTagsReq;

  static void _initializeBuilder(GSuggestTagsReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'SuggestTags',
    )
    ..executeOnListen = true;

  @override
  _i3.GSuggestTagsVars get vars;
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
  _i2.GSuggestTagsData? Function(
    _i2.GSuggestTagsData?,
    _i2.GSuggestTagsData?,
  )? get updateResult;
  @override
  _i2.GSuggestTagsData? get optimisticResponse;
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
  _i2.GSuggestTagsData? parseData(Map<String, dynamic> json) =>
      _i2.GSuggestTagsData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GSuggestTagsData data) => data.toJson();

  @override
  _i1.OperationRequest<_i2.GSuggestTagsData, _i3.GSuggestTagsVars>
      transformOperation(_i4.Operation Function(_i4.Operation) transform) =>
          this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GSuggestTagsReq> get serializer =>
      _$gSuggestTagsReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GSuggestTagsReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSuggestTagsReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GSuggestTagsReq.serializer,
        json,
      );
}
