/// Supabase + Google OAuth config for Orbit Notes.
///
/// Override at run time with:
/// `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
/// `--dart-define=GOOGLE_WEB_CLIENT_ID=...`
/// `--dart-define=GOOGLE_IOS_CLIENT_ID=...` (optional; enables native iOS Google)
///
/// Never put the Google client *secret* here — that belongs only in the
/// Supabase Auth → Google provider dashboard.
class SupabaseConfig {
  const SupabaseConfig._();

  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://oyjxpiradbbuocxsunmu.supabase.co',
  );

  /// Publishable / anon key (safe for the client).
  static const anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_RunjlGX9mXvJo9gwaswjcg_gHCToHIR',
  );

  /// Web OAuth client ID (also used as Google Sign-In `serverClientId`).
  static const googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue:
        '245020475764-jhbmje6n9sm636bkta903fr053aj13qt.apps.googleusercontent.com',
  );

  /// iOS OAuth client ID from Google Cloud Console (type: iOS).
  /// When empty, iOS uses Supabase browser OAuth instead of native Google Sign-In.
  static const googleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
    defaultValue: '',
  );

  static const authRedirectUrl = 'io.supabase.orbitnotes://login-callback/';

  static const photosBucket = 'orbit-photos';
}
