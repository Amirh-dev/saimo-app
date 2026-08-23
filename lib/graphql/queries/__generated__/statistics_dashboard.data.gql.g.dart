// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics_dashboard.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GStatisticsDashboardData> _$gStatisticsDashboardDataSerializer =
    _$GStatisticsDashboardDataSerializer();
Serializer<GStatisticsDashboardData_statisticsDashboard>
    _$gStatisticsDashboardDataStatisticsDashboardSerializer =
    _$GStatisticsDashboardData_statisticsDashboardSerializer();
Serializer<GStatisticsDashboardData_statisticsDashboard_comparison>
    _$gStatisticsDashboardDataStatisticsDashboardComparisonSerializer =
    _$GStatisticsDashboardData_statisticsDashboard_comparisonSerializer();
Serializer<GStatisticsDashboardData_statisticsDashboard_comparison_current>
    _$gStatisticsDashboardDataStatisticsDashboardComparisonCurrentSerializer =
    _$GStatisticsDashboardData_statisticsDashboard_comparison_currentSerializer();
Serializer<
        GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted>
    _$gStatisticsDashboardDataStatisticsDashboardComparisonCurrentPlanVsCompletedSerializer =
    _$GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompletedSerializer();
Serializer<GStatisticsDashboardData_statisticsDashboard_comparison_previous>
    _$gStatisticsDashboardDataStatisticsDashboardComparisonPreviousSerializer =
    _$GStatisticsDashboardData_statisticsDashboard_comparison_previousSerializer();
Serializer<GStatisticsDashboardData_statisticsDashboard_dailyBuckets>
    _$gStatisticsDashboardDataStatisticsDashboardDailyBucketsSerializer =
    _$GStatisticsDashboardData_statisticsDashboard_dailyBucketsSerializer();
Serializer<GStatisticsDashboardData_statisticsDashboard_subjectBuckets>
    _$gStatisticsDashboardDataStatisticsDashboardSubjectBucketsSerializer =
    _$GStatisticsDashboardData_statisticsDashboard_subjectBucketsSerializer();

class _$GStatisticsDashboardDataSerializer
    implements StructuredSerializer<GStatisticsDashboardData> {
  @override
  final Iterable<Type> types = const [
    GStatisticsDashboardData,
    _$GStatisticsDashboardData
  ];
  @override
  final String wireName = 'GStatisticsDashboardData';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GStatisticsDashboardData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'statisticsDashboard',
      serializers.serialize(object.statisticsDashboard,
          specifiedType:
              const FullType(GStatisticsDashboardData_statisticsDashboard)),
    ];

    return result;
  }

  @override
  GStatisticsDashboardData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GStatisticsDashboardDataBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'statisticsDashboard':
          result.statisticsDashboard.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      GStatisticsDashboardData_statisticsDashboard))!
              as GStatisticsDashboardData_statisticsDashboard);
          break;
      }
    }

    return result.build();
  }
}

class _$GStatisticsDashboardData_statisticsDashboardSerializer
    implements
        StructuredSerializer<GStatisticsDashboardData_statisticsDashboard> {
  @override
  final Iterable<Type> types = const [
    GStatisticsDashboardData_statisticsDashboard,
    _$GStatisticsDashboardData_statisticsDashboard
  ];
  @override
  final String wireName = 'GStatisticsDashboardData_statisticsDashboard';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GStatisticsDashboardData_statisticsDashboard object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'comparison',
      serializers.serialize(object.comparison,
          specifiedType: const FullType(
              GStatisticsDashboardData_statisticsDashboard_comparison)),
      'dailyBuckets',
      serializers.serialize(object.dailyBuckets,
          specifiedType: const FullType(BuiltList, const [
            const FullType(
                GStatisticsDashboardData_statisticsDashboard_dailyBuckets)
          ])),
      'subjectBuckets',
      serializers.serialize(object.subjectBuckets,
          specifiedType: const FullType(BuiltList, const [
            const FullType(
                GStatisticsDashboardData_statisticsDashboard_subjectBuckets)
          ])),
    ];

    return result;
  }

  @override
  GStatisticsDashboardData_statisticsDashboard deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GStatisticsDashboardData_statisticsDashboardBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'comparison':
          result.comparison.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      GStatisticsDashboardData_statisticsDashboard_comparison))!
              as GStatisticsDashboardData_statisticsDashboard_comparison);
          break;
        case 'dailyBuckets':
          result.dailyBuckets.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltList, const [
                const FullType(
                    GStatisticsDashboardData_statisticsDashboard_dailyBuckets)
              ]))! as BuiltList<Object?>);
          break;
        case 'subjectBuckets':
          result.subjectBuckets.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltList, const [
                const FullType(
                    GStatisticsDashboardData_statisticsDashboard_subjectBuckets)
              ]))! as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$GStatisticsDashboardData_statisticsDashboard_comparisonSerializer
    implements
        StructuredSerializer<
            GStatisticsDashboardData_statisticsDashboard_comparison> {
  @override
  final Iterable<Type> types = const [
    GStatisticsDashboardData_statisticsDashboard_comparison,
    _$GStatisticsDashboardData_statisticsDashboard_comparison
  ];
  @override
  final String wireName =
      'GStatisticsDashboardData_statisticsDashboard_comparison';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GStatisticsDashboardData_statisticsDashboard_comparison object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'current',
      serializers.serialize(object.current,
          specifiedType: const FullType(
              GStatisticsDashboardData_statisticsDashboard_comparison_current)),
      'previous',
      serializers.serialize(object.previous,
          specifiedType: const FullType(
              GStatisticsDashboardData_statisticsDashboard_comparison_previous)),
    ];
    Object? value;
    value = object.studySecondsChangePercentage;
    if (value != null) {
      result
        ..add('studySecondsChangePercentage')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    value = object.adherenceChangePercentage;
    if (value != null) {
      result
        ..add('adherenceChangePercentage')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    value = object.totalQuestionsChangePercentage;
    if (value != null) {
      result
        ..add('totalQuestionsChangePercentage')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    value = object.correctAnswersChangePercentage;
    if (value != null) {
      result
        ..add('correctAnswersChangePercentage')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    return result;
  }

  @override
  GStatisticsDashboardData_statisticsDashboard_comparison deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result =
        GStatisticsDashboardData_statisticsDashboard_comparisonBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'current':
          result.current.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      GStatisticsDashboardData_statisticsDashboard_comparison_current))!
              as GStatisticsDashboardData_statisticsDashboard_comparison_current);
          break;
        case 'previous':
          result.previous.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      GStatisticsDashboardData_statisticsDashboard_comparison_previous))!
              as GStatisticsDashboardData_statisticsDashboard_comparison_previous);
          break;
        case 'studySecondsChangePercentage':
          result.studySecondsChangePercentage = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double?;
          break;
        case 'adherenceChangePercentage':
          result.adherenceChangePercentage = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double?;
          break;
        case 'totalQuestionsChangePercentage':
          result.totalQuestionsChangePercentage = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double?;
          break;
        case 'correctAnswersChangePercentage':
          result.correctAnswersChangePercentage = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double?;
          break;
      }
    }

    return result.build();
  }
}

