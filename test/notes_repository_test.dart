import 'package:flutter_test/flutter_test.dart';
import 'package:orbit_notes/features/notes/data/datasources/app_database.dart';
import 'package:orbit_notes/features/notes/data/repositories/notes_repository_impl.dart';
import 'package:orbit_notes/features/notes/domain/entities/day.dart';
import 'package:orbit_notes/features/notes/domain/entities/entry.dart';
import 'package:orbit_notes/features/notes/domain/entities/map_pin.dart';
import 'package:orbit_notes/features/notes/domain/entities/trip.dart';
import 'package:orbit_notes/features/notes/domain/usecases/journal_usecases.dart';
import 'package:orbit_notes/features/notes/domain/usecases/trip_usecases.dart';
import 'package:drift/native.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotesRepositoryImpl', () {
    late AppDatabase db;
    late NotesRepositoryImpl repository;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repository = NotesRepositoryImpl(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('creates and lists trips', () async {
      final now = DateTime(2026, 7, 1);
      final trip = Trip(
        id: 'trip-1',
        title: 'Kyoto',
        startDate: now,
        endDate: now.add(const Duration(days: 2)),
        destination: 'Japan',
        accentIndex: 0,
        createdAt: now,
      );

      await repository.createTrip(trip);
      final trips = await repository.getTrips();

      expect(trips, hasLength(1));
      expect(trips.first.title, 'Kyoto');
      expect(trips.first.dayCount, 3);
    });

    test('creates day and entry under a trip', () async {
      final now = DateTime(2026, 7, 1);
      await repository.createTrip(
        Trip(
          id: 'trip-1',
          title: 'Lisbon',
          startDate: now,
          endDate: now,
          destination: 'Portugal',
          createdAt: now,
        ),
      );
      await repository.createDay(
        Day(
          id: 'day-1',
          tripId: 'trip-1',
          date: now,
          title: 'Day 1',
          createdAt: now,
        ),
      );
      await repository.createEntry(
        Entry(
          id: 'entry-1',
          dayId: 'day-1',
          body: 'Trams and tiles.',
          placeName: 'Alfama',
          createdAt: now,
        ),
      );

      final entries = await repository.getEntriesForTrip('trip-1');
      expect(entries, hasLength(1));
      expect(entries.first.placeName, 'Alfama');
    });
  });

  group('Use cases', () {
    late AppDatabase db;
    late NotesRepositoryImpl repository;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repository = NotesRepositoryImpl(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('CreateTrip and GetTrips round-trip', () async {
      final createTrip = CreateTrip(repository);
      final getTrips = GetTrips(repository);
      final now = DateTime.now();

      await createTrip(
        Trip(
          id: 't1',
          title: 'Test',
          startDate: now,
          endDate: now,
          destination: 'Here',
          createdAt: now,
        ),
      );

      final trips = await getTrips();
      expect(trips.single.title, 'Test');
    });

    test('CreateEntry stores body', () async {
      final now = DateTime.now();
      await repository.createTrip(
        Trip(
          id: 't1',
          title: 'T',
          startDate: now,
          endDate: now,
          destination: '',
          createdAt: now,
        ),
      );
      await repository.createDay(
        Day(id: 'd1', tripId: 't1', date: now, createdAt: now),
      );

      final createEntry = CreateEntry(repository);
      await createEntry(
        Entry(
          id: 'e1',
          dayId: 'd1',
          body: 'Hello journal',
          createdAt: now,
        ),
      );

      final entries = await GetEntriesForDay(repository)('d1');
      expect(entries.single.body, 'Hello journal');
    });

    test('upsertPin updates existing pin for same entry', () async {
      final now = DateTime.now();
      await repository.createTrip(
        Trip(
          id: 't1',
          title: 'T',
          startDate: now,
          endDate: now,
          destination: '',
          createdAt: now,
        ),
      );
      await repository.createDay(
        Day(id: 'd1', tripId: 't1', date: now, createdAt: now),
      );
      await repository.createEntry(
        Entry(
          id: 'e1',
          dayId: 'd1',
          body: 'Here',
          createdAt: now,
        ),
      );

      final first = await repository.upsertPin(
        MapPin(
          id: 'pin-1',
          latitude: 1,
          longitude: 2,
          label: 'A',
          tripId: 't1',
          dayId: 'd1',
          entryId: 'e1',
          createdAt: now,
        ),
      );
      final second = await repository.upsertPin(
        MapPin(
          id: 'pin-other',
          latitude: 9,
          longitude: 8,
          label: 'B',
          tripId: 't1',
          dayId: 'd1',
          entryId: 'e1',
          createdAt: now,
        ),
      );

      expect(second.id, first.id);
      expect(second.latitude, 9);
      final pins = await repository.getPinsForTrip('t1');
      expect(pins, hasLength(1));
    });
  });
}
