# typed_result

[![pub package](https://img.shields.io/pub/v/typed_result.svg)](https://pub.dev/packages/typed_result)
[![Dart CI](https://github.com/payamomidvar/typed_result/actions/workflows/dart.yml/badge.svg)](https://github.com/payamomidvar/typed_result/actions/workflows/dart.yml)
[![coverage](https://img.shields.io/badge/coverage-100%25-brightgreen)](#testing)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A lightweight, zero-dependency `Result<T, E>` type for Dart — explicit, type-safe success/failure handling without exceptions for expected errors, and without an ambiguous `null`.

## Overview

Dart's usual failure signals — thrown exceptions, or a `null` return — don't distinguish "this call has no meaningful value" from "this call failed." `Result<T, E>` makes success and failure two distinct, statically-known cases, so the compiler (and Dart 3's exhaustive pattern matching) can hold callers accountable for handling both.

This isn't a general-purpose functional-programming toolkit. It does one thing — a `Result` type — and does it with no external dependencies, so it's safe to add to any Dart or Flutter project without pulling in a wider ecosystem.

## Features

- **`Result<T, E>`** — a sealed class with two cases, `Success<T, E>` and `Failure<T, E>`, built on Dart 3 sealed classes and pattern matching.
- **Combinators** — `map`, `mapError`, `flatMap`, `fold`, `getOrElse`.
- **`Result.guard`** — wraps a sync or async operation and converts any thrown error into a `Failure`, so call sites don't need manual try/catch.
- **`toResult()`** — extension method converting a nullable value into a `Result`.
- **Zero external dependencies.**
- **100% test coverage.**
- **Full dartdoc on every public member.**

## Installation

```bash
dart pub add typed_result
```

## Usage

```dart
import 'package:typed_result/typed_result.dart';

Result<int, String> parseAge(String input) {
  final age = int.tryParse(input.trim());
  if (age == null) return Result.failure('"$input" is not a number');
  if (age <= 0) return Result.failure('age must be positive, got $age');
  return Result.success(age);
}

int fetchLoyaltyPoints(String userId) {
  if (userId.isEmpty) {
    throw StateError('cannot look up loyalty points for an empty user id');
  }
  return userId.length * 10;
}

Future<void> main() async {
  // Pattern matching over the sealed Result hierarchy.
  final parsed = parseAge('42');
  final message = switch (parsed) {
    Success(:final value) => 'Got $value',
    Failure(:final error) => 'Error: $error',
  };
  print(message);

  // map / flatMap / getOrElse, all built on fold.
  final doubled = parseAge('10').map((age) => age * 2);
  final chained = parseAge('10').flatMap(parseAge);
  final safe = parseAge('-1').getOrElse((_) => 0);

  // Result.guard converts a thrown error into a typed Failure.
  final points = await Result.guard<int, String>(
    () => fetchLoyaltyPoints(''),
    (error, stackTrace) => 'could not fetch loyalty points: $error',
  );

  // toResult converts a nullable value into an explicit Result.
  final discountCodes = <String, int>{'SAVE10': 10};
  final discount = discountCodes['UNKNOWN'].toResult(
    () => 'unknown discount code',
  );
}
```

See [`example/typed_result.dart`](example/typed_result.dart) for the complete, runnable example this is trimmed from.

## API Reference

| Member | Description |
|---|---|
| `Result.success(T value)` | Construct a successful result. |
| `Result.failure(E error)` | Construct a failed result. |
| `Result.guard<T, E>(body, onError)` | Run `body` (sync or async), converting any thrown error or rejected `Future` into a `Failure` via `onError`. Always returns a `Future<Result<T, E>>`. |
| `isSuccess` / `isFailure` | Check which case a result is. |
| `valueOrNull` / `errorOrNull` | Unwrap without pattern matching, `null` if the wrong case. |
| `fold(onSuccess, onFailure)` | Collapse the result to a single value. |
| `map(transform)` | Transform the success value; failures pass through unchanged. |
| `mapError(transform)` | Transform the failure value; successes pass through unchanged. |
| `flatMap(transform)` | Chain an operation that itself returns a `Result`, without nesting. |
| `getOrElse(orElse)` | Unwrap the success value, or compute a fallback from the error. |
| `T?.toResult(ifNull)` | Convert a nullable value to a `Result`. |

Full API documentation: [pub.dev/documentation/typed_result](https://pub.dev/documentation/typed_result/latest/).

## Design Notes

This package is deliberately narrow. It doesn't include an `Either<L, R>` type (redundant with `Result`'s clearer, error-specific naming), an `Option`/`Maybe` type, `Stream`/`Future` combinators beyond `Result.guard`, or integration helpers for specific HTTP clients. Each of those would either duplicate what `Result` already covers or pull the package away from having zero dependencies. The scope is intentionally small so the package stays a safe, general-purpose primitive rather than a framework.

## Testing

```bash
dart test --coverage=coverage
```

The full suite maintains 100% line coverage, including both branches of `Result.guard` (thrown errors and awaited-`Future` rejections) and every combinator against both `Success` and `Failure` inputs.

## Versioning

This package follows [semantic versioning](https://semver.org) starting from `1.0.0` — a deliberate commitment to public API stability from the first release. Any breaking change to the API described above will be released as a major version bump, not folded silently into a minor or patch release.

## Project Scope

This is the third project in a broader Flutter/Dart skills roadmap, following two Flutter apps. Where those demonstrate using architecture and tooling well, this project demonstrates designing and publishing a public API:

- Primary focus: a small, well-documented, dependency-free public API, with real semantic versioning and a published pub.dev listing.
- Explicitly out of scope: `Either`/`Option` types, async stream combinators, HTTP-client-specific helpers, and code generation — see [Design Notes](#design-notes).

## Contributing

Issues and pull requests are welcome. Please run `dart format`, `dart analyze`, and `dart test` before submitting.

## License

MIT — see [LICENSE](LICENSE).