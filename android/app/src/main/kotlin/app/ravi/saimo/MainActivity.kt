package app.ravi.saimo

import android.content.Context
import android.os.PowerManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
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
    }
}
