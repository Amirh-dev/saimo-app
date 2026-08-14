import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/presentation/screens/app_navigation_tabs.dart';
import 'package:simo_learn/presentation/screens/goals/index.dart';
import 'package:simo_learn/presentation/screens/profile/index.dart';
import 'package:simo_learn/presentation/screens/statistics/index.dart';
import 'package:simo_learn/utils/extentions.dart';
import 'package:vibration/vibration.dart';

import '../presentation/screens/tasks/index.dart';

const Map<String, String> _englishToPersianNumbersMap = {
  '0': '۰',
  '1': '۱',
  '2': '۲',
  '3': '۳',
  '4': '۴',
  '5': '۵',
  '6': '۶',
  '7': '۷',
  '8': '۸',
  '9': '۹',
};

const Map<String, String> _persianArabicToEnglishNumbersMap = {
  '۰': '0',
  '۱': '1',
  '۲': '2',
  '۳': '3',
  '۴': '4',
  '۵': '5',
  '۶': '6',
  '۷': '7',
  '۸': '8',
  '۹': '9',
  '٠': '0',
  '١': '1',
  '٢': '2',
  '٣': '3',
  '٤': '4',
  '٥': '5',
  '٦': '6',
  '٧': '7',
  '٨': '8',
  '٩': '9',
};

String? formatDate(DateTime? date) {
  if (date == null) return null;
  return '${date.day}/${date.month}/${date.year}';
}

bool isNullOrEmpty(String? value) {
  return value == null || value.isEmpty;
}

String removeSeparators(String input) {
  return input.replaceAll(',', '');
}

String convertToEnglishNumbers(String input) {
  return input.replaceAllMapped(RegExp(r'[۰-۹٠-٩]'), (match) {
    return _persianArabicToEnglishNumbersMap[match.group(0)] ?? match.group(0)!;
  });
}

String convertToPersianNumbers(String input, {bool addSeparator = false}) {
  final normalizedInput = convertToEnglishNumbers(input);

  if (addSeparator) {
    String separator = ',';

    String reversedInput = normalizedInput.split('').reversed.join();

    String result = reversedInput.replaceAllMapped(RegExp(r'\d{1,3}'), (match) {
      return '${match.group(0)!}$separator';
    });

    return result.split('').reversed.join().replaceAllMapped(RegExp(r'\d'),
        (match) {
      return _englishToPersianNumbersMap[match.group(0)]!;
    }).replaceFirst(',', '');
  } else {
    return normalizedInput.replaceAllMapped(RegExp(r'\d'), (match) {
      return _englishToPersianNumbersMap[match.group(0)]!;
    });
  }
}

class PersianDigitsInputFormatter extends TextInputFormatter {
  const PersianDigitsInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final persianText = convertToPersianNumbers(newValue.text);

    final baseOffset =
        newValue.selection.baseOffset.clamp(0, persianText.length).toInt();
    final extentOffset =
        newValue.selection.extentOffset.clamp(0, persianText.length).toInt();

    return newValue.copyWith(
      text: persianText,
      selection: TextSelection(
        baseOffset: baseOffset,
        extentOffset: extentOffset,
      ),
    );
  }
}

bool isInRoute(BuildContext context, String path) {
  return ModalRoute.of(context) != null &&
      ModalRoute.of(context)!.settings.name != null &&
      ModalRoute.of(context)!.settings.name == path;
}

String convertQueryListToUrl(List<String> queryList, String baseUrl) {
  String queryString = queryList.join('&');
  print('rrr $queryString');
  String fullUrl = "$baseUrl?$queryString";
  if (queryList.isEmpty) return baseUrl;
  return fullUrl;
}

String convertToSolarDate(
  DateTime utcDateTime, {
  bool justDay = false,
  bool justDate = false,
  bool justTime = false,
  bool justTimePair = false,
  bool justTimePairWithouUTC = false,
  bool justMonthName = false,
  bool justMonth = false,
  bool withOutDay = false,
  bool justDayName = false,
  bool justYear = false,
  bool justDateNumbers = false,
}) {
  Jalali jalaliDate = Jalali.fromDateTime(utcDateTime);

  List<String> monthNames = [
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
    'اسفند'
  ];
  final weekDays = [
    '',
    'شنبه',
    'یکشنبه',
    'دوشنبه',
    'سه شنبه',
    'چهارشنبه',
    'پنجشنبه',
    'جمعه',
  ];
  String formattedDate = '';
  final dateTime = utcDateTime.add(
    const Duration(hours: 3, minutes: 30),
  );
  final day =
      '${weekDays[jalaliDate.weekDay]} ${jalaliDate.day.toString().padLeft(2, '0')}';
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');

  if (justYear) {
    return jalaliDate.year.toString();
  } else if (justDateNumbers) {
    return '${jalaliDate.year}/${jalaliDate.month.toString().padLeft(2, '0')}/${jalaliDate.day.toString().padLeft(2, '0')}';
  } else if (justDayName) {
    return weekDays[jalaliDate.weekDay];
  } else if (withOutDay) {
    formattedDate =
        '$hour:$minute - ${jalaliDate.month.toString().padLeft(2, '0')}/${jalaliDate.day.toString().padLeft(2, '0')}';
  } else if (justMonthName) {
    formattedDate = monthNames[jalaliDate.month - 1];
  } else if (justMonth) {
    formattedDate = jalaliDate.month.toString().padLeft(2, '0');
  } else if (justDay) {
    formattedDate = jalaliDate.day.toString().padLeft(2, '0');
  } else if (justDate) {
    formattedDate =
        '${weekDays[jalaliDate.weekDay]} ${jalaliDate.month.toString().padLeft(2, '0')}/${jalaliDate.day.toString().padLeft(2, '0')}';
  } else if (justTime) {
    formattedDate = '$hour:$minute - $day';
  } else if (justTimePair) {
    formattedDate = '$hour:$minute';
  } else if (justTimePairWithouUTC) {
    final hour = utcDateTime.hour.toString().padLeft(2, '0');
    final minute = utcDateTime.minute.toString().padLeft(2, '0');

    formattedDate = '$hour:$minute';
  } else {
    formattedDate =
        '$hour:$minute - ${weekDays[jalaliDate.weekDay]} ${jalaliDate.month.toString().padLeft(2, '0')}/${jalaliDate.day.toString().padLeft(2, '0')}';
  }
  return formattedDate;
}

