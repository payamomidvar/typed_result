import 'result.dart';

/// Converts a nullable value into a [Result].
extension NullableToResult<T> on T? {
  /// Returns `Success(this)` if this value is non-null, or `Failure` built
  /// from [ifNull] if this value is null.
  ///
  /// Useful for turning APIs that signal "not found" or "unset" with
  /// `null` into the same explicit [Result] shape used everywhere else,
  /// without a separate `if (value == null)` check at every call site.
  Result<T, E> toResult<E>(E Function() ifNull) {
    final value = this;
    if (value == null) return Failure(ifNull());
    return Success(value);
  }
}
