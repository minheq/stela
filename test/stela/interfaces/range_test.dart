import 'package:flutter_test/flutter_test.dart';
import 'package:inday/stela/interfaces/path.dart';
import 'package:inday/stela/interfaces/point.dart';
import 'package:inday/stela/interfaces/range.dart';

void main() {
  group("edges", () {
    test('backward', () {
      Point anchor = Point(Path([3]), 0);
      Point focus = Point(Path([0]), 0);
      Range range = Range(anchor, focus);

      Edges edges = RangeUtils.edges(range);
      Point start = edges.start;
      Point end = edges.end;

      expect(PointUtils.equals(focus, start), true);
      expect(PointUtils.equals(anchor, end), true);
    });

    test('collapsed', () {
      Point anchor = Point(Path([0]), 0);
      Point focus = Point(Path([0]), 0);
      Range range = Range(anchor, focus);

      Edges edges = RangeUtils.edges(range);
      Point start = edges.start;
      Point end = edges.end;

      expect(PointUtils.equals(anchor, start), true);
      expect(PointUtils.equals(focus, end), true);
    });

    test('forward', () {
      Point anchor = Point(Path([0]), 0);
      Point focus = Point(Path([3]), 0);
      Range range = Range(anchor, focus);

      Edges edges = RangeUtils.edges(range);
      Point start = edges.start;
      Point end = edges.end;

      expect(PointUtils.equals(anchor, start), true);
      expect(PointUtils.equals(focus, end), true);
    });
  });

  group("equals", () {
    test('equal', () {
      Point anchor = Point(Path([0, 1]), 0);
      Point focus = Point(Path([0, 1]), 0);
      Range range = Range(anchor, focus);

      Point anotherAnchor = Point(Path([0, 1]), 0);
      Point anotherFocus = Point(Path([0, 1]), 0);
      Range another = Range(anotherAnchor, anotherFocus);

      expect(RangeUtils.equals(range, another), true);
    });

    test('not equal', () {
      Point anchor = Point(Path([0, 4]), 7);
      Point focus = Point(Path([0, 4]), 7);
      Range range = Range(anchor, focus);

      Point anotherAnchor = Point(Path([0, 1]), 0);
      Point anotherFocus = Point(Path([0, 1]), 0);
      Range another = Range(anotherAnchor, anotherFocus);

      expect(RangeUtils.equals(range, another), false);
    });
  });

  group("includes", () {
    test('path after', () {
      Point anchor = Point(Path([1]), 0);
      Point focus = Point(Path([3]), 0);
      Range range = Range(anchor, focus);

      Path path = Path([4]);

      expect(RangeUtils.includes(range, path), false);
    });

    test('path before', () {
      Point anchor = Point(Path([1]), 0);
      Point focus = Point(Path([3]), 0);
      Range range = Range(anchor, focus);

      Path target = Path([0]);

      expect(RangeUtils.includes(range, target), false);
    });

    test('path end', () {
      Point anchor = Point(Path([1]), 0);
      Point focus = Point(Path([3]), 0);
      Range range = Range(anchor, focus);

      Path target = Path([3]);

      expect(RangeUtils.includes(range, target), true);
    });

    test('path inside', () {
      Point anchor = Point(Path([1]), 0);
      Point focus = Point(Path([3]), 0);
      Range range = Range(anchor, focus);

      Path target = Path([2]);

      expect(RangeUtils.includes(range, target), true);
    });

    test('path inside', () {
      Point anchor = Point(Path([1]), 0);
      Point focus = Point(Path([3]), 0);
      Range range = Range(anchor, focus);

      Path target = Path([1]);

      expect(RangeUtils.includes(range, target), true);
    });

    test('point end', () {
      Point anchor = Point(Path([1]), 0);
      Point focus = Point(Path([3]), 0);
      Range range = Range(anchor, focus);

      Point target = Point(Path([3]), 0);

      expect(RangeUtils.includes(range, target), true);
    });

    test('point inside', () {
      Point anchor = Point(Path([1]), 0);
      Point focus = Point(Path([3]), 0);
      Range range = Range(anchor, focus);

      Point target = Point(Path([2]), 0);

      expect(RangeUtils.includes(range, target), true);
    });

    test('point offset after', () {
      Point anchor = Point(Path([1]), 0);
      Point focus = Point(Path([3]), 0);
      Range range = Range(anchor, focus);

      Point target = Point(Path([3]), 3);

      expect(RangeUtils.includes(range, target), false);
    });

    test('point offset after', () {
      Point anchor = Point(Path([1]), 3);
      Point focus = Point(Path([3]), 0);
      Range range = Range(anchor, focus);

      Point target = Point(Path([1]), 0);

      expect(RangeUtils.includes(range, target), false);
    });

    test('point path after', () {
      Point anchor = Point(Path([1]), 0);
      Point focus = Point(Path([3]), 0);
      Range range = Range(anchor, focus);

      Point target = Point(Path([4]), 0);

      expect(RangeUtils.includes(range, target), false);
    });

    test('point path before', () {
      Point anchor = Point(Path([1]), 0);
      Point focus = Point(Path([3]), 0);
      Range range = Range(anchor, focus);

      Point target = Point(Path([0]), 0);

      expect(RangeUtils.includes(range, target), false);
    });

    test('point start', () {
      Point anchor = Point(Path([1]), 0);
      Point focus = Point(Path([3]), 0);
      Range range = Range(anchor, focus);

      Point target = Point(Path([1]), 0);

      expect(RangeUtils.includes(range, target), true);
    });
  });

  group("isBackward", () {
    test('backward', () {
      Point anchor = Point(Path([3]), 0);
      Point focus = Point(Path([0]), 0);
      Range range = Range(anchor, focus);

      expect(RangeUtils.isBackward(range), true);
    });

    test('collapsed', () {
      Point anchor = Point(Path([0]), 0);
      Point focus = Point(Path([0]), 0);
      Range range = Range(anchor, focus);

      expect(RangeUtils.isBackward(range), false);
    });

    test('collapsed', () {
      Point anchor = Point(Path([0]), 0);
      Point focus = Point(Path([3]), 0);
      Range range = Range(anchor, focus);

      expect(RangeUtils.isBackward(range), false);
    });
  });

  group("isCollapsed", () {
    test('collapsed', () {
      Point anchor = Point(Path([0]), 0);
      Point focus = Point(Path([0]), 0);
      Range range = Range(anchor, focus);

      expect(RangeUtils.isCollapsed(range), true);
    });

    test('expanded', () {
      Point anchor = Point(Path([0]), 0);
      Point focus = Point(Path([3]), 0);
      Range range = Range(anchor, focus);

      expect(RangeUtils.isCollapsed(range), false);
    });
  });

  group("isExpanded", () {
    test('collapsed', () {
      Point anchor = Point(Path([0]), 0);
      Point focus = Point(Path([0]), 0);
      Range range = Range(anchor, focus);

      expect(RangeUtils.isExpanded(range), false);
    });

    test('expanded', () {
      Point anchor = Point(Path([0]), 0);
      Point focus = Point(Path([3]), 0);
      Range range = Range(anchor, focus);

      expect(RangeUtils.isExpanded(range), true);
    });
  });

  group("isForward", () {
    test('backward', () {
      Point anchor = Point(Path([3]), 0);
      Point focus = Point(Path([0]), 0);
      Range range = Range(anchor, focus);

      expect(RangeUtils.isForward(range), false);
    });

    test('collapsed', () {
      Point anchor = Point(Path([0]), 0);
      Point focus = Point(Path([0]), 0);
      Range range = Range(anchor, focus);

      expect(RangeUtils.isForward(range), true);
    });

    test('collapsed', () {
      Point anchor = Point(Path([0]), 0);
      Point focus = Point(Path([3]), 0);
      Range range = Range(anchor, focus);

      expect(RangeUtils.isForward(range), true);
    });
  });

  group("points", () {
    test('full selection', () {
      Point anchor = Point(Path([3]), 0);
      Point focus = Point(Path([0]), 0);
      Range range = Range(anchor, focus);

      List<PointEntry> pointEntries =
          List<PointEntry>.from(RangeUtils.points(range));
      PointEntry p1 = pointEntries[0];
      PointEntry p2 = pointEntries[1];

      expect(p1.point == anchor, true);
      expect(p1.type == PointType.anchor, true);

      expect(p2.point == focus, true);
      expect(p2.type == PointType.focus, true);
    });
  });
}
