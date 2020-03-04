import 'package:flutter_test/flutter_test.dart';
import 'package:inday/stela/editor.dart';
import 'package:inday/stela/element.dart';
import 'package:inday/stela/node.dart';
import 'package:inday/stela/operation.dart';
import 'package:inday/stela/path.dart';
import 'package:inday/stela/range.dart';
import 'package:inday/stela/text.dart';

class TestEditor extends Editor {
  TestEditor(
      {List<Node> children,
      Range selection,
      List<Operation> operations,
      Map<String, dynamic> marks,
      Map<String, dynamic> props})
      : super(
            children: children,
            selection: selection,
            operations: operations,
            marks: marks,
            props: props);

  @override
  bool isInline(Element element) {
    return element is Inline;
  }
}

void main() {
  group("above", () {
    test('block highest', () {
      Block highest = Block(children: <Node>[
        Block(children: <Node>[Text("one")])
      ]);
      Editor editor = Editor(children: <Node>[highest]);

      NodeEntry entry = EditorUtils.above(editor,
          at: Path([0, 0, 0]), mode: Mode.highest, match: (node) {
        return EditorUtils.isBlock(editor, node);
      });

      expect(entry.node, highest);
      expect(PathUtils.equals(entry.path, Path([0])), true);
    });

    test('block lowest', () {
      Block lowest = Block(children: <Node>[Text("one")]);
      Editor editor = Editor(children: <Node>[
        Block(children: <Node>[lowest])
      ]);

      NodeEntry entry = EditorUtils.above(editor,
          at: Path([0, 0, 0]), mode: Mode.lowest, match: (node) {
        return EditorUtils.isBlock(editor, node);
      });

      expect(entry.node, lowest);
      expect(PathUtils.equals(entry.path, Path([0, 0])), true);
    });

    test('inline', () {
      Inline inline = Inline(children: <Node>[Text("two")]);
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[Text("one"), inline, Text("three")])
      ]);

      NodeEntry entry =
          EditorUtils.above(editor, at: Path([0, 1, 0]), match: (node) {
        bool isInline = EditorUtils.isInline(editor, node);
        return isInline;
      });

      expect(entry.node, inline);
      expect(PathUtils.equals(entry.path, Path([0, 1])), true);
    });
  });
}
