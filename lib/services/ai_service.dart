import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  // =================================================================================
  // WARNING: DO NOT COMMIT THIS FILE WITH THE API KEY.
  // Replace 'YOUR_API_KEY' with your actual Google AI Studio API key.
  // It's recommended to load the key from a secure location or environment variables.
  // =================================================================================
  static const String _apiKey = 'AIzaSyDQwe3eYuPU4tDNhJZtqYFChF93rQfXBEI';

  final GenerativeModel _model;
  late final ChatSession _chatSession;

  AIService()
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash-latest',
          apiKey: _apiKey,
        ) {
    _chatSession = _model.startChat(history: [
      Content.text(
          'You are a helpful and friendly AI learning assistant for a quiz app. Your name is MasterBot. Keep your answers concise and easy to understand for students. Your answers should be in Vietnamese.'),
      Content.model([
        TextPart(
            'Sure, I am MasterBot, your virtual tutor. How can I help you with your studies today?')
      ])
    ]);
  }

  Future<String> sendMessage(String message) async {
    try {
      final response = await _chatSession.sendMessage(
        Content.text(message),
      );
      final text = response.text;

      if (text == null) {
        return 'I am sorry, I cannot provide a response at the moment.';
      }
      return text;
    } catch (e) {
      print('Error sending message to AI: $e');
      return 'An error occurred. Please try again.';
    }
  }
}
