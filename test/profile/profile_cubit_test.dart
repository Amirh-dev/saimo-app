import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/features/profile/profile_cubit.dart';
import 'package:simo_learn/features/profile/profile_repository.dart';

void main() {
  test('getMe reuses its cached profile until a refresh is forced', () async {
    var requestCount = 0;
    final cubit = ProfileCubit.withRepository(
      ProfileRepository.withRawRequest(({
        required String query,
        Map<String, dynamic> variables = const {},
        bool requiresAuth = true,
      }) async {
        requestCount += 1;
        return _profileResponse(fullName: 'علی رضایی');
      }),
    );
    addTearDown(cubit.close);

    final first = await cubit.getMe();
    final cached = await cubit.getMe();

    expect(requestCount, 1);
    expect(identical(cached, first), isTrue);

    await cubit.getMe(forceRefresh: true);
    expect(requestCount, 2);
  });

  test('concurrent getMe calls share one network request', () async {
    var requestCount = 0;
    final response = Completer<Map<String, dynamic>>();
    final cubit = ProfileCubit.withRepository(
      ProfileRepository.withRawRequest(({
        required String query,
        Map<String, dynamic> variables = const {},
        bool requiresAuth = true,
      }) {
        requestCount += 1;
        return response.future;
      }),
    );
    addTearDown(cubit.close);

    final first = cubit.getMe();
    final second = cubit.getMe();
    expect(identical(first, second), isTrue);
    expect(requestCount, 1);

    response.complete(_profileResponse(fullName: 'علی رضایی'));
    await Future.wait([first, second]);
    expect(requestCount, 1);
  });

  test('updated profile replaces the cached value without another getMe',
      () async {
    var getMeCount = 0;
    var updateCount = 0;
    final cubit = ProfileCubit.withRepository(
      ProfileRepository.withRawRequest(({
        required String query,
        Map<String, dynamic> variables = const {},
        bool requiresAuth = true,
      }) async {
        if (query.contains('UpdateProfile')) {
          updateCount += 1;
          return {
            'updateProfile': _profileJson(
              fullName: 'نام جدید',
              username: 'new_name',
            ),
          };
        }
        getMeCount += 1;
        return _profileResponse(fullName: 'علی رضایی');
      }),
    );
    addTearDown(cubit.close);

    await cubit.getMe();
    final updated = await cubit.updateProfile(
      fullName: 'نام جدید',
      username: 'new_name',
      birthDate: DateTime.utc(2001, 2, 3),
    );
    final cached = await cubit.getMe();

    expect(updateCount, 1);
    expect(getMeCount, 1);
    expect(updated.displayName, 'نام جدید');
    expect(identical(cached, updated), isTrue);
  });

  test('reset clears cached profile for the next authenticated session',
      () async {
    var requestCount = 0;
    final cubit = ProfileCubit.withRepository(
      ProfileRepository.withRawRequest(({
        required String query,
        Map<String, dynamic> variables = const {},
        bool requiresAuth = true,
      }) async {
        requestCount += 1;
        return _profileResponse(fullName: 'علی رضایی');
      }),
    );
    addTearDown(cubit.close);

    await cubit.getMe();
    cubit.reset();
    expect(cubit.cachedProfile, isNull);
    expect(cubit.state, isA<ProfileInitial>());

    await cubit.getMe();
    expect(requestCount, 2);
  });
}

Map<String, dynamic> _profileResponse({required String fullName}) {
  return {'getMe': _profileJson(fullName: fullName)};
}

Map<String, dynamic> _profileJson({
  required String fullName,
  String username = 'ali_rezaei',
}) {
  return {
    'id': 'user-1',
    'username': username,
    'fullName': fullName,
    'birthDate': '2001-02-03T00:00:00.000Z',
    'simoCoins': 36,
    'score': 3,
    'isPremium': true,
  };
}
