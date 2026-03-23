import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  GenerativeModel? _model;

  void initialize() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in .env');
    }
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );
  }

  Future<Map<String, dynamic>?> parseTransaction(
    String voiceText, {
    List<String> categoryNames = const [],
  }) async {
    try {
      if (_model == null) initialize();
    } catch (e) {
      throw Exception('GEMINI_INIT_ERROR: $e');
    }

    final today = DateTime.now();
    final categoryList = categoryNames.isNotEmpty
        ? categoryNames.join(', ')
        : 'Ông Bà, Bố Mẹ, Cô Chú, Anh Chị, Bạn bè, Đồng nghiệp, Hàng xóm, Khác';

    final prompt = '''
Bạn là trợ lý AI phân tích giao dịch lì xì. Hãy trích xuất thông tin từ câu nói sau và trả về JSON.

Câu nói: "$voiceText"

Ngày hôm nay (dương lịch): ${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}

DANH SÁCH NHÓM NGƯỜI THÂN BẮT BUỘC (Chỉ được chọn 1 trong các tên này): [$categoryList]

Hãy trả về ĐÚNG format JSON sau (không có markdown, không có giải thích):
{
  "type": "received" hoặc "given",
  "amount": <số tiền dạng số>,
  "personName": "<tên người cụ thể>",
  "category": "<CHỌN CHÍNH XÁC 1 TÊN TRONG DANH SÁCH NHÓM TRÊN>",
  "date": "<ngày dạng YYYY-MM-DD>",
  "note": "<ghi chú nếu có, null nếu không>"
}

Quy tắc:
- "nhận lì xì", "được", "nhận từ" → type = "received"
- "cho", "lì xì cho", "tặng", "biếu" → type = "given"
- Nếu người dùng nói "Mùng 1 Tết" mà không nói năm, hãy tính là ngày mùng 1 tháng 1 âm lịch tiếp theo tính từ hôm nay.
- Nếu không thể khớp chính xác Nhóm người thân, hãy chọn cái gần đúng nhất trong danh sách.
- Chỉ trả về JSON.
''';

    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      final text = response.text;
      if (text == null || text.isEmpty) {
        throw Exception('GEMINI_EMPTY_RESPONSE: AI không trả về dữ liệu');
      }

      // Robust JSON extraction using Regex
      final jsonRegex = RegExp(r'\{[\s\S]*\}');
      final match = jsonRegex.stringMatch(text);
      
      if (match == null) {
        throw Exception('GEMINI_PARSE_ERROR: Phản hồi không chứa JSON: $text');
      }

      final Map<String, dynamic> parsed = jsonDecode(match);

      // Validate required fields
      if (!parsed.containsKey('type') ||
          !parsed.containsKey('amount') ||
          !parsed.containsKey('personName')) {
        throw Exception('GEMINI_DATA_ERROR: Thiếu thông tin bắt buộc trong JSON');
      }

      // Ensure amount is a number
      if (parsed['amount'] is String) {
        parsed['amount'] = double.tryParse(parsed['amount'].toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
      }

      return parsed;
    } catch (e) {
      // debugPrint('Gemini error: $e');
      rethrow;
    }
  }
}
