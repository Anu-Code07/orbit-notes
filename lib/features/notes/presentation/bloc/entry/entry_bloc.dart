import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'package:orbit_notes/core/failure/failure.dart';
import 'package:orbit_notes/features/notes/domain/entities/entry.dart';
import 'package:orbit_notes/features/notes/domain/entities/map_pin.dart';
import 'package:orbit_notes/features/notes/domain/entities/photo.dart';
import 'package:orbit_notes/features/notes/domain/usecases/journal_usecases.dart';

part 'entry_event.dart';
part 'entry_state.dart';

class EntryBloc extends Bloc<EntryEvent, EntryState> {
  EntryBloc({
    required GetEntry getEntry,
    required GetPhotosForEntry getPhotosForEntry,
    required GetPinForEntry getPinForEntry,
    required CreateEntry createEntry,
    required UpdateEntry updateEntry,
    required AddPhoto addPhoto,
    required PersistImage persistImage,
    required UpsertPin upsertPin,
    Uuid? uuid,
  })  : _getEntry = getEntry,
        _getPhotosForEntry = getPhotosForEntry,
        _getPinForEntry = getPinForEntry,
        _createEntry = createEntry,
        _updateEntry = updateEntry,
        _addPhoto = addPhoto,
        _persistImage = persistImage,
        _upsertPin = upsertPin,
        _uuid = uuid ?? const Uuid(),
        super(const EntryInitial()) {
    on<PrepareNewEntry>(_onPrepareNew);
    on<LoadEntry>(_onLoad);
    on<BodyChanged>(_onBodyChanged);
    on<PlaceNameChanged>(_onPlaceChanged);
    on<AddLocalPhoto>(_onAddPhoto);
    on<SetMapPin>(_onSetPin);
    on<SaveEntry>(_onSave);
  }

  final GetEntry _getEntry;
  final GetPhotosForEntry _getPhotosForEntry;
  final GetPinForEntry _getPinForEntry;
  final CreateEntry _createEntry;
  final UpdateEntry _updateEntry;
  final AddPhoto _addPhoto;
  final PersistImage _persistImage;
  final UpsertPin _upsertPin;
  final Uuid _uuid;

  Future<void> _onPrepareNew(
    PrepareNewEntry event,
    Emitter<EntryState> emit,
  ) async {
    emit(
      EntryEditing(
        dayId: event.dayId,
        tripId: event.tripId,
        body: '',
        placeName: '',
        existingPhotoPaths: const [],
        pendingPhotoPaths: const [],
        isNew: true,
      ),
    );
  }

  Future<void> _onLoad(LoadEntry event, Emitter<EntryState> emit) async {
    emit(const EntryLoading());
    try {
      final entry = await _getEntry(event.entryId);
      if (entry == null) {
        emit(const EntryError(NotFoundFailure()));
        return;
      }
      final photos = await _getPhotosForEntry(entry.id);
      final pin = await _getPinForEntry(entry.id);
      emit(
        EntryEditing(
          dayId: entry.dayId,
          tripId: event.tripId,
          entryId: entry.id,
          body: entry.body,
          placeName: entry.placeName ?? '',
          existingPhotoPaths: photos.map((p) => p.localPath).toList(),
          pendingPhotoPaths: const [],
          isNew: false,
          createdAt: entry.createdAt,
          pinId: pin?.id,
          pinLatitude: pin?.latitude,
          pinLongitude: pin?.longitude,
        ),
      );
    } catch (_) {
      emit(const EntryError(StorageFailure()));
    }
  }

  void _onBodyChanged(BodyChanged event, Emitter<EntryState> emit) {
    final current = state;
    if (current is EntryEditing) {
      emit(current.copyWith(body: event.body, clearMessage: true));
    }
  }

  void _onPlaceChanged(PlaceNameChanged event, Emitter<EntryState> emit) {
    final current = state;
    if (current is EntryEditing) {
      emit(current.copyWith(placeName: event.placeName, clearMessage: true));
    }
  }

  Future<void> _onAddPhoto(
    AddLocalPhoto event,
    Emitter<EntryState> emit,
  ) async {
    final current = state;
    if (current is! EntryEditing) return;
    try {
      final path = await _persistImage(event.sourcePath);
      emit(
        current.copyWith(
          pendingPhotoPaths: [...current.pendingPhotoPaths, path],
          clearMessage: true,
        ),
      );
    } catch (_) {
      emit(current.copyWith(message: 'Could not save that photo.'));
    }
  }

  void _onSetPin(SetMapPin event, Emitter<EntryState> emit) {
    final current = state;
    if (current is EntryEditing) {
      emit(
        current.copyWith(
          pinLatitude: event.latitude,
          pinLongitude: event.longitude,
          placeName: event.label.isEmpty ? current.placeName : event.label,
          clearMessage: true,
        ),
      );
    }
  }

  Future<void> _onSave(SaveEntry event, Emitter<EntryState> emit) async {
    final current = state;
    if (current is! EntryEditing) return;

    final body = current.body.trim();
    if (body.isEmpty) {
      emit(current.copyWith(message: 'Write a few words before saving.'));
      return;
    }

    var working = current.copyWith(isSaving: true, clearMessage: true);
    emit(working);

    try {
      final now = DateTime.now();
      final entryId = working.entryId ?? _uuid.v4();
      final entry = Entry(
        id: entryId,
        dayId: working.dayId,
        body: body,
        placeName:
            working.placeName.trim().isEmpty ? null : working.placeName.trim(),
        createdAt: working.createdAt ?? now,
        updatedAt: working.isNew ? null : now,
      );

      final existingEntry = await _getEntry(entryId);
      if (existingEntry == null) {
        await _createEntry(entry);
      } else {
        await _updateEntry(
          entry.copyWith(createdAt: existingEntry.createdAt, updatedAt: now),
        );
      }

      // Checkpoint so a retry won't create a second entry.
      working = working.copyWith(
        entryId: entryId,
        isNew: false,
        createdAt: entry.createdAt,
        isSaving: true,
      );
      emit(working);

      final remaining = List<String>.from(working.pendingPhotoPaths);
      var existing = List<String>.from(working.existingPhotoPaths);
      var order = existing.length;
      while (remaining.isNotEmpty) {
        final path = remaining.removeAt(0);
        await _addPhoto(
          Photo(
            id: _uuid.v4(),
            entryId: entryId,
            tripId: working.tripId,
            localPath: path,
            sortOrder: order++,
            createdAt: now,
          ),
        );
        existing = [...existing, path];
        working = working.copyWith(
          existingPhotoPaths: existing,
          pendingPhotoPaths: List<String>.from(remaining),
          isSaving: true,
        );
        emit(working);
      }

      if (working.pinLatitude != null && working.pinLongitude != null) {
        final savedPin = await _upsertPin(
          MapPin(
            id: working.pinId ?? _uuid.v4(),
            latitude: working.pinLatitude!,
            longitude: working.pinLongitude!,
            label: working.placeName.trim().isEmpty
                ? 'Pin'
                : working.placeName.trim(),
            tripId: working.tripId,
            dayId: working.dayId,
            entryId: entryId,
            createdAt: now,
          ),
        );
        working = working.copyWith(pinId: savedPin.id, isSaving: true);
        emit(working);
      }

      emit(EntrySaved(entryId));
    } catch (_) {
      final latest = state;
      if (latest is EntryEditing) {
        emit(
          latest.copyWith(
            isSaving: false,
            message: const StorageFailure().message,
          ),
        );
      } else {
        emit(
          working.copyWith(
            isSaving: false,
            message: const StorageFailure().message,
          ),
        );
      }
    }
  }
}
