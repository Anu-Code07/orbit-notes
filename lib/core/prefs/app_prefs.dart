import 'package:shared_preferences/shared_preferences.dart';

/// Local flags for first-launch auth gate.
class AppPrefs {
  AppPrefs(this._prefs);

  final SharedPreferences _prefs;

  static const _authGateKey = 'orbit_auth_gate_completed';

  bool get hasCompletedAuthGate => _prefs.getBool(_authGateKey) ?? false;

  Future<void> markAuthGateCompleted() => _prefs.setBool(_authGateKey, true);

  static Future<AppPrefs> open() async {
    final prefs = await SharedPreferences.getInstance();
    return AppPrefs(prefs);
  }
}
