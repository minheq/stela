import 'package:flutter_test/flutter_test.dart';
import 'package:inday/stela/editor.dart';
import 'package:inday/stela/element.dart';
import 'package:inday/stela/node.dart';
import 'package:inday/stela/path.dart';
import 'package:inday/stela/text.dart';

void main() {
  group('ancestor', () {
    test('success', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text('a')])
      ]);

      expect(NodeUtils.ancestor(editor, Path([0])), editor.children[0]);
    });
  });

  group('ancestors', () {
    test('reverse', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text('a')])
      ]);

      List<NodeEntry<Ancestor>> nodes = List<NodeEntry<Ancestor>>.from(
          NodeUtils.ancestors(editor, Path([0, 0]), reverse: true));

      expect(nodes[0].node, editor.children[0]);
      expect(nodes[0].path.equals(Path([0])), true);

      expect(nodes[1].node, editor);
      expect(nodes[1].path.equals(Path([])), true);
    });

    test('success', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text('a')])
      ]);

      List<NodeEntry<Ancestor>> nodes = List<NodeEntry<Ancestor>>.from(
          NodeUtils.ancestors(editor, Path([0, 0])));

      expect(nodes[0].node, editor);
      expect(nodes[0].path.equals(Path([])), true);

      expect(nodes[1].node, editor.children[0]);
      expect(nodes[1].path.equals(Path([0])), true);
    });
  });

  group('child', () {
    test('success', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text('a')])
      ]);

      expect(NodeUtils.child(editor, 0), editor.children[0]);
    });
  });

  group('children', () {
    test('all', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text('a'), Text('b')])
      ]);

      List<NodeEntry<Descendant>> children = List<NodeEntry<Descendant>>.from(
          NodeUtils.children(editor, Path([0])));

      expect(TextUtils.equals(children[0].node, Text('a')), true);
      expect(children[0].path.equals(Path([0, 0])), true);

      expect(TextUtils.equals(children[1].node, Text('b')), true);
      expect(children[1].path.equals(Path([0, 1])), true);
    });

    test('reverse', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text('a'), Text('b')])
      ]);

      List<NodeEntry<Descendant>> nodes = List<NodeEntry<Descendant>>.from(
          NodeUtils.children(editor, Path([0]), reverse: true));

      expect(TextUtils.equals(nodes[0].node, Text('b')), true);
      expect(nodes[0].path.equals(Path([0, 1])), true);

      expect(TextUtils.equals(nodes[1].node, Text('a')), true);
      expect(nodes[1].path.equals(Path([0, 0])), true);
    });
  });

  group('descendant', () {
    test('success', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text('a')])
      ]);

      expect(NodeUtils.descendant(editor, Path([0])), editor.children[0]);
    });
  });

  group('descendants', () {
    test('all', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text('a'), Text('b')])
      ]);

      List<NodeEntry<Descendant>> nodes =
          List<NodeEntry<Descendant>>.from(NodeUtils.descendants(editor));

      expect(nodes[0].node, editor.children[0]);
      expect(nodes[0].path.equals(Path([0])), true);

      expect(TextUtils.equals(nodes[1].node, Text('a')), true);
      expect(nodes[1].path.equals(Path([0, 0])), true);

      expect(TextUtils.equals(nodes[2].node, Text('b')), true);
      expect(nodes[2].path.equals(Path([0, 1])), true);
    });

    test('from', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text('a'), Text('b')])
      ]);

      List<NodeEntry<Descendant>> nodes = List<NodeEntry<Descendant>>.from(
          NodeUtils.descendants(editor, from: Path([0, 1])));

      expect(nodes[0].node, editor.children[0]);
      expect(nodes[0].path.equals(Path([0])), true);

      expect(TextUtils.equals(nodes[1].node, Text('b')), true);
      expect(nodes[1].path.equals(Path([0, 1])), true);
    });

    test('reverse', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text('a'), Text('b')])
      ]);

      List<NodeEntry<Descendant>> nodes = List<NodeEntry<Descendant>>.from(
          NodeUtils.descendants(editor, reverse: true));

      expect(nodes[0].node, editor.children[0]);
      expect(nodes[0].path.equals(Path([0])), true);

      expect(TextUtils.equals(nodes[1].node, Text('b')), true);
      expect(nodes[1].path.equals(Path([0, 1])), true);

      expect(TextUtils.equals(nodes[2].node, Text('a')), true);
      expect(nodes[2].path.equals(Path([0, 0])), true);
    });

    test('to', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text('a'), Text('b'), Text('c'), Text('d')])
      ]);

      List<NodeEntry<Descendant>> nodes = List<NodeEntry<Descendant>>.from(
          NodeUtils.descendants(editor, from: Path([0, 1]), to: Path([0, 2])));

      expect(nodes[0].node, editor.children[0]);
      expect(nodes[0].path.equals(Path([0])), true);

      expect(TextUtils.equals(nodes[1].node, Text('b')), true);
      expect(nodes[1].path.equals(Path([0, 1])), true);

      expect(TextUtils.equals(nodes[2].node, Text('c')), true);
      expect(nodes[2].path.equals(Path([0, 2])), true);
    });
  });

  group('elements', () {
    test('all', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text('a'), Text('b')])
      ]);

      List<ElementEntry> elements =
          List<ElementEntry>.from(NodeUtils.elements(editor));

      expect(elements[0].element, editor.children[0]);
      expect(elements[0].path.equals(Path([0])), true);
    });

    test('reverse', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text('a'), Text('b')])
      ]);

      List<ElementEntry> elements =
          List<ElementEntry>.from(NodeUtils.elements(editor, reverse: true));

      expect(elements[0].element, editor.children[0]);
      expect(elements[0].path.equals(Path([0])), true);
    });
  });

  group('first', () {
    test('success', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text('a'), Text('b')])
      ]);

      NodeEntry entry = NodeUtils.first(editor, Path([0]));

      expect(entry.node, (editor.children[0] as Ancestor).children[0]);
      expect(entry.path.equals(Path([0, 0])), true);
    });
  });

  group('get', () {
    test('root', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text('a')])
      ]);

      Node node = NodeUtils.get(editor, Path([]));

      expect(node, editor);
    });

    test('success', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text('a')])
      ]);

      Node node = NodeUtils.get(editor, Path([0]));

      expect(node, editor.children[0]);
    });
  });

  group('has', () {
    test('exists', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text('a')])
      ]);

      expect(NodeUtils.has(editor, Path([0])), true);
    });

    test('not exists', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text('a')])
      ]);

      expect(NodeUtils.has(editor, Path([1])), false);
    });
  });

  group('last', () {
    test('success', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text('a'), Text('b')])
      ]);

      NodeEntry entry = NodeUtils.last(editor, Path([0]));

      expect(entry.node, (editor.children[0] as Ancestor).children[1]);
      expect(entry.path.equals(Path([0, 1])), true);
    });
  });

  group('leaf', () {
    test('succes', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text('a')])
      ]);

      Text leaf = NodeUtils.leaf(editor, Path([0, 0]));

      expect(TextUtils.equals(leaf, Text('a')), true);
    });
  });

  group('levels', () {
    test('reverse', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text('a')])
      ]);

      List<NodeEntry<Node>> nodes = List<NodeEntry<Node>>.from(
          NodeUtils.levels(editor, Path([0, 0]), reverse: true));

      expect(TextUtils.equals(nodes[0].node, Text('a')), true);
      expect(nodes[0].path.equals(Path([0, 0])), true);

      expect(nodes[1].node, editor.children[0]);
      expect(nodes[1].path.equals(Path([0])), true);

      expect(nodes[2].node, editor);
      expect(nodes[2].path.equals(Path([])), true);
    });

    test('success', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text('a')])
      ]);

      List<NodeEntry<Node>> nodes =
          List<NodeEntry<Node>>.from(NodeUtils.levels(editor, Path([0, 0])));

      expect(nodes[0].node, editor);
      expect(nodes[0].path.equals(Path([])), true);

      expect(nodes[1].node, editor.children[0]);
      expect(nodes[1].path.equals(Path([0])), true);

      expect(TextUtils.equals(nodes[2].node, Text('a')), true);
      expect(nodes[2].path.equals(Path([0, 0])), true);
    });
  });

  group('nodes', () {
    test('all', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text('a'), Text('b')])
      ]);

      List<NodeEntry<Node>> nodes =
          List<NodeEntry<Node>>.from(NodeUtils.nodes(editor));

      expect(nodes[0].node, editor);
      expect(nodes[0].path.equals(Path([])), true);

      expect(nodes[1].node, editor.children[0]);
      expect(nodes[1].path.equals(Path([0])), true);

      expect(TextUtils.equals(nodes[2].node, Text('a')), true);
      expect(nodes[2].path.equals(Path([0, 0])), true);

      expect(TextUtils.equals(nodes[3].node, Text('b')), true);
      expect(nodes[3].path.equals(Path([0, 1])), true);
    });

    test('from', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text('a'), Text('b')]),
        Element(children: <Node>[Text('c'), Text('d')])
      ]);

      List<NodeEntry<Node>> nodes = List<NodeEntry<Node>>.from(
          NodeUtils.nodes(editor, from: Path([0, 1])));

      expect(nodes[0].node, editor);
      expect(nodes[0].path.equals(Path([])), true);

      expect(nodes[1].node, editor.children[0]);
      expect(nodes[1].path.equals(Path([0])), true);

      expect(TextUtils.equals(nodes[2].node, Text('b')), true);
      expect(nodes[2].path.equals(Path([0, 1])), true);

      expect(nodes[3].node, editor.children[1]);
      expect(nodes[3].path.equals(Path([1])), true);

      expect(TextUtils.equals(nodes[4].node, Text('c')), true);
      expect(nodes[4].path.equals(Path([1, 0])), true);

      expect(TextUtils.equals(nodes[5].node, Text('d')), true);
      expect(nodes[5].path.equals(Path([1, 1])), true);
    });

    test('multiple elements', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text('a')]),
        Element(children: <Node>[Text('b')])
      ]);

      List<NodeEntry<Node>> nodes =
          List<NodeEntry<Node>>.from(NodeUtils.nodes(editor));

      expect(nodes[0].node, editor);
      expect(nodes[0].path.equals(Path([])), true);

      expect(nodes[1].node, editor.children[0]);
      expect(nodes[1].path.equals(Path([0])), true);

      expect(TextUtils.equals(nodes[2].node, Text('a')), true);
      expect(nodes[2].path.equals(Path([0, 0])), true);

      expect(nodes[3].node, editor.children[1]);
      expect(nodes[3].path.equals(Path([1])), true);

      expect(TextUtils.equals(nodes[4].node, Text('b')), true);
      expect(nodes[4].path.equals(Path([1, 0])), true);
    });

    test('nested elements', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[
          Element(children: <Node>[Text('a')])
        ])
      ]);

      List<NodeEntry<Node>> nodes =
          List<NodeEntry<Node>>.from(NodeUtils.nodes(editor));

      expect(nodes[0].node, editor);
      expect(nodes[0].path.equals(Path([])), true);

      Ancestor firstElement = editor.children[0];

      expect(nodes[1].node, firstElement);
      expect(nodes[1].path.equals(Path([0])), true);

      Ancestor secondElement = firstElement.children[0];

      expect(nodes[2].node, secondElement);
      expect(nodes[2].path.equals(Path([0, 0])), true);

      expect(TextUtils.equals(nodes[3].node, Text('a')), true);
      expect(nodes[3].path.equals(Path([0, 0, 0])), true);
    });

    test('pass', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[
          Element(children: <Node>[Text('a')])
        ])
      ]);

      List<NodeEntry<Node>> nodes =
          List<NodeEntry<Node>>.from(NodeUtils.nodes(editor, pass: (node) {
        return node.path.length > 1;
      }));

      expect(nodes[0].node, editor);
      expect(nodes[0].path.equals(Path([])), true);

      Ancestor firstElement = editor.children[0];

      expect(nodes[1].node, firstElement);
      expect(nodes[1].path.equals(Path([0])), true);

      Ancestor secondElement = firstElement.children[0];

      expect(nodes[2].node, secondElement);
      expect(nodes[2].path.equals(Path([0, 0])), true);

      expect(nodes.length, 3);
    });

    test('reverse', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text('a'), Text('b')]),
        Element(children: <Node>[Text('c'), Text('d')])
      ]);

      List<NodeEntry<Node>> nodes =
          List<NodeEntry<Node>>.from(NodeUtils.nodes(editor, reverse: true));

      expect(nodes[0].node, editor);
      expect(nodes[0].path.equals(Path([])), true);

      expect(nodes[1].node, editor.children[1]);
      expect(nodes[1].path.equals(Path([1])), true);

      expect(TextUtils.equals(nodes[2].node, Text('d')), true);
      expect(nodes[2].path.equals(Path([1, 1])), true);

      expect(TextUtils.equals(nodes[3].node, Text('c')), true);
      expect(nodes[3].path.equals(Path([1, 0])), true);

      expect(nodes[4].node, editor.children[0]);
      expect(nodes[4].path.equals(Path([0])), true);

      expect(TextUtils.equals(nodes[5].node, Text('b')), true);
      expect(nodes[5].path.equals(Path([0, 1])), true);

      expect(TextUtils.equals(nodes[6].node, Text('a')), true);
      expect(nodes[6].path.equals(Path([0, 0])), true);
    });

    test('to', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text('a'), Text('b'), Text('c'), Text('d')]),
      ]);

      List<NodeEntry<Node>> nodes = List<NodeEntry<Node>>.from(
          NodeUtils.nodes(editor, from: Path([0, 1]), to: Path([0, 2])));

      expect(nodes[0].node, editor);
      expect(nodes[0].path.equals(Path([])), true);

      expect(nodes[1].node, editor.children[0]);
      expect(nodes[1].path.equals(Path([0])), true);

      expect(TextUtils.equals(nodes[2].node, Text('b')), true);
      expect(nodes[2].path.equals(Path([0, 1])), true);

      expect(TextUtils.equals(nodes[3].node, Text('c')), true);
      expect(nodes[3].path.equals(Path([0, 2])), true);
    });
  });

  group('parent', () {
    test('success', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text('a')])
      ]);

      Ancestor node = NodeUtils.parent(editor, Path([0, 0]));

      expect(node, editor.children[0]);
    });
  });

  group('string', () {
    test('across elements', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text('a'), Text('b')]),
        Element(children: <Node>[Text('c'), Text('d')])
      ]);

      expect(NodeUtils.string(editor), 'abcd');
    });

    test('element', () {
      Element node = Element(children: <Node>[Text('a'), Text('b')]);

      expect(NodeUtils.string(node), 'ab');
    });

    test('text', () {
      Text node = Text('a');

      expect(NodeUtils.string(node), 'a');
    });
  });

  group('texts', () {
    test('all', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text('a'), Text('b')]),
      ]);

      List<NodeEntry<Text>> texts =
          List<NodeEntry<Text>>.from(NodeUtils.texts(editor));

      expect(TextUtils.equals(texts[0].node, Text('a')), true);
      expect(texts[0].path.equals(Path([0, 0])), true);

      expect(TextUtils.equals(texts[1].node, Text('b')), true);
      expect(texts[1].path.equals(Path([0, 1])), true);
    });

    test('from', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text('a'), Text('b')]),
      ]);

      List<NodeEntry<Text>> texts = List<NodeEntry<Text>>.from(
          NodeUtils.texts(editor, from: Path([0, 1])));

      expect(TextUtils.equals(texts[0].node, Text('b')), true);
      expect(texts[0].path.equals(Path([0, 1])), true);
    });

    test('multiple elements', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text('a')]),
        Element(children: <Node>[Text('b')]),
      ]);

      List<NodeEntry<Text>> texts =
          List<NodeEntry<Text>>.from(NodeUtils.texts(editor));

      expect(TextUtils.equals(texts[0].node, Text('a')), true);
      expect(texts[0].path.equals(Path([0, 0])), true);

      expect(TextUtils.equals(texts[1].node, Text('b')), true);
      expect(texts[1].path.equals(Path([1, 0])), true);
    });

    test('reverse', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text('a'), Text('b')]),
      ]);

      List<NodeEntry<Text>> texts =
          List<NodeEntry<Text>>.from(NodeUtils.texts(editor, reverse: true));

      expect(TextUtils.equals(texts[0].node, Text('b')), true);
      expect(texts[0].path.equals(Path([0, 1])), true);

      expect(TextUtils.equals(texts[1].node, Text('a')), true);
      expect(texts[1].path.equals(Path([0, 0])), true);
    });

    test('to', () {
      Editor editor = Editor(children: <Node>[
        Element(children: <Node>[Text('a'), Text('b'), Text('c'), Text('d')]),
      ]);

      List<NodeEntry<Text>> texts = List<NodeEntry<Text>>.from(
          NodeUtils.texts(editor, from: Path([0, 1]), to: Path([0, 2])));

      expect(TextUtils.equals(texts[0].node, Text('b')), true);
      expect(texts[0].path.equals(Path([0, 1])), true);

      expect(TextUtils.equals(texts[1].node, Text('c')), true);
      expect(texts[1].path.equals(Path([0, 2])), true);
    });
  });
}
