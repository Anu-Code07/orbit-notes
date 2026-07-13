import 'package:orbit_notes/features/notes/domain/entities/trip.dart';
import 'package:orbit_notes/features/notes/domain/repositories/notes_repository.dart';

class GetTrips {
  GetTrips(this._repository);

  final NotesRepository _repository;

  Future<List<Trip>> call() => _repository.getTrips();
}

class GetTrip {
  GetTrip(this._repository);

  final NotesRepository _repository;

  Future<Trip?> call(String id) => _repository.getTrip(id);
}

class CreateTrip {
  CreateTrip(this._repository);

  final NotesRepository _repository;

  Future<Trip> call(Trip trip) => _repository.createTrip(trip);
}

class UpdateTrip {
  UpdateTrip(this._repository);

  final NotesRepository _repository;

  Future<Trip> call(Trip trip) => _repository.updateTrip(trip);
}

class DeleteTrip {
  DeleteTrip(this._repository);

  final NotesRepository _repository;

  Future<void> call(String id) => _repository.deleteTrip(id);
}
