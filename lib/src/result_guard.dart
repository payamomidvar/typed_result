import 'dart:async';

import 'result.dart';

/// Runs [body] and converts any error it throws — synchronously, or via a
/// rejected [Future] when [body] is async — into a [Failure] built from
/// [onError], instead of letting the exception propagate.
///
/// Backs [Result.guard]. Kept in its own file so the try/catch mechanics
/// stay separate from the [Result] type definition itself.
Future<Result<T, E>> runResultGuard<T, E>(
  FutureOr<T> Function() body,
  E Function(Object error, StackTrace stackTrace) onError,
) async {
  try {
    final value = await body();
    return Success<T, E>(value);
  } catch (error, stackTrace) {
    return Failure<T, E>(onError(error, stackTrace));
  }
}
