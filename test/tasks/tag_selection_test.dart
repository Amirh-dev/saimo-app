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

    test('finds a tag by its other names', () {
      final selection = TagSelection(
        catalog: ['مطالعه', 'آزمون و تست', 'تست و مطالعه', 'ریاضی'],
        aliases: {
          'مطالعه': ['خواندن'],
        },
      );
      expect(selection.matches('خواندن'), ['مطالعه']);
      expect(selection.matches('خوا'), ['مطالعه']);
      expect(selection.matches('تست'), ['آزمون و تست', 'تست و مطالعه']);
      expect(selection.matches('آزمون'), ['آزمون و تست']);
    });

    test('reads the known tags when it needs them, as they may load late', () {
      var catalog = (
        names: <String>[],
        aliases: <String, List<String>>{},
        children: <String, List<String>>{},
      );
      final selection = TagSelection(readCatalog: () => catalog);
      expect(selection.matches('تست'), isEmpty);
      catalog = (names: ['آزمون و تست'], aliases: {}, children: {});
      expect(selection.matches('تست'), ['آزمون و تست']);
    });

    test('finds the tags under a subject too', () {
      final selection = TagSelection(
          catalog: ['ریاضی', 'ریاضی دهم', 'حسابان یازدهم', 'فیزیک دهم']);
      expect(selection.matches('حساب'), ['حسابان یازدهم']);
      expect(selection.matches('دهم'),
          ['ریاضی دهم', 'فیزیک دهم', 'حسابان یازدهم']);
    });

    test('saves a half-typed tag in its canonical form', () {
      final selection = TagSelection()..draftChanged(' كنكور ');
      expect(selection.selected, ['کنکور']);
    });
  });

  group('TagSelection for a title', () {
    /// A selection that has asked the server about [title] and been told
    /// [names].
    Future<TagSelection> suggested(
      String title,
      List<String> names, {
      Map<String, List<String>> aliases = const {},
      List<String> catalog = const [],
      Map<String, List<String>> children = const {},
    }) async {
      final selection = TagSelection(
        suggest: (_) async => names,
        aliases: aliases,
        catalog: catalog,
        children: children,
      )..titleChanged(title);
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return selection;
    }

    test('selects the subject a title names, and shows a fuller title',
        () async {
      final selection = await suggested(
          'ریاضی', ['ریاضی', 'ریاضی دهم', 'ریاضی یازدهم', 'ریاضی دوازدهم']);
      expect(selection.offered,
          ['ریاضی', 'ریاضی دهم', 'ریاضی یازدهم', 'ریاضی دوازدهم']);
      expect(selection.selected, ['ریاضی']);
      expect(selection.fullerTitleExample, 'ریاضی دهم');
      expect(selection.needsClearerTitle, isFalse);
    });

    test('a named course is selected; its subject stays on offer', () async {
      final selection = await suggested(
          'مرور ریاضی دهم', ['ریاضی', 'ریاضی دهم', 'ریاضی یازدهم']);
      expect(selection.offered, ['ریاضی دهم', 'ریاضی', 'ریاضی یازدهم']);
      expect(selection.selected, ['ریاضی دهم']);
      expect(selection.fullerTitleExample, isNull);
    });

    test('offers the known tags related to the title, without selecting them',
        () async {
      final selection = await suggested(
        'ریاضی یازدهم',
        const [],
        catalog: [
          'ریاضی', 'ریاضی دهم', 'ریاضی یازدهم', 'حسابان یازدهم',
          'حسابان دوازدهم', 'فیزیک یازدهم', 'شیمی',
        ],
        children: {
          'ریاضی': ['ریاضی دهم', 'ریاضی یازدهم', 'حسابان یازدهم',
              'حسابان دوازدهم'],
        },
      );
      expect(selection.selected, ['ریاضی یازدهم']);
      // Named first, then the subject's tags of this grade, then other
      // grades', then ones sharing only the grade; nothing unrelated.
      expect(selection.offered, [
        'ریاضی یازدهم', 'ریاضی', 'حسابان یازدهم', 'ریاضی دهم', 'فیزیک یازدهم',
      ]);
    });

    test('a form opening with a title offers its tags, selecting none',
        () async {
      final selection = TagSelection(
        suggest: (_) async => ['ریاضی', 'ریاضی دهم'],
        initial: ['فیزیک'],
        initialTitle: 'ریاضی',
      )..suggestNow(select: false);
      await Future<void>.delayed(Duration.zero);
      expect(selection.offered, ['ریاضی', 'ریاضی دهم', 'فیزیک']);
      expect(selection.selected, ['فیزیک']);
      expect(selection.needsClearerTitle, isFalse);
    });

    test('picking a narrower tag turns its subject off', () async {
      final selection =
          await suggested('ریاضی', ['ریاضی', 'ریاضی دهم', 'ریاضی یازدهم']);
      selection.toggle('ریاضی دهم');
      expect(selection.selected, ['ریاضی دهم']);
      expect(selection.fullerTitleExample, isNull);
    });

    test('a grade alone names no course, and a guess is not selected',
        () async {
      final selection = await suggested(
          'تست دهم', ['آزمون و تست', 'تست و مطالعه', 'فیزیک دهم', 'شیمی دهم']);
      expect(selection.offered,
          ['آزمون و تست', 'تست و مطالعه', 'فیزیک دهم', 'شیمی دهم']);
      expect(selection.selected, isEmpty);
      expect(selection.needsClearerTitle, isTrue);

      selection.toggle('آزمون و تست');
      expect(selection.needsClearerTitle, isFalse);
    });

    test('a title of only a grade asks for the lesson', () async {
      final selection = await suggested('یازدهم', ['فیزیک یازدهم']);
      expect(selection.offered, ['فیزیک یازدهم']);
      expect(selection.needsClearerTitle, isTrue);
      expect(selection.bareGrade, 'یازدهم');

      final noAnswer = await suggested('تست یازدهم', const []);
      expect(noAnswer.bareGrade, 'یازدهم');

      final named =
          await suggested('فیزیک یازدهم', ['فیزیک', 'فیزیک یازدهم']);
      expect(named.bareGrade, isNull);
      expect(named.needsClearerTitle, isFalse);
    });

    test('a title naming no lesson or grade, with nothing suggested, asks '
        'nothing', () async {
      final selection = await suggested('خرید نان', const []);
      expect(selection.needsClearerTitle, isFalse);
    });

    test('tags only learned from past tasks wait for a tap', () async {
      final selection = await suggested('حل تمرین', ['ریاضی']);
      expect(selection.selected, isEmpty);
      expect(selection.needsClearerTitle, isTrue);
    });

    test('a tag named by one of its other names is selected', () async {
      final selection = await suggested(
        'زيست',
        ['زیست‌شناسی', 'زیست‌شناسی دهم'],
        aliases: {
          'زیست‌شناسی': ['زیست', 'علوم'],
        },
      );
      expect(selection.selected, ['زیست‌شناسی']);
      expect(selection.fullerTitleExample, 'زیست‌شناسی دهم');
    });

    test('a title naming many tags selects none', () async {
      final selection = await suggested(
          'فیزیک شیمی ریاضی عربی', ['فیزیک', 'شیمی', 'ریاضی', 'عربی']);
      expect(selection.selected, isEmpty);
      expect(selection.needsClearerTitle, isTrue);
    });

    test('a picked tag stays when the title changes', () async {
      final selection =
          await suggested('حل تمرین', ['ریاضی'])..toggle('ریاضی');
      selection.titleChanged('حل تمرین فصل ۲');
      await Future<void>.delayed(const Duration(milliseconds: 500));
      expect(selection.selected, ['ریاضی']);
    });
  });
}
