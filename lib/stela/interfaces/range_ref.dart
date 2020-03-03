import 'package:inday/stela/interfaces/operation.dart';
import 'package:inday/stela/interfaces/range.dart';

/// `RangeRef` objects keep a specific range in a document synced over time as new
/// operations are applied to the editor. You can access their `current` property
/// at any time for the up-to-date range value.
class RangeRef {
  RangeRef(this.current, this.affinity, this.unref);

  Range current;
  Affinity affinity;
  Range Function() unref;

  /// Transform the range ref's current value by an operation.
  static void transform(RangeRef ref, Operation op) {
    if (ref.current == null) {
      return null;
    }

    Range range = Range.transform(ref.current, op, affinity: ref.affinity);
    ref.current = range;

    if (range == null) {
      ref.unref();
    }
  }
}
