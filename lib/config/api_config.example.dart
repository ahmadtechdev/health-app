/// API Configuration Example
/// Copy this file to api_config.dart and add your API key
/// DO NOT commit api_config.dart to version control
class ApiConfig {
  static String get geminiApiKey {
    const String? envKey = String.fromEnvironment('GEMINI_API_KEY');
    if (envKey != null && envKey.isNotEmpty) {
      return envKey;
    }
    
    // Replace with your actual API key
    return 'YOUR_API_KEY_HERE';
  }
}

