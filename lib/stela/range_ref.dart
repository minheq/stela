import 'package:inday/stela/operation.dart';
import 'package:inday/stela/range.dart';

/// `RangeRef` objects keep a specific range in a document synced over time as new
/// operations are applied to the editor. You can access their `current` property
/// at any time for the up-to-date range value.
class RangeRef {
  RangeRef({this.current, this.affinity});

  Range current;
  Affinity affinity;

  Range unref(Set<RangeRef> rangeRefs) {
    Range _current = current;
    rangeRefs.remove(this);
    current = null;

    return _current;
  }

  /// Transform the range ref's current value by an operation.
  static Range transform(Set<RangeRef> rangeRefs, RangeRef ref, Operation op) {
    if (ref.current == null) {
      return null;
    }

    Range range = RangeUtils.transform(ref.current, op, affinity: ref.affinity);
    ref.current = range;

    return range;
  }
}
