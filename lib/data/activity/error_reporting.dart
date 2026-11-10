import 'package:flutter/foundation.dart';
import 'package:simo_learn/data/activity/app_activity_reporter.dart';

/// Forwards unhandled Flutter and platform errors to [reporter], keeping the
/// handlers that were already installed.
void installErrorReporting(AppActivityReporter reporter) {
  final previousFlutterHandler = FlutterError.onError;
  FlutterError.onError = (details) {
    previousFlutterHandler?.call(details);
    if (shouldReportFlutterError(details)) {
      reporter.recordError(details.exception, details.stack);
    }
  };

  final previousPlatformHandler = PlatformDispatcher.instance.onError;
  PlatformDispatcher.instance.onError = (error, stack) {
    reporter.recordError(error, stack);
    return previousPlatformHandler?.call(error, stack) ?? false;
  };
}

/// Silent errors and failed image downloads (a flaky network, not a bug) are
/// left out.
bool shouldReportFlutterError(FlutterErrorDetails details) {
  if (details.silent) return false;
  return details.library != 'image resource service';
}
