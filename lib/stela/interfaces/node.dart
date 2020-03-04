import 'package:inday/stela/interfaces/editor.dart';
import 'package:inday/stela/interfaces/element.dart';
import 'package:inday/stela/interfaces/path.dart';
import 'package:inday/stela/interfaces/point.dart';
import 'package:inday/stela/interfaces/range.dart';
import 'package:inday/stela/interfaces/text.dart';

/// The `Node` represents all of the different types of nodes that
/// occur in a document tree.
abstract class Node {
  Node({this.props});

  /// Custom properties that can extend the `Node` behavior
  Map<String, dynamic> props;
}

/// The `Descendant` represents nodes that are descendants in the
/// tree. It is returned as a convenience in certain cases to narrow a value
/// further than the more generic `Node` union.
abstract class Descendant implements Node {}

/// The `Ancestor` represents nodes that are ancestors in the tree.
/// It is returned as a convenience in certain cases to narrow a value further
/// than the more generic `Node` union.
abstract class Ancestor implements Node {
  Ancestor({this.children = const <Node>[]});

  List<Node> children;
}

/// `NodeEntry` objects are returned when iterating over the nodes in a Slate
/// document tree. They consist of the node and its `Path` relative to the root
/// node in the document.
class NodeEntry<T extends Node> {
  NodeEntry(this.node, this.path);

  final T node;
  final Path path;
}

class NodeUtils {
  /// Get the node at a specific path, asserting that it's an ancestor node.
  static Ancestor ancestor(Node root, Path path) {
    Ancestor node = NodeUtils.get(root, path);

    if (node is Text) {
      throw Exception(
          "Cannot get the ancestor node at path [$path] because it refers to a text node instead: $node");
    }

    return node;
  }

  /// Return an iterable of all the ancestor nodes above a specific path.
  ///
  /// By default the order is bottom-up, from lowest to highest ancestor in
  /// the tree, but you can pass the `reverse: true` option to go top-down.
  static Iterable<NodeEntry<Ancestor>> ancestors(Node root, Path path,
      {bool reverse = false}) sync* {
    for (Path p in PathUtils.ancestors(path, reverse: reverse)) {
      Ancestor n = NodeUtils.ancestor(root, p);

      yield NodeEntry(n, p);
    }
  }

  /// Get the child of a node at a specific index.
  static Descendant child(Node root, int index) {
    if (root is Text) {
      throw Exception(
          "Cannot get the child of a text node: ${root.toString()}");
    }

    Descendant c = (root as Ancestor).children[index];

    if (c == null) {
      throw Exception(
          "Cannot get child at index $index in node: ${root.toString()}");
    }

    return c;
  }

  /// Iterate over the children of a node at a specific path.

  static Iterable<NodeEntry<Descendant>> children(Node root, Path path,
      {bool reverse = false}) sync* {
    Ancestor ancestor = NodeUtils.ancestor(root, path);
    int index = reverse ? ancestor.children.length - 1 : 0;

    while (reverse ? index >= 0 : index < ancestor.children.length) {
      Descendant child = NodeUtils.child(ancestor, index);
      List<int> newPositions = List.from(path.path);
      newPositions.add(index);
      Path childPath = Path(newPositions);

      yield NodeEntry<Descendant>(child, childPath);

      index = reverse ? index - 1 : index + 1;
    }
  }

  /// Get an entry for the common ancestor node of two paths.
  static NodeEntry common(Node root, Path path, Path another) {
    Path p = PathUtils.common(path, another);
    Node n = NodeUtils.get(root, p);

    return NodeEntry(n, p);
  }

  /// Returns a new instance of the node
  static Node copy(Node root) {
    if (root is Text) {
      return Text(root.text);
    }

    List<Node> copiedChildren = [];

    for (Node node in (root as Ancestor).children) {
      copiedChildren.add(NodeUtils.copy(node));
    }

    if (root is Element) {
      return Element(children: copiedChildren);
    }

    if (root is Editor) {
      return Editor(
          children: copiedChildren,
          selection: root.selection,
          operations: root.operations,
          marks: root.marks);
    }

    throw Exception("Unrecognized node type ${root.toString()}");
  }

  /// Get the node at a specific path, asserting that it's a descendant node.
  static Descendant descendant(Node root, Path path) {
    Node node = NodeUtils.get(root, path);

    if (node is Editor) {
      throw Exception(
          "Cannot get the descendant node at path [$path] because it refers to the root editor node instead: $node");
    }

    return node;
  }

