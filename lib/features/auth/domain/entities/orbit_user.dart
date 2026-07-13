import 'package:equatable/equatable.dart';

class OrbitUser extends Equatable {
  const OrbitUser({
    required this.id,
    required this.email,
  });

  final String id;
  final String email;

  @override
  List<Object?> get props => [id, email];
}
