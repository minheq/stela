import 'package:inday/stela/interfaces/element.dart';
import 'package:inday/stela/interfaces/path.dart';
import 'package:inday/stela/interfaces/text.dart';

/// The `Node` union type represents all of the different types of nodes that
/// occur in a document tree. Namely Editor, Element and Text.
class Node {
  Node get(Node root, Path path) {
    Node node = root;

    for (int i = 0; i < path.length; i++) {
      int p = path[i];

      if (Text.isText(node)) {
        throw Exception(
            "Cannot find a descendant at path [$path] of a text node");
      }

      if (Element.isElement(node)) {
        Element element = node;

        if (element.children[p] == null) {
          throw Exception(
              "Cannot find a descendant at path [$path] in node: $root");
        }

        node = element.children[p];
      }
    }

    return node;
  }

  static bool isNodeList(Node node) {
    // return Node.isNodeList(value.children) /* && !Editor.isEditor(value)*/;
    return node is Element;
  }
}
