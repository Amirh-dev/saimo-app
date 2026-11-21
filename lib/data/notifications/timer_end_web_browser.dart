import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import 'timer_end_platform.dart';

TimerEndPlatform createWebTimerEndPlatform() => _BrowserTimerEndPlatform();

/// `web/sounds/timer_end.wav`, the tune the phones play.
const String _sound = 'sounds/timer_end.wav';
const String _icon = 'icons/Icon-192.png';
const String _tag = 'timer-end';

/// A browser cannot schedule a notification for later, so the page keeps
/// the wait itself. It only works while the tab is open, and a hidden tab's
/// timers can run up to a minute late.
class _BrowserTimerEndPlatform implements TimerEndPlatform {
  Timer? _pending;
  web.Notification? _shown;

  /// Safari on iPhone outside a home-screen app has no notifications.
  bool get _canNotify => web.window.has('Notification');

  @override
  void prepare() {
    if (!_canNotify || web.Notification.permission != 'default') return;
    unawaited(
      web.Notification.requestPermission().toDart.catchError((Object error) {
        debugPrint('TimerEndNotice: permission failed: $error');
        return 'default'.toJS;
      }),
    );
  }

  @override
  Future<void> schedule(DateTime at, String title, String body) async {
    _pending?.cancel();
    final wait = at.difference(DateTime.now());
    _pending = Timer(wait.isNegative ? Duration.zero : wait, () {
      _pending = null;
      unawaited(chime());
      _notify(title, body);
    });
  }

  void _notify(String title, String body) {
    // Someone looking at the tab already sees the timer page.
    if (!_canNotify ||
        web.Notification.permission != 'granted' ||
        !web.document.hidden) {
      return;
    }
    final options = web.NotificationOptions(
      body: body,
      icon: _icon,
      lang: 'fa',
      dir: 'rtl',
      tag: _tag,
    );
    try {
      final shown = web.Notification(title, options);
      shown.onclick = ((web.Event _) {
        web.window.focus();
        shown.close();
      }).toJS;
      _shown = shown;
    } catch (_) {
      // Android Chrome only notifies through the service worker (whose
      // click handler brings the tab forward).
      unawaited(_notifyThroughWorker(title, options));
    }
  }

  Future<void> _notifyThroughWorker(
    String title,
    web.NotificationOptions options,
  ) async {
    try {
      final worker = await _worker();
      await worker?.showNotification(title, options).toDart;
    } catch (error) {
      debugPrint('TimerEndNotice: notification failed: $error');
    }
  }

  Future<web.ServiceWorkerRegistration?> _worker() async {
    if (!web.window.navigator.has('serviceWorker')) return null;
    return web.window.navigator.serviceWorker.getRegistration().toDart;
  }

  @override
  Future<void> cancel() async {
    _pending?.cancel();
    _pending = null;
    _shown?.close();
    _shown = null;
    try {
      final worker = await _worker();
      if (worker == null) return;
      final shown = await worker
          .getNotifications(web.GetNotificationOptions(tag: _tag))
          .toDart;
      for (final notification in shown.toDart) {
        notification.close();
      }
    } catch (error) {
      debugPrint('TimerEndNotice: cancel failed: $error');
    }
  }

  @override
  Future<void> chime() async {
    try {
      final audio = web.HTMLAudioElement()..src = _sound;
      await audio.play().toDart;
    } catch (error) {
      // The browser blocks sound before the first tap on the page.
      debugPrint('TimerEndNotice: chime failed: $error');
    }
  }
}
