/// What [TimerEndNotice] needs from the phone or browser.
abstract class TimerEndPlatform {
  /// A timer just started (from a tap): get ready to notify, e.g. ask the
  /// browser for permission.
  void prepare();

  /// Notify at [at], unless [cancel]led first. Replaces an earlier one.
  Future<void> schedule(DateTime at, String title, String body);

  Future<void> cancel();

  /// The short tune, for a timer that ran out with the app on screen.
  Future<void> chime();
}
