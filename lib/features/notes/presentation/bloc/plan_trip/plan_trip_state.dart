part of 'plan_trip_bloc.dart';

sealed class PlanTripState extends Equatable {
  const PlanTripState();

  @override
  List<Object?> get props => [];
}

class PlanTripFormState extends PlanTripState {
  PlanTripFormState({
    this.vibe = '',
    this.interests = const {},
    this.dayCount = 4,
    this.mustInclude = '',
    DateTime? startDate,
    this.error,
  }) : startDate = startDate ??
            DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
            );

  final String vibe;
  final Set<String> interests;
  final int dayCount;
  final String mustInclude;
  final DateTime startDate;
  final String? error;

  PlanTripFormState copyWith({
    String? vibe,
    Set<String>? interests,
    int? dayCount,
    String? mustInclude,
    DateTime? startDate,
    String? error,
    bool clearError = false,
  }) {
    return PlanTripFormState(
      vibe: vibe ?? this.vibe,
      interests: interests ?? this.interests,
      dayCount: dayCount ?? this.dayCount,
      mustInclude: mustInclude ?? this.mustInclude,
      startDate: startDate ?? this.startDate,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props =>
      [vibe, interests, dayCount, mustInclude, startDate, error];
}

class PlanTripGenerating extends PlanTripState {
  const PlanTripGenerating({required this.form});
  final PlanTripFormState form;

  @override
  List<Object?> get props => [form];
}

class PlanTripPreview extends PlanTripState {
  const PlanTripPreview({
    required this.form,
    required this.plan,
    this.error,
  });

  final PlanTripFormState form;
  final PlannedTrip plan;
  final String? error;

  @override
  List<Object?> get props => [form, plan, error];
}

class PlanTripCreating extends PlanTripState {
  const PlanTripCreating({required this.form, required this.plan});
  final PlanTripFormState form;
  final PlannedTrip plan;

  @override
  List<Object?> get props => [form, plan];
}

class PlanTripCreated extends PlanTripState {
  const PlanTripCreated({required this.trip});
  final Trip trip;

  @override
  List<Object?> get props => [trip];
}
