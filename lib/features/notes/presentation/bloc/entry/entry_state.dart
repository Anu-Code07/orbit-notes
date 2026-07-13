part of 'entry_bloc.dart';

sealed class EntryState extends Equatable {
  const EntryState();

  @override
  List<Object?> get props => [];
}

class EntryInitial extends EntryState {
  const EntryInitial();
}

class EntryLoading extends EntryState {
  const EntryLoading();
}

class EntryEditing extends EntryState {
  const EntryEditing({
    required this.dayId,
    required this.tripId,
    required this.body,
    required this.placeName,
    required this.existingPhotoPaths,
    required this.pendingPhotoPaths,
    required this.isNew,
    this.entryId,
    this.createdAt,
    this.pinId,
    this.pinLatitude,
    this.pinLongitude,
    this.isSaving = false,
    this.message,
  });

  final String dayId;
  final String tripId;
  final String? entryId;
  final String body;
  final String placeName;
  final List<String> existingPhotoPaths;
  final List<String> pendingPhotoPaths;
  final String? pinId;
  final double? pinLatitude;
  final double? pinLongitude;
  final bool isNew;
  final bool isSaving;
  final String? message;
  final DateTime? createdAt;

  List<String> get allPhotoPaths =>
      [...existingPhotoPaths, ...pendingPhotoPaths];

  EntryEditing copyWith({
    String? dayId,
    String? tripId,
    String? entryId,
    String? body,
    String? placeName,
    List<String>? existingPhotoPaths,
    List<String>? pendingPhotoPaths,
    String? pinId,
    double? pinLatitude,
    double? pinLongitude,
    bool? isNew,
    bool? isSaving,
    String? message,
    DateTime? createdAt,
    bool clearMessage = false,
  }) {
    return EntryEditing(
      dayId: dayId ?? this.dayId,
      tripId: tripId ?? this.tripId,
      entryId: entryId ?? this.entryId,
      body: body ?? this.body,
      placeName: placeName ?? this.placeName,
      existingPhotoPaths: existingPhotoPaths ?? this.existingPhotoPaths,
      pendingPhotoPaths: pendingPhotoPaths ?? this.pendingPhotoPaths,
      pinId: pinId ?? this.pinId,
      pinLatitude: pinLatitude ?? this.pinLatitude,
      pinLongitude: pinLongitude ?? this.pinLongitude,
      isNew: isNew ?? this.isNew,
      isSaving: isSaving ?? this.isSaving,
      createdAt: createdAt ?? this.createdAt,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [
        dayId,
        tripId,
        entryId,
        body,
        placeName,
        existingPhotoPaths,
        pendingPhotoPaths,
        pinId,
        pinLatitude,
        pinLongitude,
        isNew,
        isSaving,
        message,
        createdAt,
      ];
}

class EntrySaved extends EntryState {
  const EntrySaved(this.entryId);

  final String entryId;

  @override
  List<Object?> get props => [entryId];
}

class EntryError extends EntryState {
  const EntryError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
