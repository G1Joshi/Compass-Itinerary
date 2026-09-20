import 'package:flutter_test/flutter_test.dart';
import 'package:compass_itinerary/core/utils/command.dart';
import 'package:compass_itinerary/core/utils/result.dart';

void main() {
  group('Command Pattern Tests', () {
    test('Command0 manages running and completed state', () async {
      final command = Command0<String>(() async {
        await Future.delayed(const Duration(milliseconds: 20));
        return const Result.ok('Done');
      });

      expect(command.running, isFalse);
      expect(command.completed, isFalse);

      final future = command.execute();
      expect(command.running, isTrue);

      await future;
      expect(command.running, isFalse);
      expect(command.completed, isTrue);
      expect(command.value, equals('Done'));
    });

    test(
      'Command blocks concurrent execution to prevent double taps',
      () async {
        var executionCount = 0;
        final command = Command0<void>(() async {
          executionCount++;
          await Future.delayed(const Duration(milliseconds: 40));
          return const Result.ok(null);
        });

        final f1 = command.execute();
        final f2 = command.execute();
        await Future.wait([f1, f2]);

        expect(executionCount, equals(1));
      },
    );

    test('Command1 passes arguments and reports error state', () async {
      final command = Command1<int, String>((input) async {
        if (input.isEmpty) {
          return Result.error(Exception('Invalid parameter'));
        }
        return Result.ok(input.length);
      });

      await command.execute('');
      expect(command.error, isTrue);
      expect(command.errorException.toString(), contains('Invalid parameter'));

      command.clearResult();
      expect(command.error, isFalse);

      await command.execute('Compass');
      expect(command.completed, isTrue);
      expect(command.value, equals(7));
    });
  });
}
