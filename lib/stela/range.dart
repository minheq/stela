import 'package:inday/stela/location.dart';
import 'package:inday/stela/operation.dart';
import 'package:inday/stela/path.dart';
import 'package:inday/stela/point.dart';

/// `Range` objects are a set of points that refer to a specific span of a Slate
/// document. They can define a span inside a single node or a can span across
/// multiple nodes.
class Range implements Location {
  Range(this.anchor, this.focus, {Map<String, dynamic> props})
      : props = props ?? {};

  Point anchor;
  Point focus;

  /// Custom properties that can extend the `Range` behavior for e.g. decorations or selections
  Map<String, dynamic> props;

  @override
  String toString() {
    return "Range(${anchor.toString()}, ${focus.toString()})";
  }

  /// Get the start and end points of a range, in the order in which they appear
  /// in the document.
  Edges edges({bool reverse = false}) {
    return isBackward == reverse ? Edges(anchor, focus) : Edges(focus, anchor);
  }

  /// Get the end point of a
  Point get end {
    Point end = edges().end;

    return end;
  }

  /// Check if a range is exactly equal to another.
  bool equals(Range another) {
    return (PointUtils.equals(anchor, another.anchor) &&
        PointUtils.equals(focus, another.focus));
  }

  /// Check if a range includes a path, a point or part of another
  bool includes(Location target) {
    if (target is Range) {
      if (includes(target.anchor) || includes(target.focus)) {
        return true;
      }

      Point rs = edges().start;
      Point re = edges().end;

      Edges targetEdges = target.edges();
      Point ts = targetEdges.start;
      Point te = targetEdges.end;

      return PointUtils.isBefore(rs, ts) && PointUtils.isAfter(re, te);
    }

    Point start = edges().start;
    Point end = edges().end;

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
  Range intersection(Range another) {
    Point s1 = edges().start;
    Point e1 = edges().end;

    Edges anotherEdges = another.edges();
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
  bool get isBackward {
    return PointUtils.isAfter(anchor, focus);
  }

  /// Check if a range is collapsed, meaning that both its anchor and focus
  /// points refer to the exact same position in the document.
  bool get isCollapsed {
    return PointUtils.equals(anchor, focus);
  }

  /// Check if a range is expanded.
  ///
  /// This is the opposite of [[isCollapsed]] and is provided for legibility.
  bool get isExpanded {
    return !isCollapsed;
  }

  /// Check if a range is forward.
  ///
  /// This is the opposite of [[isBackward]] and is provided for legibility.
  bool get isForward {
    return !isBackward;
  }

  /// Iterate through all of the point entries in a
  Iterable<PointEntry> points() sync* {
    yield PointEntry(anchor, PointType.anchor);
    yield PointEntry(focus, PointType.focus);
  }

  /// Get the start point of a
  Point get start {
    return edges().start;
  }

  /// Transform a range by an operation.
  Range transform(Operation op, {Affinity affinity = Affinity.inward}) {
    Affinity affinityAnchor;
    Affinity affinityFocus;

    if (affinity == Affinity.inward) {
      if (isForward) {
        affinityAnchor = Affinity.forward;
        affinityFocus = Affinity.backward;
      } else {
        affinityAnchor = Affinity.backward;
        affinityFocus = Affinity.forward;
      }
    } else if (affinity == Affinity.outward) {
      if (isForward) {
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

    Range next = Range(anchor, focus);

    Point nextAnchor =
        PointUtils.transform(next.anchor, op, affinity: affinityAnchor);
    Point nextFocus =
        PointUtils.transform(next.focus, op, affinity: affinityFocus);

    if (nextAnchor == null || nextFocus == null) {
      return null;
    }

    next.anchor = nextAnchor;
    next.focus = nextFocus;

    return next;
  }
}

class Edges {
  Edges(this.start, this.end);

  final Point start;
  final Point end;
}

/// `RangeRef` objects keep a specific range in a document synced over time as new
/// operations are applied to the editor. You can access their `current` property
/// at any time for the up-to-date range value.
class RangeRef {
  RangeRef({this.current, this.affinity});

  Range current;
  Affinity affinity;

  Range unref(Set<RangeRef> rangeRefs) {
    Range _current = current;
    rangeRefs.remove(this);
    current = null;

    return _current;
  }

  /// Transform the range ref's current value by an operation.
  static Range transform(Set<RangeRef> rangeRefs, RangeRef ref, Operation op) {
    if (ref.current == null) {
      return null;
    }

    Range range = ref.current.transform(op, affinity: ref.affinity);
    ref.current = range;

    return range;
  }
}
