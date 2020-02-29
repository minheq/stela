import 'package:flutter/foundation.dart';
import 'package:inday/stela/interfaces/location.dart';

/// `Path` arrays are a list of indexes that describe a node's exact position in
/// a Slate node tree. Although they are usually relative to the root `Editor`
/// object, they can be relative to any `Node` object.
class Path implements Location {
  Path([this._path]);

  List<int> _path = <int>[];

  int get length {
    return _path.length;
  }

  List<int> get path {
    return _path;
  }

  /// Returns a `Path` containing the elements between [start] and [end].
  Path slice(int start, [int end]) {
    List<int> sliced = _path.sublist(start, end);

    return Path(sliced);
  }

  /// Returns the `Path` position at [index].
  int position(int index) {
    return _path[index];
  }

  /// Check if two `Path` nodes are equal.
  bool equals(Path other) {
    return listEquals(_path, other.path);
  }

  /// Get a list of ancestor paths for a given path.
  ///
  /// The paths are sorted from deepest to shallowest ancestor. However, if the
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
}
