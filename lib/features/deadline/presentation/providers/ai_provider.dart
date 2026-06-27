import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/ai_service.dart';

final aiServiceProvider = Provider<AIService>((ref) {
  // Lấy API Key từ file .env
  final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  return AIService(apiKey: apiKey);
});