  /// Return an iterable of all the descendant node entries inside a root node.
  static Iterable<NodeEntry<Descendant>> descendants(Node root,
      {Path from,
      Path to,
      bool reverse = false,
      bool Function(NodeEntry entry) pass}) sync* {
    for (NodeEntry node in NodeUtils.nodes(root,
        from: from, to: to, reverse: reverse, pass: pass)) {
      if (node.path.length != 0) {
        node = NodeEntry<Descendant>(node.node, node.path);
        // NOTE: we have to coerce here because checking the path's length does
        // guarantee that `node` is not a `Editor`, but TypeScript doesn't know.
        yield node;
      }
    }
  }

  /// Return an iterable of all the element nodes inside a root node. Each iteration
  /// will return an `ElementEntry` tuple consisting of `[Element, Path]`. If the
  /// root node is an element it will be included in the iteration as well.
  static Iterable<ElementEntry> elements(Node root,
      {Path from,
      Path to,
      bool reverse = false,
      bool Function(NodeEntry entry) pass}) sync* {
    for (NodeEntry entry in NodeUtils.nodes(root,
        from: from, to: to, reverse: reverse, pass: pass)) {
      if (entry.node is Element) {
        ElementEntry elemEntry = ElementEntry(entry.node, entry.path);

        yield elemEntry;
      }
    }
  }

  /// Get the first node entry in a root node from a path.
  static NodeEntry first(Node root, Path path) {
    Path p = path.slice();
    Node n = NodeUtils.get(root, p);

    while (n != null) {
      if (n is Text) {
        break;
      }

      if ((n as Ancestor).children.length == 0) {
        break;
      }

      n = (n as Ancestor).children[0];
      p.path.add(0);
    }

    return NodeEntry(n, p);
  }

  /// Get the sliced fragment represented by a range inside a root node.
  static List<Descendant> fragment(Node root, Range range) {
    if (root is Text) {
      throw Exception(
          "Cannot get a fragment starting from a root text node: ${root.toString()}");
    }

    Ancestor newRoot = NodeUtils.copy(root);

    Edges edges = RangeUtils.edges(range);
    Point start = edges.start;
    Point end = edges.end;

    Iterable<NodeEntry<Node>> nodes =
        NodeUtils.nodes(newRoot, reverse: true, pass: (entry) {
      return !RangeUtils.includes(range, entry.path);
    });

    for (NodeEntry<Node> entry in nodes) {
      Path path = entry.path;

      if (!RangeUtils.includes(range, path)) {
        Ancestor parent = NodeUtils.parent(newRoot, path);
        int index = path.path[path.length - 1];
        parent.children = parent.children.sublist(index, 1);
      }

      if (PathUtils.equals(path, end.path)) {
        Text leaf = NodeUtils.leaf(newRoot, path);
        leaf.text = leaf.text.substring(0, end.offset);
      }

      if (PathUtils.equals(path, start.path)) {
        Text leaf = NodeUtils.leaf(newRoot, path);
        leaf.text = leaf.text.substring(start.offset);
      }
    }

    if (newRoot is Editor) {
      newRoot.selection = null;
    }

    return newRoot.children;
  }

  /// Get the descendant node referred to by a specific path. If the path is an
  /// empty array, it refers to the root node itself.
  static Node get(Node root, Path path) {
    Node node = root;

    // Traverse the nodes tree with the given path
    for (int i = 0; i < path.length; i++) {
      int p = path.path[i];

      if (node is Text) {
        throw Exception(
            "Cannot find a descendant at path [$path] because it refers to a text node instead: ${node.toString()}");
      }

      if ((node as Ancestor).children[p] == null) {
        throw Exception(
            "Cannot find a descendant at path [$path] in node: ${root.toString()}");
      }

      node = (node as Ancestor).children[p];
    }

    return node;
  }

  /// Check if a descendant node exists at a specific path.
  static bool has(Node root, Path path) {
    Node node = root;

    for (int i = 0; i < path.length; i++) {
      int p = path.path[i];

      if (node is Text) {
        return false;
      }

      // Position p (child index) is greater than the node's children length
      if ((node as Ancestor).children.length - 1 < p ||
          (node as Ancestor).children[p] == null) {
        return false;
      }

      node = (node as Ancestor).children[p];
    }

    return true;
  }

  /// Get the lash node entry in a root node from a path.
  static NodeEntry last(Node root, Path path) {
    Path p = path.slice();
    Node n = NodeUtils.get(root, p);

    while (n != null) {
      if (n is Text) {
        break;
      }

      if ((n as Ancestor).children.length == 0) {
        break;
      }

      int i = (n as Ancestor).children.length - 1;
      n = (n as Ancestor).children[i];
      p.path.add(i);
    }

    return NodeEntry(n, p);
  }

