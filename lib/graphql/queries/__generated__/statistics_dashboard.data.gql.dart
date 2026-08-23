// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart' as _i2;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i1;

part 'statistics_dashboard.data.gql.g.dart';

abstract class GStatisticsDashboardData
    implements
        Built<GStatisticsDashboardData, GStatisticsDashboardDataBuilder> {
  GStatisticsDashboardData._();

  factory GStatisticsDashboardData(
          [void Function(GStatisticsDashboardDataBuilder b) updates]) =
      _$GStatisticsDashboardData;

  static void _initializeBuilder(GStatisticsDashboardDataBuilder b) =>
      b..G__typename = 'Query';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GStatisticsDashboardData_statisticsDashboard get statisticsDashboard;
  static Serializer<GStatisticsDashboardData> get serializer =>
      _$gStatisticsDashboardDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GStatisticsDashboardData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GStatisticsDashboardData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GStatisticsDashboardData.serializer,
        json,
      );
}

abstract class GStatisticsDashboardData_statisticsDashboard
    implements
        Built<GStatisticsDashboardData_statisticsDashboard,
            GStatisticsDashboardData_statisticsDashboardBuilder> {
  GStatisticsDashboardData_statisticsDashboard._();

  factory GStatisticsDashboardData_statisticsDashboard(
      [void Function(GStatisticsDashboardData_statisticsDashboardBuilder b)
          updates]) = _$GStatisticsDashboardData_statisticsDashboard;

  static void _initializeBuilder(
          GStatisticsDashboardData_statisticsDashboardBuilder b) =>
      b..G__typename = 'StatisticsDashboard';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GStatisticsDashboardData_statisticsDashboard_comparison get comparison;
  BuiltList<GStatisticsDashboardData_statisticsDashboard_dailyBuckets>
      get dailyBuckets;
  BuiltList<GStatisticsDashboardData_statisticsDashboard_subjectBuckets>
      get subjectBuckets;
  static Serializer<GStatisticsDashboardData_statisticsDashboard>
      get serializer => _$gStatisticsDashboardDataStatisticsDashboardSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GStatisticsDashboardData_statisticsDashboard.serializer,
        this,
      ) as Map<String, dynamic>);

  static GStatisticsDashboardData_statisticsDashboard? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GStatisticsDashboardData_statisticsDashboard.serializer,
        json,
      );
}

abstract class GStatisticsDashboardData_statisticsDashboard_comparison
    implements
        Built<GStatisticsDashboardData_statisticsDashboard_comparison,
            GStatisticsDashboardData_statisticsDashboard_comparisonBuilder> {
  GStatisticsDashboardData_statisticsDashboard_comparison._();

  factory GStatisticsDashboardData_statisticsDashboard_comparison(
      [void Function(
              GStatisticsDashboardData_statisticsDashboard_comparisonBuilder b)
          updates]) = _$GStatisticsDashboardData_statisticsDashboard_comparison;

  static void _initializeBuilder(
          GStatisticsDashboardData_statisticsDashboard_comparisonBuilder b) =>
      b..G__typename = 'StatisticsComparison';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GStatisticsDashboardData_statisticsDashboard_comparison_current get current;
  GStatisticsDashboardData_statisticsDashboard_comparison_previous get previous;
  double? get studySecondsChangePercentage;
  double? get adherenceChangePercentage;
  double? get totalQuestionsChangePercentage;
  double? get correctAnswersChangePercentage;
  static Serializer<GStatisticsDashboardData_statisticsDashboard_comparison>
      get serializer =>
          _$gStatisticsDashboardDataStatisticsDashboardComparisonSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GStatisticsDashboardData_statisticsDashboard_comparison.serializer,
        this,
      ) as Map<String, dynamic>);

  static GStatisticsDashboardData_statisticsDashboard_comparison? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GStatisticsDashboardData_statisticsDashboard_comparison.serializer,
        json,
      );
}

abstract class GStatisticsDashboardData_statisticsDashboard_comparison_current
    implements
        Built<GStatisticsDashboardData_statisticsDashboard_comparison_current,
            GStatisticsDashboardData_statisticsDashboard_comparison_currentBuilder> {
  GStatisticsDashboardData_statisticsDashboard_comparison_current._();

  factory GStatisticsDashboardData_statisticsDashboard_comparison_current(
          [void Function(
                  GStatisticsDashboardData_statisticsDashboard_comparison_currentBuilder
                      b)
              updates]) =
      _$GStatisticsDashboardData_statisticsDashboard_comparison_current;

  static void _initializeBuilder(
          GStatisticsDashboardData_statisticsDashboard_comparison_currentBuilder
              b) =>
      b..G__typename = 'StatisticsSummary';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  int get studySeconds;
  double get adherencePercentage;
  int get totalQuestions;
  int get correctAnswers;
  int get tasksWithTests;
  GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted
      get planVsCompleted;
  static Serializer<
          GStatisticsDashboardData_statisticsDashboard_comparison_current>
      get serializer =>
          _$gStatisticsDashboardDataStatisticsDashboardComparisonCurrentSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GStatisticsDashboardData_statisticsDashboard_comparison_current
            .serializer,
        this,
      ) as Map<String, dynamic>);

  static GStatisticsDashboardData_statisticsDashboard_comparison_current?
      fromJson(Map<String, dynamic> json) => _i1.serializers.deserializeWith(
            GStatisticsDashboardData_statisticsDashboard_comparison_current
                .serializer,
            json,
          );
}

