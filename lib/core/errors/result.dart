import 'failures.dart';

sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Fail<T>;

  T? get valueOrNull => switch (this) {
    Success(:final value) => value,
    Fail() => null,
  };

  Failure? get failureOrNull => switch (this) {
    Fail(:final failure) => failure,
    Success() => null,
  };

  R when<R>({
    required R Function(T value) success,
    required R Function(Failure failure) failure,
  }) {
    return switch (this) {
      Success(:final value) => success(value),
      Fail(failure: final f) => failure(f),
    };
  }

  Result<R> map<R>(R Function(T value) transform) {
    return switch (this) {
      Success(:final value) => Success(transform(value)),
      Fail(:final failure) => Fail(failure),
    };
  }
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

class Fail<T> extends Result<T> {
  final Failure failure;
  const Fail(this.failure);
}
