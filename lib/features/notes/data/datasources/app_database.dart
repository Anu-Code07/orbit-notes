import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DataClassName('TripRow')
class Trips extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  TextColumn get destination => text().withDefault(const Constant(''))();
  TextColumn get coverPath => text().nullable()();
  IntColumn get accentIndex => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DayRow')
class Days extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text().references(Trips, #id)();
  DateTimeColumn get date => dateTime()();
  TextColumn get title => text().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('EntryRow')
class Entries extends Table {
  TextColumn get id => text()();
  TextColumn get dayId => text().references(Days, #id)();
  TextColumn get body => text()();
  TextColumn get placeName => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PhotoRow')
class Photos extends Table {
  TextColumn get id => text()();
  TextColumn get entryId => text().nullable().references(Entries, #id)();
  TextColumn get tripId => text().nullable().references(Trips, #id)();
  TextColumn get localPath => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MapPinRow')
class MapPins extends Table {
  TextColumn get id => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  TextColumn get label => text().withDefault(const Constant(''))();
  TextColumn get tripId => text().nullable().references(Trips, #id)();
  TextColumn get dayId => text().nullable().references(Days, #id)();
  TextColumn get entryId => text().nullable().references(Entries, #id)();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Trips, Days, Entries, Photos, MapPins])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'orbit_notes'));

  @override
  int get schemaVersion => 1;
}
