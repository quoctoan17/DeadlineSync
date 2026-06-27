import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../../deadline/domain/entities/deadline.dart';

class LocalNotificationService {
  LocalNotificationService(this._notifications);

  final FlutterLocalNotificationsPlugin _notifications;
  Future<void>? _initialization;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    final existingInitialization = _initialization;
    if (existingInitialization != null) {
      return existingInitialization;
    }

    final initialization = _initialize();
    _initialization = initialization;
    return initialization;
  }

  Future<void> _initialize() async {
    try {
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
    } finally {
      _initialization = null;
    }
  }

  Future<void> requestPermissions() async {
    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.requestNotificationsPermission();

    final ios = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
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

    await _notifications.zonedSchedule(
      _notificationId(deadline.id),
      'Cảnh báo AI',
      _deadlineReminderBody(deadline),
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
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
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
          channelDescription:
              'Notifications received from Firebase Cloud Messaging',
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

  String _deadlineReminderBody(Deadline deadline) {
    final riskLabel = _riskLabel(deadline.riskLevel);
    final actionText = _riskActionText(deadline.riskLevel);
    return 'Cảnh báo AI: ${deadline.title} có rủi ro $riskLabel, $actionText';
  }

  String _riskLabel(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.extreme:
        return 'RẤT CAO';
      case RiskLevel.high:
        return 'CAO';
      case RiskLevel.medium:
        return 'TRUNG BÌNH';
      case RiskLevel.low:
        return 'THẤP';
    }
  }

  String _riskActionText(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.extreme:
        return 'hãy làm ngay!';
      case RiskLevel.high:
        return 'nên bắt đầu ngay!';
      case RiskLevel.medium:
        return 'hãy sắp xếp thời gian sớm.';
      case RiskLevel.low:
        return 'bạn vẫn nên theo dõi tiến độ.';
    }
  }
}
