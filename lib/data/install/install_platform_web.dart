import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// What web/index.html keeps of the browser's install offer.
extension type _InstallState(JSObject _) implements JSObject {
  external JSObject? get prompt;
  external bool get installed;
  external JSPromise<JSString> run();
}

@JS('saimoInstall')
external _InstallState? get _state;

/// Safari's own flag for a page opened from the home screen.
@JS('navigator.standalone')
external bool? get _iosStandalone;

const bool canOfferInstall = true;

/// Opened from the home screen (or as an installed app), not in a tab.
bool runsInstalled() {
  if (_state?.installed ?? false) return true;
  if (_iosStandalone ?? false) return true;
  for (final mode in const ['standalone', 'fullscreen', 'minimal-ui']) {
    if (web.window.matchMedia('(display-mode: $mode)').matches) return true;
  }
  return false;
}

/// iPhone or iPad. iPadOS reports itself as a Mac, so a Mac with a touch
/// screen counts too.
bool runsOnIos() {
  final navigator = web.window.navigator;
  final agent = navigator.userAgent;
  if (RegExp('iPhone|iPad|iPod').hasMatch(agent)) return true;
  return agent.contains('Macintosh') && navigator.maxTouchPoints > 1;
}

/// The browser has an install dialog ready (Chrome, Edge, Samsung Internet).
bool canPromptInstall() => _state?.prompt != null;

/// Shows the browser's install dialog; true when the user accepted.
Future<bool> promptInstall() async {
  final state = _state;
  if (state == null) return false;
  final outcome = (await state.run().toDart).toDart;
  return outcome == 'accepted';
}

void onInstallChange(VoidCallback listener) {
  web.window.addEventListener(
    'saimo-install-change',
    ((web.Event _) => listener()).toJS,
  );
}
