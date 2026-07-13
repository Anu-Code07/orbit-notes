import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:orbit_notes/features/notes/domain/entities/day.dart';
import 'package:orbit_notes/features/notes/domain/entities/entry.dart';
import 'package:orbit_notes/features/notes/domain/entities/map_pin.dart';
import 'package:orbit_notes/features/notes/domain/entities/photo.dart';
import 'package:orbit_notes/features/notes/domain/entities/trip.dart';
import 'package:orbit_notes/features/notes/domain/repositories/notes_repository.dart';
import 'package:orbit_notes/features/notes/data/datasources/app_database.dart';

class NotesRepositoryImpl implements NotesRepository {
  NotesRepositoryImpl(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Uuid _uuid;

  @override
  Future<List<Trip>> getTrips() async {
    final rows = await (_db.select(_db.trips)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
    return rows.map(_tripFromRow).toList();
  }

  @override
  Future<Trip?> getTrip(String id) async {
    final row = await (_db.select(_db.trips)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _tripFromRow(row);
  }

  @override
  Future<Trip> createTrip(Trip trip) async {
    await _db.into(_db.trips).insert(_tripCompanion(trip));
    return trip;
  }

  @override
  Future<Trip> updateTrip(Trip trip) async {
    await (_db.update(_db.trips)..where((t) => t.id.equals(trip.id)))
        .write(_tripCompanion(trip));
    return trip;
  }

  @override
  Future<void> deleteTrip(String id) async {
    await _db.transaction(() async {
      final trip = await getTrip(id);
      final photoRows = await getPhotosForTrip(id);
      for (final photo in photoRows) {
        final file = File(photo.localPath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      if (trip?.coverPath != null) {
        final cover = File(trip!.coverPath!);
        if (await cover.exists()) {
          await cover.delete();
        }
      }

      final days = await getDaysForTrip(id);
      for (final day in days) {
        final entries = await getEntriesForDay(day.id);
        for (final entry in entries) {
          await (_db.delete(_db.photos)
                ..where((p) => p.entryId.equals(entry.id)))
              .go();
          await (_db.delete(_db.mapPins)
                ..where((p) => p.entryId.equals(entry.id)))
              .go();
          await (_db.delete(_db.entries)..where((e) => e.id.equals(entry.id)))
              .go();
        }
        await (_db.delete(_db.days)..where((d) => d.id.equals(day.id))).go();
      }
      await (_db.delete(_db.photos)..where((p) => p.tripId.equals(id))).go();
      await (_db.delete(_db.mapPins)..where((p) => p.tripId.equals(id))).go();
      await (_db.delete(_db.trips)..where((t) => t.id.equals(id))).go();
    });
  }

  @override
  Future<List<Day>> getDaysForTrip(String tripId) async {
    final rows = await (_db.select(_db.days)
          ..where((d) => d.tripId.equals(tripId))
          ..orderBy([(d) => OrderingTerm.asc(d.date)]))
        .get();
    return rows.map(_dayFromRow).toList();
  }

  @override
  Future<Day?> getDay(String id) async {
    final row = await (_db.select(_db.days)..where((d) => d.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _dayFromRow(row);
  }

  @override
  Future<Day> createDay(Day day) async {
    await _db.into(_db.days).insert(_dayCompanion(day));
    return day;
  }

  @override
  Future<Day> updateDay(Day day) async {
    await (_db.update(_db.days)..where((d) => d.id.equals(day.id)))
        .write(_dayCompanion(day));
    return day;
  }

  @override
  Future<List<Entry>> getEntriesForDay(String dayId) async {
    final rows = await (_db.select(_db.entries)
          ..where((e) => e.dayId.equals(dayId))
          ..orderBy([(e) => OrderingTerm.asc(e.createdAt)]))
        .get();
    return rows.map(_entryFromRow).toList();
  }

  @override
  Future<List<Entry>> getEntriesForTrip(String tripId) async {
    final days = await getDaysForTrip(tripId);
    final all = <Entry>[];
    for (final day in days) {
      all.addAll(await getEntriesForDay(day.id));
    }
    return all;
  }

  @override
  Future<Entry?> getEntry(String id) async {
    final row =
        await (_db.select(_db.entries)..where((e) => e.id.equals(id)))
            .getSingleOrNull();
    return row == null ? null : _entryFromRow(row);
  }

  @override
  Future<Entry> createEntry(Entry entry) async {
    await _db.into(_db.entries).insert(_entryCompanion(entry));
    return entry;
  }

  @override
  Future<Entry> updateEntry(Entry entry) async {
    await (_db.update(_db.entries)..where((e) => e.id.equals(entry.id)))
        .write(_entryCompanion(entry));
    return entry;
  }

  @override
  Future<void> deleteEntry(String id) async {
    await (_db.delete(_db.photos)..where((p) => p.entryId.equals(id))).go();
    await (_db.delete(_db.mapPins)..where((p) => p.entryId.equals(id))).go();
    await (_db.delete(_db.entries)..where((e) => e.id.equals(id))).go();
  }

  @override
  Future<List<Photo>> getPhotosForTrip(String tripId) async {
    final tripPhotos = await (_db.select(_db.photos)
          ..where((p) => p.tripId.equals(tripId))
          ..orderBy([(p) => OrderingTerm.asc(p.sortOrder)]))
        .get();

    final entries = await getEntriesForTrip(tripId);
    final entryIds = entries.map((e) => e.id).toSet();
    final entryPhotos = <PhotoRow>[];
    if (entryIds.isNotEmpty) {
      final all = await _db.select(_db.photos).get();
      entryPhotos.addAll(
        all.where((p) => p.entryId != null && entryIds.contains(p.entryId)),
      );
    }

    final merged = {...tripPhotos, ...entryPhotos}
        .map(_photoFromRow)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return merged;
  }

  @override
  Future<List<Photo>> getPhotosForEntry(String entryId) async {
    final rows = await (_db.select(_db.photos)
          ..where((p) => p.entryId.equals(entryId))
          ..orderBy([(p) => OrderingTerm.asc(p.sortOrder)]))
        .get();
    return rows.map(_photoFromRow).toList();
  }

  @override
  Future<Photo> addPhoto(Photo photo) async {
    await _db.into(_db.photos).insert(_photoCompanion(photo));
    return photo;
  }

  @override
  Future<void> deletePhoto(String id) async {
    final row =
        await (_db.select(_db.photos)..where((p) => p.id.equals(id)))
            .getSingleOrNull();
    if (row != null) {
      final file = File(row.localPath);
      if (await file.exists()) {
        await file.delete();
      }
    }
    await (_db.delete(_db.photos)..where((p) => p.id.equals(id))).go();
  }

  @override
  Future<List<MapPin>> getPinsForTrip(String tripId) async {
    final rows = await (_db.select(_db.mapPins)
          ..where((p) => p.tripId.equals(tripId))
          ..orderBy([(p) => OrderingTerm.asc(p.createdAt)]))
        .get();
    return rows.map(_pinFromRow).toList();
  }

  @override
  Future<MapPin?> getPinForEntry(String entryId) async {
    final row = await (_db.select(_db.mapPins)
          ..where((p) => p.entryId.equals(entryId)))
        .getSingleOrNull();
    return row == null ? null : _pinFromRow(row);
  }

  @override
  Future<MapPin> upsertPin(MapPin pin) async {
    return _db.transaction(() async {
      MapPin toSave = pin;
      if (pin.entryId != null) {
        final existing = await getPinForEntry(pin.entryId!);
        if (existing != null) {
          toSave = MapPin(
            id: existing.id,
            latitude: pin.latitude,
            longitude: pin.longitude,
            label: pin.label,
            tripId: pin.tripId,
            dayId: pin.dayId,
            entryId: pin.entryId,
            createdAt: existing.createdAt,
          );
        }
      }
      await _db.into(_db.mapPins).insertOnConflictUpdate(_pinCompanion(toSave));
      return toSave;
    });
  }

  @override
  Future<void> deletePin(String id) async {
    await (_db.delete(_db.mapPins)..where((p) => p.id.equals(id))).go();
  }

  @override
  Future<String> persistImage(String sourcePath) async {
    final docs = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(docs.path, 'photos'));
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }
    final ext = p.extension(sourcePath);
    final dest = p.join(photosDir.path, '${_uuid.v4()}$ext');
    await File(sourcePath).copy(dest);
    return dest;
  }

  Trip _tripFromRow(TripRow row) => Trip(
        id: row.id,
        title: row.title,
        startDate: row.startDate,
        endDate: row.endDate,
        destination: row.destination,
        coverPath: row.coverPath,
        accentIndex: row.accentIndex,
        createdAt: row.createdAt,
      );

  TripsCompanion _tripCompanion(Trip trip) => TripsCompanion(
        id: Value(trip.id),
        title: Value(trip.title),
        startDate: Value(trip.startDate),
        endDate: Value(trip.endDate),
        destination: Value(trip.destination),
        coverPath: Value(trip.coverPath),
        accentIndex: Value(trip.accentIndex),
        createdAt: Value(trip.createdAt),
      );

  Day _dayFromRow(DayRow row) => Day(
        id: row.id,
        tripId: row.tripId,
        date: row.date,
        title: row.title,
        note: row.note,
        createdAt: row.createdAt,
      );

  DaysCompanion _dayCompanion(Day day) => DaysCompanion(
        id: Value(day.id),
        tripId: Value(day.tripId),
        date: Value(day.date),
        title: Value(day.title),
        note: Value(day.note),
        createdAt: Value(day.createdAt),
      );

  Entry _entryFromRow(EntryRow row) => Entry(
        id: row.id,
        dayId: row.dayId,
        body: row.body,
        placeName: row.placeName,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  EntriesCompanion _entryCompanion(Entry entry) => EntriesCompanion(
        id: Value(entry.id),
        dayId: Value(entry.dayId),
        body: Value(entry.body),
        placeName: Value(entry.placeName),
        createdAt: Value(entry.createdAt),
        updatedAt: Value(entry.updatedAt),
      );

  Photo _photoFromRow(PhotoRow row) => Photo(
        id: row.id,
        entryId: row.entryId,
        tripId: row.tripId,
        localPath: row.localPath,
        sortOrder: row.sortOrder,
        createdAt: row.createdAt,
      );

  PhotosCompanion _photoCompanion(Photo photo) => PhotosCompanion(
        id: Value(photo.id),
        entryId: Value(photo.entryId),
        tripId: Value(photo.tripId),
        localPath: Value(photo.localPath),
        sortOrder: Value(photo.sortOrder),
        createdAt: Value(photo.createdAt),
      );

  MapPin _pinFromRow(MapPinRow row) => MapPin(
        id: row.id,
        latitude: row.latitude,
        longitude: row.longitude,
        label: row.label,
        tripId: row.tripId,
        dayId: row.dayId,
        entryId: row.entryId,
        createdAt: row.createdAt,
      );

  MapPinsCompanion _pinCompanion(MapPin pin) => MapPinsCompanion(
        id: Value(pin.id),
        latitude: Value(pin.latitude),
        longitude: Value(pin.longitude),
        label: Value(pin.label),
        tripId: Value(pin.tripId),
        dayId: Value(pin.dayId),
        entryId: Value(pin.entryId),
        createdAt: Value(pin.createdAt),
      );
}
