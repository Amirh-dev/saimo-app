import 'dart:async';

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
import 'package:simo_learn/features/auth/cubit/auth_cubit.dart';
import 'package:simo_learn/features/auth/username_repository.dart';
import 'package:simo_learn/presentation/screens/authentication/register/index.dart';

void main() {
  testWidgets('requests a username suggestion only after full-name focus loss',
      (tester) async {
    var suggestionRequests = 0;
    final usernameRepository = UsernameRepository.withRawRequest(({
      required String query,
      Map<String, dynamic> variables = const {},
      bool requiresAuth = true,
    }) async {
      suggestionRequests += 1;
      expect(query, contains('suggestUsername'));
      expect(variables, {'fullName': 'علی رضایی'});
      return {
        'suggestUsername': {'username': 'ali_rezaei', 'available': true},
      };
    });
    await _pumpRegister(tester, usernameRepository);

    final fullName = find.byKey(const ValueKey('register-full-name-field'));
    await tester.enterText(fullName, 'علی رضایی');
    await tester.pump(const Duration(seconds: 1));

    expect(suggestionRequests, 0);

    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();

    expect(suggestionRequests, 1);
    expect(_usernameText(tester), 'ali_rezaei');
    expect(find.textContaining('@ali_rezaei'), findsOneWidget);
  });

  testWidgets('a late suggestion never overwrites a manually entered username',
      (tester) async {
    final suggestionResponse = Completer<Map<String, dynamic>>();
    final usernameRepository = UsernameRepository.withRawRequest(({
      required String query,
      Map<String, dynamic> variables = const {},
      bool requiresAuth = true,
    }) {
      if (query.contains('suggestUsername')) return suggestionResponse.future;
      return Future.value({
        'checkUsernameAvailability': {
          'available': true,
          'normalizedUsername': variables['username'],
          'suggestion': null,
        },
      });
    });
    await _pumpRegister(tester, usernameRepository);

    await tester.enterText(
      find.byKey(const ValueKey('register-full-name-field')),
      'علی رضایی',
    );
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();

    final usernameField = find.descendant(
      of: find.byKey(const ValueKey('register-username-field')),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(usernameField, 'custom_user');
    suggestionResponse.complete({
      'suggestUsername': {'username': 'ali_rezaei', 'available': true},
    });
    await tester.pump();

    expect(_usernameText(tester), 'custom_user');
  });
}

Future<void> _pumpRegister(
  WidgetTester tester,
  UsernameRepository usernameRepository,
) async {
  SharedPreferences.setMockInitialValues({});
  final tokenStorage = await TokenStorage.create();
  final graphqlRepository = GraphQLRepository(
    Client(
      link: Link.function(
        (request, [forward]) => const Stream<Response>.empty(),
      ),
    ),
    tokenStorage: tokenStorage,
    logger: GraphQLConsoleLogger(endpoint: 'https://example.invalid/graphql'),
  );
  final authCubit = AuthCubit(
    graphQLRepository: graphqlRepository,
    tokenStorage: tokenStorage,
  );
  addTearDown(authCubit.close);

  tester.view.physicalSize = const Size(1080, 1920);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    RepositoryProvider.value(
      value: graphqlRepository,
      child: BlocProvider.value(
        value: authCubit,
        child: MaterialApp(
          home: RegisterScreen(usernameRepository: usernameRepository),
        ),
      ),
    ),
  );
  await tester.pump();
}

String? _usernameText(WidgetTester tester) {
  final usernameField = find.descendant(
    of: find.byKey(const ValueKey('register-username-field')),
    matching: find.byType(TextFormField),
  );
  return tester.widget<TextFormField>(usernameField).controller?.text;
}
