part of 'trips_bloc.dart';

sealed class TripsState extends Equatable {
  const TripsState();

  @override
  List<Object?> get props => [];
}

class TripsInitial extends TripsState {
  const TripsInitial();
}

class TripsLoading extends TripsState {
  const TripsLoading();
}

class TripsEmpty extends TripsState {
  const TripsEmpty();
}

class TripsSuccess extends TripsState {
  const TripsSuccess(this.trips);

  final List<Trip> trips;

  @override
  List<Object?> get props => [trips];
}

class TripsError extends TripsState {
  const TripsError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
