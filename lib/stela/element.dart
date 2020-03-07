import 'package:inday/stela/node.dart';
import 'package:inday/stela/path.dart';

/// `Element` objects are a type of node that contain other
/// element nodes or text nodes. They can be either "blocks" or "inlines"
/// depending on the editor's configuration.
class Element implements Ancestor, Descendant {
  Element({this.children = const <Node>[], this.props = const {}, this.isVoid = false});

  List<Node> children;

  /// Custom properties that can extend the `Element` behavior
  Map<String, dynamic> props;

  bool isVoid;

  @override
  String toString() {
    String str = '';

    for (Node child in children) {
      str += child.toString() + ', ';
    }

    return 'Element(children:[$str])';
  }
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
  Block(
      {this.children = const <Node>[],
      this.props = const {},
      this.isVoid = false});

  List<Node> children;

  /// Custom properties that can extend the `Element` behavior
  Map<String, dynamic> props;

  bool isVoid;

  @override
  String toString() {
    String str = '';

    for (Node child in children) {
      str += child.toString() + ', ';
    }

    return 'Block(children:[$str])';
  }
}

class Inline implements Element {
  Inline(
      {this.children = const <Node>[],
      this.props = const {},
      this.isVoid = false});

  List<Node> children;

  /// Custom properties that can extend the `Element` behavior
  Map<String, dynamic> props;

  bool isVoid;

  @override
  String toString() {
    String str = '';

    for (Node child in children) {
      str += child.toString() + ', ';
    }

    return 'Inline(children:[$str])';
  }
}
