import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:orbit_notes/core/failure/failure.dart';
import 'package:orbit_notes/core/prefs/app_prefs.dart';
import 'package:orbit_notes/features/notes/domain/entities/trip.dart';
import 'package:orbit_notes/features/notes/domain/usecases/journal_usecases.dart';
import 'package:orbit_notes/features/notes/domain/usecases/trip_usecases.dart';

part 'trips_event.dart';
part 'trips_state.dart';

class TripsBloc extends Bloc<TripsEvent, TripsState> {
  TripsBloc({
    required GetTrips getTrips,
    required SeedDemoIfEmpty seedDemoIfEmpty,
    required DeleteTrip deleteTrip,
    required AppPrefs prefs,
  })  : _getTrips = getTrips,
        _seedDemoIfEmpty = seedDemoIfEmpty,
        _deleteTrip = deleteTrip,
        _prefs = prefs,
        super(const TripsInitial()) {
    on<LoadTrips>(_onLoad);
    on<RefreshTrips>(_onRefresh);
    on<RemoveTrip>(_onRemove);
  }

  final GetTrips _getTrips;
  final SeedDemoIfEmpty _seedDemoIfEmpty;
  final DeleteTrip _deleteTrip;
  final AppPrefs _prefs;

  Future<void> _onLoad(LoadTrips event, Emitter<TripsState> emit) async {
    emit(const TripsLoading());
    try {
      if (event.seedDemo) {
        await _seedDemoIfEmpty();
      }
      final trips = await _getTrips();
      if (trips.isEmpty) {
        emit(const TripsEmpty());
      } else {
        emit(TripsSuccess(trips));
      }
    } catch (_) {
      emit(const TripsError(StorageFailure()));
    }
  }

  Future<void> _onRefresh(RefreshTrips event, Emitter<TripsState> emit) async {
    try {
      final trips = await _getTrips();
      if (trips.isEmpty) {
        emit(const TripsEmpty());
      } else {
        emit(TripsSuccess(trips));
      }
    } catch (_) {
      emit(const TripsError(StorageFailure()));
    }
  }

  Future<void> _onRemove(RemoveTrip event, Emitter<TripsState> emit) async {
    try {
      await _deleteTrip(event.tripId);
      // Once the example is removed, never seed it again.
      if (event.tripId == AppPrefs.exampleTripId) {
        await _prefs.markExampleTripSeeded();
      }
      add(const RefreshTrips());
    } catch (_) {
      emit(const TripsError(StorageFailure()));
    }
  }
}
