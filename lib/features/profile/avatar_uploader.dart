import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:simo_learn/data/graphql/graphql_endpoints.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';

/// An avatar upload that failed, with a message ready to show the user.
class AvatarUploadException implements Exception {
  const AvatarUploadException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Returns a valid access token, refreshing it first when asked to; null
/// when the session is over.
typedef AccessTokenProvider = Future<String?> Function({bool forceRefresh});

/// Sends a profile picture to the server's `/uploads/avatar` endpoint, which
/// takes one JPEG or PNG of up to 5 MB in the multipart field `file` and
/// answers with the new avatar's URL.
class AvatarUploader {
  AvatarUploader({
    required AccessTokenProvider accessToken,
    http.Client? client,
    Uri? endpoint,
  })  : _accessToken = accessToken,
        _client = client ?? http.Client(),
        _endpoint = endpoint ?? defaultEndpoint;

  /// Uses the app's session, so an expired token is refreshed first, the same
  /// way every GraphQL request does it.
  factory AvatarUploader.fromGraphQL(GraphQLRepository graphql) =>
      AvatarUploader(accessToken: graphql.ensureValidAccessToken);

  /// Beside the GraphQL endpoint, on the same server.
  static final Uri defaultEndpoint =
      Uri.parse(GraphQLEndpoints.http).replace(path: '/uploads/avatar');

  static const _timeout = Duration(seconds: 60);

  final AccessTokenProvider _accessToken;
  final http.Client _client;
  final Uri _endpoint;

  Future<String> upload(Uint8List imageBytes, {String fileName = 'avatar.jpg'}) async {
    // A token the server turns down is refreshed once and the upload tried
    // again; a second refusal means the session is over.
    for (var attempt = 0; attempt < 2; attempt += 1) {
      final String? token;
      try {
        token = await _accessToken(forceRefresh: attempt > 0);
      } catch (_) {
        throw const AvatarUploadException(_offline);
      }
      if (token == null || token.isEmpty) {
        throw const AvatarUploadException(_signedOut);
      }

      final request = http.MultipartRequest('POST', _endpoint)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(http.MultipartFile.fromBytes('file', imageBytes, filename: fileName));

      final http.Response response;
      try {
        response = await http.Response.fromStream(await _client.send(request).timeout(_timeout)).timeout(_timeout);
      } on TimeoutException {
        throw const AvatarUploadException('بارگذاری بیش از حد طول کشید. دوباره تلاش کنید.');
      } on http.ClientException {
        // No connection, on every platform: the browser client and the
        // dart:io one both report it this way.
        throw const AvatarUploadException(_offline);
      }

      if (response.statusCode == 401 && attempt == 0) continue;
      return _avatarUrl(response);
    }
    throw const AvatarUploadException(_signedOut);
  }

  static String _avatarUrl(http.Response response) {
    Object? body;
    try {
      body = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {}
    final json = body is Map<String, dynamic> ? body : const <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = json['data'];
      final url = data is Map ? data['avatarUrl'] : null;
      if (url is String && url.isNotEmpty) return url;
      throw const AvatarUploadException(_failed);
    }

    throw AvatarUploadException(switch (json['code']) {
      'AVATAR_TOO_LARGE' => 'حجم تصویر بیشتر از ۵ مگابایت است.',
      'INVALID_AVATAR' => 'این فایل پذیرفته نشد. یک تصویر JPG یا PNG انتخاب کنید.',
      'AVATAR_UPLOAD_UNAVAILABLE' => 'بارگذاری تصویر فعلاً ممکن نیست. کمی بعد دوباره تلاش کنید.',
      'UNAUTHORIZED' => _signedOut,
      _ => _failed,
    });
  }

  static const _offline = 'اتصال اینترنت را بررسی کنید و دوباره تلاش کنید.';
  static const _signedOut = 'نشست شما به پایان رسیده است. دوباره وارد حساب شوید.';
  static const _failed = 'ذخیره تصویر ناموفق بود. دوباره تلاش کنید.';
}
