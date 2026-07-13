import 'package:equatable/equatable.dart';

class PlaceSearchResult extends Equatable {
  const PlaceSearchResult({
    required this.name,
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final String displayName;
  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [name, displayName, latitude, longitude];
}
