// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart' as _i1;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i2;

part 'send_otp.var.gql.g.dart';

abstract class GSendOTPVars
    implements Built<GSendOTPVars, GSendOTPVarsBuilder> {
  GSendOTPVars._();

  factory GSendOTPVars([void Function(GSendOTPVarsBuilder b) updates]) =
      _$GSendOTPVars;

  _i1.GSendOTPInput get input;
  static Serializer<GSendOTPVars> get serializer => _$gSendOTPVarsSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GSendOTPVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSendOTPVars? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GSendOTPVars.serializer,
        json,
      );
}
