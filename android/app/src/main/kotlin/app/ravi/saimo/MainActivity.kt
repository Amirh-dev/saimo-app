package app.ravi.saimo

import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import app.ravi.saimo.widgets.HomeWidgets
import app.ravi.saimo.widgets.WidgetStore

class MainActivity : FlutterActivity() {
    // The saimo:// link the app was opened with, until Dart takes it.
    private var pendingLink: String? = null
    private var linksChannel: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        // A restored activity still carries the link it was first opened
        // with, and that one was already handled.
        if (savedInstanceState == null) pendingLink = linkFrom(intent)
        super.onCreate(savedInstanceState)
        if (isTaskAlarm(intent)) showOverLockScreen(true)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // SimoGuard asks this as the app leaves the foreground: a screen that
        // went off means the phone was locked, not that the user left the app.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app.ravi.saimo/screen")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isScreenOn" -> {
                        val power = getSystemService(Context.POWER_SERVICE) as PowerManager
                        result.success(power.isInteractive)
                    }
                    else -> result.notImplemented()
                }
            }

        // The task alarm page closed: the phone locks again as before.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app.ravi.saimo/alarm")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "release" -> {
                        showOverLockScreen(false)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        // HomeWidgets (Dart) hands over today's tasks whenever they change;
        // the home-screen widgets draw from that snapshot.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app.ravi.saimo/widgets")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "update" -> {
                        WidgetStore.save(applicationContext, call.arguments as? String ?: "")
                        HomeWidgets.updateAll(applicationContext)
                        result.success(null)
                    }
                    "clear" -> {
                        WidgetStore.clear(applicationContext)
                        HomeWidgets.updateAll(applicationContext)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        // AppLinks takes the pending link on start and again on every
        // "linkAvailable", so a link is handled once even if Dart was not
        // listening yet when it arrived.
        linksChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app.ravi.saimo/links")
            .apply {
                setMethodCallHandler { call, result ->
                    when (call.method) {
                        "takeLink" -> {
                            result.success(pendingLink)
                            pendingLink = null
                        }
                        else -> result.notImplemented()
                    }
                }
            }
    }

    // The app was already open (singleTop): the link arrives here.
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (isTaskAlarm(intent)) showOverLockScreen(true)
        val link = linkFrom(intent) ?: return
        pendingLink = link
        linksChannel?.invokeMethod("linkAvailable", null)
    }

    // A ringing task alarm opened the app (its full-screen intent or a tap):
    // its page shows over the lock screen and turns the screen on. Only
    // then, so the app is never reachable from a locked phone otherwise.
    private fun isTaskAlarm(intent: Intent?): Boolean {
        if (intent?.action != "SELECT_NOTIFICATION") return false
        return intent.getStringExtra("payload")?.contains("\"TASK_ALARM\"") == true
    }

    private fun showOverLockScreen(show: Boolean) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(show)
            setTurnScreenOn(show)
        } else {
            ("DEPRECATION")
            val flags = android.view.WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                android.view.WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            if (show) window.addFlags(flags) else window.clearFlags(flags)
        }
    }

    private fun linkFrom(intent: Intent?): String? {
        if (intent == null || intent.action != Intent.ACTION_VIEW) return null
        // Reopening from recents replays the original link.
        if (intent.flags and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY != 0) return null
        return intent.dataString
    }
}
