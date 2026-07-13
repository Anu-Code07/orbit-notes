import 'package:equatable/equatable.dart';

class Day extends Equatable {
  const Day({
    required this.id,
    required this.tripId,
    required this.date,
    required this.createdAt,
    this.title,
    this.note,
  });

  final String id;
  final String tripId;
  final DateTime date;
  final String? title;
  final String? note;
  final DateTime createdAt;

  Day copyWith({
    String? id,
    String? tripId,
    DateTime? date,
    String? title,
    String? note,
    DateTime? createdAt,
  }) {
    return Day(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      date: date ?? this.date,
      title: title ?? this.title,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, tripId, date, title, note, createdAt];
}
