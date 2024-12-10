package com.pichillilorenzo.flutter_browser

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Context
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.os.Handler
import android.os.Looper

class MyAccessibilityService : AccessibilityService() {
    private val TAG = "MyAccessibilityService"
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        val isKioskModeEnabled = getKioskModeFromPreferences()
    
        if (isKioskModeEnabled && event?.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val packageName = event.packageName?.toString()
    
            if (packageName == null) {
                Log.w(TAG, "Package name is null, skipping event")
                return
            }
    
            Log.d(TAG, "Current package: $packageName")
    
            val excludeList = setOf(
               
                "com.amazon.firelauncher",
                "com.android.inputmethod.latin",
                "android",
                "com.google.android.ext.services",
                "com.google.android.inputmethod.latin",
                "com.pichillilorenzo.flutter_browser",
                "com.android.systemui",
                "com.google.android.apps.nexuslauncher",
                "com.google.android.launcher"
            )
    
            if (!excludeList.contains(packageName)) {
                Log.d(TAG, "Blocking package: $packageName")
    
                // Perform the first block action
                val backSuccess = performGlobalAction(AccessibilityService.GLOBAL_ACTION_BACK)
                Log.d(TAG, "Performed back action: $backSuccess")
    
                // Schedule the second block after a delay
                Handler(Looper.getMainLooper()).postDelayed({
                    val currentPackageAfterDelay = event.packageName?.toString()
                    if (currentPackageAfterDelay != null && !excludeList.contains(currentPackageAfterDelay)) {
                        Log.d(TAG, "Still blocking package after delay: $currentPackageAfterDelay")
                        performGlobalAction(AccessibilityService.GLOBAL_ACTION_HOME)
                    }
                }, 2000) // 2-second delay
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