  /// Get the node at a specific path, ensuring it's a leaf text node.
  static Text leaf(Node root, Path path) {
    Node node = NodeUtils.get(root, path);

    if (!(node is Text)) {
      throw Exception(
          "Cannot get the leaf node at path [$path] because it refers to a non-leaf node: ${node.toString()}");
    }

    return node;
  }

  /// Return an iterable of the in a branch of the tree, from a specific path.
  ///
  /// By default the order is top-down, from lowest to highest node in the tree,
  /// but you can pass the `reverse: true` option to go bottom-up.
  static Iterable<NodeEntry> levels(Node root, Path path,
      {bool reverse = false}) sync* {
    for (Path p in PathUtils.levels(path, reverse: reverse)) {
      Node n = NodeUtils.get(root, p);
      yield NodeEntry(n, p);
    }
  }

  /// Return an iterable of all the node entries of a root node. Each entry is
  /// returned as a `[Node, Path]` tuple, with the path referring to the node's
  /// position inside the root node.
  ///
  /// Optional predicate [pass] to exclude a node entry.
  /// Optional path [from] to indicate from which path to take nodes from.
  /// Note that it will still include root node
  static Iterable<NodeEntry> nodes(Node root,
      {Path from,
      Path to,
      bool reverse = false,
      bool Function(NodeEntry entry) pass}) sync* {
    from = from ?? Path([]);
    Set<Node> visited = Set();
    Path p = Path([]);
    Node n = root;

    while (true) {
      if (to != null &&
          (reverse ? PathUtils.isBefore(p, to) : PathUtils.isAfter(p, to))) {
        break;
      }

      if (!visited.contains(n)) {
        yield NodeEntry(n, p);
      }

      // If we're allowed to go downward and we haven't descended yet, do.
      if (!visited.contains(n) &&
          !(n is Text) &&
          (n as Ancestor).children.length != 0 &&
          (pass == null || pass(NodeEntry(n, p)) == false)) {
        visited.add(n);
        int nextIndex = reverse ? (n as Ancestor).children.length - 1 : 0;

        if (PathUtils.isAncestor(p, from)) {
          nextIndex = from.path[p.length];
        }
        List<int> newPositions = List.from(p.path);
        newPositions.add(nextIndex);
        p = Path(newPositions);
        n = NodeUtils.get(root, p);
        continue;
      }

      // If we're at the root and we can't go down, we're done.
      if (p.length == 0) {
        break;
      }

      // If we're going forward...
      if (!reverse) {
        Path newPath = PathUtils.next(p);

        if (NodeUtils.has(root, newPath)) {
          p = newPath;
          n = NodeUtils.get(root, p);
          continue;
        }
      }

      // If we're going backward...
      if (reverse && p.path[p.length - 1] != 0) {
        Path newPath = PathUtils.previous(p);
        p = newPath;
        n = NodeUtils.get(root, p);
        continue;
      }

      // Otherwise we're going upward...
      p = PathUtils.parent(p);
      n = NodeUtils.get(root, p);
      visited.add(n);
    }
  }

  /// Get the parent of a node at a specific path.
  static Ancestor parent(Node root, Path path) {
    Path parentPath = PathUtils.parent(path);
    Node p = NodeUtils.get(root, parentPath);

    if (p is Text) {
      throw Exception(
          "Cannot get the parent of path [$path] because it does not exist in the root.");
    }

    return p;
  }

  /// Get the concatenated text string of a node's content.
  ///
  /// Note that this will not include spaces or line breaks between block nodes.
  /// It is not a user-facing string, but a string for performing offset-related
  /// computations for a node.
  static String string(Node node) {
    if (node is Text) {
      return node.text;
    } else {
      return (node as Ancestor).children.map(NodeUtils.string).join('');
    }
  }

  /// Return an iterable of all leaf text nodes in a root node.
  static Iterable<NodeEntry<Text>> texts(Node root,
      {Path from,
      Path to,
      bool reverse = false,
      bool Function(NodeEntry entry) pass}) sync* {
    for (NodeEntry node in NodeUtils.nodes(root,
        from: from, to: to, reverse: reverse, pass: pass)) {
      if (node.node is Text) {
        node = NodeEntry<Text>(node.node, node.path);
        yield node;
      }
    }
  }
}
