import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simo_learn/data/auth/token_storage.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';

import 'profile_repository.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(GraphQLRepository graphql)
      : _repository = ProfileRepository(graphql),
        super(ProfileInitial());

  ProfileCubit.withRepository(this._repository) : super(ProfileInitial());

  final ProfileRepository _repository;
  ProfileUser? _cachedProfile;
  Future<ProfileUser>? _activeLoad;
  int _cacheRevision = 0;

  ProfileUser? get cachedProfile => _cachedProfile;

  /// Returns the session-cached profile unless [forceRefresh] is requested.
  ///
  /// A single in-flight request is shared by all callers, which prevents
  /// duplicate `getMe` requests when more than one widget starts loading at
  /// the same time.
  Future<ProfileUser> getMe({bool forceRefresh = false}) {
    final cached = _cachedProfile;
    if (!forceRefresh && cached != null) {
      if (state is! ProfileSuccess) emit(ProfileSuccess(cached));
      return Future.value(cached);
    }

    final activeLoad = _activeLoad;
    if (activeLoad != null) return activeLoad;

    late final Future<ProfileUser> load;
    load = _loadFromNetwork().whenComplete(() {
      if (identical(_activeLoad, load)) _activeLoad = null;
    });
    _activeLoad = load;
    return load;
  }

  Future<ProfileUser> _loadFromNetwork() async {
    final cached = _cachedProfile;
    final revision = _cacheRevision;
    emit(
      cached == null ? ProfileLoading() : ProfileSuccess(cached, isRefreshing: true),
    );
    try {
      final profile = await _repository.getMe();
      if (revision != _cacheRevision) return profile;
      _cachedProfile = profile;
      emit(ProfileSuccess(profile));
      return profile;
    } catch (error) {
      if (revision == _cacheRevision) {
        emit(
          cached == null ? ProfileFailure(error.toString()) : ProfileSuccess(cached),
        );
      }
      rethrow;
    }
  }

  Future<ProfileUser> updateProfile({
    required String fullName,
    required String username,
    required DateTime birthDate,
    String? major,
  }) async {
    final profile = await _repository.updateProfile(
      fullName: fullName,
      username: username,
      birthDate: birthDate,
      major: major,
    );
    _cacheRevision += 1;
    _cachedProfile = profile;
    emit(ProfileSuccess(profile));
    return profile;
  }

  void reset() {
    _cacheRevision += 1;
    _cachedProfile = null;
    _activeLoad = null;
    emit(ProfileInitial());
  }

  Future<String> uploadProfileImage({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    final tokenStorage = await TokenStorage.create();

    final token = tokenStorage.currentAccessToken;

    if (token == null || token.isEmpty) {
      throw Exception('Access token is missing');
    }

    final uri = Uri.parse(
      'https://simo.raa-vi.ir/uploads/avatar',
    );

    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: fileName,
      ),
    );

    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

      final data = jsonResponse['data'] as Map<String, dynamic>?;

      final avatarUrl = data?['avatarUrl'] as String?;

      if (avatarUrl == null || avatarUrl.isEmpty) {
        throw Exception('Avatar URL is missing from server response');
      }

      return avatarUrl;
    }

    throw Exception(
      'Failed to upload profile image. '
      'Status code: ${response.statusCode}. '
      'Response: ${response.body}',
    );
  }
}
