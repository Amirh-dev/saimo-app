/// Accounts the team uses to try features quickly on a real phone.
///
/// They get extras ordinary users never see, such as a 1-minute task for
/// checking the timer and its end notice without waiting 25 minutes.
const Set<String> _testPhoneNumbers = {'9993152212'};

String? _currentPhoneNumber;

/// Remembers who is signed in. Set on login and on every app start, cleared
/// on logout.
void setCurrentPhoneNumber(String? phoneNumber) {
  _currentPhoneNumber = phoneNumber;
}

/// Whether the signed-in user is one of the test accounts. Numbers are
/// compared by their last ten digits, so 0999…, +98999… and 98999… all match.
bool get isTestAccount {
  final digits = (_currentPhoneNumber ?? '').replaceAll(RegExp(r'\D'), '');
  if (digits.length < 10) return false;
  return _testPhoneNumbers.contains(digits.substring(digits.length - 10));
}
