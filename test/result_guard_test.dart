import 'package:test/test.dart';
import 'package:explicit_result/explicit_result.dart';

void main() {
  group('Result.guard', () {
    test('wraps a successful synchronous body in a Success', () async {
      final result = await Result.guard<int, String>(
        () => 42,
        (error, stackTrace) => 'unexpected: $error',
      );

      expect(result, isA<Success<int, String>>());
      expect(result.valueOrNull, 42);
    });

    test('wraps a successful asynchronous body in a Success', () async {
      final result = await Result.guard<int, String>(
        () async => 42,
        (error, stackTrace) => 'unexpected: $error',
      );

      expect(result, isA<Success<int, String>>());
      expect(result.valueOrNull, 42);
    });

    test('converts a synchronous throw into a Failure via onError', () async {
      Object? capturedError;
      StackTrace? capturedStackTrace;

      final result = await Result.guard<int, String>(
        () => throw StateError('sync failure'),
        (error, stackTrace) {
          capturedError = error;
          capturedStackTrace = stackTrace;
          return 'handled: $error';
        },
      );

      expect(result, isA<Failure<int, String>>());
      expect(result.errorOrNull, 'handled: Bad state: sync failure');
      expect(capturedError, isA<StateError>());
      expect(capturedStackTrace, isNotNull);
    });

    test('converts a rejected Future into a Failure via onError', () async {
      Object? capturedError;
      StackTrace? capturedStackTrace;

      final result = await Result.guard<int, String>(
        () => Future<int>.error(StateError('async failure')),
        (error, stackTrace) {
          capturedError = error;
          capturedStackTrace = stackTrace;
          return 'handled: $error';
        },
      );

      expect(result, isA<Failure<int, String>>());
      expect(result.errorOrNull, 'handled: Bad state: async failure');
      expect(capturedError, isA<StateError>());
      expect(capturedStackTrace, isNotNull);
    });
  });
}
