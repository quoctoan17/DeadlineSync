import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/local_notification_service.dart';
import '../services/push_notification_service.dart';

final localNotificationServiceProvider = Provider<LocalNotificationService>((
  ref,
) {
  return LocalNotificationService(FlutterLocalNotificationsPlugin());
});

final pushNotificationServiceProvider = Provider<PushNotificationService>((
  ref,
) {
  final messaging = Firebase.apps.isEmpty ? null : FirebaseMessaging.instance;
  final service = PushNotificationService(
    messaging: messaging,
    localNotificationService: ref.watch(localNotificationServiceProvider),
  );

  ref.onDispose(() {
    unawaited(service.dispose());
  });
  return service;
});
