import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/utils/iran_phone_number.dart';

void main() {
  group('normalizeIranianMobileNumber', () {
    test('normalizes supported Iranian formats to E.164', () {
      expect(normalizeIranianMobileNumber('09123456789'), '+989123456789');
      expect(normalizeIranianMobileNumber('+989123456789'), '+989123456789');
      expect(normalizeIranianMobileNumber('00989123456789'), '+989123456789');
      expect(normalizeIranianMobileNumber('989123456789'), '+989123456789');
    });

    test('normalizes Persian and Arabic digits', () {
      expect(normalizeIranianMobileNumber('۰۹۱۲۳۴۵۶۷۸۹'), '+989123456789');
      expect(normalizeIranianMobileNumber('٠٩١٢٣٤٥٦٧٨٩'), '+989123456789');
    });

    test('allows common visual separators', () {
      expect(normalizeIranianMobileNumber('0912 345 67 89'), '+989123456789');
      expect(
          normalizeIranianMobileNumber('+98 (912) 345-6789'), '+989123456789');
    });

    test('rejects invalid and non-mobile numbers', () {
      expect(normalizeIranianMobileNumber(''), isNull);
      expect(normalizeIranianMobileNumber('02112345678'), isNull);
      expect(normalizeIranianMobileNumber('0912345678'), isNull);
      expect(normalizeIranianMobileNumber('+9891234567890'), isNull);
    });

    test('masks a valid number for display', () {
      expect(maskIranianMobileNumber('+989123456789'), '0912***789');
      expect(maskIranianMobileNumber('invalid'), isNull);
    });
  });
}
