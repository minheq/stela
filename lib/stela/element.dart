import 'package:flutter/foundation.dart';
import 'package:inday/stela/node.dart';
import 'package:inday/stela/path.dart';

/// `Element` objects are a type of node that contain other
/// element nodes or text nodes. They can be either "blocks" or "inlines"
/// depending on the editor's configuration.
///
/// Depending on your use case, you might want to define another behavior for Element nodes
/// which determines their editing "flow".
///
/// All elements default to being "block" elements.
///
/// But in certain cases, like for links, you might want to make as "inline" flowing elements instead.
/// That way they live at the same level as text nodes, and flow.
///
/// Elements default to being non-void, meaning that their children are fully editable as text.
class Element implements Ancestor, Descendant {
  Element({List<Node> children, Map<String, dynamic> props, bool isVoid})
      : children = children ?? [],
        props = props ?? {},
        isVoid = isVoid ?? false;

  String type = 'element';

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

/// `Block` objects are a type of node that contain other element nodes or text nodes.
/// They each appear separated by vertical space, and they never run into each other.
class Block implements Element {
  Block(
      {@required List<Node> children,
      Map<String, dynamic> props,
      bool isVoid,
      @required String type})
      : children = children ?? [],
        props = props ?? {},
        type = type ?? 'block',
        isVoid = isVoid ?? false;

  String type;

  List<Node> children;

  /// Custom properties that can extend the `Element` behavior
  Map<String, dynamic> props;

  /// Void-ness means that the content of the node should not be treated as editable
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

/// `Inline` objects are a type of node that contain other text nodes.
/// They live at the same level as text nodes and are useful for e.g. links.
class Inline implements Element {
  Inline(
      {@required List<Node> children,
      Map<String, dynamic> props,
      bool isVoid,
      @required String type})
      : children = children ?? [],
        props = props ?? {},
        type = type ?? 'inline',
        isVoid = isVoid ?? false;

  String type;

  List<Node> children;

  /// Custom properties that can extend the `Element` behavior
  Map<String, dynamic> props;

  /// Void-ness means that the content of the node should not be treated as editable
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
