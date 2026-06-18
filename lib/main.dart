import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  // Đảm bảo các dịch vụ Flutter đã được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();
  
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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE64A19), // Màu cam đặc trưng của Canvas
          primary: const Color(0xFFE64A19),
          secondary: const Color(0xFF0078D4), // Màu xanh đặc trưng của Outlook
        ),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const MainDashboard(),
    );
  }
}

class MainDashboard extends StatelessWidget {
  const MainDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DeadlineSync'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sync, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Chào mừng đến với DeadlineSync',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
              child: Text(
                'Ứng dụng đang được thiết lập kiến trúc. Hãy bắt đầu kết nối Canvas hoặc Outlook.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {}, 
              icon: const Icon(Icons.school),
              label: const Text('Kết nối Canvas LMS'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE64A19),
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {}, 
              icon: const Icon(Icons.email),
              label: const Text('Kết nối Outlook'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0078D4),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
