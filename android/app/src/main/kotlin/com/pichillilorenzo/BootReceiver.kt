package com.pichillilorenzo

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.pichillilorenzo.flutter_browser.MyAccessibilityService

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            Log.d("BootReceiver", "Device booted. Checking kiosk mode.")

            // Check if kiosk mode was previously enabled
            val sharedPrefs = context.getSharedPreferences("KioskModePrefs", Context.MODE_PRIVATE)
            val isEnabled = sharedPrefs.getBoolean("kioskModeEnabled", false)

            if (isEnabled) {
                // Restart services
                val serviceIntent = Intent(context, MyAccessibilityService::class.java)
                context.startService(serviceIntent)
            }
        }
    }
}
