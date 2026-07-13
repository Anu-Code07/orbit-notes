part of 'entry_bloc.dart';

sealed class EntryEvent extends Equatable {
  const EntryEvent();

  @override
  List<Object?> get props => [];
}

class PrepareNewEntry extends EntryEvent {
  const PrepareNewEntry({required this.dayId, required this.tripId});

  final String dayId;
  final String tripId;

  @override
  List<Object?> get props => [dayId, tripId];
}

class LoadEntry extends EntryEvent {
  const LoadEntry({required this.entryId, required this.tripId});

  final String entryId;
  final String tripId;

  @override
  List<Object?> get props => [entryId, tripId];
}

class BodyChanged extends EntryEvent {
  const BodyChanged(this.body);

  final String body;

  @override
  List<Object?> get props => [body];
}

class PlaceNameChanged extends EntryEvent {
  const PlaceNameChanged(this.placeName);

  final String placeName;

  @override
  List<Object?> get props => [placeName];
}

class AddLocalPhoto extends EntryEvent {
  const AddLocalPhoto(this.sourcePath);

  final String sourcePath;

  @override
  List<Object?> get props => [sourcePath];
}

class SetMapPin extends EntryEvent {
  const SetMapPin({
    required this.latitude,
    required this.longitude,
    this.label = '',
  });

  final double latitude;
  final double longitude;
  final String label;

  @override
  List<Object?> get props => [latitude, longitude, label];
}

class SaveEntry extends EntryEvent {
  const SaveEntry();
}
