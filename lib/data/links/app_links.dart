import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:simo_learn/data/links/browser_link.dart';

/// Links that open the app from outside, such as "بازگشت به اپلیکیشن" on the
/// payment result page.
///
/// Android receives `saimo://` links in MainActivity. The web app reads its
/// own address, which the result page may point at with the payment fields.
class AppLinks {
  AppLinks._();

  static final AppLinks instance = AppLinks._();

  static const _channel = MethodChannel('app.ravi.saimo/links');

  /// Calls [onLink] with the link the app was opened with, if any, and on
  /// Android with every link that arrives while it runs.
  void listen(void Function(Uri link) onLink) {
    if (kIsWeb) {
      final link = takeBrowserLink();
      if (link != null) onLink(link);
      return;
    }
    if (defaultTargetPlatform != TargetPlatform.android) return;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'linkAvailable') await _take(onLink);
    });
    unawaited(_take(onLink));
  }

  Future<void> _take(void Function(Uri link) onLink) async {
    final String? raw;
    try {
      raw = await _channel.invokeMethod<String>('takeLink');
    } catch (_) {
      return;
    }
    final link = raw == null ? null : Uri.tryParse(raw);
    if (link != null) onLink(link);
  }
}
