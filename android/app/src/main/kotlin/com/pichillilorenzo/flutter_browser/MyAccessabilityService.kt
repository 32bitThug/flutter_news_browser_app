package com.pichillilorenzo.flutter_browser

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.util.Log
import android.view.accessibility.AccessibilityEvent

class MyAccessibilityService : AccessibilityService() {
    val excludeList =
            setOf(
                    "com.google.android.googlequicksearchbox",
                    "com.amazon.firelauncher",
                    "com.android.inputmethod.latin",
                    "android",
                    "com.google.android.ext.services",
                    "com.google.android.inputmethod.latin",
                    "com.pichillilorenzo.flutter_browser",
                    "com.android.systemui",
                    "com.google.android.apps.nexuslauncher",
                    "com.google.android.launcher",
                    "com.android.launcher"
            )
    private val TAG = "MyAccessibilityService"
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        Log.d(TAG, "Event type: ${event?.eventType}")
        val isKioskModeEnabled = getKioskModeFromPreferences()
        Log.d(TAG, "Kiosk mode enabled: $isKioskModeEnabled")

        if (isKioskModeEnabled && event?.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
        ) {
            val packageName = event.packageName?.toString()
            Log.d(TAG, "Current package: $packageName")

            if (!excludeList.contains(packageName)) {
                Log.d(TAG, "Blocking package: $packageName")

                val backSuccess = performGlobalAction(AccessibilityService.GLOBAL_ACTION_BACK)
                Log.d(TAG, "Performed back action: $backSuccess")

                Handler(Looper.getMainLooper())
                        .postDelayed(
                                {
                                    val currentPackageAfterDelay = event.packageName?.toString()
                                    if (!excludeList.contains(currentPackageAfterDelay)) {
                                        Log.d(
                                                TAG,
                                                "Still blocking package after delay: $currentPackageAfterDelay"
                                        )
                                        performGlobalAction(AccessibilityService.GLOBAL_ACTION_HOME)
                                    }
                                },
                                2000
                        )
            }
        }
    }

    override fun onInterrupt() {
        // Handle interrupt
    }

    override fun onServiceConnected() {
        super.onServiceConnected()

        // Restore kiosk mode state from SharedPreferences
        val isKioskModeEnabled = getKioskModeFromPreferences()
        Log.d(TAG, "Kiosk mode restored: $isKioskModeEnabled")
        val enabledServices =
                Settings.Secure.getString(
                        contentResolver,
                        Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
                )

        if (enabledServices != null &&
                        enabledServices.contains(MyAccessibilityService::class.java.name)
        ) {
            Log.d(TAG, "Accesibility Permission granted: true")
        } else {
            Log.d(TAG, "Accesibility Permission not granted")
        }
        // onAccessibilityEvent(null)
        // Setup the service to listen for window state changes
        val info =
                AccessibilityServiceInfo().apply {
                    eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
                    packageNames = null
                    feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
                    notificationTimeout = 100
                }
        this.serviceInfo = info
    }

    // Method to update the kiosk mode status from Flutter
    fun setKioskModeEnabled(enabled: Boolean) {
        Log.d(TAG, "Kiosk mode enabled: $enabled")

        // Save the state to SharedPreferences
        val sharedPrefs =
                applicationContext.getSharedPreferences("KioskModePrefs", Context.MODE_PRIVATE)
        sharedPrefs.edit().putBoolean("kioskModeEnabled", enabled).apply()
    }

    // Helper method to get the kiosk mode state from SharedPreferences
    private fun getKioskModeFromPreferences(): Boolean {
        val sharedPrefs =
                applicationContext.getSharedPreferences("KioskModePrefs", Context.MODE_PRIVATE)
        return sharedPrefs.getBoolean("kioskModeEnabled", false)
    }
}
