import 'package:flutter/foundation.dart';

/// The mobile apps come from the stores; only the web app can be added to
/// the home screen.
const bool canOfferInstall = false;

bool runsInstalled() => true;

bool runsOnIos() => false;

bool canPromptInstall() => false;

Future<bool> promptInstall() async => false;

void onInstallChange(VoidCallback listener) {}
