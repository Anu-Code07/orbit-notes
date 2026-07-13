import 'package:orbit_notes/core/config/groq_secrets.dart';

/// Groq API config.
///
/// Key is read from [GroqSecrets] (local string), or override with:
/// `--dart-define=GROQ_API_KEY=...`
class GroqConfig {
  const GroqConfig._();

  static const apiKey = String.fromEnvironment(
    'GROQ_API_KEY',
    defaultValue: GroqSecrets.apiKey,
  );

  static const model = String.fromEnvironment(
    'GROQ_MODEL',
    defaultValue: 'llama-3.3-70b-versatile',
  );

  static bool get isConfigured => apiKey.isNotEmpty;
}
