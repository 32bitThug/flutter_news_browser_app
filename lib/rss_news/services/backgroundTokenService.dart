// import 'package:flutter/material.dart';
// import 'package:workmanager/workmanager.dart';
// import 'dart:async';
// import 'package:flutter_browser/Db/hive_db_helper.dart';

// // This is the callback that will be executed when the background task runs
// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((taskName, inputData) async {
//     debugPrint("Native called background task: $taskName");
    
//     try {
//       // Check token expiration
//       DateTime? expirationTime = HiveDBHelper.getToken();
      
//       if (expirationTime != null && DateTime.now().isAfter(expirationTime)) {
//         // Token has expired
//         // Here you can:
//         // 1. Send a local notification
//         // 2. Trigger a token refresh
//         // 3. Log the expiration
//         debugPrint("Token has expired in background task");
        
//         // Optional: Perform token refresh or other actions
//         // await GraphQLRequests().refreshToken();
//       } else {
//         debugPrint("Token is still valid");
//       }
      
//       return Future.value(true);
//     } catch (e) {
//       debugPrint("Error in background token check: $e");
//       return Future.value(false);
//     }
//   });
// }

// class BackgroundTokenService {
//   static void initialize() {
//     // Initialize WorkManager
//     Workmanager().initialize(
//       callbackDispatcher,
//       isInDebugMode: true, // Set to false in production
//     );

//     // Register periodic task
//     Workmanager().registerPeriodicTask(
//       'token-expiration-check', // Unique name for the task
//       'checkTokenExpiration', // Task name
//       frequency: const Duration(minutes: 15), // Check every 15 minutes
//       constraints: Constraints(
//         networkType: NetworkType.connected, // Only run when internet is available
//         requiresBatteryNotLow: true, // Avoid running when battery is low
//       ),
//     );
//   }

//   // Method to cancel all background tasks if needed
//   static void cancelAllTasks() {
//     Workmanager().cancelAll();
//   }
// }
