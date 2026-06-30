import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/presentation/widgets/re_toast.dart';
import 'package:simo_learn/utils/colors.dart';

void main() {
  const hostKey = Key('toast-host');

  Future<void> pumpHost(WidgetTester tester) {
    return tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SizedBox(key: hostKey)),
      ),
    );
  }

  testWidgets('renders and dismisses every toast type', (tester) async {
    await pumpHost(tester);

    const cases = [
      (ReToastType.success, 'پیام موفقیت', AppColors.toastSuccess),
      (ReToastType.error, 'پیام خطا', AppColors.toastError),
      (ReToastType.info, 'پیام اطلاعات', AppColors.toastInfo),
      (ReToastType.warning, 'پیام هشدار', AppColors.toastWarning),
    ];

    for (final (type, message, color) in cases) {
      showReToast(tester.element(find.byKey(hostKey)), message, type);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 420));

      expect(find.text(message), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration! as BoxDecoration).color == color,
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('re-toast-dismiss')));
      await tester.pumpAndSettle();
      expect(find.text(message), findsNothing);
    }
  });

  testWidgets('automatically dismisses after its display duration',
      (tester) async {
    await pumpHost(tester);

    showReToast(
      tester.element(find.byKey(hostKey)),
      'پیام موقت',
      ReToastType.info,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 420));
    expect(find.text('پیام موقت'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('پیام موقت'), findsNothing);
  });
}
