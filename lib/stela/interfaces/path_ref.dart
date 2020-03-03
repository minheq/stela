import 'package:inday/stela/interfaces/operation.dart';
import 'package:inday/stela/interfaces/path.dart';

/// `PathRef` objects keep a specific path in a document synced over time as new
/// operations are applied to the editor. You can access their `current` property
/// at any time for the up-to-date path value.
class PathRef {
  PathRef({this.current, this.affinity, this.unref});

  Path current;
  Affinity affinity;
  Path Function() unref;

  /// Transform the path ref's current value by an operation.
  static void transform(PathRef ref, Operation op) {
    if (ref.current == null) {
      return null;
    }

    Path path = PathUtils.transform(ref.current, op, affinity: ref.affinity);
    ref.current = path;

    if (path == null) {
      ref.unref();
    }
  }
}
