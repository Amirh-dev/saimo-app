import 'package:flutter/material.dart';

class Routes {
  static const String initialRoute = '/';
  static const String sampleMain = '/sample';

  static Map<String, WidgetBuilder> routes() {
    return {
      initialRoute: (_) => const SizedBox.shrink(),
      sampleMain: (_) => const SizedBox.shrink(),
    };
  }
}
