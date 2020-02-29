import 'package:inday/stela/interfaces/node.dart';
import 'package:inday/stela/interfaces/operation.dart';
import 'package:inday/stela/interfaces/range.dart';

/// The `Editor` interface stores all the state of a Stela editor. It is extended
/// by plugins that wish to add their own helpers and implement new behaviors.
class Editor implements Ancestor {
  Editor({this.children = const <Node>[]});

  /// The `children` property contains the document tree of nodes that make up the editor's content
  List<Node> children;

  /// The `selection` property contains the user's current selection, if any
  Range selection;

  /// The `operations` property contains all of the operations that have been applied since the last "change" was flushed. (Since Slate batches operations up into ticks of the event loop.)
  List<Operation> operations;

  /// The `marks` property stores formatting that is attached to the cursor, and that will be applied to the text that is inserted next
  Map<String, dynamic> marks;
}
