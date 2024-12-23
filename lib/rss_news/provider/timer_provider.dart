import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_browser/Db/hive_db_helper.dart';
import 'package:flutter_browser/rss_news/constants/constants.dart';
import 'package:flutter_browser/rss_news/models/device_model.dart';
import 'package:flutter_browser/rss_news/screens/session_screen.dart';
import 'package:flutter_browser/rss_news/utils/debug.dart';

class TimerProvider extends ChangeNotifier {
  Timer? _timer;
  DateTime _lastSessionTime = DateTime.now();

  DateTime get lastSessionTime => _lastSessionTime;

  TimerProvider() {
    _loadLastSessionTime(); // Load last session time when provider is created
  }

  /// Load last session time from SharedPreferences
  Future<void> _loadLastSessionTime() async {
    // final prefs = await SharedPreferences.getInstance();
    final savedTime = HiveDBHelper.getToken();
    debug(savedTime);
    if (savedTime != null) {
      _lastSessionTime = (savedTime);
    }
    // notifyListeners();
  }

  void startTimer() {
    _timer?.cancel();
    debug(_lastSessionTime.toLocal());

    _timer = Timer.periodic(const Duration(minutes: 10), (_) {
      if (DateTime.now().difference(_lastSessionTime).inMinutes >= 60) {
        _triggerSessionScreen();
      }
    });

    // notifyListeners();
  }

  Future<void> updateLastSessionTime() async {
    _lastSessionTime = DateTime.now();
    await HiveDBHelper.setToken(_lastSessionTime);
    debug(HiveDBHelper.getToken()!.toIso8601String());
    // notifyListeners();
  }

  void _triggerSessionScreen() async {
    debug("Last session time: $lastSessionTime");
    await Future.delayed(Durations.extralong1);
    Device? device = HiveDBHelper.getDevice();
    if (device != null) {
      myNavigatorKey.currentState?.push(MaterialPageRoute(
        builder: (_) => const SessionScreen(),
      ));
    }
    debug("Navigation pushed");
    notifyListeners();
  }

  void stopTimer() {
    _timer?.cancel();
  }
}
