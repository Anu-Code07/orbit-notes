import 'package:get_it/get_it.dart';

import 'package:orbit_notes/core/location/device_location_service.dart';
import 'package:orbit_notes/core/prefs/app_prefs.dart';
import 'package:orbit_notes/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:orbit_notes/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:orbit_notes/features/auth/domain/repositories/auth_repository.dart';
import 'package:orbit_notes/features/auth/domain/usecases/auth_usecases.dart';
import 'package:orbit_notes/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:orbit_notes/features/notes/data/datasources/app_database.dart';
import 'package:orbit_notes/features/notes/data/repositories/notes_repository_impl.dart';
import 'package:orbit_notes/features/notes/data/sync/orbit_cloud_sync.dart';
import 'package:orbit_notes/features/notes/domain/repositories/notes_repository.dart';
import 'package:orbit_notes/features/notes/domain/usecases/journal_usecases.dart';
import 'package:orbit_notes/features/notes/domain/usecases/trip_usecases.dart';
import 'package:orbit_notes/features/notes/presentation/bloc/entry/entry_bloc.dart';
import 'package:orbit_notes/features/notes/presentation/bloc/trip_detail/trip_detail_bloc.dart';
import 'package:orbit_notes/features/notes/presentation/bloc/trips/trips_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies({required AppPrefs prefs}) async {
  getIt.registerSingleton<AppPrefs>(prefs);

  final db = AppDatabase();
  getIt.registerSingleton<AppDatabase>(db);
  getIt.registerSingleton<NotesRepository>(NotesRepositoryImpl(db));
  getIt.registerLazySingleton(DeviceLocationService.new);
  getIt.registerLazySingleton(
    () => OrbitCloudSync(notesRepository: getIt()),
  );

  getIt.registerLazySingleton(AuthRemoteDataSource.new);
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton(() => SignInWithEmail(getIt()));
  getIt.registerLazySingleton(() => SignUpWithEmail(getIt()));
  getIt.registerLazySingleton(() => SignInWithGoogle(getIt()));
  getIt.registerLazySingleton(() => SignOut(getIt()));
  getIt.registerLazySingleton(() => WatchAuthState(getIt()));
  getIt.registerSingleton(
    AuthBloc(
      watchAuthState: getIt(),
      signInWithEmail: getIt(),
      signUpWithEmail: getIt(),
      signInWithGoogle: getIt(),
      signOut: getIt(),
      cloudSync: getIt(),
    ),
  );

  final repo = getIt<NotesRepository>();

  getIt.registerLazySingleton(() => GetTrips(repo));
  getIt.registerLazySingleton(() => GetTrip(repo));
  getIt.registerLazySingleton(() => CreateTrip(repo));
  getIt.registerLazySingleton(() => UpdateTrip(repo));
  getIt.registerLazySingleton(() => DeleteTrip(repo));
  getIt.registerLazySingleton(() => GetDaysForTrip(repo));
  getIt.registerLazySingleton(() => CreateDay(repo));
  getIt.registerLazySingleton(() => GetEntriesForDay(repo));
  getIt.registerLazySingleton(() => GetEntriesForTrip(repo));
  getIt.registerLazySingleton(() => GetEntry(repo));
  getIt.registerLazySingleton(() => CreateEntry(repo));
  getIt.registerLazySingleton(() => UpdateEntry(repo));
  getIt.registerLazySingleton(() => DeleteEntry(repo));
  getIt.registerLazySingleton(() => GetPhotosForTrip(repo));
  getIt.registerLazySingleton(() => GetPhotosForEntry(repo));
  getIt.registerLazySingleton(() => AddPhoto(repo));
  getIt.registerLazySingleton(() => PersistImage(repo));
  getIt.registerLazySingleton(() => GetPinsForTrip(repo));
  getIt.registerLazySingleton(() => GetPinForEntry(repo));
  getIt.registerLazySingleton(() => UpsertPin(repo));
  getIt.registerLazySingleton(() => SeedDemoIfEmpty(repo));

  getIt.registerFactory(
    () => TripsBloc(
      getTrips: getIt(),
      seedDemoIfEmpty: getIt(),
      deleteTrip: getIt(),
    ),
  );

  getIt.registerFactory(
    () => TripDetailBloc(
      getTrip: getIt(),
      getDaysForTrip: getIt(),
      getEntriesForTrip: getIt(),
      getPhotosForTrip: getIt(),
      getPinsForTrip: getIt(),
      createDay: getIt(),
      updateTrip: getIt(),
    ),
  );

  getIt.registerFactory(
    () => EntryBloc(
      getEntry: getIt(),
      getPhotosForEntry: getIt(),
      getPinForEntry: getIt(),
      createEntry: getIt(),
      updateEntry: getIt(),
      addPhoto: getIt(),
      persistImage: getIt(),
      upsertPin: getIt(),
    ),
  );
}
