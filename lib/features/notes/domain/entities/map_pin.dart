import 'package:equatable/equatable.dart';

class MapPin extends Equatable {
  const MapPin({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.label,
    required this.createdAt,
    this.tripId,
    this.dayId,
    this.entryId,
  });

  final String id;
  final double latitude;
  final double longitude;
  final String label;
  final String? tripId;
  final String? dayId;
  final String? entryId;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        latitude,
        longitude,
        label,
        tripId,
        dayId,
        entryId,
        createdAt,
      ];
}
