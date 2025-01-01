// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_browser/Db/hive_db_helper.dart';
import 'package:flutter_browser/rss_news/utils/debug.dart';
import 'package:flutter_browser/rss_news/utils/show_snackbar.dart';

class KioskModeSwitch extends StatefulWidget {
  const KioskModeSwitch({super.key});

  @override
  KioskModeSwitchState createState() => KioskModeSwitchState();
}

class KioskModeSwitchState extends State<KioskModeSwitch> {
  bool _isKioskModeEnabled =
      HiveDBHelper.getKioskMode(); // Initial value for the switch
  final String _correctPassword = "qwerty"; // Set your desired password here

  static const platform =
      MethodChannel('com.pichillilorenzo.flutter_browser.intent_data');

  // Method to start the service
  Future<void> _startService() async {
    try {
      final String result = await platform.invokeMethod('startService');
      debug(result);
    } on PlatformException catch (e) {
      debug("Failed to invoke method: '${e.message}'.");
    }
  }

  // Method to request accessibility permission
  Future<void> _requestAccessibilityPermission() async {
    try {
      final String result =
          await platform.invokeMethod('requestAccessibilityPermission');
      debug(result);
    } on PlatformException catch (e) {
      debug("Failed to invoke method: '${e.message}'.");
    }
  }

  // Show password dialog to disable kiosk mode
  Future _showPasswordDialog() async {
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter Password"),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(hintText: "Password"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (passwordController.text == _correctPassword) {
                  _isKioskModeEnabled = false;
                  await HiveDBHelper.setKioskMode(false);
                  await _setKioskMode(false);
                  setState(() {});
                  Navigator.of(context).pop(); // Close the dialog
                } else {
                  Navigator.of(context).pop();
                  showSnackBar(message: "Incorrect password");
                }
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Method to handle the switch change
  Future _onKioskModeChanged(bool value) async {
    if (value) {
      // If turning on Kiosk Mode, first check for permission
      await _checkPermissionsAndStartService();
    } else {
      // If turning off Kiosk Mode, show the password dialog
      await _showPasswordDialog();
    }
  }

  // Method to update the kiosk mode status in the service
  Future<void> _setKioskMode(bool enabled) async {
    try {
      await platform.invokeMethod('setKioskMode', {'enabled': enabled});
    } on PlatformException catch (e) {
      debug("Failed to invoke method: '${e.message}'.");
    }
  }

  // Check if the permissions are set and request if not
  Future _checkPermissionsAndStartService() async {
    // You can check the permission status here (you might need a plugin for this)
    // If permissions are not granted, request permission
    await _startService();
    await _requestAccessibilityPermission();

    // Start the service after requesting permission
    _isKioskModeEnabled = true;
    await HiveDBHelper.setKioskMode(true);
    setState(() {});

    // Notify service to start blocking apps
    await _setKioskMode(true);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text("Kiosk mode"),
          subtitle: const Text("Restricts device to run this specific app"),
          value: _isKioskModeEnabled,
          onChanged: _onKioskModeChanged,
        ),
      ],
    );
  }
}
