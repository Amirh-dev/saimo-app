/// The server's `UserMajor` enum, with the label each value shows in the app.
enum UserMajor {
  science('SCIENCE', 'تجربی'),
  humanities('HUMANITIES', 'انسانی'),
  mathematics('MATHEMATICS', 'ریاضی'),
  art('ART', 'هنر'),
  language('LANGUAGE', 'زبان'),
  other('OTHER', 'سایر');

  const UserMajor(this.apiValue, this.label);

  final String apiValue;
  final String label;

  /// Null for no selection, and for free text an older app version cached.
  static UserMajor? fromApi(Object? value) {
    for (final major in values) {
      if (major.apiValue == value) return major;
    }
    return null;
  }
}
