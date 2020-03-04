import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:inday/stela/location.dart';
import 'package:inday/stela/operation.dart';

/// `Path` arrays are a list of indexes that describe a node's exact at in
/// a Slate node tree. Although they are usually relative to the root `Editor`
/// object, they can be relative to any `Node` object.
class Path implements Location {
  const Path(this.path);

  final List<int> path;

  int get length {
    return path.length;
  }

  /// Returns a `Path` containing the elements between [start] and [end].
  ///
  /// When [end] is a negative number, the list will be subtracted by that amount.
  ///
  /// When [end] is greater than the length of `Path`, it defaults to length of the `Path`.
  Path slice([int start = 0, int end]) {
    if (end != null && end < 0) {
      return Path(path.sublist(start, path.length + end));
    }

    if (end != null && end > path.length) {
      return Path(path.sublist(start));
    }

    return Path(path.sublist(start, end));
  }
}

class PathUtils {
  /// Get a list of ancestor paths for a given path.
  ///
  /// The paths are sorted from nearest to furthest ancestor. However, if the
  /// `reverse: true` option is passed, they are reversed.
  static List<Path> ancestors(Path path, {bool reverse = false}) {
    List<Path> paths = PathUtils.levels(path, reverse: reverse);

    if (reverse) {
      paths = paths.sublist(1);
    } else {
      paths = paths.sublist(0, paths.length - 1);
    }

    return paths;
  }

  /// Get the common ancestor path of two paths.
  static Path common(Path path, Path another) {
    Path common = Path([]);

    for (int i = 0; i < path.length && i < another.length; i++) {
      int av = path.path[i];
      int bv = another.path[i];

      if (av != bv) {
        break;
      }

      common.path.add(av);
    }

    return common;
  }

  /// Compare a path to another, returning an integer indicating whether the path
  /// was before (-1), at (0), or after (1) the other.
  ///
  /// Note: Two paths of unequal length can still receive a `0` result if one is
  /// directly above or below the other. If you want exact matching, use
  /// [[PathUtils.equals]] instead.
  static int compare(Path path, Path another) {
    int smaller = min(path.length, another.length);

    for (int i = 0; i < smaller; i++) {
      if (path.path[i] < another.path[i]) return -1;
      if (path.path[i] > another.path[i]) return 1;
    }

    return 0;
  }

  /// Check if a path ends after one of the indexes in another.
  static bool endsAfter(Path path, Path another) {
    int i = path.length - 1;
    Path as = path.slice(0, i);
    Path bs = another.slice(0, i);
    int av = i >= path.length ? -1 : path.path[i];
    int bv = i >= another.length ? -1 : another.path[i];

    return PathUtils.equals(as, bs) && av > bv;
  }

  /// Check if a path ends at one of the indexes in another.
  static bool endsAt(Path path, Path another) {
    int i = path.length;
    Path as = path.slice(0, i);
    Path bs = another.slice(0, i);

    return PathUtils.equals(as, bs);
  }

  /// Check if a path ends before one of the indexes in another.
  static bool endsBefore(Path path, Path another) {
    int i = path.length - 1;
    Path as = path.slice(0, i);
    Path bs = another.slice(0, i);
    int av = i >= path.length ? -1 : path.path[i];
    int bv = i >= another.length ? -1 : another.path[i];

    return PathUtils.equals(as, bs) && av < bv;
  }

  /// Check if two `Path` nodes are equal.
  static bool equals(Path path, Path another) {
    return listEquals(path.path, another.path);
  }

  /// Check if a path is after another.
  static bool isAfter(Path path, Path another) {
    return PathUtils.compare(path, another) == 1;
  }

  /// Check if a path is an ancestor of another.
  static bool isAncestor(Path path, Path another) {
    return path.length < another.length &&
        PathUtils.compare(path, another) == 0;
  }

  /// Check if a path is before another.
  static bool isBefore(Path path, Path another) {
    return PathUtils.compare(path, another) == -1;
  }

  /// Check if a path is a child of another.
  static bool isChild(Path path, Path another) {
    return (path.length == another.length + 1 &&
        PathUtils.compare(path, another) == 0);
  }

  /// Check if a path is equal to or an ancestor of another.
  static bool isCommon(Path path, Path another) {
    return path.length <= another.length &&
        PathUtils.compare(path, another) == 0;
  }

  /// Check if a path is a descendant of another.
  static bool isDescendant(Path path, Path another) {
    return path.length > another.length &&
        PathUtils.compare(path, another) == 0;
  }

  /// Check if a path is the parent of another.
  static bool isParent(Path path, Path another) {
    return (path.length + 1 == another.length &&
        PathUtils.compare(path, another) == 0);
  }

  /// Check if a path is a sibling of another.
  static bool isSibling(Path path, Path another) {
    if (path.length != another.length) {
      return false;
    }

    Path as = path.slice(0, -1);
    Path bs = another.slice(0, -1);
    int al = path.path[path.length - 1];
    int bl = another.path[another.length - 1];

    return al != bl && PathUtils.equals(as, bs);
  }

