import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../../deadline/domain/entities/deadline.dart';

class LocalNotificationService {
  LocalNotificationService(this._notifications);

  final FlutterLocalNotificationsPlugin _notifications;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
    await requestPermissions();
    _isInitialized = true;
  }

  Future<void> requestPermissions() async {
    final android = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();

    final ios = _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> scheduleDeadlineReminder(
    Deadline deadline, {
    Duration remindBefore = const Duration(days: 1),
  }) async {
    await initialize();

    final dueDate = deadline.dueDate;
    if (dueDate == null || deadline.isCompleted) {
      await cancelDeadlineReminder(deadline.id);
      return;
    }

    final scheduledAt = _nextReminderTime(dueDate, remindBefore);
    if (scheduledAt == null) {
      await cancelDeadlineReminder(deadline.id);
      return;
    }

    final riskText = _riskMessage(deadline.riskLevel);
    await _notifications.zonedSchedule(
      _notificationId(deadline.id),
      'Deadline reminder',
      '$riskText${deadline.title}',
      tz.TZDateTime.from(scheduledAt, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'deadline_reminders',
          'Deadline reminders',
          channelDescription: 'Reminder before a deadline is due',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: deadline.id,
    );
  }

  Future<void> cancelDeadlineReminder(String deadlineId) async {
    await _notifications.cancel(_notificationId(deadlineId));
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await initialize();

    await _notifications.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'push_notifications',
          'Push notifications',
          channelDescription: 'Notifications received from Firebase Cloud Messaging',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  int _notificationId(String deadlineId) {
    var hash = 0;
    for (final codeUnit in deadlineId.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7fffffff;
    }
    return hash;
  }

  DateTime? _nextReminderTime(DateTime dueDate, Duration remindBefore) {
    final now = DateTime.now();
    final preferredTime = dueDate.subtract(remindBefore);
    if (preferredTime.isAfter(now)) {
      return preferredTime;
    }

    final oneHourBefore = dueDate.subtract(const Duration(hours: 1));
    if (oneHourBefore.isAfter(now)) {
      return oneHourBefore;
    }

    final soon = now.add(const Duration(minutes: 1));
    return soon.isBefore(dueDate) ? soon : null;
  }

  String _riskMessage(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.high:
      case RiskLevel.extreme:
        return 'High risk: ';
      case RiskLevel.medium:
        return 'Heads up: ';
      case RiskLevel.low:
        return '';
    }
  }
}

