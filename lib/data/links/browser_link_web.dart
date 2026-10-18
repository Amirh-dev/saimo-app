import 'package:web/web.dart' as web;

/// Query fields the payment result page passes on.
const _paymentFields = {'paymentStatus', 'attemptID', 'subscriptionID'};

/// Returns the page address when the payment result page sent the student
/// here, and drops the payment fields from the address bar so a reload does
/// not report the payment again.
Uri? takeBrowserLink() {
  final address = Uri.tryParse(web.window.location.href);
  if (address == null ||
      !address.queryParameters.keys.any(_paymentFields.contains)) {
    return null;
  }

  final rest = Map.of(address.queryParameters)
    ..removeWhere((key, _) => _paymentFields.contains(key));
  final base = Uri.tryParse(web.document.baseURI)?.path ?? '/';
  final clean = Uri(
    path: base,
    queryParameters: rest.isEmpty ? null : rest,
    fragment: address.hasFragment ? address.fragment : null,
  );
  // Flutter keeps its own history entry in the state; leave it as it is.
  web.window.history.replaceState(
    web.window.history.state,
    '',
    clean.toString(),
  );
  return address;
}
