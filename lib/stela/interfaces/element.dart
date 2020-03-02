import 'package:inday/stela/interfaces/node.dart';
import 'package:inday/stela/interfaces/path.dart';

/// `Element` objects are a type of node that contain other
/// element nodes or text nodes. They can be either "blocks" or "inlines"
/// depending on the editor's configuration.
class Element implements Ancestor, Descendant {
  Element({this.children = const <Node>[]});

  List<Node> children;

  /// Check if list of nodes consist of only `Element` nodes.
  static bool isElementList(List<Node> nodes) {
    for (Node node in nodes) {
      if (node is Element == false) {
        return false;
      }
    }

    return true;
  }

  // /// Check if an element matches set of properties.
  // ///
  // /// Note: this checks custom properties, and it does not ensure that any
  // /// children are equivalent.
  // matches(element: Element, props: Partial<Element>): boolean {
  //   for (const key in props) {
  //     if (key === 'children') {
  //       continue
  //     }

  //     if (element[key] !== props[key]) {
  //       return false
  //     }
  //   }

  //   return true
  // }
}

/// `ElementEntry` objects refer to an `Element` and the `Path` where it can be
/// found inside a root node.
class ElementEntry {
  ElementEntry(this.element, this.path);

  final Element element;
  final Path path;
}
