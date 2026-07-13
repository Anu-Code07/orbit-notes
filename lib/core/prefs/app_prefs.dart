import 'package:shared_preferences/shared_preferences.dart';

/// Local flags for first-launch auth gate, example trip, and home tour.
class AppPrefs {
  AppPrefs(this._prefs);

  final SharedPreferences _prefs;

  static const _authGateKey = 'orbit_auth_gate_completed';
  static const _homeTourKey = 'orbit_home_tour_seen';
  static const _exampleSeededKey = 'orbit_example_seeded';

  /// Stable id for the one seeded sample trip (safe to delete).
  static const exampleTripId = 'orbit-example-trip';

  bool get hasCompletedAuthGate => _prefs.getBool(_authGateKey) ?? false;

  Future<void> markAuthGateCompleted() => _prefs.setBool(_authGateKey, true);

  bool get hasSeenHomeTour => _prefs.getBool(_homeTourKey) ?? false;

  Future<void> markHomeTourSeen() => _prefs.setBool(_homeTourKey, true);

  bool get hasSeededExampleTrip => _prefs.getBool(_exampleSeededKey) ?? false;

  Future<void> markExampleTripSeeded() =>
      _prefs.setBool(_exampleSeededKey, true);

  static Future<AppPrefs> open() async {
    final prefs = await SharedPreferences.getInstance();
    return AppPrefs(prefs);
  }
}
