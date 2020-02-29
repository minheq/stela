import 'package:inday/stela/interfaces/node.dart';
import 'package:inday/stela/interfaces/range.dart';

/// The `Editor` interface stores all the state of a Stela editor. It is extended
/// by plugins that wish to add their own helpers and implement new behaviors.
class Editor extends Node {
  Editor(this.children);

  List<Node> children;
  Range selection;
  // Operation[] operations
  Map<String, dynamic> marks;
}
