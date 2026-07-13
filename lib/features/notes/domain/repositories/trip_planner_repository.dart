import 'package:orbit_notes/features/notes/domain/entities/planned_trip.dart';

abstract class TripPlannerRepository {
  Future<PlannedTrip> planTrip(TripPlanRequest request);
}
