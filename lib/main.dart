import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_gate.dart';
import 'features/notification/presentation/notification_bootstrap.dart';

Future<void> main() async {
  // Đảm bảo các dịch vụ Flutter đã được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // 1. Khởi tạo Firebase (Cần cho Auth và DB)
    await Firebase.initializeApp();
    
    // 2. Load biến môi trường (Cần cho AI)
    await dotenv.load(fileName: '.env', isOptional: true);
  } catch (e) {
    debugPrint("Lỗi khởi tạo hệ thống: $e");
  }

  runApp(
    const ProviderScope(
      child: DeadlineSyncApp(),
    ),
  );
}

class DeadlineSyncApp extends StatelessWidget {
  const DeadlineSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeadlineSync',
      debugShowCheckedModeBanner: false,
      // Sử dụng theme của Thiện đã thiết kế
      theme: AppTheme.light,
      // Luôn bắt đầu từ AuthGate để kiểm tra đăng nhập, 
      // bọc trong NotificationBootstrap để kích hoạt thông báo
      home: const NotificationBootstrap(
        child: AuthGate(),
      ),
    );
  }
}