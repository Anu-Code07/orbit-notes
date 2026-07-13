import 'package:equatable/equatable.dart';

class Trip extends Equatable {
  const Trip({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.destination,
    required this.createdAt,
    this.coverPath,
    this.accentIndex = 0,
  });

  final String id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final String destination;
  final String? coverPath;
  final int accentIndex;
  final DateTime createdAt;

  int get dayCount {
    final days = endDate.difference(startDate).inDays + 1;
    return days < 1 ? 1 : days;
  }

  Trip copyWith({
    String? id,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    String? destination,
    String? coverPath,
    int? accentIndex,
    DateTime? createdAt,
    bool clearCover = false,
  }) {
    return Trip(
      id: id ?? this.id,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      destination: destination ?? this.destination,
      coverPath: clearCover ? null : (coverPath ?? this.coverPath),
      accentIndex: accentIndex ?? this.accentIndex,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        startDate,
        endDate,
        destination,
        coverPath,
        accentIndex,
        createdAt,
      ];
}
