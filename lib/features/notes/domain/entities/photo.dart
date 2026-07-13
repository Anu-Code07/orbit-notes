import 'package:equatable/equatable.dart';

class Photo extends Equatable {
  const Photo({
    required this.id,
    required this.localPath,
    required this.sortOrder,
    required this.createdAt,
    this.entryId,
    this.tripId,
  });

  final String id;
  final String? entryId;
  final String? tripId;
  final String localPath;
  final int sortOrder;
  final DateTime createdAt;

  @override
  List<Object?> get props =>
      [id, entryId, tripId, localPath, sortOrder, createdAt];
}
