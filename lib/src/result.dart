import 'dart:async';

import 'result_guard.dart';

/// The result of an operation that can either succeed with a value of type
/// [T] or fail with an error of type [E].
///
/// This is a sealed class with exactly two variants, [Success] and
/// [Failure], so a `switch` expression over a [Result] is
/// exhaustive-checkable by the compiler with no `default` branch needed.
sealed class Result<T, E> {
  const Result();

  /// Creates a successful [Result] holding [value].
  factory Result.success(T value) = Success<T, E>;

  /// Creates a failed [Result] holding [error].
  factory Result.failure(E error) = Failure<T, E>;

  /// Whether this result is a [Success].
  bool get isSuccess => this is Success<T, E>;

  /// Whether this result is a [Failure].
  bool get isFailure => this is Failure<T, E>;

  /// The success value, or `null` if this is a [Failure].
  T? get valueOrNull => switch (this) {
    Success(:final value) => value,
    Failure() => null,
  };

  /// The failure error, or `null` if this is a [Success].
  E? get errorOrNull => switch (this) {
    Success() => null,
    Failure(:final error) => error,
  };

  /// Collapses this result to a single value of type [R] by calling
  /// [onSuccess] or [onFailure] depending on the variant.
  ///
  /// Every other convenience method on [Result] can be expressed in terms
  /// of [fold], which is why it's the one method defined directly here.
  R fold<R>(R Function(T value) onSuccess, R Function(E error) onFailure) =>
      switch (this) {
        Success(:final value) => onSuccess(value),
        Failure(:final error) => onFailure(error),
      };

  /// Runs [body] and converts any error it throws — synchronously, or via
  /// a rejected [Future] for an async [body] — into a [Failure] built by
  /// [onError], instead of letting the exception propagate to the caller.
  ///
  /// Always returns a [Future], even when [body] completes synchronously,
  /// so call sites can `await Result.guard(...)` uniformly regardless of
  /// whether [body] does async work.
  static Future<Result<T, E>> guard<T, E>(
    FutureOr<T> Function() body,
    E Function(Object error, StackTrace stackTrace) onError,
  ) => runResultGuard(body, onError);

  /// Transforms the success value using [transform], leaving a [Failure]
  /// unchanged.
  ///
  /// Implemented in terms of [fold]: on success, wrap the transformed
  /// value back into a [Success]; on failure, pass the error through as-is.
  Result<R, E> map<R>(R Function(T value) transform) =>
      fold((value) => Success(transform(value)), (error) => Failure(error));

  /// Transforms the failure error using [transform], leaving a [Success]
  /// unchanged.
  ///
  /// The mirror image of [map]: it operates on the error channel instead
  /// of the value channel.
  Result<T, R> mapError<R>(R Function(E error) transform) =>
      fold((value) => Success(value), (error) => Failure(transform(error)));

  /// Chains an operation that itself returns a [Result], without nesting
  /// the result in another [Result] (i.e. avoids `Result<Result<R, E>, E>`).
  ///
  /// Use this instead of [map] when [transform] can itself fail.
  Result<R, E> flatMap<R>(Result<R, E> Function(T value) transform) =>
      fold((value) => transform(value), (error) => Failure(error));

  /// Unwraps the success value, or computes a fallback from the error via
  /// [orElse] if this is a [Failure].
  T getOrElse(T Function(E error) orElse) =>
      fold((value) => value, (error) => orElse(error));
}

/// A [Result] that represents success, holding the resulting [value].
final class Success<T, E> extends Result<T, E> {
  /// Creates a [Success] holding [value].
  const Success(this.value);

  /// The value produced by the successful operation.
  final T value;
}

/// A [Result] that represents failure, holding the resulting [error].
final class Failure<T, E> extends Result<T, E> {
  /// Creates a [Failure] holding [error].
  const Failure(this.error);

  /// The error produced by the failed operation.
  final E error;
}
