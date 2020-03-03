import 'package:inday/stela/interfaces/location.dart';
import 'package:inday/stela/interfaces/operation.dart';
import 'package:inday/stela/interfaces/path.dart';
import 'package:inday/stela/interfaces/point.dart';

/// `Range` objects are a set of points that refer to a specific span of a Slate
/// document. They can define a span inside a single node or a can span across
/// multiple nodes.
class Range implements Location {
  Range(this.anchor, this.focus);

  Point anchor;
  Point focus;

  /// Get the start and end points of a range, in the order in which they appear
  /// in the document.
  static List<Point> edges(Range range, {bool reverse = false}) {
    Point anchor = range.anchor;
    Point focus = range.focus;

    return Range.isBackward(range) == reverse
        ? [anchor, focus]
        : [focus, anchor];
  }

  /// Get the end point of a range.
  static Point end(Range range) {
    List<Point> edges = Range.edges(range);
    Point end = edges[1];

    return end;
  }

  /// Check if a range is exactly equal to another.
  static bool equals(Range range, Range another) {
    return (Point.equals(range.anchor, another.anchor) &&
        Point.equals(range.focus, another.focus));
  }

  /// Check if a range includes a path, a point or part of another range.
  static bool includes(Range range, Location target) {
    if (target is Range) {
      if (Range.includes(range, target.anchor) ||
          Range.includes(range, target.focus)) {
        return true;
      }

      List<Point> edges = Range.edges(range);
      Point rs = edges[0];
      Point re = edges[1];

      List<Point> targetEdges = Range.edges(target);
      Point ts = targetEdges[0];
      Point te = targetEdges[1];

      return Point.isBefore(rs, ts) && Point.isAfter(re, te);
    }

    List<Point> edges = Range.edges(range);
    Point start = edges[0];
    Point end = edges[1];

    bool isAfterStart = false;
    bool isBeforeEnd = false;

    if (target is Point) {
      isAfterStart = Point.compare(target, start) >= 0;
      isBeforeEnd = Point.compare(target, end) <= 0;
    } else {
      isAfterStart = Path.compare(target, start.path) >= 0;
      isBeforeEnd = Path.compare(target, end.path) <= 0;
    }

    return isAfterStart && isBeforeEnd;
  }

  /// Get the intersection of a range with another.
  static Range intersection(Range range, Range another) {
    List<Point> edges = Range.edges(range);
    Point s1 = edges[0];
    Point e1 = edges[1];

    List<Point> anotherEdges = Range.edges(another);
    Point s2 = anotherEdges[0];
    Point e2 = anotherEdges[1];

    Point start = Point.isBefore(s1, s2) ? s2 : s1;
    Point end = Point.isBefore(e1, e2) ? e1 : e2;

    if (Point.isBefore(end, start)) {
      return null;
    } else {
      return Range(start, end);
    }
  }

  /// Check if a range is backward, meaning that its anchor point appears in the
  /// document _after_ its focus point.
  static bool isBackward(Range range) {
    return Point.isAfter(range.anchor, range.focus);
  }

  /// Check if a range is collapsed, meaning that both its anchor and focus
  /// points refer to the exact same position in the document.
  static bool isCollapsed(Range range) {
    return Point.equals(range.anchor, range.focus);
  }

  /// Check if a range is expanded.
  ///
  /// This is the opposite of [[Range.isCollapsed]] and is provided for legibility.
  static bool isExpanded(Range range) {
    return !Range.isCollapsed(range);
  }

  /// Check if a range is forward.
  ///
  /// This is the opposite of [[Range.isBackward]] and is provided for legibility.
  static bool isForward(Range range) {
    return !Range.isBackward(range);
  }

  /// Check if a value implements the [[Range]] interface.
  static bool isRange(Location location) {
    return location is Range;
  }

  /// Iterate through all of the point entries in a range.
  static Iterable<PointEntry> points(Range range) sync* {
    yield PointEntry(range.anchor, PointType.anchor);
    yield PointEntry(range.focus, PointType.focus);
  }

  /// Get the start point of a range.
  static Point start(Range range) {
    List<Point> edges = Range.edges(range);
    Point start = edges[0];

    return start;
  }

  /// Transform a range by an operation.
  static Range transform(Range range, Operation op,
      {Affinity affinity = Affinity.inward}) {
    Affinity affinityAnchor;
    Affinity affinityFocus;

    if (affinity == Affinity.inward) {
      if (Range.isForward(range)) {
        affinityAnchor = Affinity.forward;
        affinityFocus = Affinity.backward;
      } else {
        affinityAnchor = Affinity.backward;
        affinityFocus = Affinity.forward;
      }
    } else if (affinity == Affinity.outward) {
      if (Range.isForward(range)) {
        affinityAnchor = Affinity.backward;
        affinityFocus = Affinity.forward;
      } else {
        affinityAnchor = Affinity.forward;
        affinityFocus = Affinity.backward;
      }
    } else {
      affinityAnchor = affinity;
      affinityFocus = affinity;
    }

    Range r = Range(range.anchor, range.focus);

    Point anchor = Point.transform(r.anchor, op, affinity: affinityAnchor);
    Point focus = Point.transform(r.focus, op, affinity: affinityFocus);

    if (anchor == null || focus == null) {
      return null;
    }

    r.anchor = anchor;
    r.focus = focus;

    return r;
  }
}

class Decoration extends Range {
  Decoration(Point anchor, Point focus, {props})
      : props = props ?? {},
        super(anchor, focus);

  Map<String, dynamic> props;
}

class Edges {
  Edges(this.start, this.end);

  final Point start;
  final Point end;
}
