import 'package:inday/stela/operation.dart';
import 'package:inday/stela/path.dart';

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

    Path path = PathUtils.transform(ref.current, op, affinity: ref.affinity);
    ref.current = path;

    return path;
  }
}
