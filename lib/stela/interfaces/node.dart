import 'package:inday/stela/interfaces/path.dart';
import 'package:inday/stela/interfaces/text.dart';

/// The `Node` represents all of the different types of nodes that
/// occur in a document tree.
class Node {
  /// Get the node at a specific path, asserting that it's an ancestor node.
  static Node ancestor(Node root, Path path) {
    Node node = Node.get(root, path);

    if (node is Text) {
      throw Exception(
          "Cannot get the ancestor node at path [$path] because it refers to a text node instead: $node");
    }

    return node;
  }

  static Node get(Node root, Path path) {
    Node node = root;

    if (node is Text) {
      throw Exception(
          "Cannot find a descendant at path [$path] because it refers to a text node instead: $root");
    }

    // Traverse the nodes tree with the given path
    for (int i = 0; i < path.length; i++) {
      int p = path.at(i);

      Ancestor ancestor = node;

      if (ancestor.children[p] == null) {
        throw Exception(
            "Cannot find a descendant at path [$path] in node: ${root.toString()}");
      }

      node = ancestor.children[p];
    }

    return node;
  }
}

/// The `Descendant` represents nodes that are descendants in the
/// tree. It is returned as a convenience in certain cases to narrow a value
/// further than the more generic `Node` union.
class Descendant implements Node {}

/// The `Ancestor` represents nodes that are ancestors in the tree.
/// It is returned as a convenience in certain cases to narrow a value further
/// than the more generic `Node` union.
class Ancestor implements Node {
  Ancestor({this.children = const <Node>[]});

  final List<Node> children;
}

/// `NodeEntry` objects are returned when iterating over the nodes in a Slate
/// document tree. They consist of the node and its `Path` relative to the root
/// node in the document.
class NodeEntry {
  NodeEntry(this.node, this.path);

  final Node node;
  final Path path;
}
