part of 'trips_bloc.dart';

sealed class TripsEvent extends Equatable {
  const TripsEvent();

  @override
  List<Object?> get props => [];
}

class LoadTrips extends TripsEvent {
  const LoadTrips();
}

class RefreshTrips extends TripsEvent {
  const RefreshTrips();
}

class RemoveTrip extends TripsEvent {
  const RemoveTrip(this.tripId);

  final String tripId;

  @override
  List<Object?> get props => [tripId];
}