  /// Get a list of paths at every level down to a path. Note: this is the same
  /// as `PathUtils.ancestors`, but including the path itself.
  ///
  /// The paths are sorted from shallowest to deepest. However, if the `reverse:
  /// true` option is passed, they are reversed.
  static List<Path> levels(Path path, {bool reverse = false}) {
    List<Path> list = [];

    for (int i = 0; i <= path.length; i++) {
      list.add(path.slice(0, i));
    }

    if (reverse) {
      return List.from(list.reversed);
    }

    return list;
  }

  /// Given a path, get the path to the next sibling node.
  static Path next(Path path) {
    if (path.length == 0) {
      throw Exception(
          "Cannot get the next path of a root path [$path], because it has no next index.");
    }

    int last = path.path[path.length - 1];

    Path next = path.slice(0, -1);

    next.path.add(last + 1);

    return next;
  }

  /// Given a path, return a new path referring to the parent node above it.
  static Path parent(Path path) {
    if (path.length == 0) {
      throw Exception("Cannot get the parent path of the root path [$path].");
    }

    return path.slice(0, -1);
  }

  /// Given a path, get the path to the previous sibling node.
  static Path previous(Path path) {
    if (path.length == 0) {
      throw Exception(
          "Cannot get the previous path of a root path [$path], because it has no previous index.");
    }

    int last = path.path[path.length - 1];

    if (last <= 0) {
      throw Exception(
          "Cannot get the previous path of a first child path [$path] because it would result in a negative index.");
    }

    Path prev = path.slice(0, -1);

    prev.path.add(last - 1);

    return prev;
  }

  /// Get a path relative to an ancestor.
  static Path relative(Path path, Path ancestor) {
    if (!PathUtils.isAncestor(ancestor, path) &&
        !PathUtils.equals(path, ancestor)) {
      throw Exception(
          "Cannot get the relative path of [$path] inside ancestor [$ancestor], because it is not above or equal to the path.");
    }

    return path.slice(ancestor.length);
  }

  /// Transform a path by an operation.
  static Path transform(Path path, Operation operation,
      {Affinity affinity = Affinity.forward}) {
    Path p = Path(path.path);

    // PERF: Exit early if the operation is guaranteed not to have an effect.
    if (path.length == 0) {
      return null;
    }

    if (operation is InsertNodeOperation) {
      Path op = operation.path;

      if (PathUtils.equals(op, p) ||
          PathUtils.endsBefore(op, p) ||
          PathUtils.isAncestor(op, p)) {
        p.path[op.length - 1] += 1;

        return p;
      }
    }

    if (operation is RemoveNodeOperation) {
      Path op = operation.path;

      if (PathUtils.equals(op, p) || PathUtils.isAncestor(op, p)) {
        return null;
      } else if (PathUtils.endsBefore(op, p)) {
        p.path[op.length - 1] -= 1;
      }

      return p;
    }

    if (operation is MergeNodeOperation) {
      Path op = operation.path;
      int position = operation.position;

      if (PathUtils.equals(op, p) || PathUtils.endsBefore(op, p)) {
        p.path[op.length - 1] -= 1;
      } else if (PathUtils.isAncestor(op, p)) {
        p.path[op.length - 1] -= 1;
        p.path[op.length] += position;
      }

      return p;
    }

    if (operation is SplitNodeOperation) {
      Path op = operation.path;
      int position = operation.position;

      if (PathUtils.equals(op, p)) {
        if (affinity == Affinity.forward) {
          p.path[p.length - 1] += 1;
        } else if (affinity == Affinity.backward) {
          // Nothing, because it still refers to the right path.
        } else {
          return null;
        }
      } else if (PathUtils.endsBefore(op, p)) {
        p.path[op.length - 1] += 1;
      } else if (PathUtils.isAncestor(op, p) &&
          path.path[op.length] >= position) {
        p.path[op.length - 1] += 1;
        p.path[op.length] -= position;
      }

      return p;
    }

    if (operation is MoveNodeOperation) {
      Path op = operation.path;
      Path onp = operation.newPath;

      // If the old and new path are the same, it's a no-op.
      if (PathUtils.equals(op, onp)) {
        return null;
      }

      if (PathUtils.isAncestor(op, p) || PathUtils.equals(op, p)) {
        Path copy = onp.slice();

        if (PathUtils.endsBefore(op, onp) && op.length < onp.length) {
          int i = min(onp.length, op.length) - 1;
          copy.path[i] -= 1;
        }

        copy.path.addAll(p.slice(op.length).path);

        return copy;
      } else if (PathUtils.endsBefore(onp, p) ||
          PathUtils.equals(onp, p) ||
          PathUtils.isAncestor(onp, p)) {
        if (PathUtils.endsBefore(op, p)) {
          p.path[op.length - 1] -= 1;
        }

        p.path[onp.length - 1] += 1;
      } else if (PathUtils.endsBefore(op, p)) {
        if (PathUtils.equals(onp, p)) {
          p.path[onp.length - 1] += 1;
        }

        p.path[op.length - 1] -= 1;
      }

      return p;
    }

    return null;
  }
}
