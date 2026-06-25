import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      ref.read(pushNotificationServiceProvider).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
