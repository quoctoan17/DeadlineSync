import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:logger/logger.dart';
import '../domain/entities/deadline.dart';

class AIService {
  final String apiKey;
  final _logger = Logger();
  late final GenerativeModel _model;

  AIService({required this.apiKey}) {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash', // Sử dụng bản latest để tránh lỗi version
      apiKey: apiKey,
    );
  }

  /// Trích xuất thông tin deadline từ nội dung email (Task 3 & 4)
  Future<Deadline?> extractDeadlineFromEmail(String emailContent, String emailId) async {
    try {
      final prompt = """
        Bạn là một trợ lý ảo chuyên nghiệp. Hãy phân tích nội dung email dưới đây và trích xuất thông tin về deadline (hạn chót công việc/bài tập).
        
        Nội dung email:
        \"\"\"
        $emailContent
        \"\"\"
        
        Hãy trả về kết quả duy nhất dưới định dạng JSON như sau:
        {
          "title": "Tên bài tập hoặc công việc",
          "dueDate": "Định dạng ISO8601 (YYYY-MM-DDTHH:MM:SS)",
          "description": "Mô tả ngắn gọn nội dung công việc",
          "priority": "low" hoặc "medium" hoặc "high"
        }
        
        Lưu ý: 
        - Nếu không tìm thấy deadline, hãy trả về null.
        - Priority dựa trên ngôn ngữ trong email (ví dụ: "quan trọng", "khẩn cấp" -> high).
        - Đảm bảo JSON hợp lệ.
        """;

      final response = await _model.generateContent([Content.text(prompt)]);
      if (response.text == null || response.text!.isEmpty) return null;

      final cleanJson = response.text!.replaceAll('```json', '').replaceAll('```', '').trim();
      final Map<String, dynamic> data = jsonDecode(cleanJson);

      return Deadline(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        emailId: emailId, // Dùng ID email để chặn trùng lặp
        title: data['title'] ?? 'No Title',
        dueDate: data['dueDate'] != null ? DateTime.tryParse(data['dueDate']) : null,
        description: data['description'],
        isCompleted: false,
        source: DeadlineSource.gmail,
        priority: _mapPriority(data['priority']),
        createdAt: DateTime.now(),
      );
    } catch (e) {
      _logger.e("Lỗi AI Extraction: $e");
      return null;
    }
  }

  /// Phân tích rủi ro dồn lịch và đưa ra gợi ý (Task 6 & 7)
  Future<List<Deadline>> analyzeOverallRisk(List<Deadline> allDeadlines) async {
    if (allDeadlines.isEmpty) return allDeadlines;

    try {
      final deadlineDetails = allDeadlines.map((e) => 
        "- ${e.title} (Hạn: ${e.dueDate}, Ưu tiên: ${e.priority.name})"
      ).join("\n");

      final prompt = """
      Dưới đây là danh sách các deadline hiện tại của tôi:
      $deadlineDetails
      
      Hãy phân tích sự dồn dập của các deadline này và đánh giá rủi ro trễ hạn.
      Trả về kết quả duy nhất định dạng JSON là một mảng các đối tượng (giữ nguyên thứ tự danh sách trên):
      [
        {
          "riskLevel": "low" hoặc "medium" hoặc "high" hoặc "extreme",
          "aiSuggestion": "Lời khuyên ngắn gọn để hoàn thành đúng hạn"
        }
      ]
      """;

      final response = await _model.generateContent([Content.text(prompt)]);
      if (response.text == null) return allDeadlines;

      final cleanJson = response.text!.replaceAll('```json', '').replaceAll('```', '').trim();
      final List<dynamic> analysisResults = jsonDecode(cleanJson);

      List<Deadline> updatedList = [];
      for (int i = 0; i < allDeadlines.length; i++) {
        if (i < analysisResults.length) {
          updatedList.add(allDeadlines[i].copyWith(
            riskLevel: _mapRisk(analysisResults[i]['riskLevel']),
            aiSuggestion: analysisResults[i]['aiSuggestion'],
          ));
        } else {
          updatedList.add(allDeadlines[i]);
        }
      }
      return updatedList;
    } catch (e) {
      _logger.e("Lỗi AI Risk Analysis: $e");
      return allDeadlines;
    }
  }

  PriorityLevel _mapPriority(String? p) {
    switch (p?.toLowerCase()) {
      case 'high': return PriorityLevel.high;
      case 'low': return PriorityLevel.low;
      default: return PriorityLevel.medium;
    }
  }

  RiskLevel _mapRisk(String? r) {
    switch (r?.toLowerCase()) {
      case 'extreme': return RiskLevel.extreme;
      case 'high': return RiskLevel.high;
      case 'medium': return RiskLevel.medium;
      default: return RiskLevel.low;
    }
  }
}
