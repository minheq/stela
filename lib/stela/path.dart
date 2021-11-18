import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:inday/stela/location.dart';
import 'package:inday/stela/operation.dart';

/// `Path` arrays are a list of indexes that describe a node's exact at in
/// a Slate node tree. Although they are usually relative to the root `Editor`
/// object, they can be relative to any `Node` object.
class Path implements Location {
  Path(List<int> path, {this.props}) : _path = path ?? const [];

  final List<int> _path;

  /// Custom properties that can extend the `Range` behavior for e.g. decorations or selections
  Map<String, dynamic> props;

  int get length {
    return _path.length;
  }

  int get first {
    return _path.first;
  }

  int get last {
    return _path.last;
  }

  bool get isEmpty {
    return _path.isEmpty;
  }

  bool get isNotEmpty {
    return _path.isNotEmpty;
  }

  @override
  String toString() {
    return "[${_path.join(', ')}]";
  }

  /// Adds [position] to the start of the `Path`, extending the length by one.
  void prepend(int position) {
    return _path.insert(0, position);
  }

  /// Adds [position] to the end of the `Path`, extending the length by one.
  void add(int position) {
    return _path.add(position);
  }

  /// Adds [position] to the end of the `Path`, extending the length by one.
  Path copyAndAdd(int position) {
    Path newPath = copy()..add(position);
    return newPath;
  }

  /// Appends all objects of [iterable] to the end of this list.
  ///
  /// Extends the length of the list by the number of objects in [iterable]. Throws an [UnsupportedError] if this list is fixed-length.
  void addAll(Path path) {
    return _path.addAll(path.toList());
  }

  /// Converts each element to a [String] and concatenates the strings.
  ///
  /// Iterates through elements of this iterable, converts each one to a [String] by calling [Object.toString], and then concatenates the strings, with the [separator] string interleaved between the elements.
  String join([String separator]) {
    return _path.join(separator);
  }

  /// Creates a [List] containing the positions of this `Path`.
  List<int> toList() {
    return List.from(_path);
  }

  /// Returns a `Path` containing the elements between [start] and [end].
  ///
  /// When [end] is a negative number, the list will be subtracted by that amount.
  ///
  /// When [end] is greater than the length of `Path`, it defaults to length of the `Path`.
  Path slice([int start = 0, int end]) {
    if (end != null && end < 0) {
      return Path(_path.sublist(start, _path.length + end));
    }

    if (end != null && end > _path.length) {
      return Path(_path.sublist(start));
    }

    return Path(_path.sublist(start, end));
  }

  /// Returns the object at the given index in the list or throws a RangeError if index is out of bounds.
  int operator [](int index) {
    return _path[index];
  }

  /// Sets the value at the given index in the list to value or throws a RangeError if index is out of bounds
  void operator []=(int index, int value) {
    _path[index] = value;
  }

  /// Get a list of ancestor paths for a given path.
  ///
  /// The paths are sorted from nearest to furthest ancestor. However, if the
  /// `reverse: true` option is passed, they are reversed.
  List<Path> ancestors({bool reverse = false}) {
    List<Path> paths = levels(reverse: reverse);

    if (reverse) {
      paths = paths.sublist(1);
    } else {
      paths = paths.sublist(0, paths.length - 1);
    }

    return paths;
  }

