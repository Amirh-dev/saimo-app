package app.ravi.saimo

import android.app.AppOpsManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.os.Process
import android.provider.Settings
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
                    "access" -> result.success(alarmAccess())
                    "openSetting" -> result.success(openSetting(call.arguments as? String))
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

    // What a ringing alarm needs beyond Android's own permissions. Xiaomi
    // deletes the alarms of a swiped-away app and blocks its page unless
    // «نمایش روی صفحه قفل», «نمایش پنجره در پس‌زمینه» and battery «بدون
    // محدودیت» are on. A switch this ROM does not have reads as null.
    private fun alarmAccess(): Map<String, Any?> {
        val power = getSystemService(Context.POWER_SERVICE) as PowerManager
        return mapOf(
            "xiaomi" to isXiaomi(),
            "lockScreen" to if (isXiaomi()) miuiOp(10020) else null,
            "backgroundPopup" to if (isXiaomi()) miuiOp(10021) else null,
            "battery" to power.isIgnoringBatteryOptimizations(packageName),
        )
    }

    private fun isXiaomi(): Boolean {
        val names = "${Build.MANUFACTURER} ${Build.BRAND}".lowercase()
        return listOf("xiaomi", "redmi", "poco").any { names.contains(it) }
    }

    // MIUI keeps its own switches as app ops: 10020 show on lock screen,
    // 10021 open pages from the background.
    private fun miuiOp(op: Int): Boolean? = try {
        val ops = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val check = AppOpsManager::class.java.getMethod(
            "checkOpNoThrow",
            Int::class.javaPrimitiveType,
            Int::class.javaPrimitiveType,
            String::class.java,
        )
        check.invoke(ops, op, Process.myUid(), packageName) as Int == AppOpsManager.MODE_ALLOWED
    } catch (e: Exception) {
        null
    }

    // Opens the settings page for one of the alarm's needs, falling back to
    // the app's info page when this phone has no such page.
    private fun openSetting(which: String?): Boolean {
        val pages = mutableListOf<Intent>()
        when (which) {
            "lockScreen", "backgroundPopup" -> if (isXiaomi()) {
                for (page in listOf(
                    "com.miui.permcenter.permissions.PermissionsEditorActivity",
                    "com.miui.permcenter.permissions.AppPermissionsEditorActivity",
                )) {
                    pages += Intent("miui.intent.action.APP_PERM_EDITOR")
                        .setClassName("com.miui.securitycenter", page)
                        .putExtra("extra_pkgname", packageName)
                }
            }
            "battery" -> if (isXiaomi()) {
                pages += Intent()
                    .setClassName("com.miui.powerkeeper", "com.miui.powerkeeper.ui.HiddenAppsConfigActivity")
                    .putExtra("package_name", packageName)
                    .putExtra("package_label", applicationInfo.loadLabel(packageManager).toString())
            }
            "notifications" -> if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                pages += Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                    .putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
            }
        }
        pages += Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.fromParts("package", packageName, null))
        for (page in pages) {
            try {
                startActivity(page)
                return true
            } catch (e: Exception) {
                // Not on this phone, or not allowed: try the next page.
            }
        }
        return false
    }

    private fun linkFrom(intent: Intent?): String? {
        if (intent == null || intent.action != Intent.ACTION_VIEW) return null
        // Reopening from recents replays the original link.
        if (intent.flags and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY != 0) return null
        return intent.dataString
    }
}
