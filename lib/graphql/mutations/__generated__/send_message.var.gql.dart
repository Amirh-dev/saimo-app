// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart' as _i1;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i2;

part 'send_message.var.gql.g.dart';

abstract class GSendMessageVars
    implements Built<GSendMessageVars, GSendMessageVarsBuilder> {
  GSendMessageVars._();

  factory GSendMessageVars([void Function(GSendMessageVarsBuilder b) updates]) =
      _$GSendMessageVars;

  _i1.GSendMessageInput get input;
  static Serializer<GSendMessageVars> get serializer =>
      _$gSendMessageVarsSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GSendMessageVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSendMessageVars? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GSendMessageVars.serializer,
        json,
      );
}
