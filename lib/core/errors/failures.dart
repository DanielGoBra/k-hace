sealed class Failure {
  final String message;
  final Object? exception;

  const Failure(this.message, [this.exception]);

  @override
  String toString() => 'Failure: $message';
}

class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure(super.message, [super.exception, this.statusCode]);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, [super.exception]);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, [super.exception]);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, [super.exception]);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, [super.exception]);
}
