import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:inday/stela/interfaces/location.dart';

/// `Path` arrays are a list of indexes that describe a node's exact at in
/// a Slate node tree. Although they are usually relative to the root `Editor`
/// object, they can be relative to any `Node` object.
class Path implements Location {
  Path([List<int> path]) : path = path ?? [];

  final List<int> path;

  int get length {
    return path.length;
  }

  /// Returns a `Path` containing the elements between [start] and [end].
  ///
  /// When [end] is a negative number, the list will be subtracted by that amount.
  ///
  /// When [end] is greater than the length of `Path`, it defaults to length of the `Path`.
  Path slice(int start, [int end]) {
    if (end != null && end < 0) {
      return Path(path.sublist(start, path.length + end));
    }

    if (end != null && end > path.length) {
      return Path(path.sublist(start));
    }

    return Path(path.sublist(start, end));
  }

  /// Returns position at [index].
  ///
  /// Returns -1 if the [index] is out of bound
  int at(int index) {
    if (index >= path.length) {
      return -1;
    }

    return path[index];
  }

  /// Add position to `Path`
  void add(int position) {
    return path.add(position);
  }

  /// Get a list of ancestor paths for a given path.
  ///
  /// The paths are sorted from nearest to furthest ancestor. However, if the
  /// `reverse: true` option is passed, they are reversed.
  static List<Path> ancestors(Path path, {bool reverse = false}) {
    List<Path> paths = Path.levels(path, reverse: reverse);

    if (reverse) {
      paths = paths.sublist(1);
    } else {
      paths = paths.sublist(0, paths.length - 1);
    }

    return paths;
  }

  /// Get the common ancestor path of two paths.
  static Path common(Path path, Path another) {
    Path common = Path();

    for (int i = 0; i < path.length && i < another.length; i++) {
      int av = path.at(i);
      int bv = another.at(i);

      if (av != bv) {
        break;
      }

      common.add(av);
    }

    return common;
  }

  /// Compare a path to another, returning an integer indicating whether the path
  /// was before (-1), at (0), or after (1) the other.
  ///
  /// Note: Two paths of unequal length can still receive a `0` result if one is
  /// directly above or below the other. If you want exact matching, use
  /// [[Path.equals]] instead.
  static int compare(Path path, Path another) {
    int smaller = min(path.length, another.length);

    for (int i = 0; i < smaller; i++) {
      if (path.at(i) < another.at(i)) return -1;
      if (path.at(i) > another.at(i)) return 1;
    }

    return 0;
  }

  /// Check if a path ends after one of the indexes in another.
  static bool endsAfter(Path path, Path another) {
    int i = path.length - 1;
    Path as = path.slice(0, i);
    Path bs = another.slice(0, i);
    int av = path.at(i);
    int bv = another.at(i);

    return Path.equals(as, bs) && av > bv;
  }

  /// Check if a path ends at one of the indexes in another.
  static bool endsAt(Path path, Path another) {
    int i = path.length;
    Path as = path.slice(0, i);
    Path bs = another.slice(0, i);

    return Path.equals(as, bs);
  }

  /// Check if a path ends before one of the indexes in another.
  static bool endsBefore(Path path, Path another) {
    int i = path.length - 1;
    Path as = path.slice(0, i);
    Path bs = another.slice(0, i);
    int av = path.at(i);
    int bv = another.at(i);

    return Path.equals(as, bs) && av < bv;
  }

  /// Check if two `Path` nodes are equal.
  static bool equals(Path path, Path another) {
    return listEquals(path.path, another.path);
  }

  /// Check if a path is after another.
  static bool isAfter(Path path, Path another) {
    return Path.compare(path, another) == 1;
  }

  /// Check if a path is an ancestor of another.
  static bool isAncestor(Path path, Path another) {
    return path.length < another.length && Path.compare(path, another) == 0;
  }

  /// Check if a path is before another.
  static bool isBefore(Path path, Path another) {
    return Path.compare(path, another) == -1;
  }

  /// Check if a path is a child of another.
  static bool isChild(Path path, Path another) {
    return (path.length == another.length + 1 &&
        Path.compare(path, another) == 0);
  }

  /// Check if a path is equal to or an ancestor of another.
  static bool isCommon(Path path, Path another) {
    return path.length <= another.length && Path.compare(path, another) == 0;
  }

  /// Check if a path is a descendant of another.
  static bool isDescendant(Path path, Path another) {
    return path.length > another.length && Path.compare(path, another) == 0;
  }

