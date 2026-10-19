import 'package:shamsi_date/shamsi_date.dart';

/// Persian names for Jalali dates. Digits stay Latin here; ReText shows
/// them as Persian.
class JalaliText {
  const JalaliText._();

  static const months = [
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند',
  ];

  /// By Jalali weekday, Saturday first.
  static const weekdays = [
    'شنبه',
    'یکشنبه',
    'دوشنبه',
    'سه‌شنبه',
    'چهارشنبه',
    'پنج‌شنبه',
    'جمعه',
  ];

  static const weekdayInitials = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];

  static String month(Jalali date) => months[date.month - 1];

  static String weekday(Jalali date) => weekdays[date.weekDay - 1];

  static String weekdayInitial(Jalali date) =>
      weekdayInitials[date.weekDay - 1];

  /// «۲۸ مهر»
  static String dayMonth(Jalali date) => '${date.day} ${month(date)}';

  /// «سه‌شنبه ۲۸ مهر»
  static String fullDay(Jalali date) => '${weekday(date)} ${dayMonth(date)}';

  /// «سه‌شنبه ۲۸ مهر ۱۴۰۵»
  static String fullDate(Jalali date) => '${fullDay(date)} ${date.year}';
}
