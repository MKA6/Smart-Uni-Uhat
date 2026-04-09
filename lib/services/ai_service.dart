import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AiService extends ChangeNotifier {
  bool _isProcessing = false;
  String? _lastSummary;

  bool get isProcessing => _isProcessing;
  String? get lastSummary => _lastSummary;

  // Hugging Face Inference API endpoint
  // يمكنك استبدال النموذج بأي نموذج آخر من Hugging Face
  static const String _hfApiUrl =
      'https://api-inference.huggingface.co/models/HuggingFaceH4/zephyr-7b-beta';

  // ضع مفتاح Hugging Face API هنا أو احضره من متغيرات البيئة
  static const String _hfApiKey = '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';

  /// توليد رد ذكي على رسالة في سياق أكاديمي
  Future<String> generateAcademicReply(
    String userMessage, {
    String? courseContext,
  }) async {
    _isProcessing = true;
    notifyListeners();

    try {
      final prompt = _buildAcademicPrompt(userMessage, courseContext);

      final response = await http
          .post(
            Uri.parse(_hfApiUrl),
            headers: {
              'Authorization': 'Bearer $_hfApiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'inputs': prompt,
              'parameters': {
                'max_new_tokens': 200,
                'temperature': 0.7,
                'top_p': 0.9,
                'do_sample': true,
                'return_full_text': false,
              },
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String generatedText = '';

        if (data is List && data.isNotEmpty) {
          generatedText = data[0]['generated_text'] ?? '';
        } else if (data is Map) {
          generatedText = data['generated_text'] ?? '';
        }

        _isProcessing = false;
        notifyListeners();
        return generatedText.trim().isNotEmpty
            ? generatedText.trim()
            : _getFallbackResponse(userMessage);
      }

      // Fallback if API fails
      _isProcessing = false;
      notifyListeners();
      return _getFallbackResponse(userMessage);
    } catch (e) {
      _isProcessing = false;
      notifyListeners();
      return _getFallbackResponse(userMessage);
    }
  }

  /// تلخيص المحادثة
  Future<String> summarizeConversation(List<String> messages) async {
    _isProcessing = true;
    notifyListeners();

    try {
      final conversationText = messages.join('\n');
      final prompt =
          'Summarize this academic conversation in Arabic concisely:\n$conversationText\n\nSummary:';

      final response = await http
          .post(
            Uri.parse(_hfApiUrl),
            headers: {
              'Authorization': 'Bearer $_hfApiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'inputs': prompt,
              'parameters': {
                'max_new_tokens': 150,
                'temperature': 0.5,
                'return_full_text': false,
              },
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String summary = '';
        if (data is List && data.isNotEmpty) {
          summary = data[0]['generated_text'] ?? '';
        }
        _lastSummary = summary.trim();
        _isProcessing = false;
        notifyListeners();
        return _lastSummary ?? 'تعذّر إنشاء الملخص';
      }
    } catch (_) {}

    _isProcessing = false;
    _lastSummary = _getDefaultSummary(messages.length);
    notifyListeners();
    return _lastSummary!;
  }

  String _buildAcademicPrompt(String message, String? courseContext) {
    final context = courseContext != null
        ? 'You are an AI assistant for university students in the course: $courseContext. '
        : 'You are an AI assistant for university students. ';
    return '${context}Answer this academic question in Arabic briefly and clearly:\n$message\n\nAnswer:';
  }

  String _getFallbackResponse(String message) {
    final lowerMsg = message.toLowerCase();

    if (lowerMsg.contains('شرح') || lowerMsg.contains('explain')) {
      return '🤖 المساعد الذكي: يبدو أنك تطلب شرحًا. تأكد من مراجعة ملاحظات المحاضرة أولاً، ثم يمكنك طرح أسئلة محددة حول الجزء الذي يصعب عليك فهمه.';
    }
    if (lowerMsg.contains('مساعدة') || lowerMsg.contains('help')) {
      return '🤖 المساعد الذكي: أنا هنا للمساعدة! يرجى تحديد سؤالك بشكل أوضح حتى أتمكن من تقديم إجابة أفضل.';
    }
    if (lowerMsg.contains('امتحان') || lowerMsg.contains('exam')) {
      return '🤖 المساعد الذكي: للتحضير للامتحان، يُنصح بمراجعة الملاحظات، وحل الأسئلة السابقة، وتنظيم وقتك بشكل جيد. حظ موفق! 🌟';
    }

    return '🤖 المساعد الذكي: شكرًا على سؤالك. لتقديم إجابة أفضل، يرجى توضيح سؤالك أكثر. يمكنني مساعدتك في الشرح الأكاديمي والموارد الدراسية.';
  }

  String _getDefaultSummary(int messageCount) {
    return '📝 ملخص المحادثة: تضمنت هذه المحادثة $messageCount رسالة تناولت موضوعات أكاديمية متنوعة. يمكنك الرجوع إلى الرسائل السابقة للاطلاع على التفاصيل الكاملة.';
  }
}
