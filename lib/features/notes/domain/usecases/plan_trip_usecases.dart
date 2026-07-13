import 'package:uuid/uuid.dart';

import 'package:orbit_notes/features/notes/domain/entities/day.dart';
import 'package:orbit_notes/features/notes/domain/entities/entry.dart';
import 'package:orbit_notes/features/notes/domain/entities/planned_trip.dart';
import 'package:orbit_notes/features/notes/domain/entities/trip.dart';
import 'package:orbit_notes/features/notes/domain/repositories/notes_repository.dart';
import 'package:orbit_notes/features/notes/domain/repositories/trip_planner_repository.dart';

class PlanTripWithAi {
  const PlanTripWithAi(this._planner);

  final TripPlannerRepository _planner;

  Future<PlannedTrip> call(TripPlanRequest request) =>
      _planner.planTrip(request);
}

class PersistPlannedTrip {
  PersistPlannedTrip(this._notes);

  final NotesRepository _notes;
  final _uuid = const Uuid();

  Future<Trip> call({
    required PlannedTrip plan,
    required DateTime startDate,
  }) async {
    final trips = await _notes.getTrips();
    final now = DateTime.now();
    final dayCount = plan.days.isEmpty ? 1 : plan.days.length;
    final endDate = DateTime(
      startDate.year,
      startDate.month,
      startDate.day + (dayCount - 1),
    );

    final trip = Trip(
      id: _uuid.v4(),
      title: plan.title,
      startDate: DateTime(startDate.year, startDate.month, startDate.day),
      endDate: endDate,
      destination: plan.destination,
      accentIndex: trips.length % 6,
      createdAt: now,
    );
    await _notes.createTrip(trip);

    final sorted = [...plan.days]..sort((a, b) => a.dayIndex.compareTo(b.dayIndex));
    for (var i = 0; i < sorted.length; i++) {
      final planned = sorted[i];
      final date = DateTime(
        startDate.year,
        startDate.month,
        startDate.day + i,
      );
      final day = Day(
        id: _uuid.v4(),
        tripId: trip.id,
        date: date,
        title: planned.title,
        note: planned.placeHint,
        createdAt: now,
      );
      await _notes.createDay(day);
      await _notes.createEntry(
        Entry(
          id: _uuid.v4(),
          dayId: day.id,
          body: planned.entryPrompt,
          placeName: planned.placeHint,
          createdAt: now,
        ),
      );
    }

    return trip;
  }
}
