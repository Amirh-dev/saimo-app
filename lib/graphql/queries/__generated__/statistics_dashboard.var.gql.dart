// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart' as _i1;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i2;

part 'statistics_dashboard.var.gql.g.dart';

abstract class GStatisticsDashboardVars
    implements
        Built<GStatisticsDashboardVars, GStatisticsDashboardVarsBuilder> {
  GStatisticsDashboardVars._();

  factory GStatisticsDashboardVars(
          [void Function(GStatisticsDashboardVarsBuilder b) updates]) =
      _$GStatisticsDashboardVars;

  _i1.GStatisticsDashboardInput get input;
  static Serializer<GStatisticsDashboardVars> get serializer =>
      _$gStatisticsDashboardVarsSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GStatisticsDashboardVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GStatisticsDashboardVars? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GStatisticsDashboardVars.serializer,
        json,
      );
}
