import '../ip.dart' as legacy;

class AppConfig {
  static const String appName = 'SmokeFree';
  static const String appTagline = 'Breathe Fresh, Live Free';
  static const String appVersion = '2.0.0';

  // Base API configuration (backed by existing server)
  static String get baseUrl => legacy.ip;
  static set baseUrl(String url) => legacy.ip = url;

  // Regional configurations
  static const String defaultCurrencySymbol = '₹';
  static const String defaultCountryCode = '+91';

  // Feature Flags
  static const bool enableAIAssistant = true;
  static const bool enableBiometrics = true;
  static const bool enableAudioGuidedBreathing = true;
  static const bool enableOfflineSync = true;

  // External API keys & placeholders (ready for user to add)
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  static const String revenueCatApiKey = String.fromEnvironment('REVENUECAT_KEY', defaultValue: '');
}
