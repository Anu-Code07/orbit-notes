/// Groq API config.
///
/// Pass at build/run time:
/// `--dart-define=GROQ_API_KEY=...`
/// Do not commit a real key (GitHub push protection will block it).
class GroqConfig {
  const GroqConfig._();

  static const apiKey = String.fromEnvironment('GROQ_API_KEY');

  static const model = String.fromEnvironment(
    'GROQ_MODEL',
    defaultValue: 'llama-3.3-70b-versatile',
  );

  static bool get isConfigured => apiKey.isNotEmpty;
}
