import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../deadline/data/providers/deadline_database_providers.dart';
import '../data/providers/local_notification_providers.dart';

class NotificationBootstrap extends ConsumerStatefulWidget {
  const NotificationBootstrap({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<NotificationBootstrap> createState() =>
      _NotificationBootstrapState();
}

class _NotificationBootstrapState extends ConsumerState<NotificationBootstrap> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      unawaited(ref.read(pushNotificationServiceProvider).initialize());
      unawaited(ref.read(offlineSyncServiceProvider).start());
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