abstract class GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted
    implements
        Built<
            GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted,
            GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompletedBuilder> {
  GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted._();

  factory GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted(
          [void Function(
                  GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompletedBuilder
                      b)
              updates]) =
      _$GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted;

  static void _initializeBuilder(
          GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompletedBuilder
              b) =>
      b..G__typename = 'PlanVsCompleted';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  int get plannedSeconds;
  int get completedOnlySeconds;
  int get completedAndStudiedSeconds;
  double get completedOnlyPercentage;
  double get completedAndStudiedPercentage;
  static Serializer<
          GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted>
      get serializer =>
          _$gStatisticsDashboardDataStatisticsDashboardComparisonCurrentPlanVsCompletedSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted
            .serializer,
        this,
      ) as Map<String, dynamic>);

  static GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted?
      fromJson(Map<String, dynamic> json) => _i1.serializers.deserializeWith(
            GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted
                .serializer,
            json,
          );
}

abstract class GStatisticsDashboardData_statisticsDashboard_comparison_previous
    implements
        Built<GStatisticsDashboardData_statisticsDashboard_comparison_previous,
            GStatisticsDashboardData_statisticsDashboard_comparison_previousBuilder> {
  GStatisticsDashboardData_statisticsDashboard_comparison_previous._();

  factory GStatisticsDashboardData_statisticsDashboard_comparison_previous(
          [void Function(
                  GStatisticsDashboardData_statisticsDashboard_comparison_previousBuilder
                      b)
              updates]) =
      _$GStatisticsDashboardData_statisticsDashboard_comparison_previous;

  static void _initializeBuilder(
          GStatisticsDashboardData_statisticsDashboard_comparison_previousBuilder
              b) =>
      b..G__typename = 'StatisticsSummary';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  int get studySeconds;
  double get adherencePercentage;
  int get totalQuestions;
  int get correctAnswers;
  int get tasksWithTests;
  static Serializer<
          GStatisticsDashboardData_statisticsDashboard_comparison_previous>
      get serializer =>
          _$gStatisticsDashboardDataStatisticsDashboardComparisonPreviousSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GStatisticsDashboardData_statisticsDashboard_comparison_previous
            .serializer,
        this,
      ) as Map<String, dynamic>);

  static GStatisticsDashboardData_statisticsDashboard_comparison_previous?
      fromJson(Map<String, dynamic> json) => _i1.serializers.deserializeWith(
            GStatisticsDashboardData_statisticsDashboard_comparison_previous
                .serializer,
            json,
          );
}

abstract class GStatisticsDashboardData_statisticsDashboard_dailyBuckets
    implements
        Built<GStatisticsDashboardData_statisticsDashboard_dailyBuckets,
            GStatisticsDashboardData_statisticsDashboard_dailyBucketsBuilder> {
  GStatisticsDashboardData_statisticsDashboard_dailyBuckets._();

  factory GStatisticsDashboardData_statisticsDashboard_dailyBuckets(
      [void Function(
              GStatisticsDashboardData_statisticsDashboard_dailyBucketsBuilder
                  b)
          updates]) = _$GStatisticsDashboardData_statisticsDashboard_dailyBuckets;

  static void _initializeBuilder(
          GStatisticsDashboardData_statisticsDashboard_dailyBucketsBuilder b) =>
      b..G__typename = 'DailyStatisticsBucket';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  _i2.GTime get start;
  int get studySeconds;
  int get completedTasks;
  int get totalQuestions;
  int get correctAnswers;
  int get incorrectAnswers;
  static Serializer<GStatisticsDashboardData_statisticsDashboard_dailyBuckets>
      get serializer =>
          _$gStatisticsDashboardDataStatisticsDashboardDailyBucketsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GStatisticsDashboardData_statisticsDashboard_dailyBuckets.serializer,
        this,
      ) as Map<String, dynamic>);

  static GStatisticsDashboardData_statisticsDashboard_dailyBuckets? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GStatisticsDashboardData_statisticsDashboard_dailyBuckets.serializer,
        json,
      );
}

abstract class GStatisticsDashboardData_statisticsDashboard_subjectBuckets
    implements
        Built<GStatisticsDashboardData_statisticsDashboard_subjectBuckets,
            GStatisticsDashboardData_statisticsDashboard_subjectBucketsBuilder> {
  GStatisticsDashboardData_statisticsDashboard_subjectBuckets._();

  factory GStatisticsDashboardData_statisticsDashboard_subjectBuckets(
      [void Function(
              GStatisticsDashboardData_statisticsDashboard_subjectBucketsBuilder
                  b)
          updates]) = _$GStatisticsDashboardData_statisticsDashboard_subjectBuckets;

  static void _initializeBuilder(
          GStatisticsDashboardData_statisticsDashboard_subjectBucketsBuilder
              b) =>
      b..G__typename = 'TagStatisticsBucket';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String? get tagID;
  String get tagName;
  bool get isMiscellaneous;
  int get studySeconds;
  int get completedTasks;
  int get totalQuestions;
  int get correctAnswers;
  int get incorrectAnswers;
  static Serializer<GStatisticsDashboardData_statisticsDashboard_subjectBuckets>
      get serializer =>
          _$gStatisticsDashboardDataStatisticsDashboardSubjectBucketsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GStatisticsDashboardData_statisticsDashboard_subjectBuckets.serializer,
        this,
      ) as Map<String, dynamic>);

  static GStatisticsDashboardData_statisticsDashboard_subjectBuckets? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GStatisticsDashboardData_statisticsDashboard_subjectBuckets.serializer,
        json,
      );
}
