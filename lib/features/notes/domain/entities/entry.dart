import 'package:equatable/equatable.dart';

class Entry extends Equatable {
  const Entry({
    required this.id,
    required this.dayId,
    required this.body,
    required this.createdAt,
    this.placeName,
    this.updatedAt,
  });

  final String id;
  final String dayId;
  final String body;
  final String? placeName;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Entry copyWith({
    String? id,
    String? dayId,
    String? body,
    String? placeName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Entry(
      id: id ?? this.id,
      dayId: dayId ?? this.dayId,
      body: body ?? this.body,
      placeName: placeName ?? this.placeName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, dayId, body, placeName, createdAt, updatedAt];
}
