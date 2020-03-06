import 'dart:math';

import 'package:inday/stela/location.dart';
import 'package:inday/stela/operation.dart';
import 'package:inday/stela/path.dart';

/// `Point` objects refer to a specific location in a text node in a Slate
/// document. Its path refers to the location of the node in the tree, and its
/// offset refers to the distance into the node's string of text. Points can
/// only refer to `Text` nodes.
class Point implements Location {
  Point(this.path, this.offset, {this.props = const {}});

  Path path;
  int offset;

  /// Custom properties that can extend the `Point` behavior
  Map<String, dynamic> props;

  @override
  String toString() {
    return "Point(${path.toString()}, $offset)";
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

class PointUtils {
  /// Compare a point to another, returning an integer indicating whether the
  /// point was before (-1), at (0), or after (1) the other.
  static int compare(Point point, Point another) {
    int result = PathUtils.compare(point.path, another.path);

    if (result == 0) {
      if (point.offset < another.offset) return -1;
      if (point.offset > another.offset) return 1;
      return 0;
    }

    return result;
  }

  /// Check if a point is exactly equal to another.
  static bool equals(Point point, Point another) {
    // PERF: ensure the offsets are equal first since they are cheaper to check.
    return (point.offset == another.offset &&
        PathUtils.equals(point.path, another.path));
  }

  /// Check if a point is after another.
  static bool isAfter(Point point, Point another) {
    return PointUtils.compare(point, another) == 1;
  }

  /// Check if a point is before another.
  static bool isBefore(Point point, Point another) {
    return PointUtils.compare(point, another) == -1;
  }

  /// Transform a point by an operation.
  static Point transform(Point point, Operation op,
      {Affinity affinity = Affinity.forward}) {
    Point p = Point(point.path, point.offset);
    Path path = p.path;
    int offset = p.offset;

    if (op is InsertNodeOperation || op is MoveNodeOperation) {
      p.path = PathUtils.transform(path, op, affinity: affinity);
      return p;
    }

    if (op is InsertTextOperation) {
      if (PathUtils.equals(op.path, path) && op.offset <= offset) {
        p.offset += op.text.length;
      }
      return p;
    }

    if (op is MergeNodeOperation) {
      if (PathUtils.equals(op.path, path)) {
        p.offset += op.position;
      }

      p.path = PathUtils.transform(path, op, affinity: affinity);

      return p;
    }

    if (op is RemoveTextOperation) {
      if (PathUtils.equals(op.path, path) && op.offset <= offset) {
        p.offset -= min(offset - op.offset, op.text.length);
      }

      return p;
    }

    if (op is RemoveNodeOperation) {
      if (PathUtils.equals(op.path, path) ||
          PathUtils.isAncestor(op.path, path)) {
        return null;
      }

      p.path = PathUtils.transform(path, op, affinity: affinity);

      return p;
    }

    if (op is SplitNodeOperation) {
      if (PathUtils.equals(op.path, path)) {
        if (op.position == offset && affinity == null) {
          return null;
        } else if (op.position < offset ||
            (op.position == offset && affinity == Affinity.forward)) {
          p.offset -= op.position;

          p.path = PathUtils.transform(path, op, affinity: Affinity.forward);
        }
      } else {
        p.path = PathUtils.transform(path, op, affinity: affinity);
      }

      return p;
    }

    return null;
  }
}
