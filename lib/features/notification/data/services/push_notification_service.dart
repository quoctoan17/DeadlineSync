import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'local_notification_service.dart';

class PushNotificationService {
  PushNotificationService({
    required FirebaseMessaging messaging,
    required LocalNotificationService localNotificationService,
  }) : _messaging = messaging,
       _localNotificationService = localNotificationService;

  final FirebaseMessaging _messaging;
  final LocalNotificationService _localNotificationService;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<String>? _tokenSubscription;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    await _localNotificationService.initialize();
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      _showForegroundMessage,
    );
    _tokenSubscription = _messaging.onTokenRefresh.listen(_handleTokenRefresh);
    _isInitialized = true;
  }

  Future<String?> getToken() {
    return _messaging.getToken();
  }

  Future<RemoteMessage?> getInitialMessage() {
    return _messaging.getInitialMessage();
  }

  Future<void> dispose() async {
    await _foregroundSubscription?.cancel();
    await _tokenSubscription?.cancel();
    _foregroundSubscription = null;
    _tokenSubscription = null;
    _isInitialized = false;
  }

  Future<void> _showForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? 'DeadlineSync';
    final body = notification?.body ?? 'You have a new update.';

    await _localNotificationService.showInstantNotification(
      id: _notificationId(message),
      title: title,
      body: body,
      payload: message.data['deadlineId']?.toString(),
    );
  }

  void _handleTokenRefresh(String token) {
    // Firestore token persistence belongs to the later sync/user-settings task.
  }

  int _notificationId(RemoteMessage message) {
    final value = message.messageId ?? DateTime.now().toIso8601String();
    var hash = 0;
    for (final codeUnit in value.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7fffffff;
    }
    return hash;
  }
}
