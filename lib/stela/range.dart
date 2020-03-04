import 'package:inday/stela/location.dart';
import 'package:inday/stela/operation.dart';
import 'package:inday/stela/path.dart';
import 'package:inday/stela/point.dart';

/// `Range` objects are a set of points that refer to a specific span of a Slate
/// document. They can define a span inside a single node or a can span across
/// multiple nodes.
class Range implements Location {
  Range(this.anchor, this.focus, {this.props = const {}});

  Point anchor;
  Point focus;

  /// Custom properties that can extend the `Range` behavior for e.g. decorations or selections
  Map<String, dynamic> props;
}

class Edges {
  Edges(this.start, this.end);

  final Point start;
  final Point end;
}

class RangeUtils {
  /// Get the start and end points of a range, in the order in which they appear
  /// in the document.
  static Edges edges(Range range, {bool reverse = false}) {
    Point anchor = range.anchor;
    Point focus = range.focus;

    return RangeUtils.isBackward(range) == reverse
        ? Edges(anchor, focus)
        : Edges(focus, anchor);
  }

  /// Get the end point of a range.
  static Point end(Range range) {
    Edges edges = RangeUtils.edges(range);
    Point end = edges.end;

    return end;
  }

  /// Check if a range is exactly equal to another.
  static bool equals(Range range, Range another) {
    return (PointUtils.equals(range.anchor, another.anchor) &&
        PointUtils.equals(range.focus, another.focus));
  }

  /// Check if a range includes a path, a point or part of another range.
  static bool includes(Range range, Location target) {
    if (target is Range) {
      if (RangeUtils.includes(range, target.anchor) ||
          RangeUtils.includes(range, target.focus)) {
        return true;
      }

      Edges edges = RangeUtils.edges(range);
      Point rs = edges.start;
      Point re = edges.end;

      Edges targetEdges = RangeUtils.edges(target);
      Point ts = targetEdges.start;
      Point te = targetEdges.end;

      return PointUtils.isBefore(rs, ts) && PointUtils.isAfter(re, te);
    }

    Edges edges = RangeUtils.edges(range);
    Point start = edges.start;
    Point end = edges.end;

    bool isAfterStart = false;
    bool isBeforeEnd = false;

    if (target is Point) {
      isAfterStart = PointUtils.compare(target, start) >= 0;
      isBeforeEnd = PointUtils.compare(target, end) <= 0;
    } else {
      isAfterStart = PathUtils.compare(target, start.path) >= 0;
      isBeforeEnd = PathUtils.compare(target, end.path) <= 0;
    }

    return isAfterStart && isBeforeEnd;
  }

  /// Get the intersection of a range with another.
  static Range intersection(Range range, Range another) {
    Edges edges = RangeUtils.edges(range);
    Point s1 = edges.start;
    Point e1 = edges.end;

    Edges anotherEdges = RangeUtils.edges(another);
    Point s2 = anotherEdges.start;
    Point e2 = anotherEdges.end;

    Point start = PointUtils.isBefore(s1, s2) ? s2 : s1;
    Point end = PointUtils.isBefore(e1, e2) ? e1 : e2;

    if (PointUtils.isBefore(end, start)) {
      return null;
    } else {
      return Range(start, end);
    }
  }

  /// Check if a range is backward, meaning that its anchor point appears in the
  /// document _after_ its focus point.
  static bool isBackward(Range range) {
    return PointUtils.isAfter(range.anchor, range.focus);
  }

  /// Check if a range is collapsed, meaning that both its anchor and focus
  /// points refer to the exact same position in the document.
  static bool isCollapsed(Range range) {
    return PointUtils.equals(range.anchor, range.focus);
  }

  /// Check if a range is expanded.
  ///
  /// This is the opposite of [[RangeUtils.isCollapsed]] and is provided for legibility.
  static bool isExpanded(Range range) {
    return !RangeUtils.isCollapsed(range);
  }

  /// Check if a range is forward.
  ///
  /// This is the opposite of [[RangeUtils.isBackward]] and is provided for legibility.
  static bool isForward(Range range) {
    return !RangeUtils.isBackward(range);
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
    Edges edges = RangeUtils.edges(range);
    Point start = edges.start;

    return start;
  }

  /// Transform a range by an operation.
  static Range transform(Range range, Operation op,
      {Affinity affinity = Affinity.inward}) {
    Affinity affinityAnchor;
    Affinity affinityFocus;

    if (affinity == Affinity.inward) {
      if (RangeUtils.isForward(range)) {
        affinityAnchor = Affinity.forward;
        affinityFocus = Affinity.backward;
      } else {
        affinityAnchor = Affinity.backward;
        affinityFocus = Affinity.forward;
      }
    } else if (affinity == Affinity.outward) {
      if (RangeUtils.isForward(range)) {
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

    Point anchor = PointUtils.transform(r.anchor, op, affinity: affinityAnchor);
    Point focus = PointUtils.transform(r.focus, op, affinity: affinityFocus);

    if (anchor == null || focus == null) {
      return null;
    }

    r.anchor = anchor;
    r.focus = focus;

    return r;
  }
}
