import 'package:ferry/ferry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
// gql_exec is exposed by Ferry for building test responses.
// ignore: depend_on_referenced_packages
import 'package:gql_exec/gql_exec.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simo_learn/data/auth/token_storage.dart';
import 'package:simo_learn/data/graphql/graphql_console_logger.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/presentation/screens/tasks/add_task/index.dart';
import 'package:simo_learn/utils/_utils.dart';

import 'support/app_fonts.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets('the date wheel offers no day before today', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final repository = GraphQLRepository(
      Client(
        link: Link.function(
          (request, [forward]) => const Stream<Response>.empty(),
        ),
      ),
      tokenStorage: await TokenStorage.create(),
      logger: GraphQLConsoleLogger(endpoint: 'https://example.invalid/graphql'),
    );
    await tester.pumpWidget(RepositoryProvider<GraphQLRepository>.value(
      value: repository,
      child: const MaterialApp(home: AddTaskScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('تاریخ').first);
    await tester.pumpAndSettle();
    expect(find.text('برو به تاریخ'), findsOneWidget);

    final today = Jalali.now();
    String fa(int n) => convertToPersianNumbers('$n');
    // Last year used to sit right above this one on the wheel.
    expect(find.text(fa(today.year - 1)), findsNothing);
    expect(find.text(fa(today.year)), findsWidgets);
    // Nor is last month offered.
    if (today.month > 1) {
      const months = [
        'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور', //
        'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند',
      ];
      expect(find.text(months[today.month - 2]), findsNothing);
    }
  });
}
