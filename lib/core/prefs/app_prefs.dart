import 'package:shared_preferences/shared_preferences.dart';

/// Local flags for first-launch education and auth gate.
class AppPrefs {
  AppPrefs(this._prefs);

  final SharedPreferences _prefs;

  static const _authGateKey = 'orbit_auth_gate_completed';
  static const _homeTourKey = 'orbit_home_tour_seen';

  /// Stable id for the one seeded sample trip (safe to delete).
  static const exampleTripId = 'orbit-example-trip';

  bool get hasCompletedAuthGate => _prefs.getBool(_authGateKey) ?? false;

  Future<void> markAuthGateCompleted() => _prefs.setBool(_authGateKey, true);

  bool get hasSeenHomeTour => _prefs.getBool(_homeTourKey) ?? false;

  Future<void> markHomeTourSeen() => _prefs.setBool(_homeTourKey, true);

  static Future<AppPrefs> open() async {
    final prefs = await SharedPreferences.getInstance();
    return AppPrefs(prefs);
  }
}