  /// Check if a path is the parent of another.
  static bool isParent(Path path, Path another) {
    return (path.length + 1 == another.length &&
        Path.compare(path, another) == 0);
  }

  /// Check if a path is a sibling of another.
  static bool isSibling(Path path, Path another) {
    if (path.length != another.length) {
      return false;
    }

    Path as = path.slice(0, -1);
    Path bs = another.slice(0, -1);
    int al = path.at(path.length - 1);
    int bl = another.at(another.length - 1);

    return al != bl && Path.equals(as, bs);
  }

  /// Get a list of paths at every level down to a path. Note: this is the same
  /// as `Path.ancestors`, but including the path itself.
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

    int last = path.at(path.length - 1);

    Path next = path.slice(0, -1);

    next.add(last + 1);

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

    int last = path.at(path.length - 1);

    if (last <= 0) {
      throw Exception(
          "Cannot get the previous path of a first child path [$path] because it would result in a negative index.");
    }

    Path prev = path.slice(0, -1);

    prev.add(last - 1);

    return prev;
  }

  /// Get a path relative to an ancestor.
  static Path relative(Path path, Path ancestor) {
    if (!Path.isAncestor(ancestor, path) && !Path.equals(path, ancestor)) {
      throw Exception(
          "Cannot get the relative path of [$path] inside ancestor [$ancestor], because it is not above or equal to the path.");
    }

    return path.slice(ancestor.length);
  }

  // /**
  //  * Transform a path by an operation.
  //  */

  // transform(
  //   path: Path,
  //   operation: Operation,
  //   options: { affinity?: 'forward' | 'backward' | null } = {}
  // ): Path | null {
  //   return produce(path, p => {
  //     const { affinity = 'forward' } = options

  //     // PERF: Exit early if the operation is guaranteed not to have an effect.
  //     if (path.length === 0) {
  //       return
  //     }

  //     switch (operation.type) {
  //       case 'insert_node': {
  //         const { path: op } = operation

  //         if (
  //           Path.equals(op, p) ||
  //           Path.endsBefore(op, p) ||
  //           Path.isAncestor(op, p)
  //         ) {
  //           p[op.length - 1] += 1
  //         }

  //         break
  //       }

  //       case 'remove_node': {
  //         const { path: op } = operation

  //         if (Path.equals(op, p) || Path.isAncestor(op, p)) {
  //           return null
  //         } else if (Path.endsBefore(op, p)) {
  //           p[op.length - 1] -= 1
  //         }

  //         break
  //       }

  //       case 'merge_node': {
  //         const { path: op, position } = operation

  //         if (Path.equals(op, p) || Path.endsBefore(op, p)) {
  //           p[op.length - 1] -= 1
  //         } else if (Path.isAncestor(op, p)) {
  //           p[op.length - 1] -= 1
  //           p[op.length] += position
  //         }

  //         break
  //       }

  //       case 'split_node': {
  //         const { path: op, position } = operation

  //         if (Path.equals(op, p)) {
  //           if (affinity === 'forward') {
  //             p[p.length - 1] += 1
  //           } else if (affinity === 'backward') {
  //             // Nothing, because it still refers to the right path.
  //           } else {
  //             return null
  //           }
  //         } else if (Path.endsBefore(op, p)) {
  //           p[op.length - 1] += 1
  //         } else if (Path.isAncestor(op, p) && path[op.length] >= position) {
  //           p[op.length - 1] += 1
  //           p[op.length] -= position
  //         }

  //         break
  //       }

  //       case 'move_node': {
  //         const { path: op, newPath: onp } = operation

  //         // If the old and new path are the same, it's a no-op.
  //         if (Path.equals(op, onp)) {
  //           return
  //         }

  //         if (Path.isAncestor(op, p) || Path.equals(op, p)) {
  //           const copy = onp.slice()

  //           if (Path.endsBefore(op, onp) && op.length < onp.length) {
  //             const i = Math.min(onp.length, op.length) - 1
  //             copy[i] -= 1
  //           }

  //           return copy.concat(p.slice(op.length))
  //         } else if (
  //           Path.endsBefore(onp, p) ||
  //           Path.equals(onp, p) ||
  //           Path.isAncestor(onp, p)
  //         ) {
  //           if (Path.endsBefore(op, p)) {
  //             p[op.length - 1] -= 1
  //           }

  //           p[onp.length - 1] += 1
  //         } else if (Path.endsBefore(op, p)) {
  //           if (Path.equals(onp, p)) {
  //             p[onp.length - 1] += 1
  //           }

  //           p[op.length - 1] -= 1
  //         }

  //         break
  //       }
  //     }
  //   })
  // },
}
