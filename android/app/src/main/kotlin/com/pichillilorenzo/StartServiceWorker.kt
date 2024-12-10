//import android.content.BroadcastReceiver
//import android.content.Context
//import android.content.Intent
//import androidx.work.OneTimeWorkRequestBuilder
//import androidx.work.WorkManager
//import androidx.work.WorkRequest
//import android.util.Log
//
//class BootReceiver : BroadcastReceiver() {
//
//    override fun onReceive(context: Context, intent: Intent) {
//        Log.d("BootReceiver", "Received Intent: ${intent.action}")
//
//        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
//            Log.d("BootReceiver", "Device booted. Scheduling WorkManager task.")
//
//            // Schedule WorkManager task to start the service
//            val workRequest: WorkRequest = OneTimeWorkRequestBuilder<StartServiceWorker>()
//                .build()
//
//            WorkManager.getInstance(context).enqueue(workRequest)
//
//            Log.d("BootReceiver", "WorkManager task scheduled.")
//        }
//    }
//}
