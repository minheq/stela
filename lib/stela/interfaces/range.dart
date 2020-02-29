import 'package:inday/stela/interfaces/location.dart';
import 'package:inday/stela/interfaces/point.dart';

/// `Range` objects are a set of points that refer to a specific span of a Slate
/// document. They can define a span inside a single node or a can span across
/// multiple nodes.
class Range implements Location {
  Point anchor;
  Point focus;
}
