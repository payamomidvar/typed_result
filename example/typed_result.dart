import 'package:typed_result/typed_result.dart';

/// Parses [input] as a positive, plausible age, or fails with a message
/// describing what's wrong with it.
Result<int, String> parseAge(String input) {
  final age = int.tryParse(input.trim());
  if (age == null) return Result.failure('"$input" is not a number');
  if (age <= 0) return Result.failure('age must be positive, got $age');
  if (age > 150) return Result.failure('age $age is not plausible');
  return Result.success(age);
}

/// Checks that [age] meets the minimum age for registration.
Result<int, String> checkEligibility(int age) {
  const minimumAge = 18;
  if (age < minimumAge) {
    return Result.failure('must be at least $minimumAge to register');
  }
  return Result.success(age);
}

/// Simulates a lookup that can throw, e.g. a database or network call.
int fetchLoyaltyPoints(String userId) {
  if (userId.isEmpty) {
    throw StateError('cannot look up loyalty points for an empty user id');
  }
  return userId.length * 10;
}

Future<void> main() async {
  const inputs = ['29', 'abc', '15', '-4'];

  for (final input in inputs) {
    // Parse, add context to any error, then chain an eligibility check
    // that can itself fail — flatMap short-circuits on the first failure.
    final registration = parseAge(input)
        .mapError((error) => 'invalid age: $error')
        .flatMap(checkEligibility);

    // Pattern matching over the sealed Result hierarchy.
    final summary = switch (registration) {
      Success(:final value) => 'eligible, age $value',
      Failure(:final error) => 'rejected: $error',
    };
    print('input "$input" -> $summary');

    // map derives a display-only value without unwrapping manually.
    final birthYear = registration.map((age) => 2026 - age).valueOrNull;
    print('  estimated birth year: ${birthYear ?? 'n/a'}');

    // getOrElse falls back to a safe default when eligibility failed.
    final effectiveAge = registration.getOrElse((_) => 0);
    print('  effective age used downstream: $effectiveAge');
  }

  // Result.guard wraps a call that may throw, turning the exception into
  // a typed Failure instead of letting it propagate.
  for (final userId in ['user-42', '']) {
    final points = await Result.guard<int, String>(
      () => fetchLoyaltyPoints(userId),
      (error, stackTrace) => 'could not fetch loyalty points: $error',
    );
    final message = points.fold((value) => '$value points', (error) => error);
    print('loyalty points for "$userId": $message');
  }

  // toResult converts a nullable Map lookup into an explicit Result.
  final discountCodes = <String, int>{'SAVE10': 10, 'SAVE20': 20};
  for (final code in ['SAVE10', 'UNKNOWN']) {
    final discount = discountCodes[code].toResult(
      () => 'unknown discount code "$code"',
    );
    final message = discount.fold(
      (percent) => '$code applies a $percent% discount',
      (error) => error,
    );
    print(message);
  }
}
