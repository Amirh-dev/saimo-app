import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/presentation/screens/tasks/tag_selection.dart';

void main() {
  group('canonicalTagName', () {
    test('matches the server: Persian letters and digits, lower case, spaces',
        () {
      expect(canonicalTagName('  كتاب   Book ٢ '), 'کتاب book ۲');
      expect(canonicalTagName('ريحانه'), 'ریحانه');
      expect(canonicalTagName('   '), '');
    });
  });

  group('TagSelection', () {
    test('treats spelling variants as one tag, as the server will', () {
      final selection = TagSelection(initial: ['کتاب'])
        ..add('كتاب')
        ..add('  Book ');
      expect(selection.offered, ['کتاب', 'book']);
      expect(selection.selected, ['کتاب', 'book']);
    });

    test('starts tags that can no longer be saved turned off', () {
      final selection =
          TagSelection(initial: ['ریاضی', 'اسپم'], initialOff: ['اسپم']);
      expect(selection.offered, ['ریاضی', 'اسپم']);
      expect(selection.selected, ['ریاضی']);
      selection.toggle('اسپم');
      expect(selection.selected, ['ریاضی', 'اسپم']);
    });

    test('matches known tags across letter variants', () {
      final selection = TagSelection(catalog: ['ریاضیات', 'زبان انگلیسی']);
      expect(selection.matches('رياض'), ['ریاضیات']);
    });

    test('saves a half-typed tag in its canonical form', () {
      final selection = TagSelection()..draftChanged(' كنكور ');
      expect(selection.selected, ['کنکور']);
    });
  });
}
