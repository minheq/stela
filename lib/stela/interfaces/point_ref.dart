import 'package:inday/stela/interfaces/operation.dart';
import 'package:inday/stela/interfaces/point.dart';

/// `PointRef` objects keep a specific point in a document synced over time as new
/// operations are applied to the editor. You can access their `current` property
/// at any time for the up-to-date point value.
class PointRef {
  PointRef({this.current, this.affinity, this.unref});

  Point current;
  Affinity affinity;
  Point Function() unref;

  /// Transform the point ref's current value by an operation.
  static void transform(PointRef ref, Operation op) {
    if (ref.current == null) {
      return null;
    }

    Point point = PointUtils.transform(ref.current, op, affinity: ref.affinity);
    ref.current = point;

    if (point == null) {
      ref.unref();
    }
  }
}
