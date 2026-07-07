import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/utils/username.dart';

typedef UsernameGraphQLRequest = Future<Map<String, dynamic>> Function({
  required String query,
  Map<String, dynamic> variables,
  bool requiresAuth,
});

bool isValidPersianFullName(String value) {
  final fullName = value.trim();
  return fullName.length >= 2 &&
      RegExp(
        r'^[\u0621-\u063A\u0641-\u064A\u066E-\u066F'
        r'\u0671-\u06D3\u06FA-\u06FC\u200C\s-]+$',
      ).hasMatch(fullName);
}

class UsernameSuggestion {
  const UsernameSuggestion({
    required this.username,
    required this.available,
  });

  final String username;
  final bool available;
}

class UsernameAvailability {
  const UsernameAvailability({
    required this.available,
    required this.normalizedUsername,
    this.suggestion,
  });

  final bool available;
  final String normalizedUsername;
  final String? suggestion;
}

/// Provides the public username endpoints used before and after registration.
class UsernameRepository {
  UsernameRepository(GraphQLRepository graphql)
      : _rawRequest = graphql.rawRequest;

  UsernameRepository.withRawRequest(this._rawRequest);

  final UsernameGraphQLRequest _rawRequest;

  Future<UsernameSuggestion> suggestUsername(String fullName) async {
    final normalizedFullName = fullName.trim();
    if (normalizedFullName.isEmpty) {
      throw ArgumentError.value(fullName, 'fullName', 'must not be empty');
    }

    final data = await _rawRequest(
      query: _suggestUsernameQuery,
      variables: {'fullName': normalizedFullName},
      requiresAuth: false,
    );
    final payload = data['suggestUsername'];
    if (payload is! Map<String, dynamic>) {
      throw const GraphQLRawException('دریافت نام کاربری پیشنهادی ناموفق بود');
    }

    final username = payload['username']?.toString().trim() ?? '';
    if (username.length < 3 || !hasValidUsernameCharacters(username)) {
      throw const GraphQLRawException('نام کاربری پیشنهادی نامعتبر است');
    }
    return UsernameSuggestion(
      username: username,
      available: payload['available'] == true,
    );
  }

  Future<UsernameAvailability> checkUsernameAvailability(
    String username,
  ) async {
    final normalizedInput = username.trim();
    if (!hasValidUsernameCharacters(normalizedInput)) {
      throw ArgumentError.value(
        username,
        'username',
        'must contain only English letters, numbers, and underscores',
      );
    }
    if (normalizedInput.length < 3) {
      throw ArgumentError.value(
        username,
        'username',
        'must be at least 3 characters',
      );
    }

    final data = await _rawRequest(
      query: _checkUsernameAvailabilityQuery,
      variables: {'username': normalizedInput},
      requiresAuth: false,
    );
    final payload = data['checkUsernameAvailability'];
    if (payload is! Map<String, dynamic>) {
      throw const GraphQLRawException('بررسی نام کاربری ناموفق بود');
    }

    final normalizedUsername =
        payload['normalizedUsername']?.toString().trim() ?? '';
    if (normalizedUsername.isEmpty) {
      throw const GraphQLRawException('نام کاربری نامعتبر است');
    }
    final rawSuggestion = payload['suggestion']?.toString().trim();
    return UsernameAvailability(
      available: payload['available'] == true,
      normalizedUsername: normalizedUsername,
      suggestion:
          rawSuggestion == null || rawSuggestion.isEmpty ? null : rawSuggestion,
    );
  }
}

const _suggestUsernameQuery = r'''
query SuggestUsername($fullName: String!) {
  suggestUsername(fullName: $fullName) {
    username
    available
  }
}
''';

const _checkUsernameAvailabilityQuery = r'''
query CheckUsernameAvailability($username: String!) {
  checkUsernameAvailability(username: $username) {
    available
    normalizedUsername
    suggestion
  }
}
''';
