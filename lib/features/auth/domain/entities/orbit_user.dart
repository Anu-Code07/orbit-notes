import 'package:equatable/equatable.dart';

class OrbitUser extends Equatable {
  const OrbitUser({
    required this.id,
    required this.email,
    this.displayName,
  });

  final String id;
  final String email;
  final String? displayName;

  /// Prefer Google/full name; fall back to email local-part, then email.
  String get label {
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final at = email.indexOf('@');
    if (at > 0) return email.substring(0, at);
    return email;
  }

  @override
  List<Object?> get props => [id, email, displayName];
}
