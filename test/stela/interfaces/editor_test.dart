import 'package:flutter_test/flutter_test.dart';
import 'package:inday/stela/interfaces/editor.dart';
import 'package:inday/stela/interfaces/element.dart';
import 'package:inday/stela/interfaces/node.dart';
import 'package:inday/stela/interfaces/path.dart';
import 'package:inday/stela/interfaces/text.dart';

void main() {
  group("above", () {
    test('block highest', () {
      Editor editor = Editor(children: <Node>[
        Block(children: <Node>[
          Block(children: <Node>[Text("one")])
        ])
      ]);

      NodeEntry entry = EditorUtils.above(editor,
          at: Path([0, 0, 0]), mode: Mode.highest, match: (node) {
        return EditorUtils.isBlock(editor, node);
      });

      expect(entry.node, editor.children[0]);
      expect(PathUtils.equals(entry.path, Path([0])), true);
    });
  });
}
