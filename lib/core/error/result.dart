import 'package:flutter/foundation.dart';

/// Algebraic Result type to enforce explicit error handling across layers.
@immutable
sealed class Result<T, E> {
  const Result();

  bool get isSuccess => this is Success<T, E>;
  bool get isFailure => this is Failure<T, E>;

  R when<R>({
    required R Function(T value) success,
    required R Function(E error) failure,
  }) {
    return switch (this) {
      Success<T, E>(:final value) => success(value),
      Failure<T, E>(:final error) => failure(error),
    };
  }

  T? get valueOrNull => switch (this) {
        Success<T, E>(:final value) => value,
        Failure<T, E>() => null,
      };

  E? get errorOrNull => switch (this) {
        Success<T, E>() => null,
        Failure<T, E>(:final error) => error,
      };
}

final class Success<T, E> extends Result<T, E> {
  const Success(this.value);
  final T value;
}

final class Failure<T, E> extends Result<T, E> {
  const Failure(this.error);
  final E error;
}

@immutable
sealed class AppFailure {
  const AppFailure(this.message, [this.cause]);
  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType($message)';
}

final class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message, [super.cause]);
}

final class StorageFailure extends AppFailure {
  const StorageFailure(super.message, [super.cause]);
}

final class SecurityFailure extends AppFailure {
  const SecurityFailure(super.message, [super.cause]);
}

final class WidgetSyncFailure extends AppFailure {
  const WidgetSyncFailure(super.message, [super.cause]);
}

final class NotFoundFailure extends AppFailure {
  const NotFoundFailure(super.message, [super.cause]);
}
