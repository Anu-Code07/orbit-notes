part of 'trip_detail_bloc.dart';

sealed class TripDetailEvent extends Equatable {
  const TripDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadTripDetail extends TripDetailEvent {
  const LoadTripDetail(this.tripId);

  final String tripId;

  @override
  List<Object?> get props => [tripId];
}

class RefreshTripDetail extends TripDetailEvent {
  const RefreshTripDetail();
}

class AddDayToTrip extends TripDetailEvent {
  const AddDayToTrip(this.day);

  final Day day;

  @override
  List<Object?> get props => [day];
}

class UpdateTripCover extends TripDetailEvent {
  const UpdateTripCover(this.coverPath);

  final String coverPath;

  @override
  List<Object?> get props => [coverPath];
}
