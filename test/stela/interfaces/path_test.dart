import 'package:flutter_test/flutter_test.dart';
import 'package:inday/stela/interfaces/path.dart';

void main() {
  group("ancestors", () {
    test(
        'should return valid list of paths from furthest to nearest ancestor, excluding itself',
        () {
      Path path = Path([0, 1, 2]);
      List<Path> paths = PathUtils.ancestors(path);

      expect(PathUtils.equals(paths[0], Path([])), true);
      expect(PathUtils.equals(paths[1], Path([0])), true);
      expect(PathUtils.equals(paths[2], Path([0, 1])), true);
    });

    test(
        'should return valid list of paths from nearest to furthest ancestor when given reverse option, excluding itself',
        () {
      Path path = Path([0, 1, 2]);
      List<Path> paths = PathUtils.ancestors(path, reverse: true);

      expect(PathUtils.equals(paths[0], Path([0, 1])), true);
      expect(PathUtils.equals(paths[1], Path([0])), true);
      expect(PathUtils.equals(paths[2], Path([])), true);
    });
  });

  group("common", () {
    test('should return equal ancestor path both when both paths are the same',
        () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0, 1, 2]);

      expect(PathUtils.equals(PathUtils.common(path, another), Path([0, 1, 2])),
          true);
    });

    test('should return root when two paths are completely different', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([3, 2]);

      expect(PathUtils.equals(PathUtils.common(path, another), Path([])), true);
    });

    test('should ancestor path correctly', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0, 2]);

      expect(
          PathUtils.equals(PathUtils.common(path, another), Path([0])), true);
    });
  });

  group("compare", () {
    test('above', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0]);

      expect(PathUtils.compare(path, another), 0);
    });

    test('after', () {
      Path path = Path([1, 1, 2]);
      Path another = Path([0]);

      expect(PathUtils.compare(path, another), 1);
    });

    test('before', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([1]);

      expect(PathUtils.compare(path, another), -1);
    });

    test('below', () {
      Path path = Path([0]);
      Path another = Path([0, 1]);

      expect(PathUtils.compare(path, another), 0);
    });

    test('equal', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0, 1, 2]);

      expect(PathUtils.compare(path, another), 0);
    });

    test('root', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([]);

      expect(PathUtils.compare(path, another), 0);
    });
  });

  group("endsAfter", () {
    test('above', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0]);

      expect(PathUtils.endsAfter(path, another), false);
    });

    test('after', () {
      Path path = Path([1, 1, 2]);
      Path another = Path([0]);

      expect(PathUtils.endsAfter(path, another), false);
    });

    test('before', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([1]);

      expect(PathUtils.endsAfter(path, another), false);
    });

    test('below', () {
      Path path = Path([0]);
      Path another = Path([0, 1]);

      expect(PathUtils.endsAfter(path, another), false);
    });

    test('ends after', () {
      Path path = Path([1]);
      Path another = Path([0, 2]);

      expect(PathUtils.endsAfter(path, another), true);
    });

    test('ends at', () {
      Path path = Path([0]);
      Path another = Path([0, 2]);

      expect(PathUtils.endsAfter(path, another), false);
    });

    test('ends before', () {
      Path path = Path([0]);
      Path another = Path([1, 2]);

      expect(PathUtils.endsAfter(path, another), false);
    });

    test('equal', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0, 1, 2]);

      expect(PathUtils.endsAfter(path, another), false);
    });

    test('root', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([]);

      expect(PathUtils.endsAfter(path, another), false);
    });
  });

  group("endsAt", () {
    test('above', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0]);

      expect(PathUtils.endsAt(path, another), false);
    });

    test('after', () {
      Path path = Path([1, 1, 2]);
      Path another = Path([0]);

      expect(PathUtils.endsAt(path, another), false);
    });

    test('before', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([1]);

      expect(PathUtils.endsAt(path, another), false);
    });

    test('ends after', () {
      Path path = Path([1]);
      Path another = Path([0, 2]);

      expect(PathUtils.endsAt(path, another), false);
    });

    test('ends at', () {
      Path path = Path([0]);
      Path another = Path([0, 2]);

      expect(PathUtils.endsAt(path, another), true);
    });

    test('ends before', () {
      Path path = Path([0]);
      Path another = Path([1, 2]);

      expect(PathUtils.endsAt(path, another), false);
    });

    test('equal', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0, 1, 2]);

      expect(PathUtils.endsAt(path, another), true);
    });

    test('root', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([]);

      expect(PathUtils.endsAt(path, another), false);
    });
  });

  group("endsBefore", () {
    test('above', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0]);

      expect(PathUtils.endsBefore(path, another), false);
    });

    test('after', () {
      Path path = Path([1, 1, 2]);
      Path another = Path([0]);

      expect(PathUtils.endsBefore(path, another), false);
    });

    test('before', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([1]);

      expect(PathUtils.endsBefore(path, another), false);
    });

    test('below', () {
      Path path = Path([0]);
      Path another = Path([0, 1]);

      expect(PathUtils.endsAfter(path, another), false);
    });

    test('ends after', () {
      Path path = Path([1]);
      Path another = Path([0, 2]);

      expect(PathUtils.endsBefore(path, another), false);
    });

    test('ends at', () {
      Path path = Path([0]);
      Path another = Path([0, 2]);

      expect(PathUtils.endsBefore(path, another), false);
    });

    test('ends before', () {
      Path path = Path([0]);
      Path another = Path([1, 2]);

      expect(PathUtils.endsBefore(path, another), true);
    });

    test('equal', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0, 1, 2]);

      expect(PathUtils.endsBefore(path, another), false);
    });

    test('root', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([]);

      expect(PathUtils.endsBefore(path, another), false);
    });
  });

  group("equals", () {
    test('above', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0]);

      expect(PathUtils.equals(path, another), false);
    });

    test('after', () {
      Path path = Path([1, 1, 2]);
      Path another = Path([0]);

      expect(PathUtils.equals(path, another), false);
    });

    test('before', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([1]);

      expect(PathUtils.equals(path, another), false);
    });

    test('below', () {
      Path path = Path([0]);
      Path another = Path([0, 1]);

      expect(PathUtils.equals(path, another), false);
    });

    test('equal', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0, 1, 2]);

      expect(PathUtils.equals(path, another), true);
    });

    test('root', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([]);

      expect(PathUtils.equals(path, another), false);
    });
  });

  group("isAfter", () {
    test('above', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0]);

      expect(PathUtils.isAfter(path, another), false);
    });

    test('after', () {
      Path path = Path([1, 1, 2]);
      Path another = Path([0]);

      expect(PathUtils.isAfter(path, another), true);
    });

    test('before', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([1]);

      expect(PathUtils.isAfter(path, another), false);
    });

    test('below', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0]);

      expect(PathUtils.isAfter(path, another), false);
    });

    test('equal', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0, 1, 2]);

      expect(PathUtils.isAfter(path, another), false);
    });

    test('root', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([]);

      expect(PathUtils.isAfter(path, another), false);
    });
  });

  group("isAncestor", () {
    test('above grandparent', () {
      Path path = Path([]);
      Path another = Path([0, 1]);

      expect(PathUtils.isAncestor(path, another), true);
    });

    test('above parent', () {
      Path path = Path([]);
      Path another = Path([0, 1]);

      expect(PathUtils.isAncestor(path, another), true);
    });

    test('after', () {
      Path path = Path([1, 1, 2]);
      Path another = Path([0]);

      expect(PathUtils.isAncestor(path, another), false);
    });

    test('before', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([1]);

      expect(PathUtils.isAncestor(path, another), false);
    });

    test('below', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0]);

      expect(PathUtils.isAncestor(path, another), false);
    });

    test('equal', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0, 1, 2]);

      expect(PathUtils.isAncestor(path, another), false);
    });
  });

  group("isBefore", () {
    test('above', () {
      Path path = Path([0]);
      Path another = Path([0, 1]);

      expect(PathUtils.isBefore(path, another), false);
    });

    test('after', () {
      Path path = Path([1, 1, 2]);
      Path another = Path([0]);

      expect(PathUtils.isBefore(path, another), false);
    });

    test('before', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([1]);

      expect(PathUtils.isBefore(path, another), true);
    });

    test('below', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0]);

      expect(PathUtils.isBefore(path, another), false);
    });

    test('equal', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0, 1, 2]);

      expect(PathUtils.isBefore(path, another), false);
    });
  });

  group("isChild", () {
    test('above', () {
      Path path = Path([0]);
      Path another = Path([0, 1]);

      expect(PathUtils.isChild(path, another), false);
    });

    test('after', () {
      Path path = Path([1, 1, 2]);
      Path another = Path([0]);

      expect(PathUtils.isChild(path, another), false);
    });

    test('before', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([1]);

      expect(PathUtils.isChild(path, another), false);
    });

    test('below child', () {
      Path path = Path([0, 1]);
      Path another = Path([0]);

      expect(PathUtils.isChild(path, another), true);
    });

    test('below grandchild', () {
      Path path = Path([0, 1]);
      Path another = Path([]);

      expect(PathUtils.isChild(path, another), false);
    });

    test('equal', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0, 1, 2]);

      expect(PathUtils.isChild(path, another), false);
    });
  });

  group("isDescendant", () {
    test('above', () {
      Path path = Path([0]);
      Path another = Path([0, 1]);

      expect(PathUtils.isDescendant(path, another), false);
    });

    test('after', () {
      Path path = Path([1, 1, 2]);
      Path another = Path([0]);

      expect(PathUtils.isDescendant(path, another), false);
    });

    test('before', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([1]);

      expect(PathUtils.isDescendant(path, another), false);
    });

    test('below child', () {
      Path path = Path([0, 1]);
      Path another = Path([0]);

      expect(PathUtils.isDescendant(path, another), true);
    });

    test('below grandchild', () {
      Path path = Path([0, 1]);
      Path another = Path([]);

      expect(PathUtils.isDescendant(path, another), true);
    });

    test('equal', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0, 1, 2]);

      expect(PathUtils.isDescendant(path, another), false);
    });
  });

  group("isParent", () {
    test('above grandparent', () {
      Path path = Path([]);
      Path another = Path([0, 1]);

      expect(PathUtils.isParent(path, another), false);
    });

    test('above parent', () {
      Path path = Path([0]);
      Path another = Path([0, 1]);

      expect(PathUtils.isParent(path, another), true);
    });

    test('after', () {
      Path path = Path([1, 1, 2]);
      Path another = Path([0]);

      expect(PathUtils.isParent(path, another), false);
    });

    test('before', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([1]);

      expect(PathUtils.isParent(path, another), false);
    });

    test('below', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0]);

      expect(PathUtils.isParent(path, another), false);
    });

    test('equal', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0, 1, 2]);

      expect(PathUtils.isParent(path, another), false);
    });
  });

  group("isSibling", () {
    test('above', () {
      Path path = Path([]);
      Path another = Path([0, 1]);

      expect(PathUtils.isSibling(path, another), false);
    });

    test('after sibling', () {
      Path path = Path([1, 4]);
      Path another = Path([1, 2]);

      expect(PathUtils.isSibling(path, another), true);
    });

    test('after', () {
      Path path = Path([1, 2]);
      Path another = Path([0]);

      expect(PathUtils.isSibling(path, another), false);
    });

    test('before sibling', () {
      Path path = Path([0, 1]);
      Path another = Path([0, 3]);

      expect(PathUtils.isSibling(path, another), true);
    });

    test('before', () {
      Path path = Path([0, 2]);
      Path another = Path([1]);

      expect(PathUtils.isSibling(path, another), false);
    });

    test('below', () {
      Path path = Path([0, 2]);
      Path another = Path([0]);

      expect(PathUtils.isSibling(path, another), false);
    });

    test('equal', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0, 1, 2]);

      expect(PathUtils.isSibling(path, another), false);
    });
  });

  group("levels", () {
    test('success', () {
      Path path = Path([0, 1, 2]);
      List<Path> paths = PathUtils.levels(path);

      expect(PathUtils.equals(paths[0], Path([])), true);
      expect(PathUtils.equals(paths[1], Path([0])), true);
      expect(PathUtils.equals(paths[2], Path([0, 1])), true);
      expect(PathUtils.equals(paths[3], Path([0, 1, 2])), true);
    });

    test('reverse', () {
      Path path = Path([0, 1, 2]);
      List<Path> paths = PathUtils.levels(path, reverse: true);

      expect(PathUtils.equals(paths[0], Path([0, 1, 2])), true);
      expect(PathUtils.equals(paths[1], Path([0, 1])), true);
      expect(PathUtils.equals(paths[2], Path([0])), true);
      expect(PathUtils.equals(paths[3], Path([])), true);
    });
  });

  group("next", () {
    test('success', () {
      Path path = Path([0, 1]);
      Path next = PathUtils.next(path);

      expect(PathUtils.equals(next, Path([0, 2])), true);
    });
  });

  group("parent", () {
    test('success', () {
      Path path = Path([0, 1]);
      Path parent = PathUtils.parent(path);

      expect(PathUtils.equals(parent, Path([0])), true);
    });
  });

  group("previous", () {
    test('success', () {
      Path path = Path([0, 1]);
      Path previous = PathUtils.previous(path);

      expect(PathUtils.equals(previous, Path([0, 0])), true);
    });
  });

  group("relative", () {
    test('grandparent', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0]);

      expect(PathUtils.equals(PathUtils.relative(path, another), Path([1, 2])),
          true);
    });

    test('parent', () {
      Path path = Path([0, 1]);
      Path another = Path([0]);

      expect(
          PathUtils.equals(PathUtils.relative(path, another), Path([1])), true);
    });

    test('root', () {
      Path path = Path([0, 1]);
      Path another = Path([]);

      expect(PathUtils.equals(PathUtils.relative(path, another), Path([0, 1])),
          true);
    });
  });
}
