import 'package:ferry/ferry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simo_learn/data/auth/token_storage.dart';
import 'package:simo_learn/data/graphql/graphql_console_logger.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/features/auth/cubit/auth_cubit.dart';
import 'package:simo_learn/presentation/screens/authentication/otp_code/index.dart';

void main() {
  testWidgets('OTP field keeps focus while typing digits', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final tokenStorage = await TokenStorage.create();
    final cubit = AuthCubit(
      graphQLRepository: GraphQLRepository(
        Client(link: Link.function((request, [forward]) async* {})),
        tokenStorage: tokenStorage,
        logger: GraphQLConsoleLogger(endpoint: 'https://example.invalid'),
      ),
      tokenStorage: tokenStorage,
    );
    addTearDown(cubit.close);

    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: const MaterialApp(
          home: OTPCodeScreen(phoneNumber: '09123456789', isRegistered: true),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    final editable = find.byType(EditableText);
    expect(tester.widget<EditableText>(editable).focusNode.hasFocus, isTrue);

    tester.testTextInput.updateEditingValue(const TextEditingValue(
      text: '1',
      selection: TextSelection.collapsed(offset: 1),
    ));
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.widget<EditableText>(editable).focusNode.hasFocus, isTrue);
    expect(tester.testTextInput.isVisible, isTrue);
    // The IME's value must not be rewritten; Persian digits are display-only.
    expect(tester.widget<EditableText>(editable).controller.text, '1');
    expect(find.text('۱'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
