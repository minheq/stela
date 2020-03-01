import 'package:flutter_test/flutter_test.dart';
import 'package:inday/stela/interfaces/path.dart';

void main() {
  group("ancestors", () {
    test(
        'should return valid list of paths from furthest to nearest ancestor, excluding itself',
        () {
      Path path = Path([0, 1, 2]);
      List<Path> paths = Path.ancestors(path);

      expect(Path.equals(paths[0], Path([])), true);
      expect(Path.equals(paths[1], Path([0])), true);
      expect(Path.equals(paths[2], Path([0, 1])), true);
    });

    test(
        'should return valid list of paths from nearest to furthest ancestor when given reverse option, excluding itself',
        () {
      Path path = Path([0, 1, 2]);
      List<Path> paths = Path.ancestors(path, reverse: true);

      expect(Path.equals(paths[0], Path([0, 1])), true);
      expect(Path.equals(paths[1], Path([0])), true);
      expect(Path.equals(paths[2], Path([])), true);
    });
  });

  group("common", () {
    test('should return equal ancestor path both when both paths are the same',
        () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0, 1, 2]);

      expect(Path.equals(Path.common(path, another), Path([0, 1, 2])), true);
    });

    test('should return root when two paths are completely different', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([3, 2]);

      expect(Path.equals(Path.common(path, another), Path([])), true);
    });

    test('should ancestor path correctly', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0, 2]);

      expect(Path.equals(Path.common(path, another), Path([0])), true);
    });
  });

  group("compare", () {
    test('should return 0 when other path is above', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0]);

      expect(Path.compare(path, another), 0);
    });

    test('should return 1 when path is after the other path', () {
      Path path = Path([1, 1, 2]);
      Path another = Path([0]);

      expect(Path.compare(path, another), 1);
    });

    test('should return -1 when path is before the other path', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([1]);

      expect(Path.compare(path, another), -1);
    });

    test('should return 0 when other path is below', () {
      Path path = Path([0]);
      Path another = Path([0, 1]);

      expect(Path.compare(path, another), 0);
    });

    test('should return 0 when both paths are equal', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0, 1, 2]);

      expect(Path.compare(path, another), 0);
    });

    test('should return 0 when other path is root', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([]);

      expect(Path.compare(path, another), 0);
    });
  });

  group("levels", () {
    test(
        'should return valid list of paths from shallowest to deepest, including itself',
        () {
      Path path = Path([0, 1, 2]);
      List<Path> paths = Path.levels(path);

      expect(Path.equals(paths[0], Path([])), true);
      expect(Path.equals(paths[1], Path([0])), true);
      expect(Path.equals(paths[2], Path([0, 1])), true);
      expect(Path.equals(paths[3], Path([0, 1, 2])), true);
    });

    test(
        'should return valid list of paths from deepest to shallowest when given reverse option, including itself',
        () {
      Path path = Path([0, 1, 2]);
      List<Path> paths = Path.levels(path, reverse: true);

      expect(Path.equals(paths[0], Path([0, 1, 2])), true);
      expect(Path.equals(paths[1], Path([0, 1])), true);
      expect(Path.equals(paths[2], Path([0])), true);
      expect(Path.equals(paths[3], Path([])), true);
    });
  });
}
