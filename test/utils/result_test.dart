import 'package:flutter_test/flutter_test.dart';
import 'package:compass_itinerary/core/utils/result.dart';

void main() {
  group('Result Pattern Tests', () {
    test('Ok result contains value and checks isOk', () {
      const result = Result.ok('Kyoto, Japan');

      expect(result.isOk, isTrue);
      expect(result.isError, isFalse);
      expect(result.valueOrNull, equals('Kyoto, Japan'));
      expect(result.errorOrNull, isNull);
    });

    test('Error result contains exception and checks isError', () {
      final exception = Exception('Simulated network timeout');
      final result = Result<String>.error(exception);

      expect(result.isOk, isFalse);
      expect(result.isError, isTrue);
      expect(result.valueOrNull, isNull);
      expect(result.errorOrNull, equals(exception));
    });

    test('Dart 3 exhaustive switch pattern matching works correctly', () {
      const Result<int> okResult = Result.ok(100);
      final okOutput = switch (okResult) {
        Ok(:final value) => 'Value: $value',
        Error(:final error) => 'Error: $error',
      };
      expect(okOutput, equals('Value: 100'));

      final Result<int> errResult = Result.error(Exception('Failed'));
      final errOutput = switch (errResult) {
        Ok(:final value) => 'Value: $value',
        Error(:final error) => 'Error: $error',
      };
      expect(errOutput, contains('Failed'));
    });
  });
}
