import 'package:flutter_test/flutter_test.dart';
import 'package:inday/stela/path.dart';

void main() {
  group('ancestors', () {
    test(
        'should return valid list of paths from furthest to nearest ancestor, excluding itself',
        () {
      Path path = Path([0, 1, 2]);
      List<Path> paths = path.ancestors();

      expect(paths[0].equals(Path([])), true);
      expect(paths[1].equals(Path([0])), true);
      expect(paths[2].equals(Path([0, 1])), true);
    });

    test(
        'should return valid list of paths from nearest to furthest ancestor when given reverse option, excluding itself',
        () {
      Path path = Path([0, 1, 2]);
      List<Path> paths = path.ancestors(reverse: true);

      expect(paths[0].equals(Path([0, 1])), true);
      expect(paths[1].equals(Path([0])), true);
      expect(paths[2].equals(Path([])), true);
    });
  });

  group('common', () {
    test('should return equal ancestor path both when both paths are the same',
        () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0, 1, 2]);

      expect(path.common(another).equals(Path([0, 1, 2])), true);
    });

    test('should return root when two paths are completely different', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([3, 2]);

      expect(path.common(another).equals(Path([])), true);
    });

    test('should ancestor path correctly', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0, 2]);

      expect(path.common(another).equals(Path([0])), true);
    });
  });

  group('compare', () {
    test('above', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0]);

      expect(path.compare(another), 0);
    });

    test('after', () {
      Path path = Path([1, 1, 2]);
      Path another = Path([0]);

      expect(path.compare(another), 1);
    });

    test('before', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([1]);

      expect(path.compare(another), -1);
    });

    test('below', () {
      Path path = Path([0]);
      Path another = Path([0, 1]);

      expect(path.compare(another), 0);
    });

    test('equal', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0, 1, 2]);

      expect(path.compare(another), 0);
    });

    test('root', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([]);

      expect(path.compare(another), 0);
    });
  });

  group('endsAfter', () {
    test('above', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0]);

      expect(path.endsAfter(another), false);
    });

    test('after', () {
      Path path = Path([1, 1, 2]);
      Path another = Path([0]);

      expect(path.endsAfter(another), false);
    });

    test('before', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([1]);

      expect(path.endsAfter(another), false);
    });

    test('below', () {
      Path path = Path([0]);
      Path another = Path([0, 1]);

      expect(path.endsAfter(another), false);
    });

    test('ends after', () {
      Path path = Path([1]);
      Path another = Path([0, 2]);

      expect(path.endsAfter(another), true);
    });

    test('ends at', () {
      Path path = Path([0]);
      Path another = Path([0, 2]);

      expect(path.endsAfter(another), false);
    });

    test('ends before', () {
      Path path = Path([0]);
      Path another = Path([1, 2]);

      expect(path.endsAfter(another), false);
    });

    test('equal', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0, 1, 2]);

      expect(path.endsAfter(another), false);
    });

    test('root', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([]);

      expect(path.endsAfter(another), false);
    });
  });

  group('endsAt', () {
    test('above', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0]);

      expect(path.endsAt(another), false);
    });

    test('after', () {
      Path path = Path([1, 1, 2]);
      Path another = Path([0]);

      expect(path.endsAt(another), false);
    });

    test('before', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([1]);

      expect(path.endsAt(another), false);
    });

    test('ends after', () {
      Path path = Path([1]);
      Path another = Path([0, 2]);

      expect(path.endsAt(another), false);
    });

    test('ends at', () {
      Path path = Path([0]);
      Path another = Path([0, 2]);

      expect(path.endsAt(another), true);
    });

    test('ends before', () {
      Path path = Path([0]);
      Path another = Path([1, 2]);

      expect(path.endsAt(another), false);
    });

    test('equal', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0, 1, 2]);

      expect(path.endsAt(another), true);
    });

    test('root', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([]);

      expect(path.endsAt(another), false);
    });
  });

  group('endsBefore', () {
    test('above', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0]);

      expect(path.endsBefore(another), false);
    });

    test('after', () {
      Path path = Path([1, 1, 2]);
      Path another = Path([0]);

      expect(path.endsBefore(another), false);
    });

    test('before', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([1]);

      expect(path.endsBefore(another), false);
    });

    test('below', () {
      Path path = Path([0]);
      Path another = Path([0, 1]);

      expect(path.endsAfter(another), false);
    });

    test('ends after', () {
      Path path = Path([1]);
      Path another = Path([0, 2]);

      expect(path.endsBefore(another), false);
    });

    test('ends at', () {
      Path path = Path([0]);
      Path another = Path([0, 2]);

      expect(path.endsBefore(another), false);
    });

    test('ends before', () {
      Path path = Path([0]);
      Path another = Path([1, 2]);

      expect(path.endsBefore(another), true);
    });

    test('equal', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0, 1, 2]);

      expect(path.endsBefore(another), false);
    });

    test('root', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([]);

      expect(path.endsBefore(another), false);
    });
  });

  group('equals', () {
    test('above', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0]);

      expect(path.equals(another), false);
    });

    test('after', () {
      Path path = Path([1, 1, 2]);
      Path another = Path([0]);

      expect(path.equals(another), false);
    });

    test('before', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([1]);

      expect(path.equals(another), false);
    });

    test('below', () {
      Path path = Path([0]);
      Path another = Path([0, 1]);

      expect(path.equals(another), false);
    });

    test('equal', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0, 1, 2]);

      expect(path.equals(another), true);
    });

    test('root', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([]);

      expect(path.equals(another), false);
    });
  });

  group('isAfter', () {
    test('above', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0]);

      expect(path.isAfter(another), false);
    });

    test('after', () {
      Path path = Path([1, 1, 2]);
      Path another = Path([0]);

      expect(path.isAfter(another), true);
    });

    test('before', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([1]);

      expect(path.isAfter(another), false);
    });

    test('below', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0]);

      expect(path.isAfter(another), false);
    });

    test('equal', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0, 1, 2]);

      expect(path.isAfter(another), false);
    });

    test('root', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([]);

      expect(path.isAfter(another), false);
    });
  });

  group('isAncestor', () {
    test('above grandparent', () {
      Path path = Path([]);
      Path another = Path([0, 1]);

      expect(path.isAncestor(another), true);
    });

    test('above parent', () {
      Path path = Path([]);
      Path another = Path([0, 1]);

      expect(path.isAncestor(another), true);
    });

    test('after', () {
      Path path = Path([1, 1, 2]);
      Path another = Path([0]);

      expect(path.isAncestor(another), false);
    });

    test('before', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([1]);

      expect(path.isAncestor(another), false);
    });

    test('below', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0]);

      expect(path.isAncestor(another), false);
    });

    test('equal', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0, 1, 2]);

      expect(path.isAncestor(another), false);
    });
  });

  group('isBefore', () {
    test('above', () {
      Path path = Path([0]);
      Path another = Path([0, 1]);

      expect(path.isBefore(another), false);
    });

    test('after', () {
      Path path = Path([1, 1, 2]);
      Path another = Path([0]);

      expect(path.isBefore(another), false);
    });

    test('before', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([1]);

      expect(path.isBefore(another), true);
    });

    test('below', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0]);

      expect(path.isBefore(another), false);
    });

    test('equal', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0, 1, 2]);

      expect(path.isBefore(another), false);
    });
  });

  group('isChild', () {
    test('above', () {
      Path path = Path([0]);
      Path another = Path([0, 1]);

      expect(path.isChild(another), false);
    });

    test('after', () {
      Path path = Path([1, 1, 2]);
      Path another = Path([0]);

      expect(path.isChild(another), false);
    });

    test('before', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([1]);

      expect(path.isChild(another), false);
    });

    test('below child', () {
      Path path = Path([0, 1]);
      Path another = Path([0]);

      expect(path.isChild(another), true);
    });

    test('below grandchild', () {
      Path path = Path([0, 1]);
      Path another = Path([]);

      expect(path.isChild(another), false);
    });

    test('equal', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0, 1, 2]);

      expect(path.isChild(another), false);
    });
  });

  group('isDescendant', () {
    test('above', () {
      Path path = Path([0]);
      Path another = Path([0, 1]);

      expect(path.isDescendant(another), false);
    });

    test('after', () {
      Path path = Path([1, 1, 2]);
      Path another = Path([0]);

      expect(path.isDescendant(another), false);
    });

    test('before', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([1]);

      expect(path.isDescendant(another), false);
    });

    test('below child', () {
      Path path = Path([0, 1]);
      Path another = Path([0]);

      expect(path.isDescendant(another), true);
    });

    test('below grandchild', () {
      Path path = Path([0, 1]);
      Path another = Path([]);

      expect(path.isDescendant(another), true);
    });

    test('equal', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0, 1, 2]);

      expect(path.isDescendant(another), false);
    });
  });

  group('isParent', () {
    test('above grandparent', () {
      Path path = Path([]);
      Path another = Path([0, 1]);

      expect(path.isParent(another), false);
    });

    test('above parent', () {
      Path path = Path([0]);
      Path another = Path([0, 1]);

      expect(path.isParent(another), true);
    });

    test('after', () {
      Path path = Path([1, 1, 2]);
      Path another = Path([0]);

      expect(path.isParent(another), false);
    });

    test('before', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([1]);

      expect(path.isParent(another), false);
    });

    test('below', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0]);

      expect(path.isParent(another), false);
    });

    test('equal', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0, 1, 2]);

      expect(path.isParent(another), false);
    });
  });

  group('isSibling', () {
    test('above', () {
      Path path = Path([]);
      Path another = Path([0, 1]);

      expect(path.isSibling(another), false);
    });

    test('after sibling', () {
      Path path = Path([1, 4]);
      Path another = Path([1, 2]);

      expect(path.isSibling(another), true);
    });

    test('after', () {
      Path path = Path([1, 2]);
      Path another = Path([0]);

      expect(path.isSibling(another), false);
    });

    test('before sibling', () {
      Path path = Path([0, 1]);
      Path another = Path([0, 3]);

      expect(path.isSibling(another), true);
    });

    test('before', () {
      Path path = Path([0, 2]);
      Path another = Path([1]);

      expect(path.isSibling(another), false);
    });

    test('below', () {
      Path path = Path([0, 2]);
      Path another = Path([0]);

      expect(path.isSibling(another), false);
    });

    test('equal', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0, 1, 2]);

      expect(path.isSibling(another), false);
    });
  });

  group('levels', () {
    test('success', () {
      Path path = Path([0, 1, 2]);
      List<Path> paths = path.levels();

      expect(paths[0].equals(Path([])), true);
      expect(paths[1].equals(Path([0])), true);
      expect(paths[2].equals(Path([0, 1])), true);
      expect(paths[3].equals(Path([0, 1, 2])), true);
    });

    test('reverse', () {
      Path path = Path([0, 1, 2]);
      List<Path> paths = path.levels(reverse: true);

      expect(paths[0].equals(Path([0, 1, 2])), true);
      expect(paths[1].equals(Path([0, 1])), true);
      expect(paths[2].equals(Path([0])), true);
      expect(paths[3].equals(Path([])), true);
    });
  });

  group('next', () {
    test('success', () {
      Path path = Path([0, 1]);
      expect(path.next.equals(Path([0, 2])), true);
    });
  });

  group('parent', () {
    test('success', () {
      Path path = Path([0, 1]);

      expect(path.parent.equals(Path([0])), true);
    });
  });

  group('previous', () {
    test('success', () {
      Path path = Path([0, 1]);

      expect(path.previous.equals(Path([0, 0])), true);
    });
  });

  group('relative', () {
    test('grandparent', () {
      Path path = Path([0, 1, 2]);
      Path another = Path([0]);

      expect(path.relative(another).equals(Path([1, 2])), true);
    });

    test('parent', () {
      Path path = Path([0, 1]);
      Path another = Path([0]);

      expect(path.relative(another).equals(Path([1])), true);
    });

    test('root', () {
      Path path = Path([0, 1]);
      Path another = Path([]);

      expect(path.relative(another).equals(Path([0, 1])), true);
    });
  });
}
