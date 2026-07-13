import 'package:equatable/equatable.dart';

class PlannedTripDay extends Equatable {
  const PlannedTripDay({
    required this.dayIndex,
    required this.title,
    required this.entryPrompt,
    this.placeHint,
  });

  final int dayIndex;
  final String title;
  final String entryPrompt;
  final String? placeHint;

  PlannedTripDay copyWith({
    int? dayIndex,
    String? title,
    String? entryPrompt,
    String? placeHint,
  }) {
    return PlannedTripDay(
      dayIndex: dayIndex ?? this.dayIndex,
      title: title ?? this.title,
      entryPrompt: entryPrompt ?? this.entryPrompt,
      placeHint: placeHint ?? this.placeHint,
    );
  }

  @override
  List<Object?> get props => [dayIndex, title, entryPrompt, placeHint];
}

class PlannedTrip extends Equatable {
  const PlannedTrip({
    required this.title,
    required this.destination,
    required this.summary,
    required this.days,
  });

  final String title;
  final String destination;
  final String summary;
  final List<PlannedTripDay> days;

  PlannedTrip copyWith({
    String? title,
    String? destination,
    String? summary,
    List<PlannedTripDay>? days,
  }) {
    return PlannedTrip(
      title: title ?? this.title,
      destination: destination ?? this.destination,
      summary: summary ?? this.summary,
      days: days ?? this.days,
    );
  }

  @override
  List<Object?> get props => [title, destination, summary, days];
}

class TripPlanRequest extends Equatable {
  const TripPlanRequest({
    required this.vibe,
    required this.dayCount,
    this.pace = 'balanced',
    this.focus = 'culture',
    this.companions = 'solo',
    this.mustInclude = '',
  });

  final String vibe;
  final int dayCount;
  final String pace;
  final String focus;
  final String companions;
  final String mustInclude;

  @override
  List<Object?> get props =>
      [vibe, dayCount, pace, focus, companions, mustInclude];
}
