export 'payment_tab_stub.dart'
    if (dart.library.js_interop) 'payment_tab_web.dart';

/// A browser tab the web app opened for the bank gateway.
abstract class PaymentTab {
  bool get isClosed;

  /// Points the tab at [url] and brings it to the front.
  void navigate(String url);

  void close();
}
