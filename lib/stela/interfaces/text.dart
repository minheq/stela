import 'package:inday/stela/interfaces/node.dart';
import 'package:inday/stela/interfaces/range.dart';

/// `Text` objects represent the nodes that contain the actual text content of a
/// document along with any formatting properties. They are always leaf
/// nodes in the document tree as they cannot contain any children.
class Text extends Node {
  Text(this.text);

  String text;

  /// Check if two `Text` nodes are equal.
  static bool equals(Text text, Text another) {
    return text.text == another.text;
  }

  /// Check if the node is `Text` node
  static bool isText(Node node) {
    return node is Text;
  }

  /// Check if list of nodes consist of only `Text` nodes.
  static bool isTextList(List<Node> nodes) {
    for (Node node in nodes) {
      if (Text.isText(node) == false) {
        return false;
      }
    }

    return true;
  }

  // /// Check if an `Text` matches set of properties.
  // ///
  // /// Note: this is for matching custom properties, and it does not ensure that
  // /// the `text` property are two nodes equal.
  // static bool matches(Text text, Object props) {
  //   for (var key in props) {
  //     if (key == 'text') {
  //       continue;
  //     }

  //     // if (text[key] != props[key]) {
  //     //   return false;
  //     // }
  //   }

  //   return true;
  // }

  // /// Get the leaves for a text node given decorations.
  // static List<Text> decorations(Text text, List<Range> decorations) {
  //   List<Text> leaves = [text];

  //   for (Range decoration in decorations) {
  //     const { anchor, focus, ...rest } = decoration;
  //     const [start, end] = Range.edges(dec)
  //     const next = []
  //     let o = 0

  //     for (const leaf of leaves) {
  //       const { length } = leaf.text
  //       const offset = o
  //       o += length

  //       // If the range encompases the entire leaf, add the range.
  //       if (start.offset <= offset && end.offset >= offset + length) {
  //         Object.assign(leaf, rest)
  //         next.push(leaf)
  //         continue
  //       }

  //       // If the range starts after the leaf, or ends before it, continue.
  //       if (
  //         start.offset > offset + length ||
  //         end.offset < offset ||
  //         (end.offset === offset && offset !== 0)
  //       ) {
  //         next.push(leaf)
  //         continue
  //       }

  //       // Otherwise we need to split the leaf, at the start, end, or both,
  //       // and add the range to the middle intersecting section. Do the end
  //       // split first since we don't need to update the offset that way.
  //       let middle = leaf
  //       let before
  //       let after

  //       if (end.offset < offset + length) {
  //         const off = end.offset - offset
  //         after = { ...middle, text: middle.text.slice(off) }
  //         middle = { ...middle, text: middle.text.slice(0, off) }
  //       }

  //       if (start.offset > offset) {
  //         const off = start.offset - offset
  //         before = { ...middle, text: middle.text.slice(0, off) }
  //         middle = { ...middle, text: middle.text.slice(off) }
  //       }

  //       Object.assign(middle, rest)

  //       if (before) {
  //         next.push(before)
  //       }

  //       next.push(middle)

  //       if (after) {
  //         next.push(after)
  //       }
  //     }

  //     leaves = next
  //   }

  //   return leaves
  // }
}
