import 'package:orbit_notes/core/failure/failure.dart';
import 'package:orbit_notes/features/notes/domain/entities/planned_trip.dart';
import 'package:orbit_notes/features/notes/domain/repositories/trip_planner_repository.dart';

/// Tries the Edge Function first; on missing deploy (404) uses local Groq.
class FallbackTripPlannerDataSource implements TripPlannerRepository {
  FallbackTripPlannerDataSource({
    required TripPlannerRepository primary,
    required TripPlannerRepository fallback,
  })  : _primary = primary,
        _fallback = fallback;

  final TripPlannerRepository _primary;
  final TripPlannerRepository _fallback;

  @override
  Future<PlannedTrip> planTrip(TripPlanRequest request) async {
    try {
      return await _primary.planTrip(request);
    } on UnexpectedFailure catch (error) {
      if (!_shouldFallback(error.message)) rethrow;
      return _fallback.planTrip(request);
    }
  }

  bool _shouldFallback(String message) {
    final lower = message.toLowerCase();
    return lower.contains('(404)') ||
        lower.contains('not found') ||
        lower.contains('not configured') ||
        lower.contains('not set up');
  }
}
