import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Lỗi khởi tạo: $e");
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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE64A19),
          primary: const Color(0xFFE64A19),
          secondary: const Color(0xFF4285F4),
        ),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const InitialLoadingScreen(),
    );
  }
}

class InitialLoadingScreen extends ConsumerWidget {
  const InitialLoadingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome, size: 80, color: Color(0xFFE64A19)),
              const SizedBox(height: 32),
              authState.when(
                data: (user) {
                  if (user != null) {
                    return Column(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                          child: user.photoUrl == null ? const Icon(Icons.person) : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Chào, ${user.displayName ?? 'Người dùng'}!",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(user.email, style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 24),
                        const Text("Đăng nhập thành công!", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => ref.read(authControllerProvider).logout(),
                          icon: const Icon(Icons.logout),
                          label: const Text("Đăng xuất"),
                        ),
                      ],
                    );
                  }
                  return ElevatedButton.icon(
                    onPressed: () => ref.read(authControllerProvider).login(),
                    icon: const Icon(Icons.login),
                    label: const Text("Đăng nhập Google để Test"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (e, stack) => Column(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text("Lỗi xác thực: $e", textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(authStateProvider),
                      child: const Text("Thử lại"),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Divider(),
              const Text(
                'DeadlineSync AI Engine Ready',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const Text(
                'Kiến trúc & Logic đã sẵn sàng cho UI',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
