import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  bool _deadlineReminders = true;
  bool _dailyReminders = true;

  bool get deadlineReminders =>
      _deadlineReminders;

  bool get dailyReminders =>
      _dailyReminders;

  Future<void> initialize() async {
    final prefs =
    await SharedPreferences.getInstance();

    _deadlineReminders =
        prefs.getBool('deadline_reminders') ??
            true;

    _dailyReminders =
        prefs.getBool('daily_reminders') ??
            true;

    notifyListeners();
  }

  Future<void> setDeadlineReminders(
      bool value,
      ) async {
    _deadlineReminders = value;

    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setBool(
      'deadline_reminders',
      value,
    );

    notifyListeners();
  }

  Future<void> setDailyReminders(
      bool value,
      ) async {
    _dailyReminders = value;

    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setBool(
      'daily_reminders',
      value,
    );

    notifyListeners();
  }
}