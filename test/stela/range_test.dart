import 'package:flutter_test/flutter_test.dart';
import 'package:inday/stela/path.dart';
import 'package:inday/stela/point.dart';
import 'package:inday/stela/range.dart';

void main() {
  group('edges', () {
    test('backward', () {
      Point anchor = Point(Path([3]), 0);
      Point focus = Point(Path([0]), 0);
      Range range = Range(anchor, focus);

      Edges edges = range.edges();
      Point start = edges.start;
      Point end = edges.end;

      expect(focus.equals(start), true);
      expect(anchor.equals(end), true);
    });

    test('collapsed', () {
      Point anchor = Point(Path([0]), 0);
      Point focus = Point(Path([0]), 0);
      Range range = Range(anchor, focus);

      Edges edges = range.edges();
      Point start = edges.start;
      Point end = edges.end;

      expect(anchor.equals(start), true);
      expect(focus.equals(end), true);
    });

    test('forward', () {
      Point anchor = Point(Path([0]), 0);
      Point focus = Point(Path([3]), 0);
      Range range = Range(anchor, focus);

      Edges edges = range.edges();
      Point start = edges.start;
      Point end = edges.end;

      expect(anchor.equals(start), true);
      expect(focus.equals(end), true);
    });
  });

  group('equals', () {
    test('equal', () {
      Point anchor = Point(Path([0, 1]), 0);
      Point focus = Point(Path([0, 1]), 0);
      Range range = Range(anchor, focus);

      Point anotherAnchor = Point(Path([0, 1]), 0);
      Point anotherFocus = Point(Path([0, 1]), 0);
      Range another = Range(anotherAnchor, anotherFocus);

      expect(range.equals(another), true);
    });

    test('not equal', () {
      Point anchor = Point(Path([0, 4]), 7);
      Point focus = Point(Path([0, 4]), 7);
      Range range = Range(anchor, focus);

      Point anotherAnchor = Point(Path([0, 1]), 0);
      Point anotherFocus = Point(Path([0, 1]), 0);
      Range another = Range(anotherAnchor, anotherFocus);

      expect(range.equals(another), false);
    });
  });

  group('includes', () {
    test('path after', () {
      Point anchor = Point(Path([1]), 0);
      Point focus = Point(Path([3]), 0);
      Range range = Range(anchor, focus);

      Path path = Path([4]);

      expect(range.includes(path), false);
    });

    test('path before', () {
      Point anchor = Point(Path([1]), 0);
      Point focus = Point(Path([3]), 0);
      Range range = Range(anchor, focus);

      Path target = Path([0]);

      expect(range.includes(target), false);
    });

    test('path end', () {
      Point anchor = Point(Path([1]), 0);
      Point focus = Point(Path([3]), 0);
      Range range = Range(anchor, focus);

      Path target = Path([3]);

      expect(range.includes(target), true);
    });

    test('path inside', () {
      Point anchor = Point(Path([1]), 0);
      Point focus = Point(Path([3]), 0);
      Range range = Range(anchor, focus);

      Path target = Path([2]);

      expect(range.includes(target), true);
    });

    test('path inside', () {
      Point anchor = Point(Path([1]), 0);
      Point focus = Point(Path([3]), 0);
      Range range = Range(anchor, focus);

      Path target = Path([1]);

      expect(range.includes(target), true);
    });

    test('point end', () {
      Point anchor = Point(Path([1]), 0);
      Point focus = Point(Path([3]), 0);
      Range range = Range(anchor, focus);

      Point target = Point(Path([3]), 0);

      expect(range.includes(target), true);
    });

    test('point inside', () {
      Point anchor = Point(Path([1]), 0);
      Point focus = Point(Path([3]), 0);
      Range range = Range(anchor, focus);

      Point target = Point(Path([2]), 0);

      expect(range.includes(target), true);
    });

    test('point offset after', () {
      Point anchor = Point(Path([1]), 0);
      Point focus = Point(Path([3]), 0);
      Range range = Range(anchor, focus);

      Point target = Point(Path([3]), 3);

      expect(range.includes(target), false);
    });

    test('point offset after', () {
      Point anchor = Point(Path([1]), 3);
      Point focus = Point(Path([3]), 0);
      Range range = Range(anchor, focus);

      Point target = Point(Path([1]), 0);

      expect(range.includes(target), false);
    });

    test('point path after', () {
      Point anchor = Point(Path([1]), 0);
      Point focus = Point(Path([3]), 0);
      Range range = Range(anchor, focus);

      Point target = Point(Path([4]), 0);

      expect(range.includes(target), false);
    });

    test('point path before', () {
      Point anchor = Point(Path([1]), 0);
      Point focus = Point(Path([3]), 0);
      Range range = Range(anchor, focus);

      Point target = Point(Path([0]), 0);

      expect(range.includes(target), false);
    });

    test('point start', () {
      Point anchor = Point(Path([1]), 0);
      Point focus = Point(Path([3]), 0);
      Range range = Range(anchor, focus);

      Point target = Point(Path([1]), 0);

      expect(range.includes(target), true);
    });
  });

  group('isBackward', () {
    test('backward', () {
      Point anchor = Point(Path([3]), 0);
      Point focus = Point(Path([0]), 0);
      Range range = Range(anchor, focus);

      expect(range.isBackward, true);
    });

    test('collapsed', () {
      Point anchor = Point(Path([0]), 0);
      Point focus = Point(Path([0]), 0);
      Range range = Range(anchor, focus);

      expect(range.isBackward, false);
    });

    test('collapsed', () {
      Point anchor = Point(Path([0]), 0);
      Point focus = Point(Path([3]), 0);
      Range range = Range(anchor, focus);

      expect(range.isBackward, false);
    });
  });

  group('isCollapsed', () {
    test('collapsed', () {
      Point anchor = Point(Path([0]), 0);
      Point focus = Point(Path([0]), 0);
      Range range = Range(anchor, focus);

      expect(range.isCollapsed, true);
    });

    test('expanded', () {
      Point anchor = Point(Path([0]), 0);
      Point focus = Point(Path([3]), 0);
      Range range = Range(anchor, focus);

      expect(range.isCollapsed, false);
    });
  });

  group('isExpanded', () {
    test('collapsed', () {
      Point anchor = Point(Path([0]), 0);
      Point focus = Point(Path([0]), 0);
      Range range = Range(anchor, focus);

      expect(range.isExpanded, false);
    });

    test('expanded', () {
      Point anchor = Point(Path([0]), 0);
      Point focus = Point(Path([3]), 0);
      Range range = Range(anchor, focus);

      expect(range.isExpanded, true);
    });
  });

  group('isForward', () {
    test('backward', () {
      Point anchor = Point(Path([3]), 0);
      Point focus = Point(Path([0]), 0);
      Range range = Range(anchor, focus);

      expect(range.isForward, false);
    });

    test('collapsed', () {
      Point anchor = Point(Path([0]), 0);
      Point focus = Point(Path([0]), 0);
      Range range = Range(anchor, focus);

      expect(range.isForward, true);
    });

    test('collapsed', () {
      Point anchor = Point(Path([0]), 0);
      Point focus = Point(Path([3]), 0);
      Range range = Range(anchor, focus);

      expect(range.isForward, true);
    });
  });

  group('points', () {
    test('full selection', () {
      Point anchor = Point(Path([3]), 0);
      Point focus = Point(Path([0]), 0);
      Range range = Range(anchor, focus);

      List<PointEntry> pointEntries = List<PointEntry>.from(range.points());
      PointEntry p1 = pointEntries[0];
      PointEntry p2 = pointEntries[1];

      expect(p1.point == anchor, true);
      expect(p1.type == PointType.anchor, true);

      expect(p2.point == focus, true);
      expect(p2.type == PointType.focus, true);
    });
  });
}
