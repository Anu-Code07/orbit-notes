part of 'trip_detail_bloc.dart';

sealed class TripDetailState extends Equatable {
  const TripDetailState();

  @override
  List<Object?> get props => [];
}

class TripDetailInitial extends TripDetailState {
  const TripDetailInitial();
}

class TripDetailLoading extends TripDetailState {
  const TripDetailLoading();
}

class TripDetailSuccess extends TripDetailState {
  const TripDetailSuccess({
    required this.trip,
    required this.days,
    required this.entries,
    required this.photos,
    required this.pins,
  });

  final Trip trip;
  final List<Day> days;
  final List<Entry> entries;
  final List<Photo> photos;
  final List<MapPin> pins;

  Map<String, List<Entry>> get entriesByDay {
    final map = <String, List<Entry>>{};
    for (final entry in entries) {
      map.putIfAbsent(entry.dayId, () => []).add(entry);
    }
    return map;
  }

  TripDetailSuccess copyWith({
    Trip? trip,
    List<Day>? days,
    List<Entry>? entries,
    List<Photo>? photos,
    List<MapPin>? pins,
  }) {
    return TripDetailSuccess(
      trip: trip ?? this.trip,
      days: days ?? this.days,
      entries: entries ?? this.entries,
      photos: photos ?? this.photos,
      pins: pins ?? this.pins,
    );
  }

  @override
  List<Object?> get props => [trip, days, entries, photos, pins];
}

class TripDetailError extends TripDetailState {
  const TripDetailError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
