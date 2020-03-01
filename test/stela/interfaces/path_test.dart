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
    test('above', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0]);

      expect(Path.compare(path, another), 0);
    });

    test('after', () {
      Path path = Path([1, 1, 2]);
      Path another = Path([0]);

      expect(Path.compare(path, another), 1);
    });

    test('before', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([1]);

      expect(Path.compare(path, another), -1);
    });

    test('below', () {
      Path path = Path([0]);
      Path another = Path([0, 1]);

      expect(Path.compare(path, another), 0);
    });

    test('equal', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0, 1, 2]);

      expect(Path.compare(path, another), 0);
    });

    test('root', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([]);

      expect(Path.compare(path, another), 0);
    });
  });

  group("endsAfter", () {
    test('above', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0]);

      expect(Path.endsAfter(path, another), false);
    });

    test('after', () {
      Path path = Path([1, 1, 2]);
      Path another = Path([0]);

      expect(Path.endsAfter(path, another), false);
    });

    test('before', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([1]);

      expect(Path.endsAfter(path, another), false);
    });

    test('below', () {
      Path path = Path([0]);
      Path another = Path([0, 1]);

      expect(Path.endsAfter(path, another), false);
    });

    test('ends after', () {
      Path path = Path([1]);
      Path another = Path([0, 2]);

      expect(Path.endsAfter(path, another), true);
    });

    test('ends at', () {
      Path path = Path([0]);
      Path another = Path([0, 2]);

      expect(Path.endsAfter(path, another), false);
    });

    test('ends before', () {
      Path path = Path([0]);
      Path another = Path([1, 2]);

      expect(Path.endsAfter(path, another), false);
    });

    test('equal', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0, 1, 2]);

      expect(Path.endsAfter(path, another), false);
    });

    test('root', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([]);

      expect(Path.endsAfter(path, another), false);
    });
  });

  group("endsAt", () {
    test('above', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0]);

      expect(Path.endsAt(path, another), false);
    });

    test('after', () {
      Path path = Path([1, 1, 2]);
      Path another = Path([0]);

      expect(Path.endsAt(path, another), false);
    });

    test('before', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([1]);

      expect(Path.endsAt(path, another), false);
    });

    test('ends after', () {
      Path path = Path([1]);
      Path another = Path([0, 2]);

      expect(Path.endsAt(path, another), false);
    });

    test('ends at', () {
      Path path = Path([0]);
      Path another = Path([0, 2]);

      expect(Path.endsAt(path, another), true);
    });

    test('ends before', () {
      Path path = Path([0]);
      Path another = Path([1, 2]);

      expect(Path.endsAt(path, another), false);
    });

    test('equal', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0, 1, 2]);

      expect(Path.endsAt(path, another), true);
    });

    test('root', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([]);

      expect(Path.endsAt(path, another), false);
    });
  });

  group("endsBefore", () {
    test('above', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0]);

      expect(Path.endsBefore(path, another), false);
    });

    test('after', () {
      Path path = Path([1, 1, 2]);
      Path another = Path([0]);

      expect(Path.endsBefore(path, another), false);
    });

    test('before', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([1]);

      expect(Path.endsBefore(path, another), false);
    });

    test('below', () {
      Path path = Path([0]);
      Path another = Path([0, 1]);

      expect(Path.endsAfter(path, another), false);
    });

    test('ends after', () {
      Path path = Path([1]);
      Path another = Path([0, 2]);

      expect(Path.endsBefore(path, another), false);
    });

    test('ends at', () {
      Path path = Path([0]);
      Path another = Path([0, 2]);

      expect(Path.endsBefore(path, another), false);
    });

    test('ends before', () {
      Path path = Path([0]);
      Path another = Path([1, 2]);

      expect(Path.endsBefore(path, another), true);
    });

    test('equal', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0, 1, 2]);

      expect(Path.endsBefore(path, another), false);
    });

    test('root', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([]);

      expect(Path.endsBefore(path, another), false);
    });
  });

  group("equals", () {
    test('above', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0]);

      expect(Path.equals(path, another), false);
    });

    test('after', () {
      Path path = Path([1, 1, 2]);
      Path another = Path([0]);

      expect(Path.equals(path, another), false);
    });

    test('before', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([1]);

      expect(Path.equals(path, another), false);
    });

    test('below', () {
      Path path = Path([0]);
      Path another = Path([0, 1]);

      expect(Path.equals(path, another), false);
    });

    test('equal', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0, 1, 2]);

      expect(Path.equals(path, another), true);
    });

    test('root', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([]);

      expect(Path.equals(path, another), false);
    });
  });

  group("isAfter", () {
    test('above', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0]);

      expect(Path.isAfter(path, another), false);
    });

    test('after', () {
      Path path = Path([1, 1, 2]);
      Path another = Path([0]);

      expect(Path.isAfter(path, another), true);
    });

    test('before', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([1]);

      expect(Path.isAfter(path, another), false);
    });

    test('below', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0]);

      expect(Path.isAfter(path, another), false);
    });

    test('equal', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0, 1, 2]);

      expect(Path.isAfter(path, another), false);
    });

    test('root', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([]);

      expect(Path.isAfter(path, another), false);
    });
  });

  group("isAncestor", () {
    test('above grandparent', () {
      Path path = Path([]);
      Path another = Path([0, 1]);

      expect(Path.isAncestor(path, another), true);
    });

    test('above parent', () {
      Path path = Path([]);
      Path another = Path([0, 1]);

      expect(Path.isAncestor(path, another), true);
    });

    test('after', () {
      Path path = Path([1, 1, 2]);
      Path another = Path([0]);

      expect(Path.isAncestor(path, another), false);
    });

    test('before', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([1]);

      expect(Path.isAncestor(path, another), false);
    });

    test('below', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0]);

      expect(Path.isAncestor(path, another), false);
    });

    test('equal', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0, 1, 2]);

      expect(Path.isAncestor(path, another), false);
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
