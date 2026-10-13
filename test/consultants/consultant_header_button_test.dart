import 'package:ferry/ferry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
// gql_exec is a transitive test fixture API exposed through Ferry's link stack.
// ignore: depend_on_referenced_packages
import 'package:gql_exec/gql_exec.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simo_learn/data/auth/token_storage.dart';
import 'package:simo_learn/data/graphql/graphql_console_logger.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/presentation/screens/consultants/active_counselor_store.dart';
import 'package:simo_learn/presentation/screens/consultants/consultant_header_button.dart';
import 'package:simo_learn/presentation/screens/consultants/consultant_repository.dart';

Future<void> _pumpButton(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final graphql = GraphQLRepository(
    Client(
      link: Link.function(
        (request, [forward]) => const Stream<Response>.empty(),
      ),
    ),
    tokenStorage: await TokenStorage.create(),
    logger: GraphQLConsoleLogger(endpoint: 'https://example.invalid/graphql'),
  );
  await tester.pumpWidget(
    RepositoryProvider.value(
      value: graphql,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ConsultantHeaderButton())),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(ActiveCounselorStore.instance.debugReset);

  testWidgets('without a counselor it invites the student to choose one',
      (tester) async {
    // A fresh answer, so the button does not ask the server.
    ActiveCounselorStore.instance.set(null);
    await _pumpButton(tester);

    expect(find.text('انتخاب مشاور'), findsOneWidget);
    expect(find.bySemanticsLabel('انتخاب مشاور'), findsOneWidget);
  });

  testWidgets('with a counselor it shows them instead', (tester) async {
    ActiveCounselorStore.instance.set(const ActiveCounselor(
      userID: 'counselor-1',
      avatar: 'Assets.profilePlaceholder',
      name: 'سارا احمدی',
    ));
    await _pumpButton(tester);

    expect(find.text('انتخاب مشاور'), findsNothing);
    // No photo: the counselor's initial stands in.
    expect(find.text('س'), findsOneWidget);
    expect(
      find.bySemanticsLabel('گفتگو با مشاور، سارا احمدی'),
      findsOneWidget,
    );
  });

  testWidgets('choosing a counselor elsewhere updates the button',
      (tester) async {
    ActiveCounselorStore.instance.set(null);
    await _pumpButton(tester);
    expect(find.text('انتخاب مشاور'), findsOneWidget);

    ActiveCounselorStore.instance.set(const ActiveCounselor(
      userID: 'counselor-1',
      avatar: '',
      name: 'رضا',
    ));
    await tester.pumpAndSettle();

    expect(find.text('انتخاب مشاور'), findsNothing);
    expect(find.text('ر'), findsOneWidget);
  });

  test('a lookup running at logout does not bring the counselor back',
      () async {
    SharedPreferences.setMockInitialValues({});
    final store = ActiveCounselorStore.instance;
    final answered = <String>[];
    final repository = ConsultantRepository.withRawRequest(({
      required String query,
      Map<String, dynamic> variables = const {},
      bool requiresAuth = true,
    }) async {
      answered.add(query);
      return {
        'myActiveCounselor': {
          'status': 'ACTIVE',
          'counselor': {'id': 'c', 'userID': 'counselor-1', 'user': {}},
        },
      };
    });

    final lookup = store.refresh(repository);
    await store.clear();
    await lookup;

    expect(answered, isNotEmpty);
    expect(store.isKnown, isFalse);
    expect(store.counselor, isNull);
  });
}
