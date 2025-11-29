import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones(); // Initialize time zones

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // For iOS (if you add it later)
    const DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true);

    const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsDarwin);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // --- SCHEDULE A REPEATING NOTIFICATION ---
  Future<void> scheduleReminder({
    required int id, // Unique ID for the notification
    required String title,
    required String body,
    required TimeOfDay time,
    required List<String> days, // ['Mon', 'Wed']
  }) async {
    // We map your days string to the API's DateTime.weekday constants
    // Your app uses 'Mon', 'Tue' etc.
    final dayMap = {
      'Mon': DateTime.monday,
      'Tue': DateTime.tuesday,
      'Wed': DateTime.wednesday,
      'Thu': DateTime.thursday,
      'Fri': DateTime.friday,
      'Sat': DateTime.saturday,
      'Sun': DateTime.sunday,
    };

    for (String day in days) {
      // Create a unique ID for each day of the reminder
      // e.g. If reminder ID is 100, Monday is 1001, Tuesday is 1002
      final notificationId = int.parse('$id${dayMap[day]}');

      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        title,
        body,
        _nextInstanceOfDayAndTime(dayMap[day]!, time),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminders_channel', // Channel ID
            'MindSport Reminders', // Channel Name
            channelDescription: 'Daily wellness reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  // --- CANCEL NOTIFICATION ---
  Future<void> cancelReminder(int id) async {
    // We have to cancel for all 7 possible days to be safe
    for (int i = 1; i <= 7; i++) {
      await flutterLocalNotificationsPlugin.cancel(int.parse('$id$i'));
    }
  }

  // Helper to calculate the next date/time for the alert
  tz.TZDateTime _nextInstanceOfDayAndTime(int weekday, TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, time.hour, time.minute);

    // If the scheduled time has passed today, move to tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Keep adding days until the weekday matches
    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
