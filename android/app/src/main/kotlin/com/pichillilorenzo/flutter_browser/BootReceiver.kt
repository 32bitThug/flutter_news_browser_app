package com.pichillilorenzo.flutter_browser

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.pichillilorenzo.flutter_browser.MyAccessibilityService

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED, Intent.ACTION_LOCKED_BOOT_COMPLETED -> {
                Log.d("BootReceiverL", "BootReceiver triggered: ${intent.action}")
                val sharedPrefs =
                        context.getSharedPreferences("KioskModePrefs", Context.MODE_PRIVATE)
                val isEnabled = sharedPrefs.getBoolean("kioskModeEnabled", false)

                if (isEnabled) {
                    Log.d("BootReceiverL", "Kiosk mode is enabled. Starting service.")
                    val serviceIntent = Intent(context, MyAccessibilityService::class.java)
                    context.startService(serviceIntent)
                } else {
                    Log.d("BootReceiverL", "Kiosk mode is disabled. Service not started.")
                }
            }
            else -> Log.d("BootReceiverL", "Unknown intent action: ${intent.action}")
        }
    }
}
