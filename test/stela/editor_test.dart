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

  @override
  bool isVoid(Element element) {
    return element.isVoid;
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
        return node is Block;
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
        return node is Block;
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

      expect(editor.children[0] is Block, true);
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

      expect((editor.children[0] as Block).children[1] is Block, false);
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
        Block(children: <Node>[Text('one')])
      ]);

      expect(
          EditorUtils.isEdge(editor, editor.selection.anchor, Path([0])), true);
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
        Block(children: <Node>[Text('one')]),
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
        Block(children: <Node>[Text('one')])
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
      //   <block void>
      //     <text />
      //   </block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[Text('')], isVoid: true)
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
      //     <inline void>
      //       <text />
      //     </inline>
      //     three
      //   </block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[
          Text('one'),
          Inline(children: <Node>[Text('')], isVoid: true),
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
    test('block void', () {
      // <editor>
      //   <block void>one</block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[
          Text('one'),
        ], isVoid: true),
      ]);

      expect(EditorUtils.isVoid(editor, editor.children[0]), true);
    });

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

    test('inline void', () {
      // <editor>
      //   <block>
      //     one<inline void>two</inline>three
      //   </block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[
          Text('one'),
          Inline(children: <Node>[Text('two')], isVoid: true),
          Text('three'),
        ])
      ]);

      expect(
          EditorUtils.isVoid(
              editor, (editor.children[0] as Ancestor).children[1]),
          true);
    });

    test('inline void', () {
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
          EditorUtils.isVoid(
              editor, (editor.children[0] as Ancestor).children[1]),
          false);
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
      //   <element void>
      //     <text />
      //   </element>
      // </editor>
      Text text = Text('one');
      Element element = Element(children: <Node>[text], isVoid: true);
      TestEditor editor = TestEditor(children: <Node>[element]);

      List<NodeEntry> entries = List.from(
        EditorUtils.levels(editor, at: Path([0, 0])),
      );

      expect(entries[0].node, editor);
      expect(PathUtils.equals(entries[0].path, Path([])), true);

      expect(entries[1].node, element);
      expect(PathUtils.equals(entries[1].path, Path([0])), true);
    });

    test('voids true', () {
      // <editor>
      //   <element void>
      //     <text />
      //   </element void>
      // </editor>
      Text text = Text('one');
      Element element = Element(children: <Node>[text], isVoid: true);
      TestEditor editor = TestEditor(children: <Node>[element]);

      List<NodeEntry> entries = List.from(
        EditorUtils.levels(editor, at: Path([0, 0]), voids: true),
      );

      expect(entries[0].node, editor);
      expect(PathUtils.equals(entries[0].path, Path([])), true);

      expect(entries[1].node, element);
      expect(PathUtils.equals(entries[1].path, Path([0])), true);

      expect(entries[2].node, text);
      expect(PathUtils.equals(entries[2].path, Path([0, 0])), true);
    });
  });

  group('next', () {
    test('block', () {
      // <editor>
      //   <block>one</block>
      //   <block>two</block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[Text('one')]),
        Block(children: <Node>[Text('two')]),
      ]);
      NodeEntry next = EditorUtils.next(editor, at: Path([0]), match: (node) {
        return node is Block;
      });

      expect(next.node, editor.children[1]);
      expect(PathUtils.equals(next.path, Path([1])), true);
    });

    test('default', () {
      // <editor>
      //   <block>one</block>
      //   <block>two</block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[Text('one')]),
        Block(children: <Node>[Text('two')]),
      ]);
      NodeEntry next = EditorUtils.next(editor, at: Path([0]));

      expect(next.node, editor.children[1]);
      expect(PathUtils.equals(next.path, Path([1])), true);
    });

    test('text', () {
      // <editor>
      //   <block>one</block>
      //   <block>two</block>
      // </editor>
      Text text = Text('two');
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[Text('one')]),
        Block(children: <Node>[text]),
      ]);
      NodeEntry next = EditorUtils.next(editor, at: Path([0]), match: (node) {
        return node is Text;
      });

      expect(next.node, text);
      expect(PathUtils.equals(next.path, Path([1, 0])), true);
    });
  });

  group('node', () {
    test('path', () {
      // <editor>
      //   <block>one</block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[Text('one')]),
      ]);
      NodeEntry entry = EditorUtils.node(editor, Path([0]));

      expect(entry.node, editor.children[0]);
      expect(PathUtils.equals(entry.path, Path([0])), true);
    });

    test('point', () {
      // <editor>
      //   <block>one</block>
      // </editor>
      Text text = Text('one');
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[text]),
      ]);
      NodeEntry entry = EditorUtils.node(editor, Point(Path([0, 0]), 1));

      expect(entry.node, text);
      expect(PathUtils.equals(entry.path, Path([0, 0])), true);
    });

    test('range end', () {
      // <editor>
      //   <block>one</block>
      //   <block>two</block>
      // </editor>
      Text text = Text('two');
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[Text('one')]),
        Block(children: <Node>[text]),
      ]);
      NodeEntry entry = EditorUtils.node(
          editor, Range(Point(Path([0, 0]), 1), Point(Path([1, 0]), 2)),
          edge: Edge.end);

      expect(entry.node, text);
      expect(PathUtils.equals(entry.path, Path([1, 0])), true);
    });

    test('range start', () {
      // <editor>
      //   <block>one</block>
      //   <block>two</block>
      // </editor>
      Text text = Text('one');
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[text]),
        Block(children: <Node>[Text('two')]),
      ]);
      NodeEntry entry = EditorUtils.node(
          editor, Range(Point(Path([0, 0]), 1), Point(Path([1, 0]), 2)),
          edge: Edge.start);

      expect(entry.node, text);
      expect(PathUtils.equals(entry.path, Path([0, 0])), true);
    });

    test('range', () {
      // <editor>
      //   <block>one</block>
      //   <block>two</block>
      // </editor>
      Text text = Text('one');
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[text]),
        Block(children: <Node>[Text('two')]),
      ]);
      NodeEntry entry = EditorUtils.node(
          editor, Range(Point(Path([0, 0]), 1), Point(Path([1, 0]), 2)));

      expect(entry.node, editor);
      expect(PathUtils.equals(entry.path, Path([])), true);
    });
  });

  group('nodes', () {
    group('match function', () {
      test('block', () {
        // <editor>
        //   <block>one</block>
        // </editor>
        Block block = Block(children: <Node>[Text('one')]);
        TestEditor editor = TestEditor(children: <Node>[block]);
        List<NodeEntry> entries = List.from(EditorUtils.nodes(
          editor,
          at: Path([]),
          match: (node) {
            return node is Block;
          },
        ));

        expect(entries[0].node, block);
        expect(PathUtils.equals(entries[0].path, Path([0])), true);
      });

      test('editor', () {
        // <editor>
        //   <block>one</block>
        //   <block>two</block>
        //   <block>three</block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[Text('one')]),
          Block(children: <Node>[Text('two')]),
          Block(children: <Node>[Text('three')]),
        ]);

        List<NodeEntry> entries = List.from(EditorUtils.nodes(
          editor,
          at: Path([]),
          match: (node) {
            return true;
          },
          mode: Mode.highest,
        ));

        expect(entries[0].node, editor);
        expect(PathUtils.equals(entries[0].path, Path([])), true);
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
        List<NodeEntry> entries = List.from(EditorUtils.nodes(
          editor,
          at: Path([]),
          match: (node) {
            return EditorUtils.isInline(editor, node);
          },
        ));

        expect(entries[0].node, inline);
        expect(PathUtils.equals(entries[0].path, Path([0, 1])), true);
      });
    });

    group('mode all', () {
      test('block', () {
        // <editor>
        //   <block a>
        //     <block a>one</block>
        //   </block>
        //   <block a>
        //     <block a>two</block>
        //   </block>
        // </editor>
        Block innerBlock1 =
            Block(children: <Node>[Text('one')], props: {'a': true});
        Block block1 = Block(children: <Node>[innerBlock1], props: {'a': true});
        Block innerBlock2 =
            Block(children: <Node>[Text('two')], props: {'a': true});
        Block block2 = Block(children: <Node>[innerBlock2], props: {'a': true});
        TestEditor editor = TestEditor(children: <Node>[block1, block2]);
        List<NodeEntry> entries =
            List.from(EditorUtils.nodes(editor, at: Path([]), match: (node) {
          return node.props['a'] != null;
        }, mode: Mode.all));

        expect(entries[0].node, block1);
        expect(PathUtils.equals(entries[0].path, Path([0])), true);

        expect(entries[1].node, innerBlock1);
        expect(PathUtils.equals(entries[1].path, Path([0, 0])), true);

        expect(entries[2].node, block2);
        expect(PathUtils.equals(entries[2].path, Path([1])), true);

        expect(entries[3].node, innerBlock2);
        expect(PathUtils.equals(entries[3].path, Path([1, 0])), true);
      });
    });

    group('mode highest', () {
      test('block', () {
        // <editor>
        //   <block a>
        //     <block a>one</block>
        //   </block>
        //   <block a>
        //     <block a>two</block>
        //   </block>
        // </editor>
        Block innerBlock1 =
            Block(children: <Node>[Text('one')], props: {'a': true});
        Block block1 = Block(children: <Node>[innerBlock1], props: {'a': true});
        Block innerBlock2 =
            Block(children: <Node>[Text('two')], props: {'a': true});
        Block block2 = Block(children: <Node>[innerBlock2], props: {'a': true});
        TestEditor editor = TestEditor(children: <Node>[block1, block2]);
        List<NodeEntry> entries =
            List.from(EditorUtils.nodes(editor, at: Path([]), match: (node) {
          return node.props['a'] != null;
        }, mode: Mode.highest));

        expect(entries[0].node, block1);
        expect(PathUtils.equals(entries[0].path, Path([0])), true);

        expect(entries[1].node, block2);
        expect(PathUtils.equals(entries[1].path, Path([1])), true);
      });
    });

    group('mode lowest', () {
      test('block', () {
        // <editor>
        //   <block a>
        //     <block a>one</block>
        //   </block>
        //   <block a>
        //     <block a>two</block>
        //   </block>
        // </editor>
        Block innerBlock1 =
            Block(children: <Node>[Text('one')], props: {'a': true});
        Block block1 = Block(children: <Node>[innerBlock1], props: {'a': true});
        Block innerBlock2 =
            Block(children: <Node>[Text('two')], props: {'a': true});
        Block block2 = Block(children: <Node>[innerBlock2], props: {'a': true});
        TestEditor editor = TestEditor(children: <Node>[block1, block2]);
        List<NodeEntry> entries =
            List.from(EditorUtils.nodes(editor, at: Path([]), match: (node) {
          return node.props['a'] != null;
        }, mode: Mode.lowest));

        expect(entries[0].node, innerBlock1);
        expect(PathUtils.equals(entries[0].path, Path([0, 0])), true);

        expect(entries[1].node, innerBlock2);
        expect(PathUtils.equals(entries[1].path, Path([1, 0])), true);
      });
    });

    group('mode universal', () {
      test('all nested', () {
        // <editor>
        //   <block a>
        //     <block a>one</block>
        //   </block>
        //   <block a>
        //     <block a>two</block>
        //   </block>
        // </editor>
        Block innerBlock1 =
            Block(children: <Node>[Text('one')], props: {'a': true});
        Block block1 = Block(children: <Node>[innerBlock1], props: {'a': true});
        Block innerBlock2 =
            Block(children: <Node>[Text('two')], props: {'a': true});
        Block block2 = Block(children: <Node>[innerBlock2], props: {'a': true});
        TestEditor editor = TestEditor(children: <Node>[block1, block2]);
        List<NodeEntry> entries =
            List.from(EditorUtils.nodes(editor, at: Path([]), match: (node) {
          return node.props['a'] != null;
        }, mode: Mode.lowest, universal: true));

        expect(entries[0].node, innerBlock1);
        expect(PathUtils.equals(entries[0].path, Path([0, 0])), true);

        expect(entries[1].node, innerBlock2);
        expect(PathUtils.equals(entries[1].path, Path([1, 0])), true);
      });

      test('all', () {
        // <editor>
        //   <block a>one</block>
        //   <block a>two</block>
        // </editor>
        Block block1 = Block(children: <Node>[Text('one')], props: {'a': true});
        Block block2 = Block(children: <Node>[Text('two')], props: {'a': true});

        TestEditor editor = TestEditor(children: <Node>[block1, block2]);
        List<NodeEntry> entries =
            List.from(EditorUtils.nodes(editor, at: Path([]), match: (node) {
          return node.props['a'] != null;
        }, mode: Mode.lowest, universal: true));

        expect(entries[0].node, block1);
        expect(PathUtils.equals(entries[0].path, Path([0])), true);

        expect(entries[1].node, block2);
        expect(PathUtils.equals(entries[1].path, Path([1])), true);
      });

      test('branch nested', () {
        // <editor>
        //   <block a>
        //     <block b>one</block>
        //   </block>
        //   <block b>
        //     <block a>two</block>
        //   </block>
        // </editor>
        Block innerBlock1 =
            Block(children: <Node>[Text('one')], props: {'b': true});
        Block block1 = Block(children: <Node>[innerBlock1], props: {'a': true});
        Block innerBlock2 =
            Block(children: <Node>[Text('two')], props: {'a': true});
        Block block2 = Block(children: <Node>[innerBlock2], props: {'b': true});
        TestEditor editor = TestEditor(children: <Node>[block1, block2]);
        List<NodeEntry> entries =
            List.from(EditorUtils.nodes(editor, at: Path([]), match: (node) {
          return node.props['a'] != null;
        }, mode: Mode.lowest, universal: true));

        expect(entries[0].node, block1);
        expect(PathUtils.equals(entries[0].path, Path([0])), true);

        expect(entries[1].node, innerBlock2);
        expect(PathUtils.equals(entries[1].path, Path([1, 0])), true);
      });
      test('none nested', () {
        // <editor>
        //   <block a>
        //     <block a>one</block>
        //   </block>
        //   <block a>
        //     <block a>two</block>
        //   </block>
        // </editor>
        Block innerBlock1 =
            Block(children: <Node>[Text('one')], props: {'a': true});
        Block block1 = Block(children: <Node>[innerBlock1], props: {'a': true});
        Block innerBlock2 =
            Block(children: <Node>[Text('two')], props: {'a': true});
        Block block2 = Block(children: <Node>[innerBlock2], props: {'a': true});
        TestEditor editor = TestEditor(children: <Node>[block1, block2]);
        List<NodeEntry> entries =
            List.from(EditorUtils.nodes(editor, at: Path([]), match: (node) {
          return node.props['b'] != null;
        }, mode: Mode.lowest, universal: true));

        expect(entries.isEmpty, true);
      });

      test('none', () {
        // <editor>
        //   <block a>one</block>
        //   <block a>two</block>
        // </editor>
        Block block1 = Block(children: <Node>[Text('one')], props: {'a': true});
        Block block2 = Block(children: <Node>[Text('two')], props: {'a': true});

        TestEditor editor = TestEditor(children: <Node>[block1, block2]);
        List<NodeEntry> entries =
            List.from(EditorUtils.nodes(editor, at: Path([]), match: (node) {
          return node.props['b'] != null;
        }, mode: Mode.lowest, universal: true));

        expect(entries.isEmpty, true);
      });

      test('some nested', () {
        // <editor>
        //   <block a>
        //     <block a>one</block>
        //   </block>
        //   <block b>
        //     <block b>two</block>
        //   </block>
        // </editor>
        Block innerBlock1 =
            Block(children: <Node>[Text('one')], props: {'a': true});
        Block block1 = Block(children: <Node>[innerBlock1], props: {'a': true});
        Block innerBlock2 =
            Block(children: <Node>[Text('two')], props: {'b': true});
        Block block2 = Block(children: <Node>[innerBlock2], props: {'b': true});
        TestEditor editor = TestEditor(children: <Node>[block1, block2]);
        List<NodeEntry> entries =
            List.from(EditorUtils.nodes(editor, at: Path([]), match: (node) {
          return node.props['a'] != null;
        }, mode: Mode.lowest, universal: true));

        expect(entries.isEmpty, true);
      });

      test('some', () {
        // <editor>
        //   <block a>one</block>
        //   <block b>two</block>
        // </editor>
        Block block1 = Block(children: <Node>[Text('one')], props: {'a': true});
        Block block2 = Block(children: <Node>[Text('two')], props: {'b': true});

        TestEditor editor = TestEditor(children: <Node>[block1, block2]);
        List<NodeEntry> entries =
            List.from(EditorUtils.nodes(editor, at: Path([]), match: (node) {
          return node.props['a'] != null;
        }, mode: Mode.lowest, universal: true));

        expect(entries.isEmpty, true);
      });
    });

    group('no match', () {
      test('block multiple', () {
        // <editor>
        //   <block>one</block>
        //   <block>two</block>
        // </editor>
        Text text1 = Text('one');
        Block block1 = Block(children: <Node>[text1]);
        Text text2 = Text('two');
        Block block2 = Block(children: <Node>[text2]);
        TestEditor editor = TestEditor(children: <Node>[block1, block2]);
        List<NodeEntry> entries = List.from(EditorUtils.nodes(
          editor,
          at: Path([]),
        ));

        expect(entries[0].node, editor);
        expect(PathUtils.equals(entries[0].path, Path([])), true);

        expect(entries[1].node, block1);
        expect(PathUtils.equals(entries[1].path, Path([0])), true);

        expect(entries[2].node, text1);
        expect(PathUtils.equals(entries[2].path, Path([0, 0])), true);

        expect(entries[3].node, block2);
        expect(PathUtils.equals(entries[3].path, Path([1])), true);

        expect(entries[4].node, text2);
        expect(PathUtils.equals(entries[4].path, Path([1, 0])), true);
      });

      test('block multiple', () {
        // <editor>
        //   <block>
        //     <block>one</block>
        //   </block>
        //   <block>
        //     <block>two</block>
        //   </block>
        // </editor>
        Text text1 = Text('one');
        Block innerBlock1 = Block(children: <Node>[text1]);
        Block block1 = Block(children: <Node>[innerBlock1]);
        Text text2 = Text('two');
        Block innerBlock2 = Block(children: <Node>[text2]);
        Block block2 = Block(children: <Node>[innerBlock2]);
        TestEditor editor = TestEditor(children: <Node>[block1, block2]);
        List<NodeEntry> entries = List.from(EditorUtils.nodes(
          editor,
          at: Path([]),
        ));

        expect(entries[0].node, editor);
        expect(PathUtils.equals(entries[0].path, Path([])), true);

        expect(entries[1].node, block1);
        expect(PathUtils.equals(entries[1].path, Path([0])), true);

        expect(entries[2].node, innerBlock1);
        expect(PathUtils.equals(entries[2].path, Path([0, 0])), true);

        expect(entries[3].node, text1);
        expect(PathUtils.equals(entries[3].path, Path([0, 0, 0])), true);

        expect(entries[4].node, block2);
        expect(PathUtils.equals(entries[4].path, Path([1])), true);

        expect(entries[5].node, innerBlock2);
        expect(PathUtils.equals(entries[5].path, Path([1, 0])), true);

        expect(entries[6].node, text2);
        expect(PathUtils.equals(entries[6].path, Path([1, 0, 0])), true);
      });

      test('block reverse', () {
        // <editor>
        //   <block>one</block>
        //   <block>two</block>
        // </editor>
        Text text1 = Text('one');
        Block block1 = Block(children: <Node>[text1]);
        Text text2 = Text('two');
        Block block2 = Block(children: <Node>[text2]);
        TestEditor editor = TestEditor(children: <Node>[block1, block2]);
        List<NodeEntry> entries = List.from(EditorUtils.nodes(
          editor,
          at: Path([]),
          reverse: true,
        ));

        expect(entries[0].node, editor);
        expect(PathUtils.equals(entries[0].path, Path([])), true);

        expect(entries[1].node, block2);
        expect(PathUtils.equals(entries[1].path, Path([1])), true);

        expect(entries[2].node, text2);
        expect(PathUtils.equals(entries[2].path, Path([1, 0])), true);

        expect(entries[3].node, block1);
        expect(PathUtils.equals(entries[3].path, Path([0])), true);

        expect(entries[4].node, text1);
        expect(PathUtils.equals(entries[4].path, Path([0, 0])), true);
      });

      test('block void', () {
        // <editor>
        //   <block void>one</block>
        // </editor>
        Block block = Block(children: <Node>[Text('one')], isVoid: true);
        TestEditor editor = TestEditor(children: <Node>[block]);
        List<NodeEntry> entries = List.from(EditorUtils.nodes(
          editor,
          at: Path([]),
        ));

        expect(entries[0].node, editor);
        expect(PathUtils.equals(entries[0].path, Path([])), true);

        expect(entries[1].node, block);
        expect(PathUtils.equals(entries[1].path, Path([0])), true);
      });

      test('block', () {
        // <editor>
        //   <block>one</block>
        // </editor>
        Text text = Text('one');
        Block block = Block(children: <Node>[text]);
        TestEditor editor = TestEditor(children: <Node>[block]);
        List<NodeEntry> entries = List.from(EditorUtils.nodes(
          editor,
          at: Path([]),
        ));

        expect(entries[0].node, editor);
        expect(PathUtils.equals(entries[0].path, Path([])), true);

        expect(entries[1].node, block);
        expect(PathUtils.equals(entries[1].path, Path([0])), true);

        expect(entries[2].node, text);
        expect(PathUtils.equals(entries[2].path, Path([0, 0])), true);
      });

      test('inline multiple', () {
        // <editor>
        //   <block>
        //     one<inline>two</inline>three<inline>four</inline>five
        //   </block>
        // </editor>
        Text text1 = Text('one');
        Text text2 = Text('two');
        Inline inline2 = Inline(children: <Node>[text2]);
        Text text3 = Text('three');
        Text text4 = Text('four');
        Inline inline4 = Inline(children: <Node>[text4]);
        Text text5 = Text('five');
        Block block =
            Block(children: <Node>[text1, inline2, text3, inline4, text5]);
        TestEditor editor = TestEditor(children: <Node>[block]);
        List<NodeEntry> entries = List.from(EditorUtils.nodes(
          editor,
          at: Path([]),
        ));

        expect(entries[0].node, editor);
        expect(PathUtils.equals(entries[0].path, Path([])), true);

        expect(entries[1].node, block);
        expect(PathUtils.equals(entries[1].path, Path([0])), true);

        expect(entries[2].node, text1);
        expect(PathUtils.equals(entries[2].path, Path([0, 0])), true);

        expect(entries[3].node, inline2);
        expect(PathUtils.equals(entries[3].path, Path([0, 1])), true);

        expect(entries[4].node, text2);
        expect(PathUtils.equals(entries[4].path, Path([0, 1, 0])), true);

        expect(entries[5].node, text3);
        expect(PathUtils.equals(entries[5].path, Path([0, 2])), true);

        expect(entries[6].node, inline4);
        expect(PathUtils.equals(entries[6].path, Path([0, 3])), true);

        expect(entries[7].node, text4);
        expect(PathUtils.equals(entries[7].path, Path([0, 3, 0])), true);

        expect(entries[8].node, text5);
        expect(PathUtils.equals(entries[8].path, Path([0, 4])), true);
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
        Text text1 = Text('one');
        Text text2 = Text('two');
        Text text3 = Text('three');
        Inline innerInline = Inline(children: <Node>[text3]);
        Text text4 = Text('four');
        Inline inline = Inline(children: <Node>[text2, innerInline, text4]);
        Text text5 = Text('five');
        Block block = Block(children: <Node>[text1, inline, text5]);
        TestEditor editor = TestEditor(children: <Node>[block]);

        List<NodeEntry> entries = List.from(EditorUtils.nodes(
          editor,
          at: Path([]),
        ));

        expect(entries[0].node, editor);
        expect(PathUtils.equals(entries[0].path, Path([])), true);

        expect(entries[1].node, block);
        expect(PathUtils.equals(entries[1].path, Path([0])), true);

        expect(entries[2].node, text1);
        expect(PathUtils.equals(entries[2].path, Path([0, 0])), true);

        expect(entries[3].node, inline);
        expect(PathUtils.equals(entries[3].path, Path([0, 1])), true);

        expect(entries[4].node, text2);
        expect(PathUtils.equals(entries[4].path, Path([0, 1, 0])), true);

        expect(entries[5].node, innerInline);
        expect(PathUtils.equals(entries[5].path, Path([0, 1, 1])), true);

        expect(entries[6].node, text3);
        expect(PathUtils.equals(entries[6].path, Path([0, 1, 1, 0])), true);

        expect(entries[7].node, text4);
        expect(PathUtils.equals(entries[7].path, Path([0, 1, 2])), true);

        expect(entries[8].node, text5);
        expect(PathUtils.equals(entries[8].path, Path([0, 2])), true);
      });

      test('inline reverse', () {
        // <editor>
        //   <block>
        //     one<inline>two</inline>three<inline>four</inline>five
        //   </block>
        // </editor>
        Text text1 = Text('one');
        Text text2 = Text('two');
        Inline inline2 = Inline(children: <Node>[text2]);
        Text text3 = Text('three');
        Text text4 = Text('four');
        Inline inline4 = Inline(children: <Node>[text4]);
        Text text5 = Text('five');
        Block block =
            Block(children: <Node>[text1, inline2, text3, inline4, text5]);
        TestEditor editor = TestEditor(children: <Node>[block]);
        List<NodeEntry> entries =
            List.from(EditorUtils.nodes(editor, at: Path([]), reverse: true));

        expect(entries[0].node, editor);
        expect(PathUtils.equals(entries[0].path, Path([])), true);

        expect(entries[1].node, block);
        expect(PathUtils.equals(entries[1].path, Path([0])), true);

        expect(entries[2].node, text5);
        expect(PathUtils.equals(entries[2].path, Path([0, 4])), true);

        expect(entries[3].node, inline4);
        expect(PathUtils.equals(entries[3].path, Path([0, 3])), true);

        expect(entries[4].node, text4);
        expect(PathUtils.equals(entries[4].path, Path([0, 3, 0])), true);

        expect(entries[5].node, text3);
        expect(PathUtils.equals(entries[5].path, Path([0, 2])), true);

        expect(entries[6].node, inline2);
        expect(PathUtils.equals(entries[6].path, Path([0, 1])), true);

        expect(entries[7].node, text2);
        expect(PathUtils.equals(entries[7].path, Path([0, 1, 0])), true);

        expect(entries[8].node, text1);
        expect(PathUtils.equals(entries[8].path, Path([0, 0])), true);
      });

      test('inline void', () {
        // <editor>
        //   <block>
        //     one<inline void>two</inline>three
        //   </block>
        // </editor>
        Text text1 = Text('one');
        Text text2 = Text('two');
        Text text3 = Text('three');
        Inline inline = Inline(children: <Node>[text2], isVoid: true);
        Block block = Block(children: <Node>[text1, inline, text3]);
        TestEditor editor = TestEditor(children: <Node>[block]);

        List<NodeEntry> entries =
            List.from(EditorUtils.nodes(editor, at: Path([])));

        expect(entries[0].node, editor);
        expect(PathUtils.equals(entries[0].path, Path([])), true);

        expect(entries[1].node, block);
        expect(PathUtils.equals(entries[1].path, Path([0])), true);

        expect(entries[2].node, text1);
        expect(PathUtils.equals(entries[2].path, Path([0, 0])), true);

        expect(entries[3].node, inline);
        expect(PathUtils.equals(entries[3].path, Path([0, 1])), true);

        expect(entries[4].node, text3);
        expect(PathUtils.equals(entries[4].path, Path([0, 2])), true);
      });

      test('inline', () {
        // <editor>
        //   <block>
        //     one<inline>two</inline>three
        //   </block>
        // </editor>
        Text text1 = Text('one');
        Text text2 = Text('two');
        Text text3 = Text('three');
        Inline inline = Inline(children: <Node>[text2]);
        Block block = Block(children: <Node>[text1, inline, text3]);
        TestEditor editor = TestEditor(children: <Node>[block]);

        List<NodeEntry> entries =
            List.from(EditorUtils.nodes(editor, at: Path([])));

        expect(entries[0].node, editor);
        expect(PathUtils.equals(entries[0].path, Path([])), true);

        expect(entries[1].node, block);
        expect(PathUtils.equals(entries[1].path, Path([0])), true);

        expect(entries[2].node, text1);
        expect(PathUtils.equals(entries[2].path, Path([0, 0])), true);

        expect(entries[3].node, inline);
        expect(PathUtils.equals(entries[3].path, Path([0, 1])), true);

        expect(entries[4].node, text2);
        expect(PathUtils.equals(entries[4].path, Path([0, 1, 0])), true);

        expect(entries[5].node, text3);
        expect(PathUtils.equals(entries[5].path, Path([0, 2])), true);
      });
    });

    group('voids true', () {
      test('block', () {
        // <editor>
        //   <block void>one</block>
        // </editor>
        Text text1 = Text('one');
        Block block = Block(children: <Node>[text1], isVoid: true);
        TestEditor editor = TestEditor(children: <Node>[block]);

        List<NodeEntry> entries =
            List.from(EditorUtils.nodes(editor, at: Path([]), match: (node) {
          return node is Text;
        }, voids: true));

        expect(entries[0].node, text1);
        expect(PathUtils.equals(entries[0].path, Path([0, 0])), true);
      });

      test('inline', () {
        // <editor>
        //   <block>
        //     one<inline void>two</inline>three
        //   </block>
        // </editor>
        Text text1 = Text('one');
        Text text2 = Text('two');
        Text text3 = Text('three');
        Inline inline = Inline(children: <Node>[text2], isVoid: true);
        Block block = Block(children: <Node>[text1, inline, text3]);
        TestEditor editor = TestEditor(children: <Node>[block]);

        List<NodeEntry> entries =
            List.from(EditorUtils.nodes(editor, at: Path([]), match: (node) {
          return node is Text;
        }, voids: true));

        expect(entries[0].node, text1);
        expect(PathUtils.equals(entries[0].path, Path([0, 0])), true);

        expect(entries[1].node, text2);
        expect(PathUtils.equals(entries[1].path, Path([0, 1, 0])), true);

        expect(entries[2].node, text3);
        expect(PathUtils.equals(entries[2].path, Path([0, 2])), true);
      });
    });
  });

  group('parent', () {
    test('block', () {
      // <editor>
      //   <block>one</block>
      // </editor>
      Text text1 = Text('one');
      Block block = Block(children: <Node>[text1]);
      TestEditor editor = TestEditor(children: <Node>[block]);

      NodeEntry entry = EditorUtils.parent(editor, Path([0, 0]));

      expect(entry.node, block);
      expect(PathUtils.equals(entry.path, Path([0])), true);
    });

    test('point', () {
      // <editor>
      //   <block>one</block>
      // </editor>
      Text text1 = Text('one');
      Block block = Block(children: <Node>[text1]);
      TestEditor editor = TestEditor(children: <Node>[block]);

      NodeEntry entry = EditorUtils.parent(editor, Point(Path([0, 0]), 1));

      expect(entry.node, block);
      expect(PathUtils.equals(entry.path, Path([0])), true);
    });

    test('range end', () {
      // <editor>
      //   <block>one</block>
      //   <block>two</block>
      // </editor>
      Text text1 = Text('one');
      Text text2 = Text('two');
      Block block1 = Block(children: <Node>[text1]);
      Block block2 = Block(children: <Node>[text2]);
      TestEditor editor = TestEditor(children: <Node>[block1, block2]);

      NodeEntry entry = EditorUtils.parent(
          editor, Range(Point(Path([0, 0]), 1), Point(Path([1, 0]), 2)),
          edge: Edge.end);

      expect(entry.node, block2);
      expect(PathUtils.equals(entry.path, Path([1])), true);
    });

    test('range start', () {
      // <editor>
      //   <block>one</block>
      //   <block>two</block>
      // </editor>
      Text text1 = Text('one');
      Text text2 = Text('two');
      Block block1 = Block(children: <Node>[text1]);
      Block block2 = Block(children: <Node>[text2]);
      TestEditor editor = TestEditor(children: <Node>[block1, block2]);

      NodeEntry entry = EditorUtils.parent(
          editor, Range(Point(Path([0, 0]), 1), Point(Path([1, 0]), 2)),
          edge: Edge.start);

      expect(entry.node, block1);
      expect(PathUtils.equals(entry.path, Path([0])), true);
    });

    test('range', () {
      // <editor>
      //   <block>one</block>
      //   <block>two</block>
      // </editor>
      Text text1 = Text('one');
      Text text2 = Text('two');
      Block block1 = Block(children: <Node>[text1]);
      Block block2 = Block(children: <Node>[text2]);
      TestEditor editor = TestEditor(children: <Node>[block1, block2]);

      NodeEntry entry = EditorUtils.parent(
        editor,
        Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 2)),
      );

      expect(entry.node, block1);
      expect(PathUtils.equals(entry.path, Path([0])), true);
    });
  });

  group('path', () {
    test('path', () {
      // <editor>
      //   <block>one</block>
      // </editor>
      Text text1 = Text('one');
      Block block = Block(children: <Node>[text1]);
      TestEditor editor = TestEditor(children: <Node>[block]);

      Path path = EditorUtils.path(editor, Path([0]));

      expect(PathUtils.equals(path, Path([0])), true);
    });

    test('point', () {
      // <editor>
      //   <block>one</block>
      // </editor>
      Text text1 = Text('one');
      Block block = Block(children: <Node>[text1]);
      TestEditor editor = TestEditor(children: <Node>[block]);

      Path path = EditorUtils.path(editor, Point(Path([0, 0]), 1));

      expect(PathUtils.equals(path, Path([0, 0])), true);
    });

    test('range end', () {
      // <editor>
      //   <block>one</block>
      //   <block>two</block>
      // </editor>
      Text text1 = Text('one');
      Text text2 = Text('two');
      Block block1 = Block(children: <Node>[text1]);
      Block block2 = Block(children: <Node>[text2]);
      TestEditor editor = TestEditor(children: <Node>[block1, block2]);

      Path path = EditorUtils.path(
          editor, Range(Point(Path([0, 0]), 1), Point(Path([1, 0]), 2)),
          edge: Edge.end);

      expect(PathUtils.equals(path, Path([1, 0])), true);
    });

    test('range start', () {
      // <editor>
      //   <block>one</block>
      //   <block>two</block>
      // </editor>
      Text text1 = Text('one');
      Text text2 = Text('two');
      Block block1 = Block(children: <Node>[text1]);
      Block block2 = Block(children: <Node>[text2]);
      TestEditor editor = TestEditor(children: <Node>[block1, block2]);

      Path path = EditorUtils.path(
          editor, Range(Point(Path([0, 0]), 1), Point(Path([1, 0]), 2)),
          edge: Edge.start);

      expect(PathUtils.equals(path, Path([0, 0])), true);
    });

    test('range', () {
      // <editor>
      //   <block>one</block>
      //   <block>two</block>
      // </editor>
      Text text1 = Text('one');
      Text text2 = Text('two');
      Block block1 = Block(children: <Node>[text1]);
      Block block2 = Block(children: <Node>[text2]);
      TestEditor editor = TestEditor(children: <Node>[block1, block2]);

      Path path = EditorUtils.path(
          editor, Range(Point(Path([0, 0]), 1), Point(Path([1, 0]), 2)));

      expect(PathUtils.equals(path, Path([])), true);
    });
  });

  group('point', () {
    test('path end', () {
      // <editor>
      //   <block>one</block>
      // </editor>
      Text text1 = Text('one');
      Block block = Block(children: <Node>[text1]);
      TestEditor editor = TestEditor(children: <Node>[block]);

      Point point = EditorUtils.point(editor, Path([0]), edge: Edge.end);

      expect(PointUtils.equals(point, Point(Path([0, 0]), 3)), true);
    });

    test('path start', () {
      // <editor>
      //   <block>one</block>
      // </editor>
      Text text1 = Text('one');
      Block block = Block(children: <Node>[text1]);
      TestEditor editor = TestEditor(children: <Node>[block]);

      Point point = EditorUtils.point(editor, Path([0]), edge: Edge.start);

      expect(PointUtils.equals(point, Point(Path([0, 0]), 0)), true);
    });

    test('path', () {
      // <editor>
      //   <block>one</block>
      // </editor>
      Text text1 = Text('one');
      Block block = Block(children: <Node>[text1]);
      TestEditor editor = TestEditor(children: <Node>[block]);

      Point point = EditorUtils.point(editor, Path([0]));

      expect(PointUtils.equals(point, Point(Path([0, 0]), 0)), true);
    });

    test('point', () {
      // <editor>
      //   <block>one</block>
      // </editor>
      Text text1 = Text('one');
      Block block = Block(children: <Node>[text1]);
      TestEditor editor = TestEditor(children: <Node>[block]);

      Point point = EditorUtils.point(editor, Point(Path([0, 0]), 1));

      expect(PointUtils.equals(point, Point(Path([0, 0]), 1)), true);
    });

    test('range end', () {
      // <editor>
      //   <block>one</block>
      //   <block>two</block>
      // </editor>
      Text text1 = Text('one');
      Text text2 = Text('two');
      Block block1 = Block(children: <Node>[text1]);
      Block block2 = Block(children: <Node>[text2]);
      TestEditor editor = TestEditor(children: <Node>[block1, block2]);

      Point point = EditorUtils.point(
          editor, Range(Point(Path([0, 0]), 1), Point(Path([0, 1]), 2)),
          edge: Edge.end);

      expect(PointUtils.equals(point, Point(Path([0, 1]), 2)), true);
    });

    test('range start', () {
      // <editor>
      //   <block>one</block>
      //   <block>two</block>
      // </editor>
      Text text1 = Text('one');
      Text text2 = Text('two');
      Block block1 = Block(children: <Node>[text1]);
      Block block2 = Block(children: <Node>[text2]);
      TestEditor editor = TestEditor(children: <Node>[block1, block2]);

      Point point = EditorUtils.point(
          editor, Range(Point(Path([0, 0]), 1), Point(Path([0, 1]), 2)),
          edge: Edge.start);

      expect(PointUtils.equals(point, Point(Path([0, 0]), 1)), true);
    });

    test('range', () {
      // <editor>
      //   <block>one</block>
      //   <block>two</block>
      // </editor>
      Text text1 = Text('one');
      Text text2 = Text('two');
      Block block1 = Block(children: <Node>[text1]);
      Block block2 = Block(children: <Node>[text2]);
      TestEditor editor = TestEditor(children: <Node>[block1, block2]);

      Point point = EditorUtils.point(
          editor, Range(Point(Path([0, 0]), 1), Point(Path([0, 1]), 2)));

      expect(PointUtils.equals(point, Point(Path([0, 0]), 1)), true);
    });
  });

  group('positions', () {
    group('all', () {
      test('block multiple reverse', () {
        // <editor>
        //   <block>one</block>
        //   <block>two</block>
        //   <block>three</block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[Text('one')]),
          Block(children: <Node>[Text('two')]),
          Block(children: <Node>[Text('three')]),
        ]);

        List<Point> points = List.from(
            EditorUtils.positions(editor, at: Path([]), reverse: true));

        expect(PointUtils.equals(points[0], Point(Path([2, 0]), 5)), true);
        expect(PointUtils.equals(points[1], Point(Path([2, 0]), 4)), true);
        expect(PointUtils.equals(points[2], Point(Path([2, 0]), 3)), true);
        expect(PointUtils.equals(points[3], Point(Path([2, 0]), 2)), true);
        expect(PointUtils.equals(points[4], Point(Path([2, 0]), 1)), true);
        expect(PointUtils.equals(points[5], Point(Path([2, 0]), 0)), true);
        expect(PointUtils.equals(points[6], Point(Path([1, 0]), 3)), true);
        expect(PointUtils.equals(points[7], Point(Path([1, 0]), 2)), true);
        expect(PointUtils.equals(points[8], Point(Path([1, 0]), 1)), true);
        expect(PointUtils.equals(points[9], Point(Path([1, 0]), 0)), true);
        expect(PointUtils.equals(points[10], Point(Path([0, 0]), 3)), true);
        expect(PointUtils.equals(points[11], Point(Path([0, 0]), 2)), true);
        expect(PointUtils.equals(points[12], Point(Path([0, 0]), 1)), true);
        expect(PointUtils.equals(points[13], Point(Path([0, 0]), 0)), true);
      });

      test('block multiple', () {
        // <editor>
        //   <block>one</block>
        //   <block>two</block>
        //   <block>three</block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[Text('one')]),
          Block(children: <Node>[Text('two')]),
          Block(children: <Node>[Text('three')]),
        ]);

        List<Point> points =
            List.from(EditorUtils.positions(editor, at: Path([])));

        expect(PointUtils.equals(points[0], Point(Path([0, 0]), 0)), true);
        expect(PointUtils.equals(points[1], Point(Path([0, 0]), 1)), true);
        expect(PointUtils.equals(points[2], Point(Path([0, 0]), 2)), true);
        expect(PointUtils.equals(points[3], Point(Path([0, 0]), 3)), true);
        expect(PointUtils.equals(points[4], Point(Path([1, 0]), 0)), true);
        expect(PointUtils.equals(points[5], Point(Path([1, 0]), 1)), true);
        expect(PointUtils.equals(points[6], Point(Path([1, 0]), 2)), true);
        expect(PointUtils.equals(points[7], Point(Path([1, 0]), 3)), true);
        expect(PointUtils.equals(points[8], Point(Path([2, 0]), 0)), true);
        expect(PointUtils.equals(points[9], Point(Path([2, 0]), 1)), true);
        expect(PointUtils.equals(points[10], Point(Path([2, 0]), 2)), true);
        expect(PointUtils.equals(points[11], Point(Path([2, 0]), 3)), true);
        expect(PointUtils.equals(points[12], Point(Path([2, 0]), 4)), true);
        expect(PointUtils.equals(points[13], Point(Path([2, 0]), 5)), true);
      });

      test('block nested', () {
        // <editor>
        //   <block>
        //     <block>one</block>
        //   </block>
        //   <block>
        //     <block>two</block>
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[
            Block(children: <Node>[Text('one')])
          ]),
          Block(children: <Node>[
            Block(children: <Node>[Text('two')])
          ]),
        ]);

        List<Point> points =
            List.from(EditorUtils.positions(editor, at: Path([])));

        expect(
            PointUtils.equals(
              points[0],
              Point(Path([0, 0, 0]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[1],
              Point(Path([0, 0, 0]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[2],
              Point(Path([0, 0, 0]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[3],
              Point(Path([0, 0, 0]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[4],
              Point(Path([1, 0, 0]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[5],
              Point(Path([1, 0, 0]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[6],
              Point(Path([1, 0, 0]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[7],
              Point(Path([1, 0, 0]), 3),
            ),
            true);
      });

      test('block reverse', () {
        // <editor>
        //   <block>one</block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[Text('one')]),
        ]);

        List<Point> points = List.from(
            EditorUtils.positions(editor, at: Path([]), reverse: true));

        expect(
            PointUtils.equals(
              points[0],
              Point(Path([0, 0]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[1],
              Point(Path([0, 0]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[2],
              Point(Path([0, 0]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[3],
              Point(Path([0, 0]), 0),
            ),
            true);
      });

      test('block', () {
        // <editor>
        //   <block>one</block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[Text('one')]),
        ]);

        List<Point> points =
            List.from(EditorUtils.positions(editor, at: Path([])));

        expect(
            PointUtils.equals(
              points[0],
              Point(Path([0, 0]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[1],
              Point(Path([0, 0]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[2],
              Point(Path([0, 0]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[3],
              Point(Path([0, 0]), 3),
            ),
            true);
      });

      test('inline multiple', () {
        // <editor>
        //   <block>
        //     one<inline>two</inline>three<inline>four</inline>five
        //   </block>
        // </editor>
        Text text1 = Text('one');
        Text text2 = Text('two');
        Inline inline2 = Inline(children: <Node>[text2]);
        Text text3 = Text('three');
        Text text4 = Text('four');
        Inline inline4 = Inline(children: <Node>[text4]);
        Text text5 = Text('five');
        Block block =
            Block(children: <Node>[text1, inline2, text3, inline4, text5]);
        TestEditor editor = TestEditor(children: <Node>[block]);

        List<Point> points =
            List.from(EditorUtils.positions(editor, at: Path([])));

        expect(
            PointUtils.equals(
              points[0],
              Point(Path([0, 0]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[1],
              Point(Path([0, 0]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[2],
              Point(Path([0, 0]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[3],
              Point(Path([0, 0]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[4],
              Point(Path([0, 1, 0]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[5],
              Point(Path([0, 1, 0]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[6],
              Point(Path([0, 1, 0]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[7],
              Point(Path([0, 1, 0]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[8],
              Point(Path([0, 2]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[9],
              Point(Path([0, 2]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[10],
              Point(Path([0, 2]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[11],
              Point(Path([0, 2]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[12],
              Point(Path([0, 2]), 4),
            ),
            true);
        expect(
            PointUtils.equals(
              points[13],
              Point(Path([0, 2]), 5),
            ),
            true);
        expect(
            PointUtils.equals(
              points[14],
              Point(Path([0, 3, 0]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[15],
              Point(Path([0, 3, 0]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[16],
              Point(Path([0, 3, 0]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[17],
              Point(Path([0, 3, 0]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[18],
              Point(Path([0, 3, 0]), 4),
            ),
            true);
        expect(
            PointUtils.equals(
              points[19],
              Point(Path([0, 4]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[20],
              Point(Path([0, 4]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[21],
              Point(Path([0, 4]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[22],
              Point(Path([0, 4]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[23],
              Point(Path([0, 4]), 4),
            ),
            true);
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

        List<Point> points =
            List.from(EditorUtils.positions(editor, at: Path([])));

        expect(
            PointUtils.equals(
              points[0],
              Point(Path([0, 0]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[1],
              Point(Path([0, 0]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[2],
              Point(Path([0, 0]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[3],
              Point(Path([0, 0]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[4],
              Point(Path([0, 1, 0]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[5],
              Point(Path([0, 1, 0]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[6],
              Point(Path([0, 1, 0]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[7],
              Point(Path([0, 1, 0]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[8],
              Point(Path([0, 1, 1, 0]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[9],
              Point(Path([0, 1, 1, 0]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[10],
              Point(Path([0, 1, 1, 0]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[11],
              Point(Path([0, 1, 1, 0]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[12],
              Point(Path([0, 1, 1, 0]), 4),
            ),
            true);
        expect(
            PointUtils.equals(
              points[13],
              Point(Path([0, 1, 1, 0]), 5),
            ),
            true);
        expect(
            PointUtils.equals(
              points[14],
              Point(Path([0, 1, 2]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[15],
              Point(Path([0, 1, 2]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[16],
              Point(Path([0, 1, 2]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[17],
              Point(Path([0, 1, 2]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[18],
              Point(Path([0, 1, 2]), 4),
            ),
            true);
        expect(
            PointUtils.equals(
              points[19],
              Point(Path([0, 2]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[20],
              Point(Path([0, 2]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[21],
              Point(Path([0, 2]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[22],
              Point(Path([0, 2]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[23],
              Point(Path([0, 2]), 4),
            ),
            true);
      });

      test('inline reverse', () {
        // <editor>
        //   <block>
        //     one<inline>two</inline>three
        //   </block>
        // </editor>
        Inline inline = Inline(children: <Node>[Text('two')]);
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[Text('one'), inline, Text('three')])
        ]);

        List<Point> points = List.from(
            EditorUtils.positions(editor, at: Path([]), reverse: true));

        expect(
            PointUtils.equals(
              points[0],
              Point(Path([0, 2]), 5),
            ),
            true);
        expect(
            PointUtils.equals(
              points[1],
              Point(Path([0, 2]), 4),
            ),
            true);
        expect(
            PointUtils.equals(
              points[2],
              Point(Path([0, 2]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[3],
              Point(Path([0, 2]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[4],
              Point(Path([0, 2]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[5],
              Point(Path([0, 2]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[6],
              Point(Path([0, 1, 0]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[7],
              Point(Path([0, 1, 0]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[8],
              Point(Path([0, 1, 0]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[9],
              Point(Path([0, 1, 0]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[10],
              Point(Path([0, 0]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[11],
              Point(Path([0, 0]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[12],
              Point(Path([0, 0]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[13],
              Point(Path([0, 0]), 0),
            ),
            true);
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

        List<Point> points =
            List.from(EditorUtils.positions(editor, at: Path([])));

        expect(
            PointUtils.equals(
              points[0],
              Point(Path([0, 0]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[1],
              Point(Path([0, 0]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[2],
              Point(Path([0, 0]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[3],
              Point(Path([0, 0]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[4],
              Point(Path([0, 1, 0]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[5],
              Point(Path([0, 1, 0]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[6],
              Point(Path([0, 1, 0]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[7],
              Point(Path([0, 1, 0]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[8],
              Point(Path([0, 2]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[9],
              Point(Path([0, 2]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[10],
              Point(Path([0, 2]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[11],
              Point(Path([0, 2]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[12],
              Point(Path([0, 2]), 4),
            ),
            true);
        expect(
            PointUtils.equals(
              points[13],
              Point(Path([0, 2]), 5),
            ),
            true);
      });

      test('unit block reverse', () {
        // <editor>
        //   <block>one two three</block>
        //   <block>four five six</block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[Text('one two three')]),
          Block(children: <Node>[Text('four five six')]),
        ]);

        List<Point> points = List.from(EditorUtils.positions(editor,
            at: Path([]), unit: Unit.block, reverse: true));

        expect(
            PointUtils.equals(
              points[0],
              Point(Path([1, 0]), 13),
            ),
            true);
        expect(
            PointUtils.equals(
              points[1],
              Point(Path([1, 0]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[2],
              Point(Path([0, 0]), 13),
            ),
            true);
        expect(
            PointUtils.equals(
              points[3],
              Point(Path([0, 0]), 0),
            ),
            true);
      });

      test('unit block', () {
        // <editor>
        //   <block>one two three</block>
        //   <block>four five six</block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[Text('one two three')]),
          Block(children: <Node>[Text('four five six')]),
        ]);

        List<Point> points = List.from(
            EditorUtils.positions(editor, at: Path([]), unit: Unit.block));

        expect(
            PointUtils.equals(
              points[0],
              Point(Path([0, 0]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[1],
              Point(Path([0, 0]), 13),
            ),
            true);
        expect(
            PointUtils.equals(
              points[2],
              Point(Path([1, 0]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[3],
              Point(Path([1, 0]), 13),
            ),
            true);
      });

      test('unit character reverse', () {
        // <editor>
        //   <block>
        //     one<inline>two</inline>three
        //   </block>
        //   <block>
        //     four<inline>five</inline>six
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
          Block(children: <Node>[
            Text('four'),
            Inline(children: <Node>[
              Text('five'),
            ]),
            Text('six')
          ]),
        ]);

        List<Point> points = List.from(EditorUtils.positions(editor,
            at: Path([]), unit: Unit.character, reverse: true));

        expect(
            PointUtils.equals(
              points[0],
              Point(Path([1, 2]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[1],
              Point(Path([1, 2]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[2],
              Point(Path([1, 2]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[3],
              Point(Path([1, 2]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[4],
              Point(Path([1, 1, 0]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[5],
              Point(Path([1, 1, 0]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[6],
              Point(Path([1, 1, 0]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[7],
              Point(Path([1, 1, 0]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[8],
              Point(Path([1, 0]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[9],
              Point(Path([1, 0]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[10],
              Point(Path([1, 0]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[11],
              Point(Path([1, 0]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[12],
              Point(Path([0, 2]), 5),
            ),
            true);
        expect(
            PointUtils.equals(
              points[13],
              Point(Path([0, 2]), 4),
            ),
            true);
        expect(
            PointUtils.equals(
              points[14],
              Point(Path([0, 2]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[15],
              Point(Path([0, 2]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[16],
              Point(Path([0, 2]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[17],
              Point(Path([0, 2]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[18],
              Point(Path([0, 1, 0]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[19],
              Point(Path([0, 1, 0]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[20],
              Point(Path([0, 1, 0]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[21],
              Point(Path([0, 0]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[22],
              Point(Path([0, 0]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[23],
              Point(Path([0, 0]), 0),
            ),
            true);
      });

      test('unit character', () {
        // <editor>
        //   <block>
        //     one<inline>two</inline>three
        //   </block>
        //   <block>
        //     four<inline>five</inline>six
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
          Block(children: <Node>[
            Text('four'),
            Inline(children: <Node>[
              Text('five'),
            ]),
            Text('six')
          ]),
        ]);

        List<Point> points = List.from(
            EditorUtils.positions(editor, at: Path([]), unit: Unit.character));

        expect(
            PointUtils.equals(
              points[0],
              Point(Path([0, 0]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[1],
              Point(Path([0, 0]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[2],
              Point(Path([0, 0]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[3],
              Point(Path([0, 0]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[4],
              Point(Path([0, 1, 0]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[5],
              Point(Path([0, 1, 0]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[6],
              Point(Path([0, 1, 0]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[7],
              Point(Path([0, 2]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[8],
              Point(Path([0, 2]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[9],
              Point(Path([0, 2]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[10],
              Point(Path([0, 2]), 4),
            ),
            true);
        expect(
            PointUtils.equals(
              points[11],
              Point(Path([0, 2]), 5),
            ),
            true);
        expect(
            PointUtils.equals(
              points[12],
              Point(Path([1, 0]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[13],
              Point(Path([1, 0]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[14],
              Point(Path([1, 0]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[15],
              Point(Path([1, 0]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[16],
              Point(Path([1, 0]), 4),
            ),
            true);
        expect(
            PointUtils.equals(
              points[17],
              Point(Path([1, 1, 0]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[18],
              Point(Path([1, 1, 0]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[19],
              Point(Path([1, 1, 0]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[20],
              Point(Path([1, 1, 0]), 4),
            ),
            true);
        expect(
            PointUtils.equals(
              points[21],
              Point(Path([1, 2]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[22],
              Point(Path([1, 2]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[23],
              Point(Path([1, 2]), 3),
            ),
            true);
      });

      test('unit line reverse', () {
        // <editor>
        //   <block>one two three</block>
        //   <block>four five six</block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[Text('one two three')]),
          Block(children: <Node>[Text('four five six')]),
        ]);

        List<Point> points = List.from(EditorUtils.positions(editor,
            at: Path([]), unit: Unit.line, reverse: true));

        expect(
            PointUtils.equals(
              points[0],
              Point(Path([1, 0]), 13),
            ),
            true);
        expect(
            PointUtils.equals(
              points[1],
              Point(Path([1, 0]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[2],
              Point(Path([0, 0]), 13),
            ),
            true);
        expect(
            PointUtils.equals(
              points[3],
              Point(Path([0, 0]), 0),
            ),
            true);
      });

      test('unit line', () {
        // <editor>
        //   <block>one two three</block>
        //   <block>four five six</block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[Text('one two three')]),
          Block(children: <Node>[Text('four five six')]),
        ]);

        List<Point> points = List.from(
            EditorUtils.positions(editor, at: Path([]), unit: Unit.line));

        expect(
            PointUtils.equals(
              points[0],
              Point(Path([0, 0]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[1],
              Point(Path([0, 0]), 13),
            ),
            true);
        expect(
            PointUtils.equals(
              points[2],
              Point(Path([1, 0]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[3],
              Point(Path([1, 0]), 13),
            ),
            true);
      });

      test('unit word reverse', () {
        // <editor>
        //   <block>one two three</block>
        //   <block>four five six</block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[Text('one two three')]),
          Block(children: <Node>[Text('four five six')]),
        ]);

        List<Point> points = List.from(EditorUtils.positions(editor,
            at: Path([]), unit: Unit.word, reverse: true));

        expect(
            PointUtils.equals(
              points[0],
              Point(Path([1, 0]), 13),
            ),
            true);
        expect(
            PointUtils.equals(
              points[1],
              Point(Path([1, 0]), 10),
            ),
            true);
        expect(
            PointUtils.equals(
              points[2],
              Point(Path([1, 0]), 5),
            ),
            true);
        expect(
            PointUtils.equals(
              points[3],
              Point(Path([1, 0]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[4],
              Point(Path([0, 0]), 13),
            ),
            true);
        expect(
            PointUtils.equals(
              points[5],
              Point(Path([0, 0]), 8),
            ),
            true);
        expect(
            PointUtils.equals(
              points[6],
              Point(Path([0, 0]), 4),
            ),
            true);
        expect(
            PointUtils.equals(
              points[7],
              Point(Path([0, 0]), 0),
            ),
            true);
      });

      test('unit word', () {
        // <editor>
        //   <block>one two three</block>
        //   <block>four five six</block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[Text('one two three')]),
          Block(children: <Node>[Text('four five six')]),
        ]);

        List<Point> points = List.from(
            EditorUtils.positions(editor, at: Path([]), unit: Unit.word));

        expect(
            PointUtils.equals(
              points[0],
              Point(Path([0, 0]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[1],
              Point(Path([0, 0]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[2],
              Point(Path([0, 0]), 7),
            ),
            true);
        expect(
            PointUtils.equals(
              points[3],
              Point(Path([0, 0]), 13),
            ),
            true);
        expect(
            PointUtils.equals(
              points[4],
              Point(Path([1, 0]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[5],
              Point(Path([1, 0]), 4),
            ),
            true);
        expect(
            PointUtils.equals(
              points[6],
              Point(Path([1, 0]), 9),
            ),
            true);
        expect(
            PointUtils.equals(
              points[7],
              Point(Path([1, 0]), 13),
            ),
            true);
      });
    });

    group('path', () {
      test('block nested', () {
        // <editor>
        //   <block>
        //     <block>one</block>
        //     <block>two</block>
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[
            Block(children: <Node>[Text('one')]),
            Block(children: <Node>[Text('two')]),
          ]),
        ]);

        List<Point> points =
            List.from(EditorUtils.positions(editor, at: Path([0])));

        expect(
            PointUtils.equals(
              points[0],
              Point(Path([0, 0, 0]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[1],
              Point(Path([0, 0, 0]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[2],
              Point(Path([0, 0, 0]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[3],
              Point(Path([0, 0, 0]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[4],
              Point(Path([0, 1, 0]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[5],
              Point(Path([0, 1, 0]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[6],
              Point(Path([0, 1, 0]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[7],
              Point(Path([0, 1, 0]), 3),
            ),
            true);
      });

      test('block reverse', () {
        // <editor>
        //   <block>one</block>
        //   <block>two</block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[Text('one')]),
          Block(children: <Node>[Text('two')]),
        ]);

        List<Point> points = List.from(
            EditorUtils.positions(editor, at: Path([0]), reverse: true));

        expect(
            PointUtils.equals(
              points[0],
              Point(Path([0, 0]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[1],
              Point(Path([0, 0]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[2],
              Point(Path([0, 0]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[3],
              Point(Path([0, 0]), 0),
            ),
            true);
      });

      test('block', () {
        // <editor>
        //   <block>one</block>
        //   <block>two</block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[Text('one')]),
          Block(children: <Node>[Text('two')]),
        ]);

        List<Point> points =
            List.from(EditorUtils.positions(editor, at: Path([1, 0])));

        expect(
            PointUtils.equals(
              points[0],
              Point(Path([1, 0]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[1],
              Point(Path([1, 0]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[2],
              Point(Path([1, 0]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[3],
              Point(Path([1, 0]), 3),
            ),
            true);
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

        List<Point> points =
            List.from(EditorUtils.positions(editor, at: Path([0, 1])));

        expect(
            PointUtils.equals(
              points[0],
              Point(Path([0, 1, 0]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[1],
              Point(Path([0, 1, 0]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[2],
              Point(Path([0, 1, 0]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[3],
              Point(Path([0, 1, 0]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[4],
              Point(Path([0, 1, 1, 0]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[5],
              Point(Path([0, 1, 1, 0]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[6],
              Point(Path([0, 1, 1, 0]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[7],
              Point(Path([0, 1, 1, 0]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[8],
              Point(Path([0, 1, 1, 0]), 4),
            ),
            true);
        expect(
            PointUtils.equals(
              points[9],
              Point(Path([0, 1, 1, 0]), 5),
            ),
            true);
        expect(
            PointUtils.equals(
              points[10],
              Point(Path([0, 1, 2]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[11],
              Point(Path([0, 1, 2]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[12],
              Point(Path([0, 1, 2]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[13],
              Point(Path([0, 1, 2]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[14],
              Point(Path([0, 1, 2]), 4),
            ),
            true);
      });

      test('inline reverse', () {
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

        List<Point> points = List.from(
            EditorUtils.positions(editor, at: Path([0, 1]), reverse: true));

        expect(
            PointUtils.equals(
              points[0],
              Point(Path([0, 1, 0]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[1],
              Point(Path([0, 1, 0]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[2],
              Point(Path([0, 1, 0]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[3],
              Point(Path([0, 1, 0]), 0),
            ),
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

        List<Point> points =
            List.from(EditorUtils.positions(editor, at: Path([0, 1])));

        expect(
            PointUtils.equals(
              points[0],
              Point(Path([0, 1, 0]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[1],
              Point(Path([0, 1, 0]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[2],
              Point(Path([0, 1, 0]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[3],
              Point(Path([0, 1, 0]), 3),
            ),
            true);
      });
    });

    group('range', () {
      test('block reverse', () {
        // <editor>
        //   <block>one</block>
        //   <block>two</block>
        //   <block>three</block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[Text('one')]),
          Block(children: <Node>[Text('two')]),
          Block(children: <Node>[Text('three')]),
        ]);

        List<Point> points = List.from(EditorUtils.positions(editor,
            at: Range(Point(Path([0, 0]), 1), Point(Path([2, 0]), 2)),
            reverse: true));

        expect(
            PointUtils.equals(
              points[0],
              Point(Path([2, 0]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[1],
              Point(Path([2, 0]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[2],
              Point(Path([2, 0]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[3],
              Point(Path([1, 0]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[4],
              Point(Path([1, 0]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[5],
              Point(Path([1, 0]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[6],
              Point(Path([1, 0]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[7],
              Point(Path([0, 0]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[8],
              Point(Path([0, 0]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[9],
              Point(Path([0, 0]), 1),
            ),
            true);
      });

      test('block', () {
        // <editor>
        //   <block>one</block>
        //   <block>two</block>
        //   <block>three</block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[Text('one')]),
          Block(children: <Node>[Text('two')]),
          Block(children: <Node>[Text('three')]),
        ]);

        List<Point> points = List.from(EditorUtils.positions(editor,
            at: Range(Point(Path([0, 0]), 1), Point(Path([2, 0]), 2))));

        expect(
            PointUtils.equals(
              points[0],
              Point(Path([0, 0]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[1],
              Point(Path([0, 0]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[2],
              Point(Path([0, 0]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[3],
              Point(Path([1, 0]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[4],
              Point(Path([1, 0]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[5],
              Point(Path([1, 0]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[6],
              Point(Path([1, 0]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[7],
              Point(Path([2, 0]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[8],
              Point(Path([2, 0]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[9],
              Point(Path([2, 0]), 2),
            ),
            true);
      });

      test('inline', () {
        // <editor>
        //   <block>
        //     one<inline>two</inline>three<inline>four</inline>five
        //   </block>
        // </editor>
        Text text1 = Text('one');
        Text text2 = Text('two');
        Inline inline2 = Inline(children: <Node>[text2]);
        Text text3 = Text('three');
        Text text4 = Text('four');
        Inline inline4 = Inline(children: <Node>[text4]);
        Text text5 = Text('five');
        Block block =
            Block(children: <Node>[text1, inline2, text3, inline4, text5]);
        TestEditor editor = TestEditor(children: <Node>[block]);

        List<Point> points = List.from(EditorUtils.positions(editor,
            at: Range(Point(Path([0, 0]), 2), Point(Path([0, 4]), 2))));

        expect(
            PointUtils.equals(
              points[0],
              Point(Path([0, 0]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[1],
              Point(Path([0, 0]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[2],
              Point(Path([0, 1, 0]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[3],
              Point(Path([0, 1, 0]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[4],
              Point(Path([0, 1, 0]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[5],
              Point(Path([0, 1, 0]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[6],
              Point(Path([0, 2]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[7],
              Point(Path([0, 2]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[8],
              Point(Path([0, 2]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[9],
              Point(Path([0, 2]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[10],
              Point(Path([0, 2]), 4),
            ),
            true);
        expect(
            PointUtils.equals(
              points[11],
              Point(Path([0, 2]), 5),
            ),
            true);
        expect(
            PointUtils.equals(
              points[12],
              Point(Path([0, 3, 0]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[13],
              Point(Path([0, 3, 0]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[14],
              Point(Path([0, 3, 0]), 2),
            ),
            true);
        expect(
            PointUtils.equals(
              points[15],
              Point(Path([0, 3, 0]), 3),
            ),
            true);
        expect(
            PointUtils.equals(
              points[16],
              Point(Path([0, 3, 0]), 4),
            ),
            true);
        expect(
            PointUtils.equals(
              points[17],
              Point(Path([0, 4]), 0),
            ),
            true);
        expect(
            PointUtils.equals(
              points[18],
              Point(Path([0, 4]), 1),
            ),
            true);
        expect(
            PointUtils.equals(
              points[19],
              Point(Path([0, 4]), 2),
            ),
            true);
      });
    });
  });

  group('previous', () {
    test('block', () {
      // <editor>
      //   <block>one</block>
      //   <block>two</block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[Text('one')]),
        Block(children: <Node>[Text('two')]),
      ]);
      NodeEntry previous =
          EditorUtils.previous(editor, at: Path([1]), match: (node) {
        return node is Block;
      });

      expect(previous.node, editor.children[0]);
      expect(PathUtils.equals(previous.path, Path([0])), true);
    });

    test('default', () {
      // <editor>
      //   <block>one</block>
      //   <block>two</block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[Text('one')]),
        Block(children: <Node>[Text('two')]),
      ]);
      NodeEntry previous = EditorUtils.previous(editor, at: Path([1]));

      expect(previous.node, editor.children[0]);
      expect(PathUtils.equals(previous.path, Path([0])), true);
    });

    test('text', () {
      // <editor>
      //   <block>one</block>
      //   <block>two</block>
      // </editor>
      Text text = Text('one');
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[text]),
        Block(children: <Node>[Text('two')]),
      ]);
      NodeEntry previous =
          EditorUtils.previous(editor, at: Path([1]), match: (node) {
        return node is Text;
      });

      expect(previous.node, text);
      expect(PathUtils.equals(previous.path, Path([0, 0])), true);
    });
  });

  group('range', () {
    test('path', () {
      // <editor>
      //   <block>one</block>
      // </editor>
      Text text1 = Text('one');
      Block block = Block(children: <Node>[text1]);
      TestEditor editor = TestEditor(children: <Node>[block]);

      Range range = EditorUtils.range(editor, Path([0]), null);

      expect(
          RangeUtils.equals(
              range, Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 3))),
          true);
    });

    test('point', () {
      // <editor>
      //   <block>one</block>
      // </editor>
      Text text1 = Text('one');
      Block block = Block(children: <Node>[text1]);
      TestEditor editor = TestEditor(children: <Node>[block]);

      Range range = EditorUtils.range(editor, Point(Path([0, 0]), 1), null);

      expect(
          RangeUtils.equals(
              range, Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 1))),
          true);
    });

    test('range backward', () {
      // <editor>
      //   <block>one</block>
      // </editor>
      Text text1 = Text('one');
      Block block1 = Block(children: <Node>[text1]);
      TestEditor editor = TestEditor(children: <Node>[block1]);

      Range range = EditorUtils.range(
          editor, Range(Point(Path([0, 0]), 2), Point(Path([0, 0]), 1)), null);

      expect(
          RangeUtils.equals(
              range, Range(Point(Path([0, 0]), 2), Point(Path([0, 0]), 1))),
          true);
    });

    test('range', () {
      // <editor>
      //   <block>one</block>
      // </editor>
      Text text1 = Text('one');
      Block block1 = Block(children: <Node>[text1]);
      TestEditor editor = TestEditor(children: <Node>[block1]);

      Range range = EditorUtils.range(
          editor, Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 2)), null);

      expect(
          RangeUtils.equals(
              range, Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 2))),
          true);
    });
  });

  group('start', () {
    test('path', () {
      // <editor>
      //   <block>one</block>
      // </editor>
      Text text1 = Text('one');
      Block block = Block(children: <Node>[text1]);
      TestEditor editor = TestEditor(children: <Node>[block]);

      Point point = EditorUtils.start(editor, Path([0]));

      expect(
          PointUtils.equals(
            point,
            Point(Path([0, 0]), 0),
          ),
          true);
    });

    test('point', () {
      // <editor>
      //   <block>one</block>
      // </editor>
      Text text1 = Text('one');
      Block block = Block(children: <Node>[text1]);
      TestEditor editor = TestEditor(children: <Node>[block]);

      Point point = EditorUtils.start(editor, Point(Path([0, 0]), 1));

      expect(
          PointUtils.equals(
            point,
            Point(Path([0, 0]), 1),
          ),
          true);
    });

    test('range', () {
      // <editor>
      //   <block>one</block>
      // </editor>
      Text text1 = Text('one');
      Block block1 = Block(children: <Node>[text1]);
      TestEditor editor = TestEditor(children: <Node>[block1]);

      Point point = EditorUtils.start(
          editor, Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 3)));

      expect(
          PointUtils.equals(
            point,
            Point(Path([0, 0]), 1),
          ),
          true);
    });
  });

  group('string', () {
    test('block across', () {
      // <editor>
      //   <block>
      //     <text>one</text>
      //     <text>two</text>
      //   </block>
      //   <block>
      //     <text>three</text>
      //     <text>four</text>
      //   </block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[Text('one'), Text('two')]),
        Block(children: <Node>[Text('three'), Text('four')]),
      ]);

      String result = EditorUtils.string(editor, Path([]));

      expect(result, 'onetwothreefour');
    });

    test('block void', () {
      // <editor>
      //   <block void>
      //     <text>one</text>
      //     <text>two</text>
      //   </block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[Text('one'), Text('two')], isVoid: true),
      ]);

      String result = EditorUtils.string(editor, Path([]));

      expect(result, '');
    });

    test('block', () {
      // <editor>
      //   <block>
      //     <text>one</text>
      //     <text>two</text>
      //   </block>
      //   <block>
      //     <text>three</text>
      //     <text>four</text>
      //   </block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[Text('one'), Text('two')]),
        Block(children: <Node>[Text('three'), Text('four')]),
      ]);

      String result = EditorUtils.string(editor, Path([0]));

      expect(result, 'onetwo');
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

      String result = EditorUtils.string(editor, Path([0, 1]));

      expect(result, 'two');
    });

    test('text', () {
      // <editor>
      //   <block>
      //     one<inline>two</inline>three
      //   </block>
      // </editor>
      TestEditor editor = TestEditor(children: <Node>[
        Block(children: <Node>[Text('one'), Text('two')]),
      ]);

      String result = EditorUtils.string(editor, Path([0, 0]));

      expect(result, 'one');
    });
  });
}
