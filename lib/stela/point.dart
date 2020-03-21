import 'dart:math';

import 'package:inday/stela/location.dart';
import 'package:inday/stela/operation.dart';
import 'package:inday/stela/path.dart';

/// `Point` objects refer to a specific location in a text node in a Slate
/// document. Its path refers to the location of the node in the tree, and its
/// offset refers to the distance into the node's string of text. Points can
/// only refer to `Text` nodes.
class Point implements Location {
  Point(this.path, this.offset, {Map<String, dynamic> props})
      : props = props ?? {};

  Path path;
  int offset;

  /// Custom properties that can extend the `Point` behavior
  Map<String, dynamic> props;

  @override
  String toString() {
    return "Point(${path.toString()}, $offset)";
  }

  /// Compare a point to another, returning an integer indicating whether the
  /// point was before (-1), at (0), or after (1) the other.
  int compare(Point another) {
    int result = path.compare(another.path);

    if (result == 0) {
      if (offset < another.offset) return -1;
      if (offset > another.offset) return 1;
      return 0;
    }

    return result;
  }

  /// Check if a point is exactly equal to another.
  bool equals(Point another) {
    // PERF: ensure the offsets are equal first since they are cheaper to check.
    if (another == null) {
      return false;
    }

    return (offset == another.offset && path.equals(another.path));
  }

  /// Check if a point is after another.
  bool isAfter(Point another) {
    return compare(another) == 1;
  }

  /// Check if a point is before another.
  bool isBefore(Point another) {
    return compare(another) == -1;
  }

  /// Transform a point by an operation.
  Point transform(Operation op, {Affinity affinity = Affinity.forward}) {
    Point next = Point(path, offset);
    Path nextPath = next.path;
    int nextOffset = next.offset;

    if (op is InsertNodeOperation || op is MoveNodeOperation) {
      next.path = nextPath.transform(op, affinity: affinity);
      return next;
    }

    if (op is InsertTextOperation) {
      if (op.path.equals(nextPath) && op.offset <= nextOffset) {
        next.offset += op.text.length;
      }
      return next;
    }

    if (op is MergeNodeOperation) {
      if (op.path.equals(nextPath)) {
        next.offset += op.position;
      }

      next.path = nextPath.transform(op, affinity: affinity);

      return next;
    }

    if (op is RemoveTextOperation) {
      if (op.path.equals(nextPath) && op.offset <= nextOffset) {
        next.offset -= min(nextOffset - op.offset, op.text.length);
      }

      return next;
    }

    if (op is RemoveNodeOperation) {
      if (op.path.equals(nextPath) || op.path.isAncestor(nextPath)) {
        return null;
      }

      next.path = nextPath.transform(op, affinity: affinity);

      return next;
    }

    if (op is SplitNodeOperation) {
      if (op.path.equals(nextPath)) {
        if (op.position == nextOffset && affinity == null) {
          return null;
        } else if (op.position < nextOffset ||
            (op.position == nextOffset && affinity == Affinity.forward)) {
          next.offset -= op.position;

          next.path = nextPath.transform(op, affinity: Affinity.forward);
        }
      } else {
        next.path = nextPath.transform(op, affinity: affinity);
      }

      return next;
    }

    return null;
  }
}

enum PointType { anchor, focus }

/// `PointEntry` objects are returned when iterating over `Point` objects that
/// belong to a range.
class PointEntry {
  PointEntry(this.point, this.type);

  final Point point;
  final PointType type;
}

/// `PointRef` objects keep a specific point in a document synced over time as new
/// operations are applied to the editor. You can access their `current` property
/// at any time for the up-to-date point value.
class PointRef {
  PointRef({this.current, this.affinity});

  Point current;
  Affinity affinity;

  Point unref(Set<PointRef> pointRefs) {
    Point _current = current;
    pointRefs.remove(this);
    current = null;

    return _current;
  }

  /// Transform the point ref's current value by an operation.
  static Point transform(Set<PointRef> pointRefs, PointRef ref, Operation op) {
    if (ref.current == null) {
      return null;
    }

    Point point = ref.current.transform(op, affinity: ref.affinity);
    ref.current = point;

    return point;
  }
}
