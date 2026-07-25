import 'package:test/test.dart';
import 'package:explicit_result/explicit_result.dart';

void main() {
  group('isSuccess / isFailure', () {
    test('Success reports isSuccess true and isFailure false', () {
      final result = Result<int, String>.success(1);
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
    });

    test('Failure reports isSuccess false and isFailure true', () {
      final result = Result<int, String>.failure('error');
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
    });
  });

  group('valueOrNull / errorOrNull', () {
    test('Success exposes valueOrNull and a null errorOrNull', () {
      final result = Result<int, String>.success(1);
      expect(result.valueOrNull, 1);
      expect(result.errorOrNull, isNull);
    });

    test('Failure exposes errorOrNull and a null valueOrNull', () {
      final result = Result<int, String>.failure('error');
      expect(result.valueOrNull, isNull);
      expect(result.errorOrNull, 'error');
    });
  });

  group('fold', () {
    test('calls onSuccess for a Success', () {
      final result = Result<int, String>.success(2);
      final folded = result.fold(
        (value) => 'value:$value',
        (error) => 'error:$error',
      );
      expect(folded, 'value:2');
    });

    test('calls onFailure for a Failure', () {
      final result = Result<int, String>.failure('bad');
      final folded = result.fold(
        (value) => 'value:$value',
        (error) => 'error:$error',
      );
      expect(folded, 'error:bad');
    });
  });

  group('map', () {
    test('transforms the value of a Success', () {
      final result = Result<int, String>.success(2);
      final mapped = result.map((value) => value * 10);
      expect(mapped, isA<Success<int, String>>());
      expect(mapped.valueOrNull, 20);
    });

    test('passes a Failure through unchanged', () {
      final result = Result<int, String>.failure('bad');
      final mapped = result.map((value) => value * 10);
      expect(mapped, isA<Failure<int, String>>());
      expect(mapped.errorOrNull, 'bad');
    });
  });

  group('mapError', () {
    test('passes a Success through unchanged', () {
      final result = Result<int, String>.success(2);
      final mapped = result.mapError((error) => error.length);
      expect(mapped, isA<Success<int, int>>());
      expect(mapped.valueOrNull, 2);
    });

    test('transforms the error of a Failure', () {
      final result = Result<int, String>.failure('bad');
      final mapped = result.mapError((error) => error.length);
      expect(mapped, isA<Failure<int, int>>());
      expect(mapped.errorOrNull, 3);
    });
  });

  group('flatMap', () {
    test('chains into another Result on Success', () {
      final result = Result<int, String>.success(2);
      final chained = result.flatMap(
        (value) => Result<String, String>.success('positive:$value'),
      );
      expect(chained.valueOrNull, 'positive:2');
    });

    test('short-circuits on Failure without calling transform', () {
      final result = Result<int, String>.failure('bad');
      var called = false;
      final chained = result.flatMap((value) {
        called = true;
        return Result<String, String>.success('unused');
      });
      expect(called, isFalse);
      expect(chained.errorOrNull, 'bad');
    });
  });

  group('getOrElse', () {
    test('returns the value of a Success without calling orElse', () {
      final result = Result<int, String>.success(2);
      var called = false;
      final value = result.getOrElse((error) {
        called = true;
        return -1;
      });
      expect(value, 2);
      expect(called, isFalse);
    });

    test('computes a fallback from the error of a Failure', () {
      final result = Result<int, String>.failure('bad');
      final value = result.getOrElse((error) => error.length);
      expect(value, 3);
    });
  });

  test('supports exhaustive pattern matching via switch', () {
    // Exhaustiveness itself (no default branch needed) is a compile-time
    // property of the sealed hierarchy, not something a test can check;
    // this just confirms the runtime behavior behind each branch.
    final success = Result<int, String>.success(1);
    final failure = Result<int, String>.failure('bad');

    String describe(Result<int, String> result) => switch (result) {
      Success(:final value) => 'success:$value',
      Failure(:final error) => 'failure:$error',
    };

    expect(describe(success), 'success:1');
    expect(describe(failure), 'failure:bad');
  });
}
