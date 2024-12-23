package com.pichillilorenzo.flutter_browser

import android.app.AppOpsManager
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.provider.Settings
import android.util.Log
import android.view.accessibility.AccessibilityManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.pichillilorenzo.flutter_browser.intent_data"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register the MethodChannel to handle calls from Flutter
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call: MethodCall,
                result: MethodChannel.Result ->
            when (call.method) {
                "getIntentData" -> {
                    result.success(null) // You can return the data here if necessary
                }
                "startService" -> {
                    // Start the service and request permission
                    requestUsageStatsPermission()
                    result.success("Service Started")
                }
                "requestAccessibilityPermission" -> {
                    // Request accessibility permission
                    val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                    startActivity(intent)
                    result.success("Accessibility Permission Requested")
                }
                "setKioskMode" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    Log.d("MainActivity", "Setting kiosk mode to $enabled")
                    // Update the kiosk mode status in MyAccessibilityService
                    val sharedPrefs =
                            applicationContext.getSharedPreferences(
                                    "KioskModePrefs",
                                    Context.MODE_PRIVATE
                            )
                    sharedPrefs.edit().putBoolean("kioskModeEnabled", enabled).apply()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun requestUsageStatsPermission() {
        val appOpsManager = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode =
                appOpsManager.checkOpNoThrow(
                        AppOpsManager.OPSTR_GET_USAGE_STATS,
                        android.os.Process.myUid(),
                        packageName
                )
        if (mode != AppOpsManager.MODE_ALLOWED) {
            val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
            startActivity(intent)
        }
    }

    override fun onResume() {
        super.onResume()
        // Check permissions after returning from settings
        isUsageAccessPermissionGranted()
        isAccessibilityPermissionGranted()
    }

    private fun isUsageAccessPermissionGranted() {
        val appOpsManager = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode =
                appOpsManager.checkOpNoThrow(
                        AppOpsManager.OPSTR_GET_USAGE_STATS,
                        android.os.Process.myUid(),
                        packageName
                )
        Log.d("UsageAccessPermission", "Permission granted: ${mode == AppOpsManager.MODE_ALLOWED}")
    }

    private fun isAccessibilityPermissionGranted() {
        val am = getSystemService(Context.ACCESSIBILITY_SERVICE) as AccessibilityManager
        val enabledServices =
                Settings.Secure.getString(
                        contentResolver,
                        Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
                )

        if (enabledServices != null &&
                        enabledServices.contains(MyAccessibilityService::class.java.name)
        ) {
            Log.d("AccesibilityPermission", "Permission granted: true")
        } else {
            Log.d("AccesibilityPermission", "Permission not granted")
        }
    }
}
