part of 'plan_trip_bloc.dart';

sealed class PlanTripState extends Equatable {
  const PlanTripState();

  @override
  List<Object?> get props => [];
}

class PlanTripFormState extends PlanTripState {
  /// Next Friday (or next week if today is Friday) — classic getaway default.
  static DateTime smartStartDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekday = today.weekday; // Mon=1 … Fri=5
    var daysUntilFriday = DateTime.friday - weekday;
    if (daysUntilFriday <= 0) daysUntilFriday += 7;
    return today.add(Duration(days: daysUntilFriday));
  }

  PlanTripFormState({
    this.vibe = '',
    Set<String>? interests,
    this.dayCount = 3,
    this.mustInclude = '',
    this.pace = 'balanced',
    this.companions = 'solo',
    DateTime? startDate,
    this.error,
  })  : interests = interests ?? _defaultInterests,
        startDate = startDate ?? smartStartDate();

  static const _defaultInterests = {'Food trail', 'Slow mornings'};

  final String vibe;
  final Set<String> interests;
  final int dayCount;
  final String mustInclude;
  final String pace;
  final String companions;
  final DateTime startDate;
  final String? error;

  PlanTripFormState copyWith({
    String? vibe,
    Set<String>? interests,
    int? dayCount,
    String? mustInclude,
    String? pace,
    String? companions,
    DateTime? startDate,
    String? error,
    bool clearError = false,
  }) {
    return PlanTripFormState(
      vibe: vibe ?? this.vibe,
      interests: interests ?? this.interests,
      dayCount: dayCount ?? this.dayCount,
      mustInclude: mustInclude ?? this.mustInclude,
      pace: pace ?? this.pace,
      companions: companions ?? this.companions,
      startDate: startDate ?? this.startDate,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        vibe,
        interests,
        dayCount,
        mustInclude,
        pace,
        companions,
        startDate,
        error,
      ];
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
