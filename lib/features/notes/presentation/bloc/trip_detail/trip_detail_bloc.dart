import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:orbit_notes/core/failure/failure.dart';
import 'package:orbit_notes/features/notes/domain/entities/day.dart';
import 'package:orbit_notes/features/notes/domain/entities/entry.dart';
import 'package:orbit_notes/features/notes/domain/entities/map_pin.dart';
import 'package:orbit_notes/features/notes/domain/entities/photo.dart';
import 'package:orbit_notes/features/notes/domain/entities/trip.dart';
import 'package:orbit_notes/features/notes/domain/usecases/journal_usecases.dart';
import 'package:orbit_notes/features/notes/domain/usecases/trip_usecases.dart';

part 'trip_detail_event.dart';
part 'trip_detail_state.dart';

class TripDetailBloc extends Bloc<TripDetailEvent, TripDetailState> {
  TripDetailBloc({
    required GetTrip getTrip,
    required GetDaysForTrip getDaysForTrip,
    required GetEntriesForTrip getEntriesForTrip,
    required GetPhotosForTrip getPhotosForTrip,
    required GetPinsForTrip getPinsForTrip,
    required CreateDay createDay,
    required UpdateTrip updateTrip,
  })  : _getTrip = getTrip,
        _getDaysForTrip = getDaysForTrip,
        _getEntriesForTrip = getEntriesForTrip,
        _getPhotosForTrip = getPhotosForTrip,
        _getPinsForTrip = getPinsForTrip,
        _createDay = createDay,
        _updateTrip = updateTrip,
        super(const TripDetailInitial()) {
    on<LoadTripDetail>(_onLoad);
    on<RefreshTripDetail>(_onRefresh);
    on<AddDayToTrip>(_onAddDay);
    on<UpdateTripCover>(_onUpdateCover);
  }

  final GetTrip _getTrip;
  final GetDaysForTrip _getDaysForTrip;
  final GetEntriesForTrip _getEntriesForTrip;
  final GetPhotosForTrip _getPhotosForTrip;
  final GetPinsForTrip _getPinsForTrip;
  final CreateDay _createDay;
  final UpdateTrip _updateTrip;

  String? _tripId;

  Future<void> _onLoad(
    LoadTripDetail event,
    Emitter<TripDetailState> emit,
  ) async {
    _tripId = event.tripId;
    emit(const TripDetailLoading());
    await _emitLoaded(emit);
  }

  Future<void> _onRefresh(
    RefreshTripDetail event,
    Emitter<TripDetailState> emit,
  ) async {
    if (_tripId == null) return;
    await _emitLoaded(emit);
  }

  Future<void> _onAddDay(
    AddDayToTrip event,
    Emitter<TripDetailState> emit,
  ) async {
    try {
      await _createDay(event.day);
      add(const RefreshTripDetail());
    } catch (_) {
      emit(const TripDetailError(StorageFailure()));
    }
  }

  Future<void> _onUpdateCover(
    UpdateTripCover event,
    Emitter<TripDetailState> emit,
  ) async {
    final current = state;
    if (current is! TripDetailSuccess) return;
    try {
      final updated = await _updateTrip(
        current.trip.copyWith(coverPath: event.coverPath),
      );
      emit(current.copyWith(trip: updated));
    } catch (_) {
      emit(const TripDetailError(StorageFailure()));
    }
  }

  Future<void> _emitLoaded(Emitter<TripDetailState> emit) async {
    try {
      final trip = await _getTrip(_tripId!);
      if (trip == null) {
        emit(const TripDetailError(NotFoundFailure()));
        return;
      }
      final days = await _getDaysForTrip(trip.id);
      final entries = await _getEntriesForTrip(trip.id);
      final photos = await _getPhotosForTrip(trip.id);
      final pins = await _getPinsForTrip(trip.id);
      emit(
        TripDetailSuccess(
          trip: trip,
          days: days,
          entries: entries,
          photos: photos,
          pins: pins,
        ),
      );
    } catch (_) {
      emit(const TripDetailError(StorageFailure()));
    }
  }
}
