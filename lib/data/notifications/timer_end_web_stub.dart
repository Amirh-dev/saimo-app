import 'timer_end_platform.dart';

/// Only the web build has a browser to notify through.
TimerEndPlatform createWebTimerEndPlatform() =>
    throw UnsupportedError('web only');
