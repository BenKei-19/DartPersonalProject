import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;

  bool get isAvailable => _isInitialized;

  Future<bool> initialize() async {
    try {
      _isInitialized = await _speech.initialize(
        onError: (error) => {}, // Suppress in production or use a logger
        onStatus: (status) => {},
      );
      if (!_isInitialized) {
      }
      return _isInitialized;
    } catch (e) {
      return false;
    }
  }

  Future<void> startListening({
    required void Function(String text) onResult,
    String localeId = 'vi_VN',
  }) async {
    if (!_isInitialized) {
      final ok = await initialize();
      if (!ok) {
        onResult('ERROR: Khởi tạo thất bại');
        return;
      }
    }

    // Check available locales
    final locales = await _speech.locales();
    bool hasTargetLocale = locales.any((l) => l.localeId == localeId);
    String selectedLocale = hasTargetLocale ? localeId : (locales.isNotEmpty ? locales.first.localeId : 'en_US');
    
    if (!hasTargetLocale) {
    }

    // ignore: deprecated_member_use
    await _speech.listen(
      onResult: (result) {
        // print('Speech result: "${result.recognizedWords}" - Final: ${result.finalResult}');
        onResult(result.recognizedWords);
      },
      localeId: selectedLocale,
      onSoundLevelChange: (level) => {},
      // ignore: deprecated_member_use
      listenMode: ListenMode.confirmation, // Changed from dictation for better sensitivity
      // ignore: deprecated_member_use
      cancelOnError: true,
      // ignore: deprecated_member_use
      partialResults: true,
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }

  Future<List<String>> getAvailableLocales() async {
    if (!_isInitialized) await initialize();
    final locales = await _speech.locales();
    return locales.map((l) => l.localeId).toList();
  }

  bool get isListening => _speech.isListening;
}
