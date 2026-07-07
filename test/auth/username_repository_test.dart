import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/features/auth/username_repository.dart';
import 'package:simo_learn/utils/username.dart';

void main() {
  test('validates Persian full names and rejects Latin text or digits', () {
    expect(isValidPersianFullName('علی رضایی'), isTrue);
    expect(isValidPersianFullName('محمد‌رضا'), isTrue);
    expect(isValidPersianFullName('Ali Rezaei'), isFalse);
    expect(isValidPersianFullName('علی 123'), isFalse);
    expect(isValidPersianFullName('ع'), isFalse);
  });

  test('accepts only the final Latin username format', () {
    expect(hasValidUsernameCharacters('ali_rezaei'), isTrue);
    expect(hasValidUsernameCharacters('Ali123'), isTrue);
    expect(hasValidUsernameCharacters('علی'), isFalse);
    expect(hasValidUsernameCharacters('ali-reza'), isFalse);
    expect(hasValidUsernameCharacters('ali reza'), isFalse);
  });

  test('suggestUsername sends the trimmed Persian full name without auth',
      () async {
    Map<String, dynamic>? sentVariables;
    bool? sentRequiresAuth;
    final repository = UsernameRepository.withRawRequest(({
      required String query,
      Map<String, dynamic> variables = const {},
      bool requiresAuth = true,
    }) async {
      expect(query, contains('suggestUsername'));
      sentVariables = variables;
      sentRequiresAuth = requiresAuth;
      return {
        'suggestUsername': {'username': 'ali_rezaei', 'available': true},
      };
    });

    final result = await repository.suggestUsername('  علی رضایی  ');

    expect(sentVariables, {'fullName': 'علی رضایی'});
    expect(sentRequiresAuth, isFalse);
    expect(result.username, 'ali_rezaei');
    expect(result.available, isTrue);
  });

  test('checkUsernameAvailability parses normalization and suggestion',
      () async {
    Map<String, dynamic>? sentVariables;
    final repository = UsernameRepository.withRawRequest(({
      required String query,
      Map<String, dynamic> variables = const {},
      bool requiresAuth = true,
    }) async {
      expect(query, contains('checkUsernameAvailability'));
      expect(requiresAuth, isFalse);
      sentVariables = variables;
      return {
        'checkUsernameAvailability': {
          'available': false,
          'normalizedUsername': 'ali',
          'suggestion': 'ali_2',
        },
      };
    });

    final result = await repository.checkUsernameAvailability('  Ali_Reza  ');

    expect(sentVariables, {'username': 'Ali_Reza'});
    expect(result.available, isFalse);
    expect(result.normalizedUsername, 'ali');
    expect(result.suggestion, 'ali_2');
  });

  test('short usernames are rejected without calling the API', () async {
    var requestCount = 0;
    final repository = UsernameRepository.withRawRequest(({
      required String query,
      Map<String, dynamic> variables = const {},
      bool requiresAuth = true,
    }) async {
      requestCount += 1;
      return const {};
    });

    await expectLater(
      repository.checkUsernameAvailability('ab'),
      throwsArgumentError,
    );
    await expectLater(
      repository.checkUsernameAvailability('علی'),
      throwsArgumentError,
    );
    expect(requestCount, 0);
  });
}
