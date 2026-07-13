import 'package:orbit_notes/core/prefs/app_prefs.dart';
import 'package:orbit_notes/features/notes/domain/entities/day.dart';
import 'package:orbit_notes/features/notes/domain/entities/entry.dart';
import 'package:orbit_notes/features/notes/domain/entities/map_pin.dart';
import 'package:orbit_notes/features/notes/domain/entities/photo.dart';
import 'package:orbit_notes/features/notes/domain/repositories/notes_repository.dart';

class GetDaysForTrip {
  GetDaysForTrip(this._repository);

  final NotesRepository _repository;

  Future<List<Day>> call(String tripId) =>
      _repository.getDaysForTrip(tripId);
}

class CreateDay {
  CreateDay(this._repository);

  final NotesRepository _repository;

  Future<Day> call(Day day) => _repository.createDay(day);
}

class GetEntriesForDay {
  GetEntriesForDay(this._repository);

  final NotesRepository _repository;

  Future<List<Entry>> call(String dayId) =>
      _repository.getEntriesForDay(dayId);
}

class GetEntry {
  GetEntry(this._repository);

  final NotesRepository _repository;

  Future<Entry?> call(String id) => _repository.getEntry(id);
}

class GetEntriesForTrip {
  GetEntriesForTrip(this._repository);

  final NotesRepository _repository;

  Future<List<Entry>> call(String tripId) =>
      _repository.getEntriesForTrip(tripId);
}

class CreateEntry {
  CreateEntry(this._repository);

  final NotesRepository _repository;

  Future<Entry> call(Entry entry) => _repository.createEntry(entry);
}

class UpdateEntry {
  UpdateEntry(this._repository);

  final NotesRepository _repository;

  Future<Entry> call(Entry entry) => _repository.updateEntry(entry);
}

class DeleteEntry {
  DeleteEntry(this._repository);

  final NotesRepository _repository;

  Future<void> call(String id) => _repository.deleteEntry(id);
}

class GetPhotosForTrip {
  GetPhotosForTrip(this._repository);

  final NotesRepository _repository;

  Future<List<Photo>> call(String tripId) =>
      _repository.getPhotosForTrip(tripId);
}

class GetPhotosForEntry {
  GetPhotosForEntry(this._repository);

  final NotesRepository _repository;

  Future<List<Photo>> call(String entryId) =>
      _repository.getPhotosForEntry(entryId);
}

class AddPhoto {
  AddPhoto(this._repository);

  final NotesRepository _repository;

  Future<Photo> call(Photo photo) => _repository.addPhoto(photo);
}

class PersistImage {
  PersistImage(this._repository);

  final NotesRepository _repository;

  Future<String> call(String sourcePath) =>
      _repository.persistImage(sourcePath);
}

class GetPinsForTrip {
  GetPinsForTrip(this._repository);

  final NotesRepository _repository;

  Future<List<MapPin>> call(String tripId) =>
      _repository.getPinsForTrip(tripId);
}

class GetPinForEntry {
  GetPinForEntry(this._repository);

  final NotesRepository _repository;

  Future<MapPin?> call(String entryId) =>
      _repository.getPinForEntry(entryId);
}

class UpsertPin {
  UpsertPin(this._repository);

  final NotesRepository _repository;

  Future<MapPin> call(MapPin pin) => _repository.upsertPin(pin);
}

class SeedDemoIfEmpty {
  SeedDemoIfEmpty(this._repository, this._prefs);

  final NotesRepository _repository;
  final AppPrefs _prefs;

  Future<void> call() async {
    if (_prefs.hasSeededExampleTrip) return;

    final trips = await _repository.getTrips();
    if (trips.isNotEmpty) {
      await _prefs.markExampleTripSeeded();
      return;
    }

    await _repository.seedDemoIfEmpty();
    await _prefs.markExampleTripSeeded();
  }
}
