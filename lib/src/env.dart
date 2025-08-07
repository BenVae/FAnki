class Env {
  static const String openaiApiKey = String.fromEnvironment('OPEN_AI_API_KEY');
  
  static void validateEnvironment() {
    if (openaiApiKey.isEmpty) {
      throw Exception('Missing OPEN_AI_API_KEY environment variable');
    }
  }
}