Future<void> vibrate({int? duration}) async {
  if ((await Vibration.hasVibrator())) {
    Vibration.vibrate(duration: duration ?? 300);
    return;
  } else {}

  try {
    await HapticFeedback.mediumImpact();
  } catch (e) {}
}

String weekDayEnToFa(String day) {
  final weekDaysEnToFa = {
    'fri': 'جمعه',
    'sat': 'پنجشنبه',
    'sun': 'شنبه',
    'mon': 'دوشنبه',
    'tue': 'سه شنبه',
    'wed': 'چهارشنبه',
    'thu': 'پنجشنبه',
  };

  return weekDaysEnToFa[day.toLowerCase()] ?? '';
}

void scrollToBottom(ScrollController controller) {
  controller.animateTo(
    controller.position.maxScrollExtent,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOut,
  );
}

// HttpException getHttpException(Object object) {
//   if (object is HttpException) {
//     print('${object}errorroro');
//     if (object.message != '') {
//       ToastService().showToast(
//         description: object.message,
//         type: ToastType.error,
//         errorCode: object.statusCode.toString(),
//       );
//     }
//   }

//   return object is HttpException
//       ? object
//       : HttpException(400, object.toString());
// }

Color hexToColor(String hexString) {
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
  buffer.write(hexString.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

String getHijriMonthName(int month) {
  List<String> arabicMonths = [
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الآخر',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة'
  ];

  return arabicMonths[month - 1];
}

Future<(Map<String, String>, String)> getDeviceInfo() async {
  final deviceInfoPlugin = DeviceInfoPlugin();
  String brand = '';
  String model = '';
  String version = '';
  String sdkVersion = '';
  String buildNumber = '';
  String deviceId = '';

  if (Platform.isAndroid) {
    final info = await deviceInfoPlugin.androidInfo;
    brand = info.brand;
    model = info.model;
    version = info.version.release; // Android version name (e.g., "10")
    sdkVersion = info.version.sdkInt.toString(); // SDK version (e.g., "29")
    buildNumber = info.version.incremental; // Build number
    deviceId = info.id; // Device ID
  } else {
    final info = await deviceInfoPlugin.iosInfo;
    brand = 'Apple';
    model = info.utsname.machine;
    version = info.systemVersion;
    sdkVersion = info.systemVersion;
    buildNumber = info.systemName;
    deviceId = info.identifierForVendor ?? '';
  }

  String sendingInfo = (
    Platform.isAndroid
        ? (await deviceInfoPlugin.androidInfo)
        : (await deviceInfoPlugin.iosInfo),
  ).toString();

  return (
    {
      'brand': brand,
      'model': model,
      'version': version,
      'sdkVersion': sdkVersion,
      'buildNumber': buildNumber,
      'deviceId': deviceId,
    },
    sendingInfo,
  );
}

String formatTime(int seconds) {
  int minutes = seconds ~/ 60;
  int remainingSeconds = seconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
}

//   final Uri zoiperUri = Uri.parse('zoiper://9$phoneNumber');
//   if (await canLaunchUrl(zoiperUri)) {
//     await launchUrl(zoiperUri);
//   } else {
//     // await launchUrl(telUri);

//     throw 'Could not launch Zoiper';
//   }
// }

// void launchPhoneDialer(String phoneNumber) async {
//   final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
//   if (await canLaunchUrl(phoneUri)) {
//     await launchUrl(phoneUri);
//   } else {
//     throw 'Could not launch $phoneUri';
//   }
  void  navigateToIndex(BuildContext context, int index, currentIndex) {
    if(index == currentIndex) return;
    switch (index) {
      case 0:
        context.toOff(const GoalScreen());
        break;
      case 1:
        context.toOff(const TasksScreen());
        break;
      case 2:
        context.toOff(const GoalScreen());
        break;
      case 3:
        context.toOff(const StatisticsScreen());
        break;
      case 4:
        context.toOff(const ProfileScreen());
        break;
    }
  }