  /// Get the common ancestor path of two paths.
  Path common(Path another) {
    Path common = Path([]);

    for (int i = 0; i < _path.length && i < another.length; i++) {
      int av = _path[i];
      int bv = another[i];

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
  /// [[PathUtils.equals]] instead.
  int compare(Path another) {
    int smaller = min(_path.length, another.length);

    for (int i = 0; i < smaller; i++) {
      if (_path[i] < another[i]) return -1;
      if (_path[i] > another[i]) return 1;
    }

    return 0;
  }

  /// Returns a copy of the path
  Path copy() {
    return Path(_path.toList());
  }

  /// Check if a path ends after one of the indexes in another.
  bool endsAfter(Path another) {
    int i = _path.length - 1;
    Path ap = slice(0, i);
    Path bp = another.slice(0, i);
    int av = i >= _path.length ? -1 : _path[i];
    int bv = i >= another.length ? -1 : another[i];

    return ap.equals(bp) && av > bv;
  }

  /// Check if a path ends at one of the indexes in another.
  bool endsAt(Path another) {
    int i = _path.length;
    Path ap = slice(0, i);
    Path bp = another.slice(0, i);

    return ap.equals(bp);
  }

  /// Check if a path ends before one of the indexes in another.
  bool endsBefore(Path another) {
    int i = _path.length - 1;
    Path ap = slice(0, i);
    Path bp = another.slice(0, i);
    int av = i >= _path.length ? -1 : _path[i];
    int bv = i >= another.length ? -1 : another[i];

    return ap.equals(bp) && av < bv;
  }

  /// Check if two `Path` nodes are equal.
  bool equals(Path another) {
    return listEquals(_path.toList(), another.toList());
  }

  /// Check if a path is after another.
  bool isAfter(Path another) {
    return compare(another) == 1;
  }

  /// Check if a path is an ancestor of another.
  bool isAncestor(Path another) {
    return _path.length < another.length && compare(another) == 0;
  }

  /// Check if a path is before another.
  bool isBefore(Path another) {
    return compare(another) == -1;
  }

  /// Check if a path is a child of another.
  bool isChild(Path another) {
    return (_path.length == another.length + 1 && compare(another) == 0);
  }

  /// Check if a path is equal to or an ancestor of another.
  bool isCommon(Path another) {
    return _path.length <= another.length && compare(another) == 0;
  }

  /// Check if a path is a descendant of another.
  bool isDescendant(Path another) {
    return _path.length > another.length && compare(another) == 0;
  }

  /// Check if a path is the parent of another.
  bool isParent(Path another) {
    return (_path.length + 1 == another.length && compare(another) == 0);
  }

  /// Check if a path is a sibling of another.
  bool isSibling(Path another) {
    if (_path.length != another.length) {
      return false;
    }

    Path ap = slice(0, -1);
    Path bp = another.slice(0, -1);
    int al = _path[_path.length - 1];
    int bl = another[another.length - 1];

    return al != bl && ap.equals(bp);
  }

  /// Get a list of paths at every level down to a path. Note: this is the same
  /// as `PathUtils.ancestors`, but including the path itself.
  ///
  /// The paths are sorted from shallowest to deepest. However, if the `reverse:
  /// true` option is passed, they are reversed.
  List<Path> levels({bool reverse = false}) {
    List<Path> list = [];

    for (int i = 0; i <= _path.length; i++) {
      list.add(slice(0, i));
    }

    if (reverse) {
      return List.from(list.reversed);
    }

    return list;
  }

  /// Given a path, get the path to the next sibling node.
  Path get next {
    if (_path.length == 0) {
      throw Exception(
          "Cannot get the next path of a root path [${toString()}], because it has no next index.");
    }

    int last = _path[_path.length - 1];

    Path next = slice(0, -1);

    next.add(last + 1);

    return next;
  }

  /// Given a path, return a new path referring to the parent node above it.
  Path get parent {
    if (_path.length == 0) {
      throw Exception(
          "Cannot get the parent path of the root path [${toString()}].");
    }

    return slice(0, -1);
  }

  /// Given a path, get the path to the previous sibling node.
  Path get previous {
    if (_path.length == 0) {
      throw Exception(
          "Cannot get the previous path of a root path [${toString()}], because it has no previous index.");
    }

    int last = _path[_path.length - 1];

    if (last <= 0) {
      throw Exception(
          "Cannot get the previous path of a first child path [${toString()}] because it would result in a negative index.");
    }

    Path prev = slice(0, -1);

    prev.add(last - 1);

    return prev;
  }

  /// Get a path relative to an ancestor.
  Path relative(Path ancestor) {
    if (!ancestor.isAncestor(this) && !equals(ancestor)) {
      throw Exception(
          "Cannot get the relative path of [${toString()}] inside ancestor [$ancestor], because it is not above or equal to the path.");
    }

    return slice(ancestor.length);
  }

  /// Transform a path by an operation.
  Path transform(Operation operation, {Affinity affinity = Affinity.forward}) {
    Path p = copy();

    // PERF: Exit early if the operation is guaranteed not to have an effect.
    if (_path.isEmpty) {
      return this;
    }

    if (operation is InsertNodeOperation) {
      Path op = operation.path;

      if (op.equals(p) || op.endsBefore(p) || op.isAncestor(p)) {
        p[op.length - 1] += 1;

        return p;
      }
    }

    if (operation is RemoveNodeOperation) {
      Path op = operation.path;

      if (op.equals(p) || op.isAncestor(p)) {
        return null;
      } else if (op.endsBefore(p)) {
        p[op.length - 1] -= 1;
      }

      return p;
    }

    if (operation is MergeNodeOperation) {
      Path op = operation.path;
      int position = operation.position;

      if (op.equals(p) || op.endsBefore(p)) {
        p[op.length - 1] -= 1;
      } else if (op.isAncestor(p)) {
        p[op.length - 1] -= 1;
        p[op.length] += position;
      }

      return p;
    }

    if (operation is SplitNodeOperation) {
      Path op = operation.path;
      int position = operation.position;

      if (op.equals(p)) {
        if (affinity == Affinity.forward) {
          p[p.length - 1] += 1;
        } else if (affinity == Affinity.backward) {
          // Nothing, because it still refers to the right path.
        } else {
          return null;
        }
      } else if (op.endsBefore(p)) {
        p[op.length - 1] += 1;
      } else if (op.isAncestor(p) && _path[op.length] >= position) {
        p[op.length - 1] += 1;
        p[op.length] -= position;
      }

      return p;
    }

    if (operation is MoveNodeOperation) {
      Path op = operation.path;
      Path onp = operation.newPath;

      // If the old and new path are the same, it's a no-op.
      if (op.equals(onp)) {
        return this;
      }

      if (op.isAncestor(p) || op.equals(p)) {
        Path copy = onp.slice();

        if (op.endsBefore(onp) && op.length < onp.length) {
          int i = min(onp.length, op.length) - 1;
          copy[i] -= 1;
        }

        copy.addAll(p.slice(op.length));

        return copy;
      } else if (onp.endsBefore(p) || onp.equals(p) || onp.isAncestor(p)) {
        if (op.endsBefore(p)) {
          p[op.length - 1] -= 1;
        }

        p[onp.length - 1] += 1;
      } else if (op.endsBefore(p)) {
        if (onp.equals(p)) {
          p[onp.length - 1] += 1;
        }

        p[op.length - 1] -= 1;
      }

      return p;
    }

    return this;
  }
}

/// `PathRef` objects keep a specific path in a document synced over time as new
/// operations are applied to the editor. You can access their `current` property
/// at any time for the up-to-date path value.
class PathRef {
  PathRef({this.current, this.affinity});

  Path current;
  Affinity affinity;

  Path unref(Set<PathRef> pathRefs) {
    Path _current = current;
    pathRefs.remove(this);
    current = null;

    return _current;
  }

  /// Transform the path ref's current value by an operation.
  static Path transform(Set<PathRef> pathRefs, PathRef ref, Operation op) {
    if (ref.current == null) {
      return null;
    }

    Path path = ref.current.transform(op, affinity: ref.affinity);
    ref.current = path;

    return path;
  }
}
