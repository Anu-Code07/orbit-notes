part of 'plan_trip_bloc.dart';

sealed class PlanTripEvent extends Equatable {
  const PlanTripEvent();

  @override
  List<Object?> get props => [];
}

class PlanTripVibeChanged extends PlanTripEvent {
  const PlanTripVibeChanged(this.vibe);
  final String vibe;

  @override
  List<Object?> get props => [vibe];
}

class PlanTripInterestToggled extends PlanTripEvent {
  const PlanTripInterestToggled(this.interest);
  final String interest;

  @override
  List<Object?> get props => [interest];
}

class PlanTripDayCountChanged extends PlanTripEvent {
  const PlanTripDayCountChanged(this.dayCount);
  final int dayCount;

  @override
  List<Object?> get props => [dayCount];
}

class PlanTripStartDateChanged extends PlanTripEvent {
  const PlanTripStartDateChanged(this.startDate);
  final DateTime startDate;

  @override
  List<Object?> get props => [startDate];
}

class PlanTripMustIncludeChanged extends PlanTripEvent {
  const PlanTripMustIncludeChanged(this.mustInclude);
  final String mustInclude;

  @override
  List<Object?> get props => [mustInclude];
}

class PlanTripPaceChanged extends PlanTripEvent {
  const PlanTripPaceChanged(this.pace);
  final String pace;

  @override
  List<Object?> get props => [pace];
}

class PlanTripCompanionsChanged extends PlanTripEvent {
  const PlanTripCompanionsChanged(this.companions);
  final String companions;

  @override
  List<Object?> get props => [companions];
}

class PlanTripPresetApplied extends PlanTripEvent {
  const PlanTripPresetApplied({
    required this.dayCount,
    required this.startDate,
    this.vibe,
    this.interests,
    this.pace,
  });

  final int dayCount;
  final DateTime startDate;
  final String? vibe;
  final Set<String>? interests;
  final String? pace;

  @override
  List<Object?> get props => [dayCount, startDate, vibe, interests, pace];
}

class PlanTripGenerateRequested extends PlanTripEvent {
  const PlanTripGenerateRequested();
}

class PlanTripCreateJournalRequested extends PlanTripEvent {
  const PlanTripCreateJournalRequested();
}

class PlanTripResetRequested extends PlanTripEvent {
  const PlanTripResetRequested();
}
