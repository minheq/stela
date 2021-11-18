import 'package:flutter_test/flutter_test.dart';
import 'package:inday/stela/path.dart';
import 'package:inday/stela/point.dart';

void main() {
  group('compare', () {
    test('path after offset after', () {
      Point point = Point(Path([0, 4]), 7);
      Point another = Point(Path([0, 1]), 3);

      expect(point.compare(another), 1);
    });

    test('path after offset before', () {
      Point point = Point(Path([0, 4]), 0);
      Point another = Point(Path([0, 1]), 3);

      expect(point.compare(another), 1);
    });

    test('path after offset equal', () {
      Point point = Point(Path([0, 4]), 3);
      Point another = Point(Path([0, 1]), 3);

      expect(point.compare(another), 1);
    });

    test('path before offset after', () {
      Point point = Point(Path([0, 0]), 4);
      Point another = Point(Path([0, 1]), 0);

      expect(point.compare(another), -1);
    });

    test('path before offset before', () {
      Point point = Point(Path([0, 0]), 0);
      Point another = Point(Path([0, 1]), 3);

      expect(point.compare(another), -1);
    });

    test('path before offset equal', () {
      Point point = Point(Path([0, 0]), 0);
      Point another = Point(Path([0, 1]), 0);

      expect(point.compare(another), -1);
    });

    test('path equal offset after', () {
      Point point = Point(Path([0, 1]), 7);
      Point another = Point(Path([0, 1]), 3);

      expect(point.compare(another), 1);
    });

    test('path equal offset before', () {
      Point point = Point(Path([0, 1]), 0);
      Point another = Point(Path([0, 1]), 3);

      expect(point.compare(another), -1);
    });

    test('path equal offset equal', () {
      Point point = Point(Path([0, 1]), 7);
      Point another = Point(Path([0, 1]), 7);

      expect(point.compare(another), 0);
    });
  });

  group('equals', () {
    test('path after offset after', () {
      Point point = Point(Path([0, 4]), 7);
      Point another = Point(Path([0, 1]), 3);

      expect(point.equals(another), false);
    });

    test('path after offset before', () {
      Point point = Point(Path([0, 4]), 0);
      Point another = Point(Path([0, 1]), 3);

      expect(point.equals(another), false);
    });

    test('path after offset equal', () {
      Point point = Point(Path([0, 4]), 3);
      Point another = Point(Path([0, 1]), 3);

      expect(point.equals(another), false);
    });

    test('path before offset after', () {
      Point point = Point(Path([0, 0]), 4);
      Point another = Point(Path([0, 1]), 0);

      expect(point.equals(another), false);
    });

    test('path before offset before', () {
      Point point = Point(Path([0, 0]), 0);
      Point another = Point(Path([0, 1]), 3);

      expect(point.equals(another), false);
    });

    test('path before offset equal', () {
      Point point = Point(Path([0, 0]), 0);
      Point another = Point(Path([0, 1]), 0);

      expect(point.equals(another), false);
    });

    test('path equal offset after', () {
      Point point = Point(Path([0, 1]), 7);
      Point another = Point(Path([0, 1]), 3);

      expect(point.equals(another), false);
    });

    test('path equal offset before', () {
      Point point = Point(Path([0, 1]), 0);
      Point another = Point(Path([0, 1]), 3);

      expect(point.equals(another), false);
    });

    test('path equal offset equal', () {
      Point point = Point(Path([0, 1]), 7);
      Point another = Point(Path([0, 1]), 7);

      expect(point.equals(another), true);
    });
  });

  group('isAfter', () {
    test('path after offset after', () {
      Point point = Point(Path([0, 4]), 7);
      Point another = Point(Path([0, 1]), 3);

      expect(point.isAfter(another), true);
    });

    test('path after offset before', () {
      Point point = Point(Path([0, 4]), 0);
      Point another = Point(Path([0, 1]), 3);

      expect(point.isAfter(another), true);
    });

    test('path after offset equal', () {
      Point point = Point(Path([0, 4]), 3);
      Point another = Point(Path([0, 1]), 3);

      expect(point.isAfter(another), true);
    });

    test('path before offset after', () {
      Point point = Point(Path([0, 0]), 4);
      Point another = Point(Path([0, 1]), 0);

      expect(point.isAfter(another), false);
    });

    test('path before offset before', () {
      Point point = Point(Path([0, 0]), 0);
      Point another = Point(Path([0, 1]), 3);

      expect(point.isAfter(another), false);
    });

    test('path before offset equal', () {
      Point point = Point(Path([0, 0]), 0);
      Point another = Point(Path([0, 1]), 0);

      expect(point.isAfter(another), false);
    });

    test('path equal offset after', () {
      Point point = Point(Path([0, 1]), 7);
      Point another = Point(Path([0, 1]), 3);

      expect(point.isAfter(another), true);
    });

    test('path equal offset before', () {
      Point point = Point(Path([0, 1]), 0);
      Point another = Point(Path([0, 1]), 3);

      expect(point.isAfter(another), false);
    });

    test('path equal offset equal', () {
      Point point = Point(Path([0, 1]), 7);
      Point another = Point(Path([0, 1]), 7);

      expect(point.isAfter(another), false);
    });
  });

  group('isBefore', () {
    test('path after offset after', () {
      Point point = Point(Path([0, 4]), 7);
      Point another = Point(Path([0, 1]), 3);

      expect(point.isBefore(another), false);
    });

    test('path after offset before', () {
      Point point = Point(Path([0, 4]), 0);
      Point another = Point(Path([0, 1]), 3);

      expect(point.isBefore(another), false);
    });

    test('path after offset equal', () {
      Point point = Point(Path([0, 4]), 3);
      Point another = Point(Path([0, 1]), 3);

      expect(point.isBefore(another), false);
    });

    test('path before offset after', () {
      Point point = Point(Path([0, 0]), 4);
      Point another = Point(Path([0, 1]), 0);

      expect(point.isBefore(another), true);
    });

    test('path before offset before', () {
      Point point = Point(Path([0, 0]), 0);
      Point another = Point(Path([0, 1]), 3);

      expect(point.isBefore(another), true);
    });

    test('path before offset equal', () {
      Point point = Point(Path([0, 0]), 0);
      Point another = Point(Path([0, 1]), 0);

      expect(point.isBefore(another), true);
    });

    test('path equal offset after', () {
      Point point = Point(Path([0, 1]), 7);
      Point another = Point(Path([0, 1]), 3);

      expect(point.isBefore(another), false);
    });

    test('path equal offset before', () {
      Point point = Point(Path([0, 1]), 0);
      Point another = Point(Path([0, 1]), 3);

      expect(point.isBefore(another), true);
    });

    test('path equal offset equal', () {
      Point point = Point(Path([0, 1]), 7);
      Point another = Point(Path([0, 1]), 7);

      expect(point.isBefore(another), false);
    });
  });
}
