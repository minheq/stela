import 'package:inday/stela/interfaces/node.dart';
import 'package:inday/stela/interfaces/point.dart';
import 'package:inday/stela/interfaces/range.dart';

/// `Text` objects represent the nodes that contain the actual text content of a
/// document along with any formatting properties. They are always leaf
/// nodes in the document tree as they cannot contain any children.
class Text implements Descendant {
  Text(this.text, {this.props = const {}});

  /// Text content
  String text;

  /// Custom properties that can extend the `Text` behavior
  Map<String, dynamic> props;
}

class TextUtils {
  /// Check if two `Text` nodes are equal.
  static bool equals(Text text, Text another) {
    return text.text == another.text;
  }

  /// Check if list of nodes consist of only `Text` nodes.
  static bool isTextList(List<Node> nodes) {
    for (Node node in nodes) {
      if (!(node is Text)) {
        return false;
      }
    }

    return true;
  }

  /// Get the leaves for a text node given decorations.
  static List<Text> decorations(Text text, List<Decoration> decorations) {
    List<Text> leaves = [text];

    for (Decoration dec in decorations) {
      Edges edges = RangeUtils.edges(dec);
      Point start = edges.start;
      Point end = edges.end;

      List<Text> next = [];
      int o = 0;

      for (Text leaf in leaves) {
        int length = leaf.text.length;
        int offset = o;
        o += length;

        // If the range encompases the entire leaf, add the range.
        if (start.offset <= offset && end.offset >= offset + length) {
          leaf.props.addAll(dec.props);
          next.add(leaf);
          continue;
        }

        // If the range starts after the leaf, or ends before it, continue.
        if (start.offset > offset + length ||
            end.offset < offset ||
            (end.offset == offset && offset != 0)) {
          next.add(leaf);
          continue;
        }

        // Otherwise we need to split the leaf, at the start, end, or both,
        // and add the range to the middle intersecting section. Do the end
        // split first since we don't need to update the offset that way.
        Text middle = leaf;
        Text before;
        Text after;

        if (end.offset < offset + length) {
          int off = end.offset - offset;

          after = Text(middle.text.substring(off), props: middle.props);
          middle = Text(middle.text.substring(0, off), props: middle.props);
        }

        if (start.offset > offset) {
          int off = start.offset - offset;

          before = Text(middle.text.substring(0, off), props: middle.props);
          middle = Text(middle.text.substring(off), props: middle.props);
        }

        middle.props.addAll(dec.props);

        if (before != null) {
          next.add(before);
        }

        next.add(middle);

        if (after != null) {
          next.add(after);
        }
      }

      leaves = next;
    }

    return leaves;
  }
}
