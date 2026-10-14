import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:simo_learn/features/profile/avatar_uploader.dart';

void main() {
  final image = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 1, 2, 3]);
  final endpoint = Uri.parse('https://example.invalid/uploads/avatar');

  http.Response json(int status, Object body) =>
      http.Response.bytes(utf8.encode(jsonEncode(body)), status);

  test('sends the image under "file" with the session token', () async {
    late http.BaseRequest sent;
    late String body;
    final uploader = AvatarUploader(
      endpoint: endpoint,
      accessToken: ({bool forceRefresh = false}) async => 'token-1',
      client: MockClient((request) async {
        sent = request;
        body = latin1.decode(request.bodyBytes);
        return json(200, {
          'data': {'avatarUrl': 'https://cdn.example/a.jpg'},
        });
      }),
    );

    expect(await uploader.upload(image), 'https://cdn.example/a.jpg');
    expect(sent.method, 'POST');
    expect(sent.url, endpoint);
    expect(sent.headers['Authorization'], 'Bearer token-1');
    expect(body, contains('name="file"; filename="avatar.jpg"'));
  });

  test('a turned-down token is refreshed once and the upload retried',
      () async {
    final refreshes = <bool>[];
    final tokens = <String?>[];
    final uploader = AvatarUploader(
      endpoint: endpoint,
      accessToken: ({bool forceRefresh = false}) async {
        refreshes.add(forceRefresh);
        return forceRefresh ? 'fresh' : 'stale';
      },
      client: MockClient((request) async {
        tokens.add(request.headers['Authorization']);
        if (request.headers['Authorization'] == 'Bearer stale') {
          return json(401, {'code': 'UNAUTHORIZED', 'message': 'no'});
        }
        return json(200, {
          'data': {'avatarUrl': 'https://cdn.example/b.jpg'},
        });
      }),
    );

    expect(await uploader.upload(image), 'https://cdn.example/b.jpg');
    expect(refreshes, [false, true]);
    expect(tokens, ['Bearer stale', 'Bearer fresh']);
  });

  test('an ended session says so', () async {
    final uploader = AvatarUploader(
      endpoint: endpoint,
      accessToken: ({bool forceRefresh = false}) async => null,
      client: MockClient((_) async => fail('nothing should be sent')),
    );

    await expectLater(
      uploader.upload(image),
      throwsA(isA<AvatarUploadException>().having(
          (e) => e.message, 'message', contains('دوباره وارد حساب شوید'))),
    );
  });

  test('server refusals become messages the user can act on', () async {
    Future<String> messageFor(Object body, int status) async {
      final uploader = AvatarUploader(
        endpoint: endpoint,
        accessToken: ({bool forceRefresh = false}) async => 't',
        client: MockClient((_) async => json(status, body)),
      );
      try {
        await uploader.upload(image);
      } on AvatarUploadException catch (error) {
        return error.message;
      }
      fail('the upload should fail');
    }

    expect(await messageFor({'code': 'AVATAR_TOO_LARGE'}, 413),
        'حجم تصویر بیشتر از ۵ مگابایت است.');
    expect(await messageFor({'code': 'INVALID_AVATAR'}, 400),
        contains('JPG یا PNG'));
    expect(await messageFor({'code': 'AVATAR_UPLOAD_UNAVAILABLE'}, 503),
        contains('فعلاً ممکن نیست'));
    expect(await messageFor({'data': {}}, 200), contains('ناموفق'));
  });

  test('no connection asks the user to check it', () async {
    final uploader = AvatarUploader(
      endpoint: endpoint,
      accessToken: ({bool forceRefresh = false}) async => 't',
      client: MockClient((_) async => throw http.ClientException('offline')),
    );

    await expectLater(
      uploader.upload(image),
      throwsA(isA<AvatarUploadException>()
          .having((e) => e.message, 'message', contains('اتصال اینترنت'))),
    );
  });
}
