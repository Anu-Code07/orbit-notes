import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:orbit_notes/core/config/supabase_config.dart';
import 'package:orbit_notes/core/failure/failure.dart';
import 'package:orbit_notes/features/notes/domain/entities/day.dart';
import 'package:orbit_notes/features/notes/domain/entities/entry.dart';
import 'package:orbit_notes/features/notes/domain/entities/map_pin.dart';
import 'package:orbit_notes/features/notes/domain/entities/photo.dart';
import 'package:orbit_notes/features/notes/domain/entities/trip.dart';
import 'package:orbit_notes/features/notes/domain/repositories/notes_repository.dart';

/// Push local Drift journal rows to Supabase and pull remote rows locally.
class OrbitCloudSync {
  OrbitCloudSync({
    required NotesRepository notesRepository,
    SupabaseClient? client,
  })  : _notes = notesRepository,
        _client = client ?? Supabase.instance.client;

  final NotesRepository _notes;
  final SupabaseClient _client;

  static final _dateFmt = DateFormat('yyyy-MM-dd');

  Future<void> syncBidirectional() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      await pushLocal(user.id);
      await pullRemote(user.id);
    } on Failure {
      rethrow;
    } catch (error) {
      throw SyncFailure(error.toString());
    }
  }

  Future<void> pushLocal(String userId) async {
    final trips = await _notes.getTrips();
    for (final trip in trips) {
      await _upsertTrip(userId, trip);

      final days = await _notes.getDaysForTrip(trip.id);
      for (final day in days) {
        await _upsertDay(userId, day);

        final entries = await _notes.getEntriesForDay(day.id);
        for (final entry in entries) {
          await _upsertEntry(userId, entry);

          final photos = await _notes.getPhotosForEntry(entry.id);
          for (final photo in photos) {
            await _upsertPhoto(userId, photo);
          }

          final pin = await _notes.getPinForEntry(entry.id);
          if (pin != null) {
            await _upsertPin(userId, pin);
          }
        }
      }

      final tripPhotos = await _notes.getPhotosForTrip(trip.id);
      for (final photo in tripPhotos) {
        if (photo.entryId == null) {
          await _upsertPhoto(userId, photo);
        }
      }

      final pins = await _notes.getPinsForTrip(trip.id);
      for (final pin in pins) {
        await _upsertPin(userId, pin);
      }
    }
  }

  Future<void> pullRemote(String userId) async {
    final tripRows = await _client
        .from('orbit_trips')
        .select()
        .eq('user_id', userId);

    for (final raw in tripRows as List<dynamic>) {
      final map = Map<String, dynamic>.from(raw as Map);
      final trip = _tripFromRemote(map);
      final existing = await _notes.getTrip(trip.id);
      if (existing == null) {
        await _notes.createTrip(trip);
      } else {
        await _notes.updateTrip(trip);
      }

      final dayRows = await _client
          .from('orbit_days')
          .select()
          .eq('trip_id', trip.id);
      for (final dayRaw in dayRows as List<dynamic>) {
        final day = _dayFromRemote(Map<String, dynamic>.from(dayRaw as Map));
        final existingDay = await _notes.getDay(day.id);
        if (existingDay == null) {
          await _notes.createDay(day);
        } else {
          await _notes.updateDay(day);
        }
      }

      final dayIds = (dayRows as List<dynamic>)
          .map((row) => (row as Map)['id'] as String)
          .toList();
      for (final dayId in dayIds) {
        final entryRows = await _client
            .from('orbit_entries')
            .select()
            .eq('day_id', dayId);
        for (final entryRaw in entryRows as List<dynamic>) {
          final entry =
              _entryFromRemote(Map<String, dynamic>.from(entryRaw as Map));
          final existingEntry = await _notes.getEntry(entry.id);
          if (existingEntry == null) {
            await _notes.createEntry(entry);
          } else {
            await _notes.updateEntry(entry);
          }
        }
      }

      final photoRows = await _client
          .from('orbit_photos')
          .select()
          .eq('trip_id', trip.id);
      for (final photoRaw in photoRows as List<dynamic>) {
        final remote = Map<String, dynamic>.from(photoRaw as Map);
        await _pullPhoto(remote);
      }

      final pinRows = await _client
          .from('orbit_map_pins')
          .select()
          .eq('trip_id', trip.id);
      for (final pinRaw in pinRows as List<dynamic>) {
        final pin = _pinFromRemote(Map<String, dynamic>.from(pinRaw as Map));
        await _notes.upsertPin(pin);
      }
    }
  }

  Future<void> _upsertTrip(String userId, Trip trip) async {
    await _client.from('orbit_trips').upsert({
      'id': trip.id,
      'user_id': userId,
      'title': trip.title,
      'start_date': _dateFmt.format(trip.startDate),
      'end_date': _dateFmt.format(trip.endDate),
      'destination': trip.destination,
      'cover_path': trip.coverPath,
      'accent_index': trip.accentIndex,
      'created_at': trip.createdAt.toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<void> _upsertDay(String userId, Day day) async {
    await _client.from('orbit_days').upsert({
      'id': day.id,
      'user_id': userId,
      'trip_id': day.tripId,
      'date': _dateFmt.format(day.date),
      'title': day.title,
      'note': day.note,
      'created_at': day.createdAt.toUtc().toIso8601String(),
    });
  }

  Future<void> _upsertEntry(String userId, Entry entry) async {
    await _client.from('orbit_entries').upsert({
      'id': entry.id,
      'user_id': userId,
      'day_id': entry.dayId,
      'body': entry.body,
      'place_name': entry.placeName,
      'created_at': entry.createdAt.toUtc().toIso8601String(),
      'updated_at': entry.updatedAt?.toUtc().toIso8601String(),
    });
  }

  Future<void> _upsertPhoto(String userId, Photo photo) async {
    String? storagePath;
    String? publicUrl;

    final file = File(photo.localPath);
    if (await file.exists()) {
      final extension = p.extension(photo.localPath).isEmpty
          ? '.jpg'
          : p.extension(photo.localPath);
      storagePath = '$userId/${photo.tripId ?? 'misc'}/${photo.id}$extension';
      try {
        await _client.storage.from(SupabaseConfig.photosBucket).upload(
              storagePath,
              file,
              fileOptions: const FileOptions(upsert: true),
            );
        publicUrl = _client.storage
            .from(SupabaseConfig.photosBucket)
            .getPublicUrl(storagePath);
      } catch (_) {
        // Keep metadata sync even if upload fails (e.g. offline).
      }
    }

    await _client.from('orbit_photos').upsert({
      'id': photo.id,
      'user_id': userId,
      'entry_id': photo.entryId,
      'trip_id': photo.tripId,
      'local_path': photo.localPath,
      'storage_path': storagePath,
      'public_url': publicUrl,
      'sort_order': photo.sortOrder,
      'created_at': photo.createdAt.toUtc().toIso8601String(),
    });
  }

  Future<void> _upsertPin(String userId, MapPin pin) async {
    await _client.from('orbit_map_pins').upsert({
      'id': pin.id,
      'user_id': userId,
      'latitude': pin.latitude,
      'longitude': pin.longitude,
      'label': pin.label,
      'trip_id': pin.tripId,
      'day_id': pin.dayId,
      'entry_id': pin.entryId,
      'created_at': pin.createdAt.toUtc().toIso8601String(),
    });
  }

  Future<void> _pullPhoto(Map<String, dynamic> remote) async {
    final id = remote['id'] as String;
    final tripId = remote['trip_id'] as String?;
    final entryId = remote['entry_id'] as String?;

    if (tripId != null) {
      final tripPhotos = await _notes.getPhotosForTrip(tripId);
      if (tripPhotos.any((photo) => photo.id == id)) return;
    } else if (entryId != null) {
      final entryPhotos = await _notes.getPhotosForEntry(entryId);
      if (entryPhotos.any((photo) => photo.id == id)) return;
    }

    var localPath = remote['local_path'] as String? ?? '';
    final storagePath = remote['storage_path'] as String?;

    if (localPath.isEmpty || !File(localPath).existsSync()) {
      if (storagePath == null || storagePath.isEmpty) return;
      try {
        final bytes = await _client.storage
            .from(SupabaseConfig.photosBucket)
            .download(storagePath);
        final temp = File(
          '${Directory.systemTemp.path}/orbit_$id${p.extension(storagePath)}',
        );
        await temp.writeAsBytes(bytes);
        localPath = await _notes.persistImage(temp.path);
        await temp.delete();
      } catch (_) {
        return;
      }
    }

    await _notes.addPhoto(
      Photo(
        id: id,
        entryId: entryId,
        tripId: tripId,
        localPath: localPath,
        sortOrder: (remote['sort_order'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.parse(remote['created_at'] as String).toLocal(),
      ),
    );
  }

  Trip _tripFromRemote(Map<String, dynamic> map) {
    return Trip(
      id: map['id'] as String,
      title: map['title'] as String,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      destination: (map['destination'] as String?) ?? '',
      coverPath: map['cover_path'] as String?,
      accentIndex: (map['accent_index'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
    );
  }

  Day _dayFromRemote(Map<String, dynamic> map) {
    return Day(
      id: map['id'] as String,
      tripId: map['trip_id'] as String,
      date: DateTime.parse(map['date'] as String),
      title: map['title'] as String?,
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
    );
  }

  Entry _entryFromRemote(Map<String, dynamic> map) {
    return Entry(
      id: map['id'] as String,
      dayId: map['day_id'] as String,
      body: map['body'] as String,
      placeName: map['place_name'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
      updatedAt: map['updated_at'] == null
          ? null
          : DateTime.parse(map['updated_at'] as String).toLocal(),
    );
  }

  MapPin _pinFromRemote(Map<String, dynamic> map) {
    return MapPin(
      id: map['id'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      label: (map['label'] as String?) ?? '',
      tripId: map['trip_id'] as String?,
      dayId: map['day_id'] as String?,
      entryId: map['entry_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
    );
  }
}
