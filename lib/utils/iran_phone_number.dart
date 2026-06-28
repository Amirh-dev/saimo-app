import 'helpers.dart';

/// Normalizes an Iranian mobile number to E.164 (`+989xxxxxxxxx`).
///
/// Returns `null` when [input] is not a supported Iranian mobile number.
String? normalizeIranianMobileNumber(String input) {
  var value = convertToEnglishNumbers(input).trim();
  value = value.replaceAll(RegExp(r'[\s\-()]'), '');

  if (value.startsWith('0098')) {
    value = '+98${value.substring(4)}';
  } else if (value.startsWith('98')) {
    value = '+$value';
  } else if (value.startsWith('09')) {
    value = '+98${value.substring(1)}';
  }

  return RegExp(r'^\+989\d{9}$').hasMatch(value) ? value : null;
}

String? maskIranianMobileNumber(String input) {
  final normalized = normalizeIranianMobileNumber(input);
  if (normalized == null) return null;

  final localNumber = '0${normalized.substring(3)}';
  return '${localNumber.substring(0, 4)}***${localNumber.substring(8)}';
}
