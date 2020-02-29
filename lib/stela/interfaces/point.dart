import 'package:inday/stela/interfaces/path.dart';

/// `Point` objects refer to a specific location in a text node in a Slate
/// document. Its path refers to the location of the node in the tree, and its
/// offset refers to the distance into the node's string of text. Points can
/// only refer to `Text` nodes.
class Point {
  Path path;
  int offset;
}
