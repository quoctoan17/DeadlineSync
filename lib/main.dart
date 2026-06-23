import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // Đảm bảo các dịch vụ Flutter đã được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (From Quân's branch)
  await Firebase.initializeApp();
  
  // Load environment variables (From Toàn's branch)
  await dotenv.load(fileName: ".env", isOptional: true);
  
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
          seedColor: const Color(0xFFE64A19),
          primary: const Color(0xFFE64A19),
          secondary: const Color(0xFF4285F4),
        ),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      // Starting screen prepared for Thiện
      home: const InitialLoadingScreen(),
    );
  }
}

class InitialLoadingScreen extends StatelessWidget {
  const InitialLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: 64, color: Color(0xFFE64A19)),
            SizedBox(height: 16),
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'DeadlineSync AI Engine Ready',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Waiting for UI implementation...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
