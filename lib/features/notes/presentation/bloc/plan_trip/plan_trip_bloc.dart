import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:orbit_notes/core/failure/failure.dart';
import 'package:orbit_notes/features/notes/domain/entities/planned_trip.dart';
import 'package:orbit_notes/features/notes/domain/entities/trip.dart';
import 'package:orbit_notes/features/notes/domain/usecases/plan_trip_usecases.dart';

part 'plan_trip_event.dart';
part 'plan_trip_state.dart';

class PlanTripBloc extends Bloc<PlanTripEvent, PlanTripState> {
  PlanTripBloc({
    required PlanTripWithAi planTripWithAi,
    required PersistPlannedTrip persistPlannedTrip,
  })  : _planTripWithAi = planTripWithAi,
        _persistPlannedTrip = persistPlannedTrip,
        super(PlanTripFormState()) {
    on<PlanTripVibeChanged>(_onVibeChanged);
    on<PlanTripInterestToggled>(_onInterestToggled);
    on<PlanTripDayCountChanged>(_onDayCountChanged);
    on<PlanTripStartDateChanged>(_onStartDateChanged);
    on<PlanTripMustIncludeChanged>(_onMustIncludeChanged);
    on<PlanTripPaceChanged>(_onPaceChanged);
    on<PlanTripCompanionsChanged>(_onCompanionsChanged);
    on<PlanTripPresetApplied>(_onPresetApplied);
    on<PlanTripGenerateRequested>(_onGenerate);
    on<PlanTripCreateJournalRequested>(_onCreate);
    on<PlanTripResetRequested>(_onReset);
  }

  final PlanTripWithAi _planTripWithAi;
  final PersistPlannedTrip _persistPlannedTrip;

  void _onVibeChanged(
    PlanTripVibeChanged event,
    Emitter<PlanTripState> emit,
  ) {
    final current = state;
    if (current is! PlanTripFormState) return;
    emit(current.copyWith(vibe: event.vibe, clearError: true));
  }

  void _onInterestToggled(
    PlanTripInterestToggled event,
    Emitter<PlanTripState> emit,
  ) {
    final current = state;
    if (current is! PlanTripFormState) return;
    final next = {...current.interests};
    if (next.contains(event.interest)) {
      next.remove(event.interest);
    } else {
      next.add(event.interest);
    }
    emit(current.copyWith(interests: next, clearError: true));
  }

  void _onDayCountChanged(
    PlanTripDayCountChanged event,
    Emitter<PlanTripState> emit,
  ) {
    final current = state;
    if (current is! PlanTripFormState) return;
    emit(current.copyWith(dayCount: event.dayCount.clamp(1, 14)));
  }

  void _onStartDateChanged(
    PlanTripStartDateChanged event,
    Emitter<PlanTripState> emit,
  ) {
    final current = state;
    if (current is! PlanTripFormState) return;
    emit(current.copyWith(startDate: event.startDate));
  }

  void _onMustIncludeChanged(
    PlanTripMustIncludeChanged event,
    Emitter<PlanTripState> emit,
  ) {
    final current = state;
    if (current is! PlanTripFormState) return;
    emit(current.copyWith(mustInclude: event.mustInclude));
  }

  void _onPaceChanged(
    PlanTripPaceChanged event,
    Emitter<PlanTripState> emit,
  ) {
    final current = state;
    if (current is! PlanTripFormState) return;
    emit(current.copyWith(pace: event.pace, clearError: true));
  }

  void _onCompanionsChanged(
    PlanTripCompanionsChanged event,
    Emitter<PlanTripState> emit,
  ) {
    final current = state;
    if (current is! PlanTripFormState) return;
    emit(current.copyWith(companions: event.companions, clearError: true));
  }

  void _onPresetApplied(
    PlanTripPresetApplied event,
    Emitter<PlanTripState> emit,
  ) {
    final current = state;
    if (current is! PlanTripFormState) return;
    emit(
      current.copyWith(
        dayCount: event.dayCount,
        startDate: event.startDate,
        vibe: event.vibe ?? current.vibe,
        interests: event.interests ?? current.interests,
        pace: event.pace ?? current.pace,
        clearError: true,
      ),
    );
  }

  Future<void> _onGenerate(
    PlanTripGenerateRequested event,
    Emitter<PlanTripState> emit,
  ) async {
    final current = state;
    if (current is! PlanTripFormState) return;
    final vibe = current.vibe.trim();
    if (vibe.isEmpty) {
      emit(current.copyWith(error: 'Pick a destination vibe first.'));
      return;
    }

    emit(PlanTripGenerating(form: current));
    try {
      final focus = current.interests.isEmpty
          ? 'mixed'
          : current.interests.join(', ');
      final plan = await _planTripWithAi(
        TripPlanRequest(
          vibe: vibe,
          dayCount: current.dayCount,
          pace: current.pace,
          focus: focus,
          companions: current.companions,
          mustInclude: current.mustInclude,
        ),
      );
      emit(PlanTripPreview(form: current, plan: plan));
    } on Failure catch (failure) {
      emit(current.copyWith(error: failure.message));
    } catch (_) {
      emit(current.copyWith(error: 'Could not plan this trip. Try again.'));
    }
  }

  Future<void> _onCreate(
    PlanTripCreateJournalRequested event,
    Emitter<PlanTripState> emit,
  ) async {
    final current = state;
    if (current is! PlanTripPreview) return;
    emit(PlanTripCreating(form: current.form, plan: current.plan));
    try {
      final trip = await _persistPlannedTrip(
        plan: current.plan,
        startDate: current.form.startDate,
      );
      emit(PlanTripCreated(trip: trip));
    } on Failure catch (failure) {
      emit(
        PlanTripPreview(
          form: current.form,
          plan: current.plan,
          error: failure.message,
        ),
      );
    } catch (_) {
      emit(
        PlanTripPreview(
          form: current.form,
          plan: current.plan,
          error: 'Could not create the journal.',
        ),
      );
    }
  }

  void _onReset(PlanTripResetRequested event, Emitter<PlanTripState> emit) {
    final current = state;
    if (current is PlanTripPreview) {
      emit(current.form);
      return;
    }
    if (current is PlanTripGenerating) {
      emit(current.form);
    }
  }
}
