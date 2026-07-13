import 'package:orbit_notes/features/notes/domain/entities/day.dart';
import 'package:orbit_notes/features/notes/domain/entities/entry.dart';
import 'package:orbit_notes/features/notes/domain/entities/map_pin.dart';
import 'package:orbit_notes/features/notes/domain/entities/photo.dart';
import 'package:orbit_notes/features/notes/domain/entities/trip.dart';

abstract class NotesRepository {
  Future<List<Trip>> getTrips();
  Future<Trip?> getTrip(String id);
  Future<Trip> createTrip(Trip trip);
  Future<Trip> updateTrip(Trip trip);
  Future<void> deleteTrip(String id);

  Future<List<Day>> getDaysForTrip(String tripId);
  Future<Day?> getDay(String id);
  Future<Day> createDay(Day day);
  Future<Day> updateDay(Day day);

  Future<List<Entry>> getEntriesForDay(String dayId);
  Future<List<Entry>> getEntriesForTrip(String tripId);
  Future<Entry?> getEntry(String id);
  Future<Entry> createEntry(Entry entry);
  Future<Entry> updateEntry(Entry entry);
  Future<void> deleteEntry(String id);

  Future<List<Photo>> getPhotosForTrip(String tripId);
  Future<List<Photo>> getPhotosForEntry(String entryId);
  Future<Photo> addPhoto(Photo photo);
  Future<void> deletePhoto(String id);

  Future<List<MapPin>> getPinsForTrip(String tripId);
  Future<MapPin?> getPinForEntry(String entryId);
  Future<MapPin> upsertPin(MapPin pin);
  Future<void> deletePin(String id);

  /// Copies a picked image into app documents and returns the new path.
  Future<String> persistImage(String sourcePath);

  /// Seeds one example trip on first empty launch (once).
  Future<void> seedDemoIfEmpty();
}
