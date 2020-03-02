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

      List<NodeEntry<Ancestor>> nodes = List<NodeEntry<Ancestor>>.from(
          Node.ancestors(editor, Path([0, 0]), reverse: true));

      expect(nodes[0].node, editor.children[0]);
      expect(Path.equals(nodes[0].path, Path([0])), true);

      expect(nodes[1].node, editor);
      expect(Path.equals(nodes[1].path, Path([])), true);
    });

    test('success', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text("a")])
      ]);

      List<NodeEntry<Ancestor>> nodes =
          List<NodeEntry<Ancestor>>.from(Node.ancestors(editor, Path([0, 0])));

      expect(nodes[0].node, editor);
      expect(Path.equals(nodes[0].path, Path([])), true);

      expect(nodes[1].node, editor.children[0]);
      expect(Path.equals(nodes[1].path, Path([0])), true);
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
    test('all', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text("a"), Text("b")])
      ]);

      List<NodeEntry<Descendant>> children =
          List<NodeEntry<Descendant>>.from(Node.children(editor, Path([0])));

      expect(Text.equals(children[0].node, Text("a")), true);
      expect(Path.equals(children[0].path, Path([0, 0])), true);

      expect(Text.equals(children[1].node, Text("b")), true);
      expect(Path.equals(children[1].path, Path([0, 1])), true);
    });

    test('reverse', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text("a"), Text("b")])
      ]);

      List<NodeEntry<Descendant>> nodes = List<NodeEntry<Descendant>>.from(
          Node.children(editor, Path([0]), reverse: true));

      expect(Text.equals(nodes[0].node, Text("b")), true);
      expect(Path.equals(nodes[0].path, Path([0, 1])), true);

      expect(Text.equals(nodes[1].node, Text("a")), true);
      expect(Path.equals(nodes[1].path, Path([0, 0])), true);
    });
  });

  group("descendant", () {
    test('success', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text("a")])
      ]);

      expect(Node.descendant(editor, Path([0])), editor.children[0]);
    });
  });

  group("descendants", () {
    test('all', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text("a"), Text("b")])
      ]);

      List<NodeEntry<Descendant>> nodes =
          List<NodeEntry<Descendant>>.from(Node.descendants(editor));

      expect(nodes[0].node, editor.children[0]);
      expect(Path.equals(nodes[0].path, Path([0])), true);

      expect(Text.equals(nodes[1].node, Text("a")), true);
      expect(Path.equals(nodes[1].path, Path([0, 0])), true);

      expect(Text.equals(nodes[2].node, Text("b")), true);
      expect(Path.equals(nodes[2].path, Path([0, 1])), true);
    });

    test('from', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text("a"), Text("b")])
      ]);

      List<NodeEntry<Descendant>> nodes = List<NodeEntry<Descendant>>.from(
          Node.descendants(editor, from: Path([0, 1])));

      expect(nodes[0].node, editor.children[0]);
      expect(Path.equals(nodes[0].path, Path([0])), true);

      expect(Text.equals(nodes[1].node, Text("b")), true);
      expect(Path.equals(nodes[1].path, Path([0, 1])), true);
    });

    test('reverse', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text("a"), Text("b")])
      ]);

      List<NodeEntry<Descendant>> nodes = List<NodeEntry<Descendant>>.from(
          Node.descendants(editor, reverse: true));

      expect(nodes[0].node, editor.children[0]);
      expect(Path.equals(nodes[0].path, Path([0])), true);

      expect(Text.equals(nodes[1].node, Text("b")), true);
      expect(Path.equals(nodes[1].path, Path([0, 1])), true);

      expect(Text.equals(nodes[2].node, Text("a")), true);
      expect(Path.equals(nodes[2].path, Path([0, 0])), true);
    });

    test('to', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text("a"), Text("b"), Text("c"), Text("d")])
      ]);

      List<NodeEntry<Descendant>> nodes = List<NodeEntry<Descendant>>.from(
          Node.descendants(editor, from: Path([0, 1]), to: Path([0, 2])));

      expect(nodes[0].node, editor.children[0]);
      expect(Path.equals(nodes[0].path, Path([0])), true);

      expect(Text.equals(nodes[1].node, Text("b")), true);
      expect(Path.equals(nodes[1].path, Path([0, 1])), true);

      expect(Text.equals(nodes[2].node, Text("c")), true);
      expect(Path.equals(nodes[2].path, Path([0, 2])), true);
    });
  });
}
