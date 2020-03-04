import 'package:inday/stela/node.dart';
import 'package:inday/stela/path.dart';

/// `Element` objects are a type of node that contain other
/// element nodes or text nodes. They can be either "blocks" or "inlines"
/// depending on the editor's configuration.
class Element implements Ancestor, Descendant {
  Element({this.children = const <Node>[], this.props = const {}});

  List<Node> children;

  /// Custom properties that can extend the `Element` behavior
  Map<String, dynamic> props;
}

class ElementUtils {
  /// Check if list of nodes consist of only `Element` nodes.
  static bool isElementList(List<Node> nodes) {
    for (Node node in nodes) {
      if (node is Element == false) {
        return false;
      }
    }

    return true;
  }
}

/// `ElementEntry` objects refer to an `Element` and the `Path` where it can be
/// found inside a root node.
class ElementEntry {
  ElementEntry(this.element, this.path);

  final Element element;
  final Path path;
}

class Block implements Element {
  Block({this.children = const <Node>[], this.props = const {}});

  List<Node> children;

  /// Custom properties that can extend the `Element` behavior
  Map<String, dynamic> props;
}
