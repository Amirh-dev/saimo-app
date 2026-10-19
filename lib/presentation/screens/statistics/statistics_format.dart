import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/features/statistics/cubit/statistics_state.dart';
import 'package:simo_learn/utils/jalali_text.dart';

/// Persian names and formats shared by the statistics screen. Digits stay
/// Latin here; ReText shows them as Persian.
class StatsFormat {
  const StatsFormat._();

  static String month(Jalali date) => JalaliText.month(date);

  static String weekday(Jalali date) => JalaliText.weekday(date);

  static String weekdayInitial(Jalali date) => JalaliText.weekdayInitial(date);

  /// «۲۸ مهر»
  static String dayMonth(Jalali date) => JalaliText.dayMonth(date);

  /// «سه‌شنبه ۲۸ مهر»
  static String fullDay(Jalali date) => JalaliText.fullDay(date);

  /// «۴:۰۵»
  static String clock(int seconds) {
    final minutes = seconds ~/ 60;
    return '${minutes ~/ 60}:${(minutes % 60).toString().padLeft(2, '0')}';
  }

  /// «۴ ساعت و ۵ دقیقه»
  static String duration(int seconds) {
    final minutes = seconds ~/ 60;
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    if (hours > 0 && rest > 0) return '$hours ساعت و $rest دقیقه';
    if (hours > 0) return '$hours ساعت';
    if (rest > 0) return '$rest دقیقه';
    return seconds > 0 ? 'کمتر از ۱ دقیقه' : '۰ دقیقه';
  }

  /// «۳٫۸»: one decimal, dropped when whole.
  static String decimal(double value) {
    final rounded = (value * 10).round() / 10;
    return rounded == rounded.roundToDouble()
        ? rounded.toInt().toString()
        : rounded.toStringAsFixed(1).replaceAll('.', '٫');
  }

  /// The range in the navigator: «۲۵ مهر تا ۱ آبان ۱۴۰۵», «مهر ۱۴۰۵».
  static String rangeTitle(StatisticsRange range) {
    final first = range.first;
    final last = range.last;
    switch (range.period) {
      case StatisticsPeriod.today:
        return '${fullDay(first)} ${first.year}';
      case StatisticsPeriod.month:
        return '${month(first)} ${first.year}';
      case StatisticsPeriod.week:
      case StatisticsPeriod.custom:
        if (range.dayCount == 1) return '${fullDay(first)} ${first.year}';
        if (first.year != last.year) {
          return '${dayMonth(first)} ${first.year} تا ${dayMonth(last)} ${last.year}';
        }
        if (first.month == last.month) {
          return '${first.day} تا ${dayMonth(last)} ${last.year}';
        }
        return '${dayMonth(first)} تا ${dayMonth(last)} ${last.year}';
    }
  }

  /// A short range for the sticky bar: no year.
  static String rangeShort(StatisticsRange range) {
    final first = range.first;
    final last = range.last;
    switch (range.period) {
      case StatisticsPeriod.today:
        return fullDay(first);
      case StatisticsPeriod.month:
        return '${month(first)} ${first.year}';
      case StatisticsPeriod.week:
      case StatisticsPeriod.custom:
        if (range.dayCount == 1) return fullDay(first);
        return '${dayMonth(first)} تا ${dayMonth(last)}';
    }
  }

  /// «این هفته» for the running range, «هفته» for another.
  static String rangeName(StatisticsRange range) {
    final current = range.isCurrent;
    switch (range.period) {
      case StatisticsPeriod.today:
        return current ? 'امروز' : 'روز';
      case StatisticsPeriod.week:
        return current ? 'این هفته' : 'هفته';
      case StatisticsPeriod.month:
        return current ? 'این ماه' : 'ماه';
      case StatisticsPeriod.custom:
        return 'بازه‌ی دلخواه';
    }
  }

  /// What the running range is called under the navigator.
  static String currentCaption(StatisticsRange range) {
    switch (range.period) {
      case StatisticsPeriod.today:
        return 'امروز';
      case StatisticsPeriod.week:
        return 'هفته‌ی جاری';
      case StatisticsPeriod.month:
        return 'ماه جاری';
      case StatisticsPeriod.custom:
        return '${range.dayCount} روز';
    }
  }

  /// The button that brings a past range back to the running one.
  static String backToCurrent(StatisticsRange range) {
    switch (range.period) {
      case StatisticsPeriod.today:
        return 'برگشت به امروز';
      case StatisticsPeriod.week:
      case StatisticsPeriod.custom:
        return 'برگشت به این هفته';
      case StatisticsPeriod.month:
        return 'برگشت به این ماه';
    }
  }

  /// The range a change is measured against: «هفته‌ی قبل».
  static String previousName(StatisticsRange range) {
    switch (range.period) {
      case StatisticsPeriod.today:
        return range.isCurrent ? 'دیروز' : 'روز قبل';
      case StatisticsPeriod.week:
        return 'هفته‌ی قبل';
      case StatisticsPeriod.month:
        return 'ماه قبل';
      case StatisticsPeriod.custom:
        return 'بازه‌ی قبل';
    }
  }

  /// «زمان مطالعه‌ی این هفته»
  static String studyTitle(StatisticsRange range) {
    if (!range.isCurrent) return 'زمان مطالعه';
    switch (range.period) {
      case StatisticsPeriod.today:
        return 'زمان مطالعه‌ی امروز';
      case StatisticsPeriod.week:
        return 'زمان مطالعه‌ی این هفته';
      case StatisticsPeriod.month:
        return 'زمان مطالعه‌ی این ماه';
      case StatisticsPeriod.custom:
        return 'زمان مطالعه در این بازه';
    }
  }
}
