import 'package:inday/stela/interfaces/location.dart';
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
    List<Point> points = Range.edges(range);
    Point end = points[1];

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

      List<Point> points = Range.edges(range);
      Point rs = points[0];
      Point re = points[1];

      List<Point> targetPoints = Range.edges(target);
      Point ts = targetPoints[0];
      Point te = targetPoints[1];

      return Point.isBefore(rs, ts) && Point.isAfter(re, te);
    }

    List<Point> points = Range.edges(range);
    Point start = points[0];
    Point end = points[1];

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
    List<Point> points = Range.edges(range);
    Point s1 = points[0];
    Point e1 = points[1];

    List<Point> anotherPoints = Range.edges(another);
    Point s2 = anotherPoints[0];
    Point e2 = anotherPoints[1];

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
  static List<PointEntry> points(Range range) {
    return [
      PointEntry(range.anchor, PointType.anchor),
      PointEntry(range.focus, PointType.focus)
    ];
  }

  /// Get the start point of a range.
  static Point start(Range range) {
    List<Point> points = Range.edges(range);
    Point start = points[0];

    return start;
  }

  // /**
  //  * Transform a range by an operation.
  //  */

  // transform(
  //   range: Range,
  //   op: Operation,
  //   options: { affinity: 'forward' | 'backward' | 'outward' | 'inward' | null }
  // ): Range | null {
  //   const { affinity = 'inward' } = options
  //   let affinityAnchor: 'forward' | 'backward' | null
  //   let affinityFocus: 'forward' | 'backward' | null

  //   if (affinity == 'inward') {
  //     if (Range.isForward(range)) {
  //       affinityAnchor = 'forward'
  //       affinityFocus = 'backward'
  //     } else {
  //       affinityAnchor = 'backward'
  //       affinityFocus = 'forward'
  //     }
  //   } else if (affinity == 'outward') {
  //     if (Range.isForward(range)) {
  //       affinityAnchor = 'backward'
  //       affinityFocus = 'forward'
  //     } else {
  //       affinityAnchor = 'forward'
  //       affinityFocus = 'backward'
  //     }
  //   } else {
  //     affinityAnchor = affinity
  //     affinityFocus = affinity
  //   }

  //   return produce(range, r => {
  //     const anchor = Point.transform(r.anchor, op, { affinity: affinityAnchor })
  //     const focus = Point.transform(r.focus, op, { affinity: affinityFocus })

  //     if (!anchor || !focus) {
  //       return null
  //     }

  //     r.anchor = anchor
  //     r.focus = focus
  //   })
  // }
}
