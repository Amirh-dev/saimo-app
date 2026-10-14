import 'package:simo_learn/presentation/screens/consultants/payment_tab.dart';
import 'package:web/web.dart' as web;

/// Opens a new browser tab, blank when [url] is empty. Returns null when the
/// browser blocked the popup, which happens unless this runs synchronously
/// inside a tap.
PaymentTab? openPaymentTab([String url = '']) {
  final tab = web.window.open(url, '_blank');
  if (tab == null) return null;
  // The bank page has no business scripting the app's tab.
  tab.opener = null;
  return _WebPaymentTab(tab);
}

class _WebPaymentTab implements PaymentTab {
  _WebPaymentTab(this._tab);

  final web.Window _tab;

  @override
  bool get isClosed => _tab.closed;

  @override
  void navigate(String url) {
    _tab.location.href = url;
    _tab.focus();
  }

  @override
  void close() {
    if (!_tab.closed) _tab.close();
  }
}
