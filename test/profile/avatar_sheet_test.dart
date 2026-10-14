import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simo_learn/features/profile/avatar_uploader.dart';
import 'package:simo_learn/presentation/screens/profile/index.dart';

import '../tasks/support/app_fonts.dart';

/// A 1x1 PNG, so the preview has a real image to decode.
final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

void main() {
  setUpAll(loadAppFonts);

  Finder byKey(String key) => find.byKey(ValueKey(key));

  /// Opens the sheet; the returned future completes with what it popped.
  Future<Future<String?>> open(
    WidgetTester tester, {
    required AvatarImagePicker pickImage,
    required Future<String> Function(Uint8List bytes) upload,
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    late Future<String?> result;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () {
                result = showModalBottomSheet<String>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => ProfileAvatarBottomSheet(
                    currentImageUrl: null,
                    pickImage: pickImage,
                    onUpload: ({required imageBytes, required fileName}) =>
                        upload(imageBytes),
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return Future.value(result);
  }

  testWidgets('choosing a photo previews it, saving uploads it',
      (tester) async {
    final sources = <ImageSource>[];
    final uploaded = <Uint8List>[];
    final result = await open(
      tester,
      pickImage: (source) async {
        sources.add(source);
        return _png;
      },
      upload: (bytes) async {
        uploaded.add(bytes);
        return 'https://cdn.example/new.jpg';
      },
    );

    expect(byKey('avatar-source-gallery'), findsOneWidget);
    expect(byKey('avatar-source-camera'), findsOneWidget);
    expect(byKey('avatar-save'), findsNothing);

    await tester.tap(byKey('avatar-source-camera'));
    await tester.pumpAndSettle();
    expect(sources, [ImageSource.camera]);
    expect(byKey('avatar-save'), findsOneWidget);
    expect(byKey('avatar-sources'), findsNothing);

    await tester.tap(byKey('avatar-save'));
    await tester.pumpAndSettle();
    expect(uploaded.single, _png);
    expect(await result, 'https://cdn.example/new.jpg');
    expect(find.byType(ProfileAvatarBottomSheet), findsNothing);
  });

  testWidgets('backing out of the picker changes nothing', (tester) async {
    await open(
      tester,
      pickImage: (_) async => null,
      upload: (_) async => fail('nothing to upload'),
    );

    await tester.tap(byKey('avatar-source-gallery'));
    await tester.pumpAndSettle();
    expect(byKey('avatar-sources'), findsOneWidget);
    expect(byKey('avatar-error'), findsNothing);
  });

  testWidgets('a failed upload says why, offers a retry, keeps the photo',
      (tester) async {
    var attempts = 0;
    final result = await open(
      tester,
      pickImage: (_) async => _png,
      upload: (_) async {
        attempts += 1;
        if (attempts == 1) {
          throw const AvatarUploadException('حجم تصویر بیشتر از ۵ مگابایت است.');
        }
        return 'https://cdn.example/ok.jpg';
      },
    );

    await tester.tap(byKey('avatar-source-gallery'));
    await tester.pumpAndSettle();
    await tester.tap(byKey('avatar-save'));
    await tester.pumpAndSettle();

    expect(find.text('حجم تصویر بیشتر از ۵ مگابایت است.'), findsOneWidget);
    expect(find.text('تلاش دوباره'), findsOneWidget);
    expect(find.byType(ProfileAvatarBottomSheet), findsOneWidget);

    await tester.tap(byKey('avatar-save'));
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(await result, 'https://cdn.example/ok.jpg');
  });

  testWidgets('picking another photo goes back to the sources',
      (tester) async {
    await open(
      tester,
      pickImage: (_) async => _png,
      upload: (_) async => fail('nothing to upload'),
    );

    await tester.tap(byKey('avatar-source-gallery'));
    await tester.pumpAndSettle();
    await tester.tap(byKey('avatar-repick'));
    await tester.pumpAndSettle();
    expect(byKey('avatar-sources'), findsOneWidget);
  });

  testWidgets('a refused permission points to the settings', (tester) async {
    await open(
      tester,
      pickImage: (_) async =>
          throw PlatformException(code: 'photo_access_denied'),
      upload: (_) async => fail('nothing to upload'),
    );

    await tester.tap(byKey('avatar-source-gallery'));
    await tester.pumpAndSettle();
    expect(
      find.text('دسترسی به عکس‌ها داده نشده است. آن را از تنظیمات گوشی فعال کنید.'),
      findsOneWidget,
    );
  });
}
