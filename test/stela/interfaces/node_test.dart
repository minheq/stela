import 'package:flutter_test/flutter_test.dart';
import 'package:inday/stela/interfaces/editor.dart';
import 'package:inday/stela/interfaces/element.dart';
import 'package:inday/stela/interfaces/node.dart';
import 'package:inday/stela/interfaces/path.dart';
import 'package:inday/stela/interfaces/text.dart';

void main() {
  group("ancestor", () {
    test('success', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text("a")])
      ]);

      expect(Node.ancestor(editor, Path([0])), editor.children[0]);
    });
  });

  group("ancestors", () {
    test('reverse', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text("a")])
      ]);

      List<NodeEntry<Ancestor>> entries = List<NodeEntry<Ancestor>>.from(
          Node.ancestors(editor, Path([0, 0]), reverse: true));

      expect(entries[0].node, editor.children[0]);
      expect(Path.equals(entries[0].path, Path([0])), true);

      expect(entries[1].node, editor);
      expect(Path.equals(entries[1].path, Path([])), true);
    });

    test('success', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text("a")])
      ]);

      List<NodeEntry<Ancestor>> entries =
          List<NodeEntry<Ancestor>>.from(Node.ancestors(editor, Path([0, 0])));

      expect(entries[0].node, editor);
      expect(Path.equals(entries[0].path, Path([])), true);

      expect(entries[1].node, editor.children[0]);
      expect(Path.equals(entries[1].path, Path([0])), true);
    });
  });

  group("child", () {
    test('success', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text("a")])
      ]);

      expect(Node.child(editor, 0), editor.children[0]);
    });
  });

  group("children", () {
    test('success', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text("a"), Text("b")])
      ]);

      expect(Node.child(editor, 0), editor.children[0]);
    });
  });
}