class _$GStatisticsDashboardData_statisticsDashboard_comparison_currentSerializer
    implements
        StructuredSerializer<
            GStatisticsDashboardData_statisticsDashboard_comparison_current> {
  @override
  final Iterable<Type> types = const [
    GStatisticsDashboardData_statisticsDashboard_comparison_current,
    _$GStatisticsDashboardData_statisticsDashboard_comparison_current
  ];
  @override
  final String wireName =
      'GStatisticsDashboardData_statisticsDashboard_comparison_current';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GStatisticsDashboardData_statisticsDashboard_comparison_current object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'studySeconds',
      serializers.serialize(object.studySeconds,
          specifiedType: const FullType(int)),
      'adherencePercentage',
      serializers.serialize(object.adherencePercentage,
          specifiedType: const FullType(double)),
      'totalQuestions',
      serializers.serialize(object.totalQuestions,
          specifiedType: const FullType(int)),
      'correctAnswers',
      serializers.serialize(object.correctAnswers,
          specifiedType: const FullType(int)),
      'tasksWithTests',
      serializers.serialize(object.tasksWithTests,
          specifiedType: const FullType(int)),
      'planVsCompleted',
      serializers.serialize(object.planVsCompleted,
          specifiedType: const FullType(
              GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted)),
    ];

    return result;
  }

  @override
  GStatisticsDashboardData_statisticsDashboard_comparison_current deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result =
        GStatisticsDashboardData_statisticsDashboard_comparison_currentBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'studySeconds':
          result.studySeconds = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'adherencePercentage':
          result.adherencePercentage = serializers.deserialize(value,
              specifiedType: const FullType(double))! as double;
          break;
        case 'totalQuestions':
          result.totalQuestions = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'correctAnswers':
          result.correctAnswers = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'tasksWithTests':
          result.tasksWithTests = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'planVsCompleted':
          result.planVsCompleted.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted))!
              as GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted);
          break;
      }
    }

    return result.build();
  }
}

class _$GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompletedSerializer
    implements
        StructuredSerializer<
            GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted> {
  @override
  final Iterable<Type> types = const [
    GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted,
    _$GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted
  ];
  @override
  final String wireName =
      'GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted';

  @override
  Iterable<Object?> serialize(
      Serializers serializers,
      GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted
          object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'plannedSeconds',
      serializers.serialize(object.plannedSeconds,
          specifiedType: const FullType(int)),
      'completedOnlySeconds',
      serializers.serialize(object.completedOnlySeconds,
          specifiedType: const FullType(int)),
      'completedAndStudiedSeconds',
      serializers.serialize(object.completedAndStudiedSeconds,
          specifiedType: const FullType(int)),
      'completedOnlyPercentage',
      serializers.serialize(object.completedOnlyPercentage,
          specifiedType: const FullType(double)),
      'completedAndStudiedPercentage',
      serializers.serialize(object.completedAndStudiedPercentage,
          specifiedType: const FullType(double)),
    ];

    return result;
  }

  @override
  GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted
      deserialize(Serializers serializers, Iterable<Object?> serialized,
          {FullType specifiedType = FullType.unspecified}) {
    final result =
        GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompletedBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'plannedSeconds':
          result.plannedSeconds = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'completedOnlySeconds':
          result.completedOnlySeconds = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'completedAndStudiedSeconds':
          result.completedAndStudiedSeconds = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'completedOnlyPercentage':
          result.completedOnlyPercentage = serializers.deserialize(value,
              specifiedType: const FullType(double))! as double;
          break;
        case 'completedAndStudiedPercentage':
          result.completedAndStudiedPercentage = serializers.deserialize(value,
              specifiedType: const FullType(double))! as double;
          break;
      }
    }

    return result.build();
  }
}

class _$GStatisticsDashboardData_statisticsDashboard_comparison_previousSerializer
    implements
        StructuredSerializer<
            GStatisticsDashboardData_statisticsDashboard_comparison_previous> {
  @override
  final Iterable<Type> types = const [
    GStatisticsDashboardData_statisticsDashboard_comparison_previous,
    _$GStatisticsDashboardData_statisticsDashboard_comparison_previous
  ];
  @override
  final String wireName =
      'GStatisticsDashboardData_statisticsDashboard_comparison_previous';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GStatisticsDashboardData_statisticsDashboard_comparison_previous object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'studySeconds',
      serializers.serialize(object.studySeconds,
          specifiedType: const FullType(int)),
      'adherencePercentage',
      serializers.serialize(object.adherencePercentage,
          specifiedType: const FullType(double)),
      'totalQuestions',
      serializers.serialize(object.totalQuestions,
          specifiedType: const FullType(int)),
      'correctAnswers',
      serializers.serialize(object.correctAnswers,
          specifiedType: const FullType(int)),
      'tasksWithTests',
      serializers.serialize(object.tasksWithTests,
          specifiedType: const FullType(int)),
    ];

    return result;
  }

  @override
  GStatisticsDashboardData_statisticsDashboard_comparison_previous deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result =
        GStatisticsDashboardData_statisticsDashboard_comparison_previousBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'studySeconds':
          result.studySeconds = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'adherencePercentage':
          result.adherencePercentage = serializers.deserialize(value,
              specifiedType: const FullType(double))! as double;
          break;
        case 'totalQuestions':
          result.totalQuestions = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'correctAnswers':
          result.correctAnswers = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'tasksWithTests':
          result.tasksWithTests = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
      }
    }

    return result.build();
  }
}

class _$GStatisticsDashboardData_statisticsDashboard_dailyBucketsSerializer
    implements
        StructuredSerializer<
            GStatisticsDashboardData_statisticsDashboard_dailyBuckets> {
  @override
  final Iterable<Type> types = const [
    GStatisticsDashboardData_statisticsDashboard_dailyBuckets,
    _$GStatisticsDashboardData_statisticsDashboard_dailyBuckets
  ];
  @override
  final String wireName =
      'GStatisticsDashboardData_statisticsDashboard_dailyBuckets';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GStatisticsDashboardData_statisticsDashboard_dailyBuckets object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'start',
      serializers.serialize(object.start,
          specifiedType: const FullType(_i2.GTime)),
      'studySeconds',
      serializers.serialize(object.studySeconds,
          specifiedType: const FullType(int)),
      'completedTasks',
      serializers.serialize(object.completedTasks,
          specifiedType: const FullType(int)),
      'totalQuestions',
      serializers.serialize(object.totalQuestions,
          specifiedType: const FullType(int)),
      'correctAnswers',
      serializers.serialize(object.correctAnswers,
          specifiedType: const FullType(int)),
      'incorrectAnswers',
      serializers.serialize(object.incorrectAnswers,
          specifiedType: const FullType(int)),
    ];

    return result;
  }

  @override
  GStatisticsDashboardData_statisticsDashboard_dailyBuckets deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result =
        GStatisticsDashboardData_statisticsDashboard_dailyBucketsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'start':
          result.start.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i2.GTime))! as _i2.GTime);
          break;
        case 'studySeconds':
          result.studySeconds = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'completedTasks':
          result.completedTasks = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'totalQuestions':
          result.totalQuestions = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'correctAnswers':
          result.correctAnswers = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'incorrectAnswers':
          result.incorrectAnswers = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
      }
    }

    return result.build();
  }
}

class _$GStatisticsDashboardData_statisticsDashboard_subjectBucketsSerializer
    implements
        StructuredSerializer<
            GStatisticsDashboardData_statisticsDashboard_subjectBuckets> {
  @override
  final Iterable<Type> types = const [
    GStatisticsDashboardData_statisticsDashboard_subjectBuckets,
    _$GStatisticsDashboardData_statisticsDashboard_subjectBuckets
  ];
  @override
  final String wireName =
      'GStatisticsDashboardData_statisticsDashboard_subjectBuckets';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GStatisticsDashboardData_statisticsDashboard_subjectBuckets object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'tagName',
      serializers.serialize(object.tagName,
          specifiedType: const FullType(String)),
      'isMiscellaneous',
      serializers.serialize(object.isMiscellaneous,
          specifiedType: const FullType(bool)),
      'studySeconds',
      serializers.serialize(object.studySeconds,
          specifiedType: const FullType(int)),
      'completedTasks',
      serializers.serialize(object.completedTasks,
          specifiedType: const FullType(int)),
      'totalQuestions',
      serializers.serialize(object.totalQuestions,
          specifiedType: const FullType(int)),
      'correctAnswers',
      serializers.serialize(object.correctAnswers,
          specifiedType: const FullType(int)),
      'incorrectAnswers',
      serializers.serialize(object.incorrectAnswers,
          specifiedType: const FullType(int)),
    ];
    Object? value;
    value = object.tagID;
    if (value != null) {
      result
        ..add('tagID')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  GStatisticsDashboardData_statisticsDashboard_subjectBuckets deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result =
        GStatisticsDashboardData_statisticsDashboard_subjectBucketsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'tagID':
          result.tagID = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'tagName':
          result.tagName = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'isMiscellaneous':
          result.isMiscellaneous = serializers.deserialize(value,
              specifiedType: const FullType(bool))! as bool;
          break;
        case 'studySeconds':
          result.studySeconds = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'completedTasks':
          result.completedTasks = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'totalQuestions':
          result.totalQuestions = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'correctAnswers':
          result.correctAnswers = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'incorrectAnswers':
          result.incorrectAnswers = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
      }
    }

    return result.build();
  }
}

