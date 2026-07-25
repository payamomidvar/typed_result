import 'package:test/test.dart';
import 'package:typed_result/typed_result.dart';

void main() {
  group('NullableToResult.toResult', () {
    test('returns Success for a non-null value', () {
      const String? input = 'hello';
      final result = input.toResult(() => 'missing value');

      expect(result, isA<Success<String, String>>());
      expect(result.valueOrNull, 'hello');
    });

    test('returns Failure built from ifNull for a null value', () {
      const String? input = null;
      var called = false;
      final result = input.toResult(() {
        called = true;
        return 'missing value';
      });

      expect(called, isTrue);
      expect(result, isA<Failure<String, String>>());
      expect(result.errorOrNull, 'missing value');
    });
  });
}
