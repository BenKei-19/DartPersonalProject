import 'package:flutter/material.dart';
import '../data/models/transaction.dart';
import '../data/models/relative_category.dart';
import '../utils/voice_service.dart';
import '../utils/gemini_service.dart';

enum VoiceState { idle, listening, processing, preview, error }

class VoiceTransactionViewModel extends ChangeNotifier {
  final VoiceService _voiceService = VoiceService();
  final GeminiService _geminiService = GeminiService();

  VoiceState _state = VoiceState.idle;
  String _recognizedText = '';
  String _errorMessage = '';
  Map<String, dynamic>? _parsedData;

  List<String> _availableLocales = [];
  bool _isLocaleSupported = true;

  List<String> get availableLocales => _availableLocales;
  bool get isLocaleSupported => _isLocaleSupported;

  Future<void> checkLocales() async {
    _availableLocales = await _voiceService.getAvailableLocales();
    _isLocaleSupported = _availableLocales.contains('vi_VN');
    notifyListeners();
  }

  VoiceState get state => _state;
  String get recognizedText => _recognizedText;
  String get errorMessage => _errorMessage;
  Map<String, dynamic>? get parsedData => _parsedData;

  bool get isListening => _state == VoiceState.listening;
  bool get isProcessing => _state == VoiceState.processing;
  bool get hasPreview => _state == VoiceState.preview;

  Future<void> startListening() async {
    _state = VoiceState.listening;
    _recognizedText = '';
    _errorMessage = '';
    _parsedData = null;
    notifyListeners();

    await _voiceService.startListening(
      onResult: (text) {
        if (text.startsWith('ERROR:')) {
          _state = VoiceState.error;
          _errorMessage = text.replaceFirst('ERROR: ', '');
          notifyListeners();
        } else {
          _recognizedText = text;
          notifyListeners();
        }
      },
    );
  }

  String _parseErrorMessage = '';
  String get parseErrorMessage => _parseErrorMessage;

  Future<void> stopAndProcess({List<RelativeCategory> categories = const []}) async {
    await _voiceService.stopListening();

    if (_recognizedText.trim().isEmpty) {
      _parseErrorMessage = 'Không nhận diện được giọng nói. Hãy thử lại.';
      notifyListeners();
      return;
    }

    _state = VoiceState.processing;
    _parseErrorMessage = '';
    notifyListeners();

    try {
      final categoryNames = categories.map((c) => c.name).toList();
      final result = await _geminiService.parseTransaction(
        _recognizedText,
        categoryNames: categoryNames,
      );
      if (result != null) {
        _parsedData = result;
        _state = VoiceState.preview;
      } else {
        _state = VoiceState.idle;
        _parseErrorMessage = 'AI không thể phân tích câu này. Hãy thử nói rõ hơn.';
      }
    } catch (e) {
      if (e.toString().contains('GEMINI_PARSE_ERROR') || e.toString().contains('GEMINI_DATA_ERROR')) {
        _state = VoiceState.idle;
        _parseErrorMessage = 'Lỗi phân tích dữ liệu AI. Hãy thử lại câu khác.';
      } else {
        _state = VoiceState.error;
        _errorMessage = 'Lỗi hệ thống AI: $e';
      }
    }
    notifyListeners();
  }

  void clearParseError() {
    _parseErrorMessage = '';
    notifyListeners();
  }

  LixiTransaction? buildTransaction(int userId, {List<RelativeCategory> categories = const []}) {
    if (_parsedData == null) return null;

    final now = DateTime.now();
    final dateStr = _parsedData!['date'] as String? ?? now.toIso8601String().substring(0, 10);
    final date = DateTime.tryParse(dateStr) ?? now;

    // Match category name to categoryId
    int? categoryId;
    final categoryName = _parsedData!['category'] as String?;
    if (categoryName != null && categories.isNotEmpty) {
      final normalizedTarget = categoryName.trim().toLowerCase();
      
      // 1. Try exact match (normalized)
      final match = categories.where(
        (c) => c.name.trim().toLowerCase() == normalizedTarget,
      );
      
      if (match.isNotEmpty) {
        categoryId = match.first.id;
      } else {
        // 2. Try partial match (if Gemini returns "Bà ngoại" and category is "Ông Bà")
        // Or vice versa
        final partialMatch = categories.where((c) {
          final catName = c.name.toLowerCase();
          return normalizedTarget.contains(catName) || catName.contains(normalizedTarget);
        });
        
        if (partialMatch.isNotEmpty) {
          categoryId = partialMatch.first.id;
        }
      }
      // print('Matching category: "$categoryName" -> ID: $categoryId');
    }

    return LixiTransaction(
      userId: userId,
      type: _parsedData!['type'] as String? ?? 'given',
      amount: (_parsedData!['amount'] as num?)?.toDouble() ?? 0,
      personName: _parsedData!['personName'] as String? ?? 'Không rõ',
      categoryId: categoryId,
      date: dateStr,
      year: date.year,
      note: _parsedData!['note'] as String?,
      createdAt: now.toIso8601String(),
    );
  }

  void setRecognizedTextForTest(String text) {
    _recognizedText = text;
    _state = VoiceState.processing;
    notifyListeners();
  }

  void reset() {
    _state = VoiceState.idle;
    _recognizedText = '';
    _errorMessage = '';
    _parsedData = null;
    notifyListeners();
  }
}