class _$GStatisticsDashboardData extends GStatisticsDashboardData {
  @override
  final String G__typename;
  @override
  final GStatisticsDashboardData_statisticsDashboard statisticsDashboard;

  factory _$GStatisticsDashboardData(
          [void Function(GStatisticsDashboardDataBuilder)? updates]) =>
      (GStatisticsDashboardDataBuilder()..update(updates))._build();

  _$GStatisticsDashboardData._(
      {required this.G__typename, required this.statisticsDashboard})
      : super._();
  @override
  GStatisticsDashboardData rebuild(
          void Function(GStatisticsDashboardDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GStatisticsDashboardDataBuilder toBuilder() =>
      GStatisticsDashboardDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GStatisticsDashboardData &&
        G__typename == other.G__typename &&
        statisticsDashboard == other.statisticsDashboard;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, statisticsDashboard.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GStatisticsDashboardData')
          ..add('G__typename', G__typename)
          ..add('statisticsDashboard', statisticsDashboard))
        .toString();
  }
}

class GStatisticsDashboardDataBuilder
    implements
        Builder<GStatisticsDashboardData, GStatisticsDashboardDataBuilder> {
  _$GStatisticsDashboardData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GStatisticsDashboardData_statisticsDashboardBuilder? _statisticsDashboard;
  GStatisticsDashboardData_statisticsDashboardBuilder get statisticsDashboard =>
      _$this._statisticsDashboard ??=
          GStatisticsDashboardData_statisticsDashboardBuilder();
  set statisticsDashboard(
          GStatisticsDashboardData_statisticsDashboardBuilder?
              statisticsDashboard) =>
      _$this._statisticsDashboard = statisticsDashboard;

  GStatisticsDashboardDataBuilder() {
    GStatisticsDashboardData._initializeBuilder(this);
  }

  GStatisticsDashboardDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _statisticsDashboard = $v.statisticsDashboard.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GStatisticsDashboardData other) {
    _$v = other as _$GStatisticsDashboardData;
  }

  @override
  void update(void Function(GStatisticsDashboardDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GStatisticsDashboardData build() => _build();

  _$GStatisticsDashboardData _build() {
    _$GStatisticsDashboardData _$result;
    try {
      _$result = _$v ??
          _$GStatisticsDashboardData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GStatisticsDashboardData', 'G__typename'),
            statisticsDashboard: statisticsDashboard.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'statisticsDashboard';
        statisticsDashboard.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GStatisticsDashboardData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GStatisticsDashboardData_statisticsDashboard
    extends GStatisticsDashboardData_statisticsDashboard {
  @override
  final String G__typename;
  @override
  final GStatisticsDashboardData_statisticsDashboard_comparison comparison;
  @override
  final BuiltList<GStatisticsDashboardData_statisticsDashboard_dailyBuckets>
      dailyBuckets;
  @override
  final BuiltList<GStatisticsDashboardData_statisticsDashboard_subjectBuckets>
      subjectBuckets;

  factory _$GStatisticsDashboardData_statisticsDashboard(
          [void Function(GStatisticsDashboardData_statisticsDashboardBuilder)?
              updates]) =>
      (GStatisticsDashboardData_statisticsDashboardBuilder()..update(updates))
          ._build();

  _$GStatisticsDashboardData_statisticsDashboard._(
      {required this.G__typename,
      required this.comparison,
      required this.dailyBuckets,
      required this.subjectBuckets})
      : super._();
  @override
  GStatisticsDashboardData_statisticsDashboard rebuild(
          void Function(GStatisticsDashboardData_statisticsDashboardBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GStatisticsDashboardData_statisticsDashboardBuilder toBuilder() =>
      GStatisticsDashboardData_statisticsDashboardBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GStatisticsDashboardData_statisticsDashboard &&
        G__typename == other.G__typename &&
        comparison == other.comparison &&
        dailyBuckets == other.dailyBuckets &&
        subjectBuckets == other.subjectBuckets;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, comparison.hashCode);
    _$hash = $jc(_$hash, dailyBuckets.hashCode);
    _$hash = $jc(_$hash, subjectBuckets.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GStatisticsDashboardData_statisticsDashboard')
          ..add('G__typename', G__typename)
          ..add('comparison', comparison)
          ..add('dailyBuckets', dailyBuckets)
          ..add('subjectBuckets', subjectBuckets))
        .toString();
  }
}

class GStatisticsDashboardData_statisticsDashboardBuilder
    implements
        Builder<GStatisticsDashboardData_statisticsDashboard,
            GStatisticsDashboardData_statisticsDashboardBuilder> {
  _$GStatisticsDashboardData_statisticsDashboard? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GStatisticsDashboardData_statisticsDashboard_comparisonBuilder? _comparison;
  GStatisticsDashboardData_statisticsDashboard_comparisonBuilder
      get comparison => _$this._comparison ??=
          GStatisticsDashboardData_statisticsDashboard_comparisonBuilder();
  set comparison(
          GStatisticsDashboardData_statisticsDashboard_comparisonBuilder?
              comparison) =>
      _$this._comparison = comparison;

  ListBuilder<GStatisticsDashboardData_statisticsDashboard_dailyBuckets>?
      _dailyBuckets;
  ListBuilder<GStatisticsDashboardData_statisticsDashboard_dailyBuckets>
      get dailyBuckets => _$this._dailyBuckets ??= ListBuilder<
          GStatisticsDashboardData_statisticsDashboard_dailyBuckets>();
  set dailyBuckets(
          ListBuilder<
                  GStatisticsDashboardData_statisticsDashboard_dailyBuckets>?
              dailyBuckets) =>
      _$this._dailyBuckets = dailyBuckets;

  ListBuilder<GStatisticsDashboardData_statisticsDashboard_subjectBuckets>?
      _subjectBuckets;
  ListBuilder<GStatisticsDashboardData_statisticsDashboard_subjectBuckets>
      get subjectBuckets => _$this._subjectBuckets ??= ListBuilder<
          GStatisticsDashboardData_statisticsDashboard_subjectBuckets>();
  set subjectBuckets(
          ListBuilder<
                  GStatisticsDashboardData_statisticsDashboard_subjectBuckets>?
              subjectBuckets) =>
      _$this._subjectBuckets = subjectBuckets;

  GStatisticsDashboardData_statisticsDashboardBuilder() {
    GStatisticsDashboardData_statisticsDashboard._initializeBuilder(this);
  }

  GStatisticsDashboardData_statisticsDashboardBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _comparison = $v.comparison.toBuilder();
      _dailyBuckets = $v.dailyBuckets.toBuilder();
      _subjectBuckets = $v.subjectBuckets.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GStatisticsDashboardData_statisticsDashboard other) {
    _$v = other as _$GStatisticsDashboardData_statisticsDashboard;
  }

  @override
  void update(
      void Function(GStatisticsDashboardData_statisticsDashboardBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GStatisticsDashboardData_statisticsDashboard build() => _build();

  _$GStatisticsDashboardData_statisticsDashboard _build() {
    _$GStatisticsDashboardData_statisticsDashboard _$result;
    try {
      _$result = _$v ??
          _$GStatisticsDashboardData_statisticsDashboard._(
            G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
                r'GStatisticsDashboardData_statisticsDashboard', 'G__typename'),
            comparison: comparison.build(),
            dailyBuckets: dailyBuckets.build(),
            subjectBuckets: subjectBuckets.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'comparison';
        comparison.build();
        _$failedField = 'dailyBuckets';
        dailyBuckets.build();
        _$failedField = 'subjectBuckets';
        subjectBuckets.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GStatisticsDashboardData_statisticsDashboard',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GStatisticsDashboardData_statisticsDashboard_comparison
    extends GStatisticsDashboardData_statisticsDashboard_comparison {
  @override
  final String G__typename;
  @override
  final GStatisticsDashboardData_statisticsDashboard_comparison_current current;
  @override
  final GStatisticsDashboardData_statisticsDashboard_comparison_previous
      previous;
  @override
  final double? studySecondsChangePercentage;
  @override
  final double? adherenceChangePercentage;
  @override
  final double? totalQuestionsChangePercentage;
  @override
  final double? correctAnswersChangePercentage;

  factory _$GStatisticsDashboardData_statisticsDashboard_comparison(
          [void Function(
                  GStatisticsDashboardData_statisticsDashboard_comparisonBuilder)?
              updates]) =>
      (GStatisticsDashboardData_statisticsDashboard_comparisonBuilder()
            ..update(updates))
          ._build();

  _$GStatisticsDashboardData_statisticsDashboard_comparison._(
      {required this.G__typename,
      required this.current,
      required this.previous,
      this.studySecondsChangePercentage,
      this.adherenceChangePercentage,
      this.totalQuestionsChangePercentage,
      this.correctAnswersChangePercentage})
      : super._();
  @override
  GStatisticsDashboardData_statisticsDashboard_comparison rebuild(
          void Function(
                  GStatisticsDashboardData_statisticsDashboard_comparisonBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GStatisticsDashboardData_statisticsDashboard_comparisonBuilder toBuilder() =>
      GStatisticsDashboardData_statisticsDashboard_comparisonBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GStatisticsDashboardData_statisticsDashboard_comparison &&
        G__typename == other.G__typename &&
        current == other.current &&
        previous == other.previous &&
        studySecondsChangePercentage == other.studySecondsChangePercentage &&
        adherenceChangePercentage == other.adherenceChangePercentage &&
        totalQuestionsChangePercentage ==
            other.totalQuestionsChangePercentage &&
        correctAnswersChangePercentage == other.correctAnswersChangePercentage;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, current.hashCode);
    _$hash = $jc(_$hash, previous.hashCode);
    _$hash = $jc(_$hash, studySecondsChangePercentage.hashCode);
    _$hash = $jc(_$hash, adherenceChangePercentage.hashCode);
    _$hash = $jc(_$hash, totalQuestionsChangePercentage.hashCode);
    _$hash = $jc(_$hash, correctAnswersChangePercentage.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GStatisticsDashboardData_statisticsDashboard_comparison')
          ..add('G__typename', G__typename)
          ..add('current', current)
          ..add('previous', previous)
          ..add('studySecondsChangePercentage', studySecondsChangePercentage)
          ..add('adherenceChangePercentage', adherenceChangePercentage)
          ..add(
              'totalQuestionsChangePercentage', totalQuestionsChangePercentage)
          ..add(
              'correctAnswersChangePercentage', correctAnswersChangePercentage))
        .toString();
  }
}

class GStatisticsDashboardData_statisticsDashboard_comparisonBuilder
    implements
        Builder<GStatisticsDashboardData_statisticsDashboard_comparison,
            GStatisticsDashboardData_statisticsDashboard_comparisonBuilder> {
  _$GStatisticsDashboardData_statisticsDashboard_comparison? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GStatisticsDashboardData_statisticsDashboard_comparison_currentBuilder?
      _current;
  GStatisticsDashboardData_statisticsDashboard_comparison_currentBuilder
      get current => _$this._current ??=
          GStatisticsDashboardData_statisticsDashboard_comparison_currentBuilder();
  set current(
          GStatisticsDashboardData_statisticsDashboard_comparison_currentBuilder?
              current) =>
      _$this._current = current;

  GStatisticsDashboardData_statisticsDashboard_comparison_previousBuilder?
      _previous;
  GStatisticsDashboardData_statisticsDashboard_comparison_previousBuilder
      get previous => _$this._previous ??=
          GStatisticsDashboardData_statisticsDashboard_comparison_previousBuilder();
  set previous(
          GStatisticsDashboardData_statisticsDashboard_comparison_previousBuilder?
              previous) =>
      _$this._previous = previous;

  double? _studySecondsChangePercentage;
  double? get studySecondsChangePercentage =>
      _$this._studySecondsChangePercentage;
  set studySecondsChangePercentage(double? studySecondsChangePercentage) =>
      _$this._studySecondsChangePercentage = studySecondsChangePercentage;

  double? _adherenceChangePercentage;
  double? get adherenceChangePercentage => _$this._adherenceChangePercentage;
  set adherenceChangePercentage(double? adherenceChangePercentage) =>
      _$this._adherenceChangePercentage = adherenceChangePercentage;

  double? _totalQuestionsChangePercentage;
  double? get totalQuestionsChangePercentage =>
      _$this._totalQuestionsChangePercentage;
  set totalQuestionsChangePercentage(double? totalQuestionsChangePercentage) =>
      _$this._totalQuestionsChangePercentage = totalQuestionsChangePercentage;

  double? _correctAnswersChangePercentage;
  double? get correctAnswersChangePercentage =>
      _$this._correctAnswersChangePercentage;
  set correctAnswersChangePercentage(double? correctAnswersChangePercentage) =>
      _$this._correctAnswersChangePercentage = correctAnswersChangePercentage;

  GStatisticsDashboardData_statisticsDashboard_comparisonBuilder() {
    GStatisticsDashboardData_statisticsDashboard_comparison._initializeBuilder(
        this);
  }

  GStatisticsDashboardData_statisticsDashboard_comparisonBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _current = $v.current.toBuilder();
      _previous = $v.previous.toBuilder();
      _studySecondsChangePercentage = $v.studySecondsChangePercentage;
      _adherenceChangePercentage = $v.adherenceChangePercentage;
      _totalQuestionsChangePercentage = $v.totalQuestionsChangePercentage;
      _correctAnswersChangePercentage = $v.correctAnswersChangePercentage;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GStatisticsDashboardData_statisticsDashboard_comparison other) {
    _$v = other as _$GStatisticsDashboardData_statisticsDashboard_comparison;
  }

  @override
  void update(
      void Function(
              GStatisticsDashboardData_statisticsDashboard_comparisonBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GStatisticsDashboardData_statisticsDashboard_comparison build() => _build();

  _$GStatisticsDashboardData_statisticsDashboard_comparison _build() {
    _$GStatisticsDashboardData_statisticsDashboard_comparison _$result;
    try {
      _$result = _$v ??
          _$GStatisticsDashboardData_statisticsDashboard_comparison._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename,
                r'GStatisticsDashboardData_statisticsDashboard_comparison',
                'G__typename'),
            current: current.build(),
            previous: previous.build(),
            studySecondsChangePercentage: studySecondsChangePercentage,
            adherenceChangePercentage: adherenceChangePercentage,
            totalQuestionsChangePercentage: totalQuestionsChangePercentage,
            correctAnswersChangePercentage: correctAnswersChangePercentage,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'current';
        current.build();
        _$failedField = 'previous';
        previous.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GStatisticsDashboardData_statisticsDashboard_comparison',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GStatisticsDashboardData_statisticsDashboard_comparison_current
    extends GStatisticsDashboardData_statisticsDashboard_comparison_current {
  @override
  final String G__typename;
  @override
  final int studySeconds;
  @override
  final double adherencePercentage;
  @override
  final int totalQuestions;
  @override
  final int correctAnswers;
  @override
  final int tasksWithTests;
  @override
  final GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted
      planVsCompleted;

  factory _$GStatisticsDashboardData_statisticsDashboard_comparison_current(
          [void Function(
                  GStatisticsDashboardData_statisticsDashboard_comparison_currentBuilder)?
              updates]) =>
      (GStatisticsDashboardData_statisticsDashboard_comparison_currentBuilder()
            ..update(updates))
          ._build();

  _$GStatisticsDashboardData_statisticsDashboard_comparison_current._(
      {required this.G__typename,
      required this.studySeconds,
      required this.adherencePercentage,
      required this.totalQuestions,
      required this.correctAnswers,
      required this.tasksWithTests,
      required this.planVsCompleted})
      : super._();
  @override
  GStatisticsDashboardData_statisticsDashboard_comparison_current rebuild(
          void Function(
                  GStatisticsDashboardData_statisticsDashboard_comparison_currentBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GStatisticsDashboardData_statisticsDashboard_comparison_currentBuilder
      toBuilder() =>
          GStatisticsDashboardData_statisticsDashboard_comparison_currentBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GStatisticsDashboardData_statisticsDashboard_comparison_current &&
        G__typename == other.G__typename &&
        studySeconds == other.studySeconds &&
        adherencePercentage == other.adherencePercentage &&
        totalQuestions == other.totalQuestions &&
        correctAnswers == other.correctAnswers &&
        tasksWithTests == other.tasksWithTests &&
        planVsCompleted == other.planVsCompleted;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, studySeconds.hashCode);
    _$hash = $jc(_$hash, adherencePercentage.hashCode);
    _$hash = $jc(_$hash, totalQuestions.hashCode);
    _$hash = $jc(_$hash, correctAnswers.hashCode);
    _$hash = $jc(_$hash, tasksWithTests.hashCode);
    _$hash = $jc(_$hash, planVsCompleted.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GStatisticsDashboardData_statisticsDashboard_comparison_current')
          ..add('G__typename', G__typename)
          ..add('studySeconds', studySeconds)
          ..add('adherencePercentage', adherencePercentage)
          ..add('totalQuestions', totalQuestions)
          ..add('correctAnswers', correctAnswers)
          ..add('tasksWithTests', tasksWithTests)
          ..add('planVsCompleted', planVsCompleted))
        .toString();
  }
}

class GStatisticsDashboardData_statisticsDashboard_comparison_currentBuilder
    implements
        Builder<GStatisticsDashboardData_statisticsDashboard_comparison_current,
            GStatisticsDashboardData_statisticsDashboard_comparison_currentBuilder> {
  _$GStatisticsDashboardData_statisticsDashboard_comparison_current? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  int? _studySeconds;
  int? get studySeconds => _$this._studySeconds;
  set studySeconds(int? studySeconds) => _$this._studySeconds = studySeconds;

  double? _adherencePercentage;
  double? get adherencePercentage => _$this._adherencePercentage;
  set adherencePercentage(double? adherencePercentage) =>
      _$this._adherencePercentage = adherencePercentage;

  int? _totalQuestions;
  int? get totalQuestions => _$this._totalQuestions;
  set totalQuestions(int? totalQuestions) =>
      _$this._totalQuestions = totalQuestions;

  int? _correctAnswers;
  int? get correctAnswers => _$this._correctAnswers;
  set correctAnswers(int? correctAnswers) =>
      _$this._correctAnswers = correctAnswers;

  int? _tasksWithTests;
  int? get tasksWithTests => _$this._tasksWithTests;
  set tasksWithTests(int? tasksWithTests) =>
      _$this._tasksWithTests = tasksWithTests;

  GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompletedBuilder?
      _planVsCompleted;
  GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompletedBuilder
      get planVsCompleted => _$this._planVsCompleted ??=
          GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompletedBuilder();
  set planVsCompleted(
          GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompletedBuilder?
              planVsCompleted) =>
      _$this._planVsCompleted = planVsCompleted;

  GStatisticsDashboardData_statisticsDashboard_comparison_currentBuilder() {
    GStatisticsDashboardData_statisticsDashboard_comparison_current
        ._initializeBuilder(this);
  }

  GStatisticsDashboardData_statisticsDashboard_comparison_currentBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _studySeconds = $v.studySeconds;
      _adherencePercentage = $v.adherencePercentage;
      _totalQuestions = $v.totalQuestions;
      _correctAnswers = $v.correctAnswers;
      _tasksWithTests = $v.tasksWithTests;
      _planVsCompleted = $v.planVsCompleted.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GStatisticsDashboardData_statisticsDashboard_comparison_current other) {
    _$v = other
        as _$GStatisticsDashboardData_statisticsDashboard_comparison_current;
  }

  @override
  void update(
      void Function(
              GStatisticsDashboardData_statisticsDashboard_comparison_currentBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GStatisticsDashboardData_statisticsDashboard_comparison_current build() =>
      _build();

  _$GStatisticsDashboardData_statisticsDashboard_comparison_current _build() {
    _$GStatisticsDashboardData_statisticsDashboard_comparison_current _$result;
    try {
      _$result = _$v ??
          _$GStatisticsDashboardData_statisticsDashboard_comparison_current._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename,
                r'GStatisticsDashboardData_statisticsDashboard_comparison_current',
                'G__typename'),
            studySeconds: BuiltValueNullFieldError.checkNotNull(
                studySeconds,
                r'GStatisticsDashboardData_statisticsDashboard_comparison_current',
                'studySeconds'),
            adherencePercentage: BuiltValueNullFieldError.checkNotNull(
                adherencePercentage,
                r'GStatisticsDashboardData_statisticsDashboard_comparison_current',
                'adherencePercentage'),
            totalQuestions: BuiltValueNullFieldError.checkNotNull(
                totalQuestions,
                r'GStatisticsDashboardData_statisticsDashboard_comparison_current',
                'totalQuestions'),
            correctAnswers: BuiltValueNullFieldError.checkNotNull(
                correctAnswers,
                r'GStatisticsDashboardData_statisticsDashboard_comparison_current',
                'correctAnswers'),
            tasksWithTests: BuiltValueNullFieldError.checkNotNull(
                tasksWithTests,
                r'GStatisticsDashboardData_statisticsDashboard_comparison_current',
                'tasksWithTests'),
            planVsCompleted: planVsCompleted.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'planVsCompleted';
        planVsCompleted.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GStatisticsDashboardData_statisticsDashboard_comparison_current',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted
    extends GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted {
  @override
  final String G__typename;
  @override
  final int plannedSeconds;
  @override
  final int completedOnlySeconds;
  @override
  final int completedAndStudiedSeconds;
  @override
  final double completedOnlyPercentage;
  @override
  final double completedAndStudiedPercentage;

  factory _$GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted(
          [void Function(
                  GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompletedBuilder)?
              updates]) =>
      (GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompletedBuilder()
            ..update(updates))
          ._build();

  _$GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted._(
      {required this.G__typename,
      required this.plannedSeconds,
      required this.completedOnlySeconds,
      required this.completedAndStudiedSeconds,
      required this.completedOnlyPercentage,
      required this.completedAndStudiedPercentage})
      : super._();
  @override
  GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted
      rebuild(
              void Function(
                      GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompletedBuilder)
                  updates) =>
          (toBuilder()..update(updates)).build();

  @override
  GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompletedBuilder
      toBuilder() =>
          GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompletedBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted &&
        G__typename == other.G__typename &&
        plannedSeconds == other.plannedSeconds &&
        completedOnlySeconds == other.completedOnlySeconds &&
        completedAndStudiedSeconds == other.completedAndStudiedSeconds &&
        completedOnlyPercentage == other.completedOnlyPercentage &&
        completedAndStudiedPercentage == other.completedAndStudiedPercentage;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, plannedSeconds.hashCode);
    _$hash = $jc(_$hash, completedOnlySeconds.hashCode);
    _$hash = $jc(_$hash, completedAndStudiedSeconds.hashCode);
    _$hash = $jc(_$hash, completedOnlyPercentage.hashCode);
    _$hash = $jc(_$hash, completedAndStudiedPercentage.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted')
          ..add('G__typename', G__typename)
          ..add('plannedSeconds', plannedSeconds)
          ..add('completedOnlySeconds', completedOnlySeconds)
          ..add('completedAndStudiedSeconds', completedAndStudiedSeconds)
          ..add('completedOnlyPercentage', completedOnlyPercentage)
          ..add('completedAndStudiedPercentage', completedAndStudiedPercentage))
        .toString();
  }
}

class GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompletedBuilder
    implements
        Builder<
            GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted,
            GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompletedBuilder> {
  _$GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted?
      _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  int? _plannedSeconds;
  int? get plannedSeconds => _$this._plannedSeconds;
  set plannedSeconds(int? plannedSeconds) =>
      _$this._plannedSeconds = plannedSeconds;

  int? _completedOnlySeconds;
  int? get completedOnlySeconds => _$this._completedOnlySeconds;
  set completedOnlySeconds(int? completedOnlySeconds) =>
      _$this._completedOnlySeconds = completedOnlySeconds;

  int? _completedAndStudiedSeconds;
  int? get completedAndStudiedSeconds => _$this._completedAndStudiedSeconds;
  set completedAndStudiedSeconds(int? completedAndStudiedSeconds) =>
      _$this._completedAndStudiedSeconds = completedAndStudiedSeconds;

  double? _completedOnlyPercentage;
  double? get completedOnlyPercentage => _$this._completedOnlyPercentage;
  set completedOnlyPercentage(double? completedOnlyPercentage) =>
      _$this._completedOnlyPercentage = completedOnlyPercentage;

  double? _completedAndStudiedPercentage;
  double? get completedAndStudiedPercentage =>
      _$this._completedAndStudiedPercentage;
  set completedAndStudiedPercentage(double? completedAndStudiedPercentage) =>
      _$this._completedAndStudiedPercentage = completedAndStudiedPercentage;

  GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompletedBuilder() {
    GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted
        ._initializeBuilder(this);
  }

  GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompletedBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _plannedSeconds = $v.plannedSeconds;
      _completedOnlySeconds = $v.completedOnlySeconds;
      _completedAndStudiedSeconds = $v.completedAndStudiedSeconds;
      _completedOnlyPercentage = $v.completedOnlyPercentage;
      _completedAndStudiedPercentage = $v.completedAndStudiedPercentage;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted
          other) {
    _$v = other
        as _$GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted;
  }

  @override
  void update(
      void Function(
              GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompletedBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted
      build() => _build();

  _$GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted
      _build() {
    final _$result = _$v ??
        _$GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted
            ._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted',
              'G__typename'),
          plannedSeconds: BuiltValueNullFieldError.checkNotNull(
              plannedSeconds,
              r'GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted',
              'plannedSeconds'),
          completedOnlySeconds: BuiltValueNullFieldError.checkNotNull(
              completedOnlySeconds,
              r'GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted',
              'completedOnlySeconds'),
          completedAndStudiedSeconds: BuiltValueNullFieldError.checkNotNull(
              completedAndStudiedSeconds,
              r'GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted',
              'completedAndStudiedSeconds'),
          completedOnlyPercentage: BuiltValueNullFieldError.checkNotNull(
              completedOnlyPercentage,
              r'GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted',
              'completedOnlyPercentage'),
          completedAndStudiedPercentage: BuiltValueNullFieldError.checkNotNull(
              completedAndStudiedPercentage,
              r'GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted',
              'completedAndStudiedPercentage'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GStatisticsDashboardData_statisticsDashboard_comparison_previous
    extends GStatisticsDashboardData_statisticsDashboard_comparison_previous {
  @override
  final String G__typename;
  @override
  final int studySeconds;
  @override
  final double adherencePercentage;
  @override
  final int totalQuestions;
  @override
  final int correctAnswers;
  @override
  final int tasksWithTests;

  factory _$GStatisticsDashboardData_statisticsDashboard_comparison_previous(
          [void Function(
                  GStatisticsDashboardData_statisticsDashboard_comparison_previousBuilder)?
              updates]) =>
      (GStatisticsDashboardData_statisticsDashboard_comparison_previousBuilder()
            ..update(updates))
          ._build();

  _$GStatisticsDashboardData_statisticsDashboard_comparison_previous._(
      {required this.G__typename,
      required this.studySeconds,
      required this.adherencePercentage,
      required this.totalQuestions,
      required this.correctAnswers,
      required this.tasksWithTests})
      : super._();
  @override
  GStatisticsDashboardData_statisticsDashboard_comparison_previous rebuild(
          void Function(
                  GStatisticsDashboardData_statisticsDashboard_comparison_previousBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GStatisticsDashboardData_statisticsDashboard_comparison_previousBuilder
      toBuilder() =>
          GStatisticsDashboardData_statisticsDashboard_comparison_previousBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GStatisticsDashboardData_statisticsDashboard_comparison_previous &&
        G__typename == other.G__typename &&
        studySeconds == other.studySeconds &&
        adherencePercentage == other.adherencePercentage &&
        totalQuestions == other.totalQuestions &&
        correctAnswers == other.correctAnswers &&
        tasksWithTests == other.tasksWithTests;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, studySeconds.hashCode);
    _$hash = $jc(_$hash, adherencePercentage.hashCode);
    _$hash = $jc(_$hash, totalQuestions.hashCode);
    _$hash = $jc(_$hash, correctAnswers.hashCode);
    _$hash = $jc(_$hash, tasksWithTests.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GStatisticsDashboardData_statisticsDashboard_comparison_previous')
          ..add('G__typename', G__typename)
          ..add('studySeconds', studySeconds)
          ..add('adherencePercentage', adherencePercentage)
          ..add('totalQuestions', totalQuestions)
          ..add('correctAnswers', correctAnswers)
          ..add('tasksWithTests', tasksWithTests))
        .toString();
  }
}

class GStatisticsDashboardData_statisticsDashboard_comparison_previousBuilder
    implements
        Builder<
            GStatisticsDashboardData_statisticsDashboard_comparison_previous,
            GStatisticsDashboardData_statisticsDashboard_comparison_previousBuilder> {
  _$GStatisticsDashboardData_statisticsDashboard_comparison_previous? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  int? _studySeconds;
  int? get studySeconds => _$this._studySeconds;
  set studySeconds(int? studySeconds) => _$this._studySeconds = studySeconds;

  double? _adherencePercentage;
  double? get adherencePercentage => _$this._adherencePercentage;
  set adherencePercentage(double? adherencePercentage) =>
      _$this._adherencePercentage = adherencePercentage;

  int? _totalQuestions;
  int? get totalQuestions => _$this._totalQuestions;
  set totalQuestions(int? totalQuestions) =>
      _$this._totalQuestions = totalQuestions;

  int? _correctAnswers;
  int? get correctAnswers => _$this._correctAnswers;
  set correctAnswers(int? correctAnswers) =>
      _$this._correctAnswers = correctAnswers;

  int? _tasksWithTests;
  int? get tasksWithTests => _$this._tasksWithTests;
  set tasksWithTests(int? tasksWithTests) =>
      _$this._tasksWithTests = tasksWithTests;

  GStatisticsDashboardData_statisticsDashboard_comparison_previousBuilder() {
    GStatisticsDashboardData_statisticsDashboard_comparison_previous
        ._initializeBuilder(this);
  }

  GStatisticsDashboardData_statisticsDashboard_comparison_previousBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _studySeconds = $v.studySeconds;
      _adherencePercentage = $v.adherencePercentage;
      _totalQuestions = $v.totalQuestions;
      _correctAnswers = $v.correctAnswers;
      _tasksWithTests = $v.tasksWithTests;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GStatisticsDashboardData_statisticsDashboard_comparison_previous other) {
    _$v = other
        as _$GStatisticsDashboardData_statisticsDashboard_comparison_previous;
  }

  @override
  void update(
      void Function(
              GStatisticsDashboardData_statisticsDashboard_comparison_previousBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GStatisticsDashboardData_statisticsDashboard_comparison_previous build() =>
      _build();

  _$GStatisticsDashboardData_statisticsDashboard_comparison_previous _build() {
    final _$result = _$v ??
        _$GStatisticsDashboardData_statisticsDashboard_comparison_previous._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GStatisticsDashboardData_statisticsDashboard_comparison_previous',
              'G__typename'),
          studySeconds: BuiltValueNullFieldError.checkNotNull(
              studySeconds,
              r'GStatisticsDashboardData_statisticsDashboard_comparison_previous',
              'studySeconds'),
          adherencePercentage: BuiltValueNullFieldError.checkNotNull(
              adherencePercentage,
              r'GStatisticsDashboardData_statisticsDashboard_comparison_previous',
              'adherencePercentage'),
          totalQuestions: BuiltValueNullFieldError.checkNotNull(
              totalQuestions,
              r'GStatisticsDashboardData_statisticsDashboard_comparison_previous',
              'totalQuestions'),
          correctAnswers: BuiltValueNullFieldError.checkNotNull(
              correctAnswers,
              r'GStatisticsDashboardData_statisticsDashboard_comparison_previous',
              'correctAnswers'),
          tasksWithTests: BuiltValueNullFieldError.checkNotNull(
              tasksWithTests,
              r'GStatisticsDashboardData_statisticsDashboard_comparison_previous',
              'tasksWithTests'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GStatisticsDashboardData_statisticsDashboard_dailyBuckets
    extends GStatisticsDashboardData_statisticsDashboard_dailyBuckets {
  @override
  final String G__typename;
  @override
  final _i2.GTime start;
  @override
  final int studySeconds;
  @override
  final int completedTasks;
  @override
  final int totalQuestions;
  @override
  final int correctAnswers;
  @override
  final int incorrectAnswers;

  factory _$GStatisticsDashboardData_statisticsDashboard_dailyBuckets(
          [void Function(
                  GStatisticsDashboardData_statisticsDashboard_dailyBucketsBuilder)?
              updates]) =>
      (GStatisticsDashboardData_statisticsDashboard_dailyBucketsBuilder()
            ..update(updates))
          ._build();

  _$GStatisticsDashboardData_statisticsDashboard_dailyBuckets._(
      {required this.G__typename,
      required this.start,
      required this.studySeconds,
      required this.completedTasks,
      required this.totalQuestions,
      required this.correctAnswers,
      required this.incorrectAnswers})
      : super._();
  @override
  GStatisticsDashboardData_statisticsDashboard_dailyBuckets rebuild(
          void Function(
                  GStatisticsDashboardData_statisticsDashboard_dailyBucketsBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GStatisticsDashboardData_statisticsDashboard_dailyBucketsBuilder
      toBuilder() =>
          GStatisticsDashboardData_statisticsDashboard_dailyBucketsBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GStatisticsDashboardData_statisticsDashboard_dailyBuckets &&
        G__typename == other.G__typename &&
        start == other.start &&
        studySeconds == other.studySeconds &&
        completedTasks == other.completedTasks &&
        totalQuestions == other.totalQuestions &&
        correctAnswers == other.correctAnswers &&
        incorrectAnswers == other.incorrectAnswers;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, start.hashCode);
    _$hash = $jc(_$hash, studySeconds.hashCode);
    _$hash = $jc(_$hash, completedTasks.hashCode);
    _$hash = $jc(_$hash, totalQuestions.hashCode);
    _$hash = $jc(_$hash, correctAnswers.hashCode);
    _$hash = $jc(_$hash, incorrectAnswers.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GStatisticsDashboardData_statisticsDashboard_dailyBuckets')
          ..add('G__typename', G__typename)
          ..add('start', start)
          ..add('studySeconds', studySeconds)
          ..add('completedTasks', completedTasks)
          ..add('totalQuestions', totalQuestions)
          ..add('correctAnswers', correctAnswers)
          ..add('incorrectAnswers', incorrectAnswers))
        .toString();
  }
}

class GStatisticsDashboardData_statisticsDashboard_dailyBucketsBuilder
    implements
        Builder<GStatisticsDashboardData_statisticsDashboard_dailyBuckets,
            GStatisticsDashboardData_statisticsDashboard_dailyBucketsBuilder> {
  _$GStatisticsDashboardData_statisticsDashboard_dailyBuckets? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  _i2.GTimeBuilder? _start;
  _i2.GTimeBuilder get start => _$this._start ??= _i2.GTimeBuilder();
  set start(_i2.GTimeBuilder? start) => _$this._start = start;

  int? _studySeconds;
  int? get studySeconds => _$this._studySeconds;
  set studySeconds(int? studySeconds) => _$this._studySeconds = studySeconds;

  int? _completedTasks;
  int? get completedTasks => _$this._completedTasks;
  set completedTasks(int? completedTasks) =>
      _$this._completedTasks = completedTasks;

  int? _totalQuestions;
  int? get totalQuestions => _$this._totalQuestions;
  set totalQuestions(int? totalQuestions) =>
      _$this._totalQuestions = totalQuestions;

  int? _correctAnswers;
  int? get correctAnswers => _$this._correctAnswers;
  set correctAnswers(int? correctAnswers) =>
      _$this._correctAnswers = correctAnswers;

  int? _incorrectAnswers;
  int? get incorrectAnswers => _$this._incorrectAnswers;
  set incorrectAnswers(int? incorrectAnswers) =>
      _$this._incorrectAnswers = incorrectAnswers;

  GStatisticsDashboardData_statisticsDashboard_dailyBucketsBuilder() {
    GStatisticsDashboardData_statisticsDashboard_dailyBuckets
        ._initializeBuilder(this);
  }

  GStatisticsDashboardData_statisticsDashboard_dailyBucketsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _start = $v.start.toBuilder();
      _studySeconds = $v.studySeconds;
      _completedTasks = $v.completedTasks;
      _totalQuestions = $v.totalQuestions;
      _correctAnswers = $v.correctAnswers;
      _incorrectAnswers = $v.incorrectAnswers;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GStatisticsDashboardData_statisticsDashboard_dailyBuckets other) {
    _$v = other as _$GStatisticsDashboardData_statisticsDashboard_dailyBuckets;
  }

  @override
  void update(
      void Function(
              GStatisticsDashboardData_statisticsDashboard_dailyBucketsBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GStatisticsDashboardData_statisticsDashboard_dailyBuckets build() => _build();

  _$GStatisticsDashboardData_statisticsDashboard_dailyBuckets _build() {
    _$GStatisticsDashboardData_statisticsDashboard_dailyBuckets _$result;
    try {
      _$result = _$v ??
          _$GStatisticsDashboardData_statisticsDashboard_dailyBuckets._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename,
                r'GStatisticsDashboardData_statisticsDashboard_dailyBuckets',
                'G__typename'),
            start: start.build(),
            studySeconds: BuiltValueNullFieldError.checkNotNull(
                studySeconds,
                r'GStatisticsDashboardData_statisticsDashboard_dailyBuckets',
                'studySeconds'),
            completedTasks: BuiltValueNullFieldError.checkNotNull(
                completedTasks,
                r'GStatisticsDashboardData_statisticsDashboard_dailyBuckets',
                'completedTasks'),
            totalQuestions: BuiltValueNullFieldError.checkNotNull(
                totalQuestions,
                r'GStatisticsDashboardData_statisticsDashboard_dailyBuckets',
                'totalQuestions'),
            correctAnswers: BuiltValueNullFieldError.checkNotNull(
                correctAnswers,
                r'GStatisticsDashboardData_statisticsDashboard_dailyBuckets',
                'correctAnswers'),
            incorrectAnswers: BuiltValueNullFieldError.checkNotNull(
                incorrectAnswers,
                r'GStatisticsDashboardData_statisticsDashboard_dailyBuckets',
                'incorrectAnswers'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'start';
        start.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GStatisticsDashboardData_statisticsDashboard_dailyBuckets',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GStatisticsDashboardData_statisticsDashboard_subjectBuckets
    extends GStatisticsDashboardData_statisticsDashboard_subjectBuckets {
  @override
  final String G__typename;
  @override
  final String? tagID;
  @override
  final String tagName;
  @override
  final bool isMiscellaneous;
  @override
  final int studySeconds;
  @override
  final int completedTasks;
  @override
  final int totalQuestions;
  @override
  final int correctAnswers;
  @override
  final int incorrectAnswers;

  factory _$GStatisticsDashboardData_statisticsDashboard_subjectBuckets(
          [void Function(
                  GStatisticsDashboardData_statisticsDashboard_subjectBucketsBuilder)?
              updates]) =>
      (GStatisticsDashboardData_statisticsDashboard_subjectBucketsBuilder()
            ..update(updates))
          ._build();

  _$GStatisticsDashboardData_statisticsDashboard_subjectBuckets._(
      {required this.G__typename,
      this.tagID,
      required this.tagName,
      required this.isMiscellaneous,
      required this.studySeconds,
      required this.completedTasks,
      required this.totalQuestions,
      required this.correctAnswers,
      required this.incorrectAnswers})
      : super._();
  @override
  GStatisticsDashboardData_statisticsDashboard_subjectBuckets rebuild(
          void Function(
                  GStatisticsDashboardData_statisticsDashboard_subjectBucketsBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GStatisticsDashboardData_statisticsDashboard_subjectBucketsBuilder
      toBuilder() =>
          GStatisticsDashboardData_statisticsDashboard_subjectBucketsBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GStatisticsDashboardData_statisticsDashboard_subjectBuckets &&
        G__typename == other.G__typename &&
        tagID == other.tagID &&
        tagName == other.tagName &&
        isMiscellaneous == other.isMiscellaneous &&
        studySeconds == other.studySeconds &&
        completedTasks == other.completedTasks &&
        totalQuestions == other.totalQuestions &&
        correctAnswers == other.correctAnswers &&
        incorrectAnswers == other.incorrectAnswers;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, tagID.hashCode);
    _$hash = $jc(_$hash, tagName.hashCode);
    _$hash = $jc(_$hash, isMiscellaneous.hashCode);
    _$hash = $jc(_$hash, studySeconds.hashCode);
    _$hash = $jc(_$hash, completedTasks.hashCode);
    _$hash = $jc(_$hash, totalQuestions.hashCode);
    _$hash = $jc(_$hash, correctAnswers.hashCode);
    _$hash = $jc(_$hash, incorrectAnswers.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GStatisticsDashboardData_statisticsDashboard_subjectBuckets')
          ..add('G__typename', G__typename)
          ..add('tagID', tagID)
          ..add('tagName', tagName)
          ..add('isMiscellaneous', isMiscellaneous)
          ..add('studySeconds', studySeconds)
          ..add('completedTasks', completedTasks)
          ..add('totalQuestions', totalQuestions)
          ..add('correctAnswers', correctAnswers)
          ..add('incorrectAnswers', incorrectAnswers))
        .toString();
  }
}

class GStatisticsDashboardData_statisticsDashboard_subjectBucketsBuilder
    implements
        Builder<GStatisticsDashboardData_statisticsDashboard_subjectBuckets,
            GStatisticsDashboardData_statisticsDashboard_subjectBucketsBuilder> {
  _$GStatisticsDashboardData_statisticsDashboard_subjectBuckets? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _tagID;
  String? get tagID => _$this._tagID;
  set tagID(String? tagID) => _$this._tagID = tagID;

  String? _tagName;
  String? get tagName => _$this._tagName;
  set tagName(String? tagName) => _$this._tagName = tagName;

  bool? _isMiscellaneous;
  bool? get isMiscellaneous => _$this._isMiscellaneous;
  set isMiscellaneous(bool? isMiscellaneous) =>
      _$this._isMiscellaneous = isMiscellaneous;

  int? _studySeconds;
  int? get studySeconds => _$this._studySeconds;
  set studySeconds(int? studySeconds) => _$this._studySeconds = studySeconds;

  int? _completedTasks;
  int? get completedTasks => _$this._completedTasks;
  set completedTasks(int? completedTasks) =>
      _$this._completedTasks = completedTasks;

  int? _totalQuestions;
  int? get totalQuestions => _$this._totalQuestions;
  set totalQuestions(int? totalQuestions) =>
      _$this._totalQuestions = totalQuestions;

  int? _correctAnswers;
  int? get correctAnswers => _$this._correctAnswers;
  set correctAnswers(int? correctAnswers) =>
      _$this._correctAnswers = correctAnswers;

  int? _incorrectAnswers;
  int? get incorrectAnswers => _$this._incorrectAnswers;
  set incorrectAnswers(int? incorrectAnswers) =>
      _$this._incorrectAnswers = incorrectAnswers;

  GStatisticsDashboardData_statisticsDashboard_subjectBucketsBuilder() {
    GStatisticsDashboardData_statisticsDashboard_subjectBuckets
        ._initializeBuilder(this);
  }

  GStatisticsDashboardData_statisticsDashboard_subjectBucketsBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _tagID = $v.tagID;
      _tagName = $v.tagName;
      _isMiscellaneous = $v.isMiscellaneous;
      _studySeconds = $v.studySeconds;
      _completedTasks = $v.completedTasks;
      _totalQuestions = $v.totalQuestions;
      _correctAnswers = $v.correctAnswers;
      _incorrectAnswers = $v.incorrectAnswers;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GStatisticsDashboardData_statisticsDashboard_subjectBuckets other) {
    _$v =
        other as _$GStatisticsDashboardData_statisticsDashboard_subjectBuckets;
  }

  @override
  void update(
      void Function(
              GStatisticsDashboardData_statisticsDashboard_subjectBucketsBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GStatisticsDashboardData_statisticsDashboard_subjectBuckets build() =>
      _build();

  _$GStatisticsDashboardData_statisticsDashboard_subjectBuckets _build() {
    final _$result = _$v ??
        _$GStatisticsDashboardData_statisticsDashboard_subjectBuckets._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GStatisticsDashboardData_statisticsDashboard_subjectBuckets',
              'G__typename'),
          tagID: tagID,
          tagName: BuiltValueNullFieldError.checkNotNull(
              tagName,
              r'GStatisticsDashboardData_statisticsDashboard_subjectBuckets',
              'tagName'),
          isMiscellaneous: BuiltValueNullFieldError.checkNotNull(
              isMiscellaneous,
              r'GStatisticsDashboardData_statisticsDashboard_subjectBuckets',
              'isMiscellaneous'),
          studySeconds: BuiltValueNullFieldError.checkNotNull(
              studySeconds,
              r'GStatisticsDashboardData_statisticsDashboard_subjectBuckets',
              'studySeconds'),
          completedTasks: BuiltValueNullFieldError.checkNotNull(
              completedTasks,
              r'GStatisticsDashboardData_statisticsDashboard_subjectBuckets',
              'completedTasks'),
          totalQuestions: BuiltValueNullFieldError.checkNotNull(
              totalQuestions,
              r'GStatisticsDashboardData_statisticsDashboard_subjectBuckets',
              'totalQuestions'),
          correctAnswers: BuiltValueNullFieldError.checkNotNull(
              correctAnswers,
              r'GStatisticsDashboardData_statisticsDashboard_subjectBuckets',
              'correctAnswers'),
          incorrectAnswers: BuiltValueNullFieldError.checkNotNull(
              incorrectAnswers,
              r'GStatisticsDashboardData_statisticsDashboard_subjectBuckets',
              'incorrectAnswers'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
