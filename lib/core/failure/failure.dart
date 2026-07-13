import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class StorageFailure extends Failure {
  const StorageFailure([
    super.message = 'Could not save or load your journal data.',
  ]);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'That item could not be found.']);
}

class PermissionFailure extends Failure {
  const PermissionFailure([
    super.message =
        'Permission was denied. You can enable it in Settings, or continue manually.',
  ]);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Please check your input.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Could not sign in. Please try again.']);
}

class SyncFailure extends Failure {
  const SyncFailure([
    super.message = 'Could not sync your journal with the cloud.',
  ]);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Something went wrong.']);
}
