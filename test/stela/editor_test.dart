import 'package:flutter_test/flutter_test.dart';
import 'package:inday/stela/editor.dart';
import 'package:inday/stela/element.dart';
import 'package:inday/stela/node.dart';
import 'package:inday/stela/operation.dart';
import 'package:inday/stela/path.dart';
import 'package:inday/stela/point.dart';
import 'package:inday/stela/range.dart';
import 'package:inday/stela/text.dart';

class TestEditor extends Editor {
  TestEditor(
      {List<Node> children,
      Range selection,
      List<Operation> operations,
      Map<String, dynamic> marks,
      Map<String, dynamic> props = const {}})
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

  @override
  bool isVoid(Element element) {
    return element is Void;
  }
}

void main() {
  group('above', () {
    test('block highest', () {
      // <editor>
      //   <block>
      //     <block>one</block>
      //   </block>
      // </editor>
      Block highest = Block(children: <Node>[
        Block(children: <Node>[Text('one')])
      ]);
      TestEditor editor = TestEditor(children: <Node>[highest]);

      NodeEntry entry = EditorUtils.above(editor,
          at: Path([0, 0, 0]), mode: Mode.highest, match: (node) {
        return EditorUtils.isBlock(editor, node);
      });

      expect(entry.node, highest);
      expect(PathUtils.equals(entry.path, Path([0])), true);
    });

    test('block lowest', () {
      // <editor>
      //   <block>
      //     <block>one</block>
      //   </block>
      // </editor>
      Block lowest = Block(children: <Node>[Text('one')]);
      TestEditor editor = TestEditor(children: <Node>[
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
      // <editor>
      //   <block>
      //     one<inline>two</inline>three
      //   </block>
      // </editor>
      Inline inline = Inline(children: <Node>[Text('two')]);
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[Text('one'), inline, Text('three')])
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

  group('after', () {
    test('end', () {
      // <editor>
      //   <block>one</block>
      //   <block>two</block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[Text('one')]),
        Block(children: <Node>[Text('two')])
      ]);

      Point point = EditorUtils.after(editor, Path([1, 0]));

      expect(point, null);
    });

    test('path', () {
      // <editor>
      //   <block>one</block>
      //   <block>two</block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[Text('one')]),
        Block(children: <Node>[Text('two')])
      ]);

      Point point = EditorUtils.after(editor, Path([0, 0]));

      expect(PointUtils.equals(point, Point(Path([1, 0]), 0)), true);
    });

    test('point', () {
      // <editor>
      //   <block>one</block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[Text('one')]),
      ]);

      Point point = EditorUtils.after(editor, Point(Path([0, 0]), 1));

      expect(PointUtils.equals(point, Point(Path([0, 0]), 2)), true);
    });

    test('range', () {
      // <editor>
      //   <block>one</block>
      //   <block>two</block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[Text('one')]),
        Block(children: <Node>[Text('two')]),
      ]);

      Point point = EditorUtils.after(
          editor, Range(Point(Path([0, 0]), 1), Point(Path([1, 0]), 2)));

      expect(PointUtils.equals(point, Point(Path([1, 0]), 3)), true);
    });
  });

  group('before', () {
    test('path', () {
      // <editor>
      //   <block>one</block>
      //   <block>two</block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[Text('one')]),
        Block(children: <Node>[Text('two')])
      ]);

      Point point = EditorUtils.before(editor, Path([1, 0]));

      expect(PointUtils.equals(point, Point(Path([0, 0]), 3)), true);
    });

    test('point', () {
      // <editor>
      //   <block>one</block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[Text('one')]),
      ]);

      Point point = EditorUtils.before(editor, Point(Path([0, 0]), 1));

      expect(PointUtils.equals(point, Point(Path([0, 0]), 0)), true);
    });

    test('range', () {
      // <editor>
      //   <block>one</block>
      //   <block>two</block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[Text('one')]),
        Block(children: <Node>[Text('two')]),
      ]);

      Point point = EditorUtils.before(
          editor, Range(Point(Path([0, 0]), 1), Point(Path([0, 1]), 2)));

      expect(PointUtils.equals(point, Point(Path([0, 0]), 0)), true);
    });

    test('start', () {
      // <editor>
      //   <block>one</block>
      //   <block>two</block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[Text('one')]),
        Block(children: <Node>[Text('two')])
      ]);

      Point point = EditorUtils.before(editor, Path([0, 0]));

      expect(point, null);
    });
  });

  group('edges', () {
    test('path', () {
      // <editor>
      //   <block>one</block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[Text('one')]),
      ]);

      Edges edges = EditorUtils.edges(editor, Path([0]));
      Point start = edges.start;
      Point end = edges.end;

      expect(PointUtils.equals(start, Point(Path([0, 0]), 0)), true);
      expect(PointUtils.equals(end, Point(Path([0, 0]), 3)), true);
    });

    test('point', () {
      // <editor>
      //   <block>one</block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[Text('one')]),
      ]);

      Edges edges = EditorUtils.edges(editor, Point(Path([0, 0]), 1));
      Point start = edges.start;
      Point end = edges.end;

      expect(PointUtils.equals(start, Point(Path([0, 0]), 1)), true);
      expect(PointUtils.equals(end, Point(Path([0, 0]), 1)), true);
    });

    test('range', () {
      // <editor>
      //   <block>one</block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[Text('one')]),
      ]);

      Edges edges = EditorUtils.edges(
          editor, Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 3)));
      Point start = edges.start;
      Point end = edges.end;

      expect(PointUtils.equals(start, Point(Path([0, 0]), 1)), true);
      expect(PointUtils.equals(end, Point(Path([0, 0]), 3)), true);
    });
  });

  group('end', () {
    test('path', () {
      // <editor>
      //   <block>one</block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[Text('one')]),
      ]);

      Point point = EditorUtils.end(editor, Path([0]));

      expect(PointUtils.equals(point, Point(Path([0, 0]), 3)), true);
    });

    test('point', () {
      // <editor>
      //   <block>one</block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[Text('one')]),
      ]);

      Point point = EditorUtils.end(editor, Point(Path([0, 0]), 1));

      expect(PointUtils.equals(point, Point(Path([0, 0]), 1)), true);
    });

    test('range', () {
      // <editor>
      //   <block>one</block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[Text('one')]),
      ]);

      Point point = EditorUtils.end(
          editor, Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 2)));

      expect(PointUtils.equals(point, Point(Path([0, 0]), 2)), true);
    });
  });

  group('hasBlocks', () {
    test('block nested', () {
      // <editor>
      //   <block>
      //     <block>one</block>
      //   </block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[
          Block(children: <Node>[Text('one')])
        ]),
      ]);

      expect(EditorUtils.hasBlocks(editor, editor.children[0]), true);
    });

    test('block', () {
      // <editor>
      //   <block>one</block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[Text('one')]),
      ]);

      expect(EditorUtils.hasBlocks(editor, editor.children[0]), false);
    });

    test('inline nested', () {
      // <editor>
      //   <block>
      //     one
      //     <inline>
      //       two<inline>three</inline>four
      //     </inline>
      //     five
      //   </block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[
          Text('one'),
          Inline(children: <Node>[
            Text('two'),
            Inline(children: <Node>[Text('three')]),
            Text('four')
          ]),
          Text('five')
        ]),
      ]);

      expect(
          EditorUtils.hasBlocks(
              editor, (editor.children[0] as Block).children[1]),
          false);
    });

    test('inline', () {
      // <editor>
      //   <block>
      //     one<inline>two</inline>three
      //   </block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[
          Text('one'),
          Inline(children: <Node>[
            Text('two'),
          ]),
          Text('three')
        ]),
      ]);

      expect(EditorUtils.hasBlocks(editor, editor.children[0]), false);
    });
  });

  group('hasInlines', () {
    test('block nested', () {
      // <editor>
      //   <block>
      //     <block>one</block>
      //   </block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[
          Block(children: <Node>[Text('one')])
        ]),
      ]);

      expect(EditorUtils.hasInlines(editor, editor.children[0]), false);
    });

    test('block', () {
      // <editor>
      //   <block>one</block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[Text('one')]),
      ]);

      expect(EditorUtils.hasInlines(editor, editor.children[0]), true);
    });

    test('inline nested', () {
      // <editor>
      //   <block>
      //     one
      //     <inline>
      //       two<inline>three</inline>four
      //     </inline>
      //     five
      //   </block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[
          Text('one'),
          Inline(children: <Node>[
            Text('two'),
            Inline(children: <Node>[Text('three')]),
            Text('four')
          ]),
          Text('five')
        ]),
      ]);

      expect(
          EditorUtils.hasInlines(
              editor, (editor.children[0] as Block).children[1]),
          true);
    });

    test('inline', () {
      // <editor>
      //   <block>
      //     one<inline>two</inline>three
      //   </block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[
          Text('one'),
          Inline(children: <Node>[
            Text('two'),
          ]),
          Text('three')
        ]),
      ]);

      expect(EditorUtils.hasInlines(editor, editor.children[0]), true);
    });
  });

  group('hasTexts', () {
    test('block nested', () {
      // <editor>
      //   <block>
      //     <block>one</block>
      //   </block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[
          Block(children: <Node>[Text('one')])
        ]),
      ]);

      expect(EditorUtils.hasTexts(editor, editor.children[0]), false);
    });

    test('block', () {
      // <editor>
      //   <block>one</block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[Text('one')]),
      ]);

      expect(EditorUtils.hasTexts(editor, editor.children[0]), true);
    });

    test('inline nested', () {
      // <editor>
      //   <block>
      //     one
      //     <inline>
      //       two<inline>three</inline>four
      //     </inline>
      //     five
      //   </block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[
          Text('one'),
          Inline(children: <Node>[
            Text('two'),
            Inline(children: <Node>[Text('three')]),
            Text('four')
          ]),
          Text('five')
        ]),
      ]);

      expect(
          EditorUtils.hasTexts(
              editor, (editor.children[0] as Block).children[1]),
          true);
    });

    test('inline', () {
      // <editor>
      //   <block>
      //     one<inline>two</inline>three
      //   </block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[
          Text('one'),
          Inline(children: <Node>[
            Text('two'),
          ]),
          Text('three')
        ]),
      ]);

      expect(EditorUtils.hasTexts(editor, editor.children[0]), true);
    });
  });

  group('isBlock', () {
    test('block', () {
      // <editor>
      //   <block>one</block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[Text('one')])
      ]);

      expect(EditorUtils.isBlock(editor, editor.children[0]), true);
    });

    test('inline', () {
      // <editor>
      //   <block>
      //     one<inline>two</inline>three
      //   </block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[
          Text('one'),
          Inline(children: <Node>[
            Text('two'),
          ]),
          Text('three')
        ]),
      ]);

      expect(
          EditorUtils.isBlock(
              editor, (editor.children[0] as Block).children[1]),
          false);
    });
  });

  group('isEdge', () {
    test('path end', () {
      // <editor>
      //   <block>
      //     one
      //     <cursor />
      //   </block>
      // </editor>
      Range cursor = Range(Point(Path([0, 0]), 3), Point(Path([0, 0]), 3));
      TestEditor editor = TestEditor(selection: cursor, children: <Node>[
        Block(children: <Node>[
          Block(children: <Node>[Text('one')])
        ]),
      ]);

      expect(EditorUtils.isEdge(editor, editor.selection.anchor, Path([0])),
          false);
    });

    test('path middle', () {
      // <editor>
      //   <block>
      //     on
      //     <cursor />e
      //   </block>
      // </editor>
      Range cursor = Range(Point(Path([0, 0]), 2), Point(Path([0, 0]), 2));
      TestEditor editor = TestEditor(selection: cursor, children: <Node>[
        Block(children: <Node>[
          Block(children: <Node>[Text('one')])
        ]),
      ]);

      expect(EditorUtils.isEdge(editor, editor.selection.anchor, Path([0])),
          false);
    });

    test('path start', () {
      // <editor>
      //   <block>
      //     <cursor />
      //     one
      //   </block>
      // </editor>
      Range cursor = Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0));
      TestEditor editor = TestEditor(selection: cursor, children: <Node>[
        Block(children: <Node>[
          Block(children: <Node>[Text('one')])
        ]),
      ]);

      expect(
          EditorUtils.isEdge(editor, editor.selection.anchor, Path([0])), true);
    });
  });

  group('isEmpty', () {
    test('block blank', () {
      // <editor>
      //   <block>
      //     <text />
      //   </block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[Text('')])
      ]);

      expect(EditorUtils.isEmpty(editor, editor.children[0]), true);
    });

    test('block empty', () {
      // <editor>
      //   <block />
      // </editor>
      TestEditor editor =
          TestEditor(children: <Node>[Block(children: <Node>[])]);

      expect(EditorUtils.isEmpty(editor, editor.children[0]), true);
    });

    test('block full', () {
      // <editor>
      //   <block>one</block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[Text('one')])
      ]);

      expect(EditorUtils.isEmpty(editor, editor.children[0]), false);
    });

    test('block void', () {
      // <editor>
      //   <void>
      //     <text />
      //   </void>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Void(children: <Node>[Text('')])
      ]);

      expect(EditorUtils.isEmpty(editor, editor.children[0]), false);
    });

    test('inline blank', () {
      // <editor>
      //   <block>
      //     one
      //     <inline>
      //       <text />
      //     </inline>
      //     three
      //   </block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[
          Text('one'),
          Inline(children: <Node>[Text('')]),
          Text('three'),
        ])
      ]);

      expect(
          EditorUtils.isEmpty(
              editor, (editor.children[0] as Block).children[1]),
          true);
    });

    test('inline empty', () {
      // <editor>
      //   <block>
      //     one
      //     <inline />
      //     three
      //   </block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[
          Text('one'),
          Inline(children: <Node>[]),
          Text('three'),
        ])
      ]);

      expect(
          EditorUtils.isEmpty(
              editor, (editor.children[0] as Block).children[1]),
          true);
    });

    test('inline full', () {
      // <editor>
      //   <block>
      //     one<inline>two</inline>three
      //   </block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[
          Text('one'),
          Inline(children: <Node>[Text('two')]),
          Text('three'),
        ])
      ]);

      expect(
          EditorUtils.isEmpty(
              editor, (editor.children[0] as Block).children[1]),
          false);
    });

    test('inline void', () {
      // <editor>
      //   <block>
      //     one
      //     <void>
      //       <text />
      //     </void>
      //     three
      //   </block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[
          Text('one'),
          Void(children: <Node>[Text('')]),
          Text('three'),
        ])
      ]);

      expect(
          EditorUtils.isEmpty(
              editor, (editor.children[0] as Block).children[1]),
          false);
    });
  });

  group('isEnd', () {
    test('path end', () {
      // <editor>
      //   <block>
      //     one
      //     <cursor />
      //   </block>
      // </editor>
      Range cursor = Range(Point(Path([0, 0]), 3), Point(Path([0, 0]), 3));
      TestEditor editor = TestEditor(selection: cursor, children: <Node>[
        Block(children: <Node>[Text('one')])
      ]);

      expect(
          EditorUtils.isEnd(editor, editor.selection.anchor, Path([0])), true);
    });

    test('path middle', () {
      // <editor>
      //   <block>
      //     on
      //     <cursor />e
      //   </block>
      // </editor>
      Range cursor = Range(Point(Path([0, 0]), 2), Point(Path([0, 0]), 2));
      TestEditor editor = TestEditor(selection: cursor, children: <Node>[
        Block(children: <Node>[Text('one')])
      ]);

      expect(
          EditorUtils.isEnd(editor, editor.selection.anchor, Path([0])), false);
    });

    test('path start', () {
      // <editor>
      //   <block>
      //     <cursor />
      //     one
      //   </block>
      // </editor>
      Range cursor = Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0));
      TestEditor editor = TestEditor(selection: cursor, children: <Node>[
        Block(children: <Node>[Text('one')])
      ]);

      expect(
          EditorUtils.isEnd(editor, editor.selection.anchor, Path([0])), false);
    });
  });

  group('isInline', () {
    test('block', () {
      // <editor>
      //   <block>one</block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[Text('one')])
      ]);

      expect(EditorUtils.isInline(editor, editor.children[0]), false);
    });

    test('inline', () {
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[
          Text('one'),
          Inline(children: <Node>[
            Text('two'),
          ]),
          Text('three')
        ]),
      ]);

      expect(
          EditorUtils.isInline(
              editor, (editor.children[0] as Block).children[1]),
          true);
    });
  });

  group('isStart', () {
    test('path end', () {
      // <editor>
      //   <block>
      //     one
      //     <cursor />
      //   </block>
      // </editor>
      Range cursor = Range(Point(Path([0, 0]), 3), Point(Path([0, 0]), 3));
      TestEditor editor = TestEditor(selection: cursor, children: <Node>[
        Block(children: <Node>[Text('one')])
      ]);

      expect(EditorUtils.isStart(editor, editor.selection.anchor, Path([0])),
          false);
    });

    test('path middle', () {
      // <editor>
      //   <block>
      //     on
      //     <cursor />e
      //   </block>
      // </editor>
      Range cursor = Range(Point(Path([0, 0]), 2), Point(Path([0, 0]), 2));
      TestEditor editor = TestEditor(selection: cursor, children: <Node>[
        Block(children: <Node>[Text('one')])
      ]);

      expect(EditorUtils.isStart(editor, editor.selection.anchor, Path([0])),
          false);
    });

    test('path start', () {
      // <editor>
      //   <block>
      //     <cursor />
      //     one
      //   </block>
      // </editor>
      Range cursor = Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0));
      TestEditor editor = TestEditor(selection: cursor, children: <Node>[
        Block(children: <Node>[Text('one')])
      ]);

      expect(EditorUtils.isStart(editor, editor.selection.anchor, Path([0])),
          true);
    });
  });

  group('isVoid', () {
    test('block', () {
      // <editor>
      //   <block>one</block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[
          Text('one'),
        ]),
      ]);

      expect(EditorUtils.isVoid(editor, editor.children[0]), false);
    });

    test('void', () {
      // <editor>
      //   <void>one</void>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Void(children: <Node>[Text('one')])
      ]);

      expect(EditorUtils.isVoid(editor, editor.children[0]), true);
    });
  });

  group('levels', () {
    test('match', () {
      // <editor>
      //   <element a>
      //     <text a />
      //   </element>
      // </editor>
      Text text = Text('one', props: {'a': true});
      Element element = Element(children: <Node>[text], props: {'a': true});
      TestEditor editor = TestEditor(children: <Node>[
        element,
      ]);

      List<NodeEntry> entries =
          List.from(EditorUtils.levels(editor, at: Path([0, 0]), match: (node) {
        return node.props['a'] != null;
      }));

      expect(entries[0].node, element);
      expect(PathUtils.equals(entries[0].path, Path([0])), true);

      expect(entries[1].node, text);
      expect(PathUtils.equals(entries[1].path, Path([0, 0])), true);
    });

    test('reverse', () {
      // <editor>
      //   <element>
      //     <text />
      //   </element>
      // </editor>
      Text text = Text('one');
      Element element = Element(children: <Node>[text]);
      TestEditor editor = TestEditor(children: <Node>[
        element,
      ]);

      List<NodeEntry> entries = List.from(
          EditorUtils.levels(editor, at: Path([0, 0]), reverse: true));

      expect(entries[0].node, text);
      expect(PathUtils.equals(entries[0].path, Path([0, 0])), true);

      expect(entries[1].node, element);
      expect(PathUtils.equals(entries[1].path, Path([0])), true);

      expect(entries[2].node, editor);
      expect(PathUtils.equals(entries[2].path, Path([])), true);
    });

    test('success', () {
      // <editor>
      //   <element>
      //     <text />
      //   </element>
      // </editor>
      Text text = Text('one');
      Element element = Element(children: <Node>[text]);
      TestEditor editor = TestEditor(children: <Node>[
        element,
      ]);

      List<NodeEntry> entries =
          List.from(EditorUtils.levels(editor, at: Path([0, 0])));

      expect(entries[0].node, editor);
      expect(PathUtils.equals(entries[0].path, Path([])), true);

      expect(entries[1].node, element);
      expect(PathUtils.equals(entries[1].path, Path([0])), true);

      expect(entries[2].node, text);
      expect(PathUtils.equals(entries[2].path, Path([0, 0])), true);
    });

    test('voids false', () {
      // <editor>
      //   <void>
      //     <text />
      //   </void>
      // </editor>
      Text text = Text('one');
      Void v = Void(children: <Node>[text]);
      TestEditor editor = TestEditor(children: <Node>[v]);

      List<NodeEntry> entries = List.from(
        EditorUtils.levels(editor, at: Path([0, 0])),
      );

      expect(entries[0].node, editor);
      expect(PathUtils.equals(entries[0].path, Path([])), true);

      expect(entries[1].node, v);
      expect(PathUtils.equals(entries[1].path, Path([0])), true);
    });

    test('voids true', () {
      // <editor>
      //   <void>
      //     <text />
      //   </void>
      // </editor>
      Text text = Text('one');
      Void v = Void(children: <Node>[text]);
      TestEditor editor = TestEditor(children: <Node>[v]);

      List<NodeEntry> entries = List.from(
        EditorUtils.levels(editor, at: Path([0, 0]), voids: true),
      );

      expect(entries[0].node, editor);
      expect(PathUtils.equals(entries[0].path, Path([])), true);

      expect(entries[1].node, v);
      expect(PathUtils.equals(entries[1].path, Path([0])), true);

      expect(entries[2].node, text);
      expect(PathUtils.equals(entries[2].path, Path([0, 0])), true);
    });
  });
}
