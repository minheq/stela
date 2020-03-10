import 'package:flutter_test/flutter_test.dart';
import 'package:inday/stela/editor.dart';
import 'package:inday/stela/element.dart';
import 'package:inday/stela/node.dart';
import 'package:inday/stela/operation.dart';
import 'package:inday/stela/path.dart';
import 'package:inday/stela/point.dart';
import 'package:inday/stela/range.dart';
import 'package:inday/stela/text.dart';
import 'package:inday/stela/transforms.dart';

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

void Function(Node, Node) expectEqual = (Node node, Node another) {
  expect(node.runtimeType, another.runtimeType);

  if (node is Text) {
    expect(node.text, (another as Text).text);
    return;
  }

  if (node is Editor && node.selection != null) {
    expect(
        RangeUtils.equals(node.selection, (another as Editor).selection), true,
        reason:
            "expected: ${(another as Editor).selection.toString()}, received: ${node.selection.toString()}");
  }

  if (node is Element && another is Element) {
    expect(node.isVoid, another.isVoid);
  }

  for (var i = 0; i < (node as Ancestor).children.length; i++) {
    Node n = (node as Ancestor).children[i];
    Node an = (another as Ancestor).children[i];

    expectEqual(n, an);
  }
};

void main() {
  group('delete', () {
    group('emojis', () {
      test('inline end reverse', () {
        // <editor>
        //   <block>
        //     <text />
        //     <inline>
        //       word📛
        //       <cursor />
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 6), Point(Path([0, 1, 0]), 6)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('word📛')]),
                Text(''),
              ])
            ]);

        Transforms.delete(editor, unit: Unit.character, reverse: true);

        // <editor>
        //   <block>
        //     <text />
        //     <inline>
        //       word
        //       <cursor />
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 4), Point(Path([0, 1, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('word')]),
                Text(''),
              ])
            ]);

        expectEqual(editor, expected);
      });

      test('inline middle reverse', () {
        // <editor>
        //   <block>
        //     <text />
        //     <inline>
        //       wor📛
        //       <cursor />d
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 5), Point(Path([0, 1, 0]), 5)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('wor📛d')]),
                Text(''),
              ])
            ]);

        Transforms.delete(editor, unit: Unit.character, reverse: true);

        // <editor>
        //   <block>
        //     <text />
        //     <inline>
        //       wor
        //       <cursor />d
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 3), Point(Path([0, 1, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('word')]),
                Text(''),
              ])
            ]);

        expectEqual(editor, expected);
      });

      test('inline middle', () {
        // <editor>
        //   <block>
        //     <text />
        //     <inline>
        //       wo
        //       <cursor />
        //       📛rd
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 2), Point(Path([0, 1, 0]), 2)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('wo📛rd')]),
                Text(''),
              ])
            ]);

        Transforms.delete(editor, unit: Unit.character);

        // <editor>
        //   <block>
        //     <text />
        //     <inline>
        //       wo
        //       <cursor />
        //       rd
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 2), Point(Path([0, 1, 0]), 2)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('word')]),
                Text(''),
              ])
            ]);

        expectEqual(editor, expected);
      });

      test('inline only reverse', () {
        // <editor>
        //   <block>
        //     <text />
        //     <inline>
        //       📛
        //       <cursor />
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 2), Point(Path([0, 1, 0]), 2)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('📛')]),
                Text(''),
              ])
            ]);

        Transforms.delete(editor, unit: Unit.character, reverse: true);

        // <editor>
        //   <block>
        //     <text />
        //     <inline>
        //       <cursor />
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 0), Point(Path([0, 1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('')]),
                Text(''),
              ])
            ]);

        expectEqual(editor, expected);
      });

      test('inline start', () {
        // <editor>
        //   <block>
        //     <text />
        //     <inline>
        //       <cursor />
        //       📛word
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 0), Point(Path([0, 1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('📛word')]),
                Text(''),
              ])
            ]);

        Transforms.delete(editor, unit: Unit.character);

        // <editor>
        //   <block>
        //     <text />
        //     <inline>
        //       <cursor />
        //       word
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 0), Point(Path([0, 1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('word')]),
                Text(''),
              ])
            ]);

        expectEqual(editor, expected);
      });

      test('text end reverse', () {
        // <editor>
        //   <block>
        //     word📛
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 6), Point(Path([0, 0]), 6)),
            children: <Node>[
              Block(children: <Node>[Text('word📛')])
            ]);

        Transforms.delete(editor, unit: Unit.character, reverse: true);

        // <editor>
        //   <block>
        //     word
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[Text('word')])
            ]);

        expectEqual(editor, expected);
      });

      test('text start', () {
        // <editor>
        //   <block>
        //     <cursor />
        //     📛word
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[Text('📛word')])
            ]);

        Transforms.delete(editor, unit: Unit.character);

        // <editor>
        //   <block>
        //     <cursor />
        //     word
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[Text('word')])
            ]);

        expectEqual(editor, expected);
      });
    });

    group('path', () {
      test('block', () {
        // <editor>
        //   <block>one</block>
        //   <block>two</block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[Text('one')]),
          Block(children: <Node>[Text('two')]),
        ]);

        Transforms.delete(editor, at: Path([1]));

        // <editor>
        //   <block>one</block>
        // </editor>
        TestEditor expected = TestEditor(children: <Node>[
          Block(children: <Node>[Text('one')])
        ]);

        expectEqual(editor, expected);
      });

      test('inline', () {
        // <editor>
        //   <block>
        //     <text />
        //     <inline>one</inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[
            Text(''),
            Inline(children: <Node>[Text('one')]),
            Text('')
          ]),
        ]);

        Transforms.delete(editor, at: Path([0, 1]));

        // <editor>
        //   <block>
        //     <text />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(children: <Node>[
          Block(children: <Node>[Text('')])
        ]);

        expectEqual(editor, expected);
      });

      test('selection inside', () {
        // <editor>
        //   <block>one</block>
        //   <block>
        //     <text>
        //       t<cursor />
        //       wo
        //     </text>
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([1, 0]), 1), Point(Path([1, 0]), 1)),
            children: <Node>[
              Block(children: <Node>[Text('one')]),
              Block(children: <Node>[Text('two')]),
            ]);

        Transforms.delete(editor, at: Path([1, 0]));

        // <editor>
        //   <block>
        //     one
        //     <cursor />
        //   </block>
        //   <block>
        //     <text />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 3), Point(Path([0, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[Text('one')]),
              Block(children: <Node>[Text('')]),
            ]);

        expectEqual(editor, expected);
      });

      test('text', () {
        // <editor>
        //   <block>
        //     <text>one</text>
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[Text('one')]),
        ]);

        Transforms.delete(editor, at: Path([0, 0]));

        // <editor>
        //   <block>
        //     <text />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(children: <Node>[
          Block(children: <Node>[Text('')]),
        ]);

        expectEqual(editor, expected);
      });
    });

    group('point', () {
      test('basic reverse', () {
        // <editor>
        //   <block>one</block>
        //   <block>
        //     <cursor />
        //     two
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([1, 0]), 0), Point(Path([1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[Text('one')]),
              Block(children: <Node>[Text('two')]),
            ]);

        Transforms.delete(editor, reverse: true);

        // <editor>
        //   <block>
        //     one
        //     <cursor />
        //     two
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 3), Point(Path([0, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[Text('onetwo')]),
            ]);

        expectEqual(editor, expected);
      });

      test('basic', () {
        // <editor>
        //   <block>
        //     word
        //     <cursor />
        //   </block>
        //   <block>another</block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[Text('word')]),
              Block(children: <Node>[Text('another')]),
            ]);

        Transforms.delete(editor);

        // <editor>
        //   <block>
        //     word
        //     <cursor />
        //     another
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[Text('wordanother')]),
            ]);

        expectEqual(editor, expected);
      });

      test('depths reverse', () {
        // <editor>
        //   <block>Hello</block>
        //   <block>
        //     <block>
        //       <cursor />
        //       world!
        //     </block>
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection:
                Range(Point(Path([1, 0, 0]), 0), Point(Path([1, 0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[Text('Hello')]),
              Block(children: <Node>[
                Block(children: <Node>[Text('world!')])
              ]),
            ]);

        Transforms.delete(editor, reverse: true);

        // <editor>
        //   <block>
        //     Hello
        //     <cursor />
        //     world!
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 5), Point(Path([0, 0]), 5)),
            children: <Node>[
              Block(children: <Node>[Text('Helloworld!')]),
            ]);

        expectEqual(editor, expected);
      });

      test('inline before reverse', () {
        // <editor>
        //   <block>one</block>
        //   <block>
        //     <cursor />
        //     two
        //     <inline>three</inline>
        //     four
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([1, 0]), 0), Point(Path([1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[Text('one')]),
              Block(children: <Node>[
                Text('two'),
                Inline(children: <Node>[Text('three')]),
                Text('four'),
              ])
            ]);

        Transforms.delete(editor, reverse: true);

        // <editor>
        //   <block>
        //     one
        //     <cursor />
        //     two
        //     <inline>three</inline>
        //     four
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 3), Point(Path([0, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[
                Text('onetwo'),
                Inline(children: <Node>[Text('three')]),
                Text('four'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('inline before', () {
        // <editor>
        //   <block>
        //     word
        //     <cursor />
        //   </block>
        //   <block>
        //     <text />
        //     <inline void>
        //       <text />
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[Text('word')]),
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('')], isVoid: true),
                Text(''),
              ])
            ]);

        Transforms.delete(editor);

        // <editor>
        //   <block>
        //     word
        //     <cursor />
        //     <inline void>
        //       <text />
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
                Inline(children: <Node>[Text('')], isVoid: true),
                Text(''),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('inline inside reverse', () {
        // <editor>
        //   <block>
        //     one
        //     <inline>two</inline>
        //     <text />
        //   </block>
        //   <block>
        //     <text />
        //     <inline>
        //       <cursor />
        //       three
        //     </inline>
        //     four
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection:
                Range(Point(Path([1, 1, 0]), 0), Point(Path([1, 1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
                Inline(children: <Node>[Text('two')]),
                Text(''),
              ]),
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('three')]),
                Text('four'),
              ])
            ]);

        Transforms.delete(editor, reverse: true);

        // <editor>
        //   <block>
        //     one
        //     <inline>two</inline>
        //     <text />
        //     <inline>
        //       <cursor />
        //       three
        //     </inline>
        //     four
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 3, 0]), 0), Point(Path([0, 3, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
                Inline(children: <Node>[Text('two')]),
                Text(''),
                Inline(children: <Node>[Text('three')]),
                Text('four'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('inline void reverse', () {
        // <editor>
        //   <block>
        //     <text />
        //     <inline void>
        //       <text />
        //     </inline>
        //     <text />
        //   </block>
        //   <block>
        //     <cursor />
        //     word
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([1, 0]), 0), Point(Path([1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('')], isVoid: true),
                Text(''),
              ]),
              Block(children: <Node>[
                Text('word'),
              ])
            ]);

        Transforms.delete(editor, reverse: true);

        // <editor>
        //   <block>
        //     <text />
        //     <inline void>
        //       <text />
        //     </inline>
        //     <cursor />
        //     word
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 2]), 0), Point(Path([0, 2]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('')], isVoid: true),
                Text('word'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('inline', () {
        // <editor>
        //   <block>
        //     one
        //     <cursor />
        //   </block>
        //   <block>
        //     two<inline>three</inline>four
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 3), Point(Path([0, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ]),
              Block(children: <Node>[
                Text('two'),
                Inline(children: <Node>[Text('three')]),
                Text('four'),
              ])
            ]);

        Transforms.delete(editor);

        // <editor>
        //   <block>
        //     one
        //     <cursor />
        //     two<inline>three</inline>four
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 3), Point(Path([0, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[
                Text('onetwo'),
                Inline(children: <Node>[Text('three')]),
                Text('four'),
              ])
            ]);

        expectEqual(editor, expected);
      });

      test('nested reverse', () {
        // <editor>
        //   <block>
        //     <block>word</block>
        //     <block>
        //       <cursor />
        //       another
        //     </block>
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 0), Point(Path([0, 1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Block(children: <Node>[
                  Text('word'),
                ]),
                Block(children: <Node>[
                  Text('another'),
                ])
              ]),
            ]);

        Transforms.delete(editor, reverse: true);

        // <editor>
        //   <block>
        //     <block>
        //       word
        //       <cursor />
        //       another
        //     </block>
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 0, 0]), 4), Point(Path([0, 0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Block(children: <Node>[
                  Text('wordanother'),
                ])
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('nested', () {
        // <editor>
        //   <block>
        //     <block>
        //       word
        //       <cursor />
        //     </block>
        //     <block>another</block>
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection:
                Range(Point(Path([0, 0, 0]), 4), Point(Path([0, 0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Block(children: <Node>[
                  Text('word'),
                ]),
                Block(children: <Node>[
                  Text('another'),
                ])
              ]),
            ]);

        Transforms.delete(editor);

        // <editor>
        //   <block>
        //     <block>
        //       word
        //       <cursor />
        //       another
        //     </block>
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 0, 0]), 4), Point(Path([0, 0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Block(children: <Node>[
                  Text('wordanother'),
                ])
              ]),
            ]);

        expectEqual(editor, expected);
      });
    });

    group('selection', () {
      test('block across multiple', () {
        // <editor>
        //   <block>
        //     <anchor />
        //     one
        //   </block>
        //   <block>two</block>
        //   <block>three</block>
        //   <block>
        //     four
        //     <focus />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([3, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ]),
              Block(children: <Node>[
                Text('two'),
              ]),
              Block(children: <Node>[
                Text('three'),
              ]),
              Block(children: <Node>[
                Text('four'),
              ]),
            ]);

        Transforms.delete(editor);

        // <editor>
        //   <block>
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[Text('')]),
            ]);

        expectEqual(editor, expected);
      });

      test('block across nested', () {
        // <editor>
        //   <block>
        //     <block>
        //       one
        //       <anchor />
        //     </block>
        //     <block>two</block>
        //   </block>
        //   <block>
        //     <block>
        //       <focus />
        //       three
        //     </block>
        //     <block>four</block>
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection:
                Range(Point(Path([0, 0, 0]), 3), Point(Path([1, 0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Block(children: <Node>[
                  Text('one'),
                ]),
                Block(children: <Node>[
                  Text('two'),
                ]),
              ]),
              Block(children: <Node>[
                Block(children: <Node>[
                  Text('three'),
                ]),
              ]),
              Block(children: <Node>[
                Block(children: <Node>[
                  Text('four'),
                ]),
              ]),
            ]);

        Transforms.delete(editor);

        // <editor>
        //   <block>
        //     <block>
        //       one
        //       <cursor />
        //       three
        //     </block>
        //   </block>
        //   <block>
        //     <block>four</block>
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 0, 0]), 3), Point(Path([0, 0, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[
                Block(children: <Node>[
                  Text('onethree'),
                ]),
              ]),
              Block(children: <Node>[
                Block(children: <Node>[
                  Text('four'),
                ]),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('block across', () {
        // <editor>
        //   <block>
        //     wo
        //     <anchor />
        //     rd
        //   </block>
        //   <block>
        //     an
        //     <focus />
        //     other
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 2), Point(Path([1, 0]), 2)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
              Block(children: <Node>[
                Text('another'),
              ]),
            ]);

        Transforms.delete(editor);

        // <editor>
        //   <block>
        //     wo
        //     <cursor />
        //     other
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 2), Point(Path([0, 0]), 2)),
            children: <Node>[
              Block(children: <Node>[
                Text('woother'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('block depths nested', () {
        // <editor>
        //   <block>
        //     <block>
        //       one
        //       <anchor />
        //     </block>
        //   </block>
        //   <block>
        //     <focus />
        //     two
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0, 0]), 3), Point(Path([1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Block(children: <Node>[
                  Text('one'),
                ]),
              ]),
              Block(children: <Node>[
                Text('two'),
              ]),
            ]);

        Transforms.delete(editor);

        // <editor>
        //   <block>
        //     <block>
        //       one
        //       <cursor />
        //       two
        //     </block>
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 0, 0]), 3), Point(Path([0, 0, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[
                Block(children: <Node>[
                  Text('onetwo'),
                ]),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('block depths', () {
        // <editor>
        //   <block>
        //     wo
        //     <anchor />
        //     rd
        //   </block>
        //   <block>
        //     <block>middle</block>
        //     <block>
        //       an
        //       <focus />
        //       other
        //     </block>
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 2), Point(Path([1, 1, 0]), 2)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
              Block(children: <Node>[
                Block(children: <Node>[
                  Text('middle'),
                ]),
                Block(children: <Node>[
                  Text('another'),
                ]),
              ]),
            ]);

        Transforms.delete(editor);

        // <editor>
        //   <block>
        //     wo
        //     <cursor />
        //     other
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 2), Point(Path([0, 0]), 2)),
            children: <Node>[
              Block(children: <Node>[
                Text('woother'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('block hanging multiple', () {
        // <editor>
        //   <block>
        //     <anchor />
        //     one
        //   </block>
        //   <block>two</block>
        //   <block>
        //     <focus />
        //     three
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([2, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ]),
              Block(children: <Node>[
                Text('two'),
              ]),
              Block(children: <Node>[
                Text('three'),
              ]),
            ]);

        Transforms.delete(editor);

        // <editor>
        //   <block>
        //     <cursor />
        //   </block>
        //   <block>three</block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
              ]),
              Block(children: <Node>[
                Text('three'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('block hanging single', () {
        // <editor>
        //   <block>
        //     <anchor />
        //     one
        //   </block>
        //   <block>
        //     <focus />
        //     two
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ]),
              Block(children: <Node>[
                Text('two'),
              ]),
            ]);

        Transforms.delete(editor);

        // <editor>
        //   <block>
        //     <cursor />
        //   </block>
        //   <block>two</block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
              ]),
              Block(children: <Node>[
                Text('two'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('block inline across', () {
        // <editor>
        //   <block>
        //     <text />
        //     <inline>
        //       wo
        //       <anchor />
        //       rd
        //     </inline>
        //     <text />
        //   </block>
        //   <block>
        //     <text />
        //     <inline>
        //       an
        //       <focus />
        //       other
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 2), Point(Path([1, 1, 0]), 2)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('word')]),
                Text(''),
              ]),
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('another')]),
                Text(''),
              ]),
            ]);

        Transforms.delete(editor);

        // <editor>
        //   <block>
        //     <text />
        //     <inline>wo</inline>
        //     <text />
        //     <inline>
        //       <cursor />
        //       other
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 3, 0]), 0), Point(Path([0, 3, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('wo')]),
                Text(''),
                Inline(children: <Node>[Text('other')]),
                Text(''),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('block inline over', () {
        // <editor>
        //   <block>one</block>
        //   <block>
        //     t<anchor />
        //     wo<inline>three</inline>fou
        //     <focus />r
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([1, 0]), 1), Point(Path([1, 2]), 3)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ]),
              Block(children: <Node>[
                Text('two'),
                Inline(children: <Node>[Text('three')]),
                Text('four'),
              ]),
            ]);

        Transforms.delete(editor);

        // <editor>
        //   <block>one</block>
        //   <block>
        //     t<cursor />r
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([1, 0]), 1), Point(Path([1, 0]), 1)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ]),
              Block(children: <Node>[
                Text('tr'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('block join edges', () {
        // <editor>
        //   <block>
        //     word
        //     <anchor />
        //   </block>
        //   <block>
        //     <focus />
        //     another
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
              Block(children: <Node>[
                Text('another'),
              ]),
            ]);

        Transforms.delete(editor);

        // <editor>
        //   <block>
        //     word
        //     <cursor />
        //     another
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Text('wordanother'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('block join inline', () {
        // <editor>
        //   <block>
        //     one
        //     <anchor />
        //   </block>
        //   <block>
        //     <focus />
        //     two<inline>three</inline>four
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 3), Point(Path([1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ]),
              Block(children: <Node>[
                Text('two'),
                Inline(children: <Node>[Text('three')]),
                Text('four'),
              ]),
            ]);

        Transforms.delete(editor);

        // <editor>
        //   <block>
        //     one
        //     <cursor />
        //     two<inline>three</inline>four
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 3), Point(Path([0, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[
                Text('onetwo'),
                Inline(children: <Node>[Text('three')]),
                Text('four'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('block join nested', () {
        // <editor>
        //   <block>
        //     <block>
        //       <block>
        //         word
        //         <anchor />
        //       </block>
        //       <block>
        //         <focus />
        //         another
        //       </block>
        //     </block>
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(
                Point(Path([0, 0, 0, 0]), 4), Point(Path([0, 0, 1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Block(children: <Node>[
                  Block(children: <Node>[
                    Text('word'),
                  ]),
                  Block(children: <Node>[
                    Text('another'),
                  ]),
                ]),
              ]),
            ]);

        Transforms.delete(editor);

        // <editor>
        //   <block>
        //     <block>
        //       <block>
        //         word
        //         <cursor />
        //         another
        //       </block>
        //     </block>
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(
                Point(Path([0, 0, 0, 0]), 4), Point(Path([0, 0, 0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Block(children: <Node>[
                  Block(children: <Node>[
                    Text('wordanother'),
                  ]),
                ]),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('block middle', () {
        // <editor>
        //   <block>one</block>
        //   <block>
        //     t<anchor />w<focus />o
        //   </block>
        //   <block>three</block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([1, 0]), 1), Point(Path([1, 0]), 2)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ]),
              Block(children: <Node>[
                Text('two'),
              ]),
              Block(children: <Node>[
                Text('three'),
              ]),
            ]);

        Transforms.delete(editor);

        // <editor>
        //   <block>one</block>
        //   <block>
        //     t<cursor />o
        //   </block>
        //   <block>three</block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([1, 0]), 1), Point(Path([1, 0]), 1)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ]),
              Block(children: <Node>[
                Text('to'),
              ]),
              Block(children: <Node>[
                Text('three'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('block nested', () {
        // <editor>
        //   <block>
        //     <block>
        //       <anchor />
        //       one
        //     </block>
        //     <block>
        //       <block>two</block>
        //       <block>
        //         <block>
        //           three
        //           <focus />
        //         </block>
        //       </block>
        //     </block>
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(
                Point(Path([0, 0, 0]), 0), Point(Path([0, 1, 1, 0, 0]), 5)),
            children: <Node>[
              Block(children: <Node>[
                Block(children: <Node>[Text('one')]),
                Block(children: <Node>[
                  Block(children: <Node>[
                    Text('two'),
                  ]),
                  Block(children: <Node>[
                    Block(children: <Node>[
                      Text('three'),
                    ]),
                  ]),
                ]),
              ]),
            ]);

        Transforms.delete(editor);

        // <editor>
        //   <block>
        //     <block>
        //       <cursor />
        //     </block>
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 0, 0]), 0), Point(Path([0, 0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Block(children: <Node>[
                  Text(''),
                ]),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('character end', () {
        // <editor>
        //   <block>
        //     wor
        //     <anchor />d<focus />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 3), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
            ]);

        Transforms.delete(editor);

        // <editor>
        //   <block>
        //     wor
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 3), Point(Path([0, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[
                Text('wor'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('character middle', () {
        // <editor>
        //   <block>
        //     w<anchor />o<focus />
        //     rd
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 2)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
            ]);

        Transforms.delete(editor);

        // <editor>
        //   <block>
        //     w<cursor />
        //     rd
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 1)),
            children: <Node>[
              Block(children: <Node>[
                Text('wrd'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('character start', () {
        // <editor>
        //   <block>
        //     <anchor />w<focus />
        //     ord
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 1)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
            ]);

        Transforms.delete(editor);

        // <editor>
        //   <block>
        //     <cursor />
        //     ord
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('ord'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('inline after', () {
        // <editor>
        //   <block>
        //     one<inline>two</inline>
        //     <anchor />a<focus />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 2]), 0), Point(Path([0, 2]), 1)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
                Inline(children: <Node>[Text('two')]),
                Text('a'),
              ]),
            ]);

        Transforms.delete(editor);

        // <editor>
        //   <block>
        //     one<inline>two</inline>
        //     <text>
        //       <cursor />
        //     </text>
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 2]), 0), Point(Path([0, 2]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
                Inline(children: <Node>[Text('two')]),
                Text(''),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('inline inside', () {
        // <editor>
        //   <block>
        //     <text />
        //     <inline>
        //       wo
        //       <anchor />r<focus />d
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 2), Point(Path([0, 1, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('word')]),
                Text(''),
              ]),
            ]);

        Transforms.delete(editor);

        // <editor>
        //   <block>
        //     <text />
        //     <inline>
        //       wo
        //       <cursor />d
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 2), Point(Path([0, 1, 0]), 2)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('wod')]),
                Text(''),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('inline over', () {
        // <editor>
        //   <block>
        //     o<anchor />
        //     ne<inline>two</inline>thre
        //     <focus />e
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 1), Point(Path([0, 2]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
                Inline(children: <Node>[Text('two')]),
                Text('three'),
              ]),
            ]);

        Transforms.delete(editor);

        // <editor>
        //   <block>
        //     o<cursor />e
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 1)),
            children: <Node>[
              Block(children: <Node>[
                Text('oe'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('inline whole', () {
        // <editor>
        //   <block>
        //     <text />
        //     <inline>
        //       <anchor />
        //       word
        //       <focus />
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 0), Point(Path([0, 1, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('word')]),
                Text(''),
              ]),
            ]);

        Transforms.delete(editor);

        // <editor>
        //   <block>
        //     <text />
        //     <inline>
        //       <cursor />
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 0), Point(Path([0, 1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('')]),
                Text(''),
              ])
            ]);

        expectEqual(editor, expected);
      });

      test('word', () {
        // <editor>
        //   <block>
        //     <anchor />
        //     word
        //     <focus />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
            ]);

        Transforms.delete(editor);

        // <editor>
        //   <block>
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
              ])
            ]);

        expectEqual(editor, expected);
      });
    });

    group('unit character', () {
      test('document end', () {
        // <editor>
        //   <block>
        //     word
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
            ]);

        Transforms.delete(editor, unit: Unit.character);

        // <editor>
        //   <block>
        //     word
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('document start reverse', () {
        // <editor>
        //   <block>
        //     <cursor />
        //     word
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
            ]);

        Transforms.delete(editor, unit: Unit.character, reverse: true);

        // <editor>
        //   <block>
        //     <cursor />
        //     word
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('empty reverse', () {
        // <editor>
        //   <block>
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
              ]),
            ]);

        Transforms.delete(editor, unit: Unit.character, reverse: true);

        // <editor>
        //   <block>
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('empty', () {
        // <editor>
        //   <block>
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
              ]),
            ]);

        Transforms.delete(editor, unit: Unit.character);

        // <editor>
        //   <block>
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('end reverse', () {
        // <editor>
        //   <block>
        //     word
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
            ]);

        Transforms.delete(editor, unit: Unit.character, reverse: true);

        // <editor>
        //   <block>
        //     wor
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 3), Point(Path([0, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[
                Text('wor'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('end', () {
        // <editor>
        //   <block>
        //     wor
        //     <cursor />d
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 3), Point(Path([0, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
            ]);

        Transforms.delete(editor, unit: Unit.character);

        // <editor>
        //   <block>
        //     wor
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 3), Point(Path([0, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[
                Text('wor'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('first reverse', () {
        // <editor>
        //   <block>
        //     w<cursor />
        //     ord
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 1)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
            ]);

        Transforms.delete(editor, unit: Unit.character, reverse: true);

        // <editor>
        //   <block>
        //     <cursor />
        //     ord
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('ord'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('first', () {
        // <editor>
        //   <block>
        //     <cursor />
        //     word
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
            ]);

        Transforms.delete(editor, unit: Unit.character);

        // <editor>
        //   <block>
        //     <cursor />
        //     ord
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('ord'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('inline after reverse', () {
        // <editor>
        //   <block>
        //     one
        //     <inline>two</inline>
        //     a<cursor />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 2]), 1), Point(Path([0, 2]), 1)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
                Inline(children: <Node>[Text('two')]),
                Text('a'),
              ]),
            ]);

        Transforms.delete(editor, unit: Unit.character, reverse: true);

        // <editor>
        //   <block>
        //     one
        //     <inline>two</inline>
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 2]), 0), Point(Path([0, 2]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
                Inline(children: <Node>[Text('two')]),
                Text(''),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('inline before reverse', () {
        // <editor>
        //   <block>
        //     a<cursor />
        //     <inline>two</inline>
        //     three
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 1)),
            children: <Node>[
              Block(children: <Node>[
                Text('a'),
                Inline(children: <Node>[Text('two')]),
                Text('three'),
              ]),
            ]);

        Transforms.delete(editor, unit: Unit.character, reverse: true);

        // <editor>
        //   <block>
        //     <cursor />
        //     <inline>two</inline>
        //     three
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('two')]),
                Text('three'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('inline before', () {
        // <editor>
        //   <block>
        //     one
        //     <inline>two</inline>
        //     <cursor />a
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 2]), 0), Point(Path([0, 2]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
                Inline(children: <Node>[Text('two')]),
                Text('a'),
              ]),
            ]);

        Transforms.delete(editor, unit: Unit.character);

        // <editor>
        //   <block>
        //     one
        //     <inline>two</inline>
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 2]), 0), Point(Path([0, 2]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
                Inline(children: <Node>[Text('two')]),
                Text(''),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('inline end reverse', () {
        // <editor>
        //   <block>
        //     one
        //     <inline>two</inline>
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 2]), 0), Point(Path([0, 2]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
                Inline(children: <Node>[Text('two')]),
                Text(''),
              ]),
            ]);

        Transforms.delete(editor, unit: Unit.character, reverse: true);

        // <editor>
        //   <block>
        //     one
        //     <inline>tw</inline>
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 2]), 0), Point(Path([0, 2]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
                Inline(children: <Node>[Text('tw')]),
                Text(''),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('inline inside reverse', () {
        // <editor>
        //   <block>
        //     one
        //     <inline>
        //       a<cursor />
        //     </inline>
        //     three
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 1), Point(Path([0, 1, 0]), 1)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
                Inline(children: <Node>[Text('a')]),
                Text('three'),
              ]),
            ]);

        Transforms.delete(editor, unit: Unit.character, reverse: true);

        // <editor>
        //   <block>
        //     one
        //     <inline>
        //       <cursor />
        //     </inline>
        //     three
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 0), Point(Path([0, 1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
                Inline(children: <Node>[Text('')]),
                Text('three'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('inline inside', () {
        // <editor>
        //   <block>
        //     one
        //     <inline>
        //       <cursor />a
        //     </inline>
        //     two
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 0), Point(Path([0, 1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
                Inline(children: <Node>[Text('a')]),
                Text('two'),
              ]),
            ]);

        Transforms.delete(editor, unit: Unit.character);

        // <editor>
        //   <block>
        //     one
        //     <inline>
        //       <cursor />
        //     </inline>
        //     two
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 0), Point(Path([0, 1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
                Inline(children: <Node>[Text('')]),
                Text('two'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('last reverse', () {
        // <editor>
        //   <block>
        //     word
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
            ]);

        Transforms.delete(editor, unit: Unit.character, reverse: true);

        // <editor>
        //   <block>
        //     wor
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 3), Point(Path([0, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[
                Text('wor'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('last', () {
        // <editor>
        //   <block>
        //     wor
        //     <cursor />d
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 3), Point(Path([0, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
            ]);

        Transforms.delete(editor, unit: Unit.character);

        // <editor>
        //   <block>
        //     wor
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 3), Point(Path([0, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[
                Text('wor'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('middle reverse', () {
        // <editor>
        //   <block>
        //     wo
        //     <cursor />
        //     rd
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 2), Point(Path([0, 0]), 2)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
            ]);

        Transforms.delete(editor, unit: Unit.character, reverse: true);

        // <editor>
        //   <block>
        //     w<cursor />
        //     rd
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 1)),
            children: <Node>[
              Block(children: <Node>[
                Text('wrd'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('middle', () {
        // <editor>
        //   <block>
        //     wo
        //     <cursor />
        //     rd
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 2), Point(Path([0, 0]), 2)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
            ]);

        Transforms.delete(editor, unit: Unit.character);

        // <editor>
        //   <block>
        //     wo
        //     <cursor />d
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 2), Point(Path([0, 0]), 2)),
            children: <Node>[
              Block(children: <Node>[
                Text('wod'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('multiple reverse', () {
        // <editor>
        //   <block>
        //     word
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
            ]);

        Transforms.delete(editor,
            unit: Unit.character, distance: 3, reverse: true);

        // <editor>
        //   <block>
        //     w<cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 1)),
            children: <Node>[
              Block(children: <Node>[
                Text('w'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('multiple', () {
        // <editor>
        //   <block>
        //     <cursor />
        //     word
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
            ]);

        Transforms.delete(editor, unit: Unit.character, distance: 3);

        // <editor>
        //   <block>
        //     <cursor />d
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('d'),
              ]),
            ]);

        expectEqual(editor, expected);
      });
    });

    group('unit line', () {
      test('text end reverse', () {
        // <editor>
        //   <block>
        //     one two three
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 13), Point(Path([0, 0]), 13)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.delete(editor, unit: Unit.line, reverse: true);

        // <editor>
        //   <block>
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('text end', () {
        // <editor>
        //   <block>
        //     one two three
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 13), Point(Path([0, 0]), 13)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.delete(editor, unit: Unit.line);

        // <editor>
        //   <block>
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 13), Point(Path([0, 0]), 13)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('text middle reverse', () {
        // <editor>
        //   <block>
        //     one two thr
        //     <cursor />
        //     ee
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 11), Point(Path([0, 0]), 11)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.delete(editor, unit: Unit.line, reverse: true);

        // <editor>
        //   <block>
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('ee'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('text middle', () {
        // <editor>
        //   <block>
        //     one two thr
        //     <cursor />
        //     ee
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 11), Point(Path([0, 0]), 11)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.delete(editor, unit: Unit.line);

        // <editor>
        //   <block>
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 11), Point(Path([0, 0]), 11)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two thr'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('text start reverse', () {
        // <editor>
        //   <block>
        //     <cursor />
        //     one two three
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.delete(editor, unit: Unit.line, reverse: true);

        // <editor>
        //   <block>
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('text start', () {
        // <editor>
        //   <block>
        //     <cursor />
        //     one two three
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.delete(editor, unit: Unit.line);

        // <editor>
        //   <block>
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
              ]),
            ]);

        expectEqual(editor, expected);
      });
    });

    group('unit word', () {
      test('block join reverse', () {
        // <editor>
        //   <block>word</block>
        //   <block>
        //     <cursor />
        //     another
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([1, 0]), 0), Point(Path([1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
              Block(children: <Node>[
                Text('another'),
              ]),
            ]);

        Transforms.delete(editor, unit: Unit.word, reverse: true);

        // <editor>
        //   <block>
        //     word
        //     <cursor />
        //     another
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Text('wordanother'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('block join', () {
        // <editor>
        //   <block>
        //     word
        //     <cursor />
        //   </block>
        //   <block>another</block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
              Block(children: <Node>[
                Text('another'),
              ]),
            ]);

        Transforms.delete(editor, unit: Unit.word);

        // <editor>
        //   <block>
        //     word
        //     <cursor />
        //     another
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Text('wordanother'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('text end reverse', () {
        // <editor>
        //   <block>
        //     one two three
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 13), Point(Path([0, 0]), 13)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.delete(editor, unit: Unit.word, reverse: true);

        // <editor>
        //   <block>
        //     one two <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 8), Point(Path([0, 0]), 8)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two '),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('text middle reverse', () {
        // <editor>
        //   <block>
        //     one two thr
        //     <cursor />
        //     ee
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 11), Point(Path([0, 0]), 11)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.delete(editor, unit: Unit.word, reverse: true);

        // <editor>
        //   <block>
        //     one two <cursor />
        //     ee
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 8), Point(Path([0, 0]), 8)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two ee'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('text middle', () {
        // <editor>
        //   <block>
        //     o<cursor />
        //     ne two three
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 1)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.delete(editor, unit: Unit.word);

        // <editor>
        //   <block>
        //     o<cursor /> two three
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 1)),
            children: <Node>[
              Block(children: <Node>[
                Text('o two three'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('text start', () {
        // <editor>
        //   <block>
        //     <cursor />
        //     one two three
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.delete(editor, unit: Unit.word);

        // <editor>
        //   <block>
        //     <cursor /> two three
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(' two three'),
              ]),
            ]);

        expectEqual(editor, expected);
      });
    });

    group('voids false', () {
      test('block across backward', () {
        // <editor>
        //   <block void>
        //     <focus />
        //   </block>
        //   <block>one</block>
        //   <block>
        //     two
        //     <anchor />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([2, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
              ], isVoid: true),
              Block(children: <Node>[
                Text('one'),
              ]),
              Block(children: <Node>[
                Text('two'),
              ]),
            ]);

        Transforms.delete(editor);

        // <editor>
        //   <block>
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('block after reverse', () {
        // <editor>
        //   <block void>
        //     <text />
        //   </block>
        //   <block>
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([1, 0]), 0), Point(Path([1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
              ], isVoid: true),
              Block(children: <Node>[
                Text(''),
              ]),
            ]);

        Transforms.delete(editor, reverse: true);

        // <editor>
        //   <block>
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('block before', () {
        // <editor>
        //   <block>
        //     <cursor />
        //   </block>
        //   <block void>
        //     <text />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
              ]),
              Block(children: <Node>[
                Text(''),
              ], isVoid: true),
            ]);

        Transforms.delete(editor);

        // <editor>
        //   <block>
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('block both', () {
        // <editor>
        //   <block void>
        //     <anchor />
        //   </block>
        //   <block void>
        //     <focus />
        //   </block>
        //   <block>one</block>
        //   <block>two</block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
              ], isVoid: true),
              Block(children: <Node>[
                Text(''),
              ], isVoid: true),
              Block(children: <Node>[
                Text('one'),
              ]),
              Block(children: <Node>[
                Text('two'),
              ]),
            ]);

        Transforms.delete(editor);

        // <editor>
        //   <block>
        //     <cursor />
        //     one
        //   </block>
        //   <block>two</block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ]),
              Block(children: <Node>[
                Text('two'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('block end', () {
        // <editor>
        //   <block>
        //     wo
        //     <anchor />
        //     rd
        //   </block>
        //   <block void>
        //     an
        //     <focus />
        //     other
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 2), Point(Path([1, 0]), 2)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
              Block(children: <Node>[
                Text('another'),
              ], isVoid: true),
            ]);

        Transforms.delete(editor);

        // <editor>
        //   <block>
        //     wo
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 2), Point(Path([0, 0]), 2)),
            children: <Node>[
              Block(children: <Node>[
                Text('wo'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('block hanging from', () {
        // <editor>
        //   <block void>
        //     <anchor />
        //   </block>
        //   <block>
        //     <focus />
        //     one
        //   </block>
        //   <block>two</block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
              ], isVoid: true),
              Block(children: <Node>[
                Text('one'),
              ]),
              Block(children: <Node>[
                Text('two'),
              ]),
            ]);

        Transforms.delete(editor);

        // <editor>
        //   <block>
        //     <cursor />
        //     one
        //   </block>
        //   <block>two</block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ]),
              Block(children: <Node>[
                Text('two'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('block hanging into', () {
        // <editor>
        //   <block>
        //     <anchor />
        //     one
        //   </block>
        //   <block void>
        //     <focus />
        //     two
        //   </block>
        //   <block>three</block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ]),
              Block(children: <Node>[
                Text('two'),
              ], isVoid: true),
              Block(children: <Node>[
                Text('three'),
              ]),
            ]);

        Transforms.delete(editor);

        // <editor>
        //   <block>
        //     <cursor />
        //   </block>
        //   <block>three</block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
              ]),
              Block(children: <Node>[
                Text('three'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('block only', () {
        // <editor>
        //   <block void>
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
              ], isVoid: true),
            ]);

        Transforms.delete(editor);

        // <editor />
        TestEditor expected = TestEditor(children: <Node>[]);

        expectEqual(editor, expected);
      });

      test('block start multiple', () {
        // <editor>
        //   <block void>
        //     <anchor />
        //   </block>
        //   <block void>
        //     <text />
        //   </block>
        //   <block>
        //     <focus />
        //     one
        //   </block>
        //   <block>two</block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([2, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
              ], isVoid: true),
              Block(children: <Node>[
                Text(''),
              ], isVoid: true),
              Block(children: <Node>[
                Text('one'),
              ]),
              Block(children: <Node>[
                Text('two'),
              ]),
            ]);

        Transforms.delete(editor);

        // <editor>
        //   <block>
        //     <cursor />
        //     one
        //   </block>
        //   <block>two</block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ]),
              Block(children: <Node>[
                Text('two'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('block start', () {
        // <editor>
        //   <block void>
        //     <anchor />
        //   </block>
        //   <block>one</block>
        //   <block>
        //     tw
        //     <focus />o
        //   </block>
        //   <block>three</block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([2, 0]), 2)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
              ], isVoid: true),
              Block(children: <Node>[
                Text('one'),
              ]),
              Block(children: <Node>[
                Text('two'),
              ]),
              Block(children: <Node>[
                Text('three'),
              ]),
            ]);

        Transforms.delete(editor);

        // <editor>
        //   <block>
        //     <cursor />o
        //   </block>
        //   <block>three</block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('o'),
              ]),
              Block(children: <Node>[
                Text('three'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('inline after reverse', () {
        // <editor>
        //   <block>
        //     <text />
        //     <inline void>
        //       <text />
        //     </inline>
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 2]), 0), Point(Path([0, 2]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('')], isVoid: true),
                Text(''),
              ]),
            ]);

        Transforms.delete(editor, reverse: true);

        // <editor>
        //   <block>
        //     <text>
        //       <cursor />
        //     </text>
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('inline before', () {
        // <editor>
        //   <block>
        //     <text>
        //       <cursor />
        //     </text>
        //     <inline void>
        //       <text />
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('')], isVoid: true),
                Text(''),
              ]),
            ]);

        Transforms.delete(editor);

        // <editor>
        //   <block>
        //     <text>
        //       <cursor />
        //     </text>
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('inline into', () {
        // <editor>
        //   <block>
        //     <anchor />
        //     one
        //     <inline>
        //       t<focus />
        //       wo
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 1, 0]), 1)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
                Inline(children: <Node>[Text('two')]),
                Text(''),
              ]),
            ]);

        Transforms.delete(editor);

        // <editor>
        //   <block>
        //     <text />
        //     <inline>
        //       <cursor />
        //       wo
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 0), Point(Path([0, 1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('wo')]),
                Text(''),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('inline over', () {
        // <editor>
        //   <block>
        //     <anchor />
        //     one
        //   </block>
        //   <block>two</block>
        //   <block>
        //     three
        //     <inline void>four</inline>
        //     <focus />
        //     five
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([2, 3, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ]),
              Block(children: <Node>[
                Text('two'),
              ]),
              Block(children: <Node>[
                Text('three'),
                Inline(children: <Node>[Text('vour')], isVoid: true),
                Text('five'),
              ]),
            ]);

        Transforms.delete(editor);

        // <editor>
        //   <block>
        //     <cursor />
        //     five
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('five'),
              ]),
            ]);

        expectEqual(editor, expected);
      }, skip: 'failing');

      test('inline start across', () {
        // <editor>
        //   <block>
        //     one
        //     <inline void>
        //       <anchor />
        //     </inline>
        //     two
        //   </block>
        //   <block>
        //     three <focus />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 1, 0]), 0), Point(Path([1, 0]), 6)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
                Inline(children: <Node>[Text('')], isVoid: true),
                Text('two'),
              ]),
              Block(children: <Node>[
                Text('three '),
              ]),
            ]);

        Transforms.delete(editor);

        // <editor>
        //   <block>
        //     one
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 3), Point(Path([0, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('inline start', () {
        // <editor>
        //   <block>
        //     one
        //     <inline void>
        //       <anchor />
        //     </inline>
        //     <focus />
        //     two
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 1, 0]), 0), Point(Path([0, 2]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
                Inline(children: <Node>[Text('')], isVoid: true),
                Text('two'),
              ]),
            ]);

        Transforms.delete(editor);

        // <editor>
        //   <block>
        //     one
        //     <cursor />
        //     two
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 3), Point(Path([0, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[
                Text('onetwo'),
              ]),
            ]);

        expectEqual(editor, expected);
      });
    });

    group('voids true', () {
      test('across blocks', () {
        // <editor>
        //   <block void>
        //     <text>
        //       on
        //       <anchor />e
        //     </text>
        //   </block>
        //   <block void>
        //     <text>
        //       t<focus />
        //       wo
        //     </text>
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 2), Point(Path([1, 0]), 1)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ], isVoid: true),
              Block(children: <Node>[
                Text('two'),
              ], isVoid: true),
            ]);

        Transforms.delete(editor, voids: true);

        // <editor>
        //   <block void>
        //     on
        //     <cursor />
        //     wo
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 2), Point(Path([0, 0]), 2)),
            children: <Node>[
              Block(children: <Node>[
                Text('onwo'),
              ], isVoid: true),
            ]);

        expectEqual(editor, expected);
      });

      test('path', () {
        // <editor>
        //   <block void>
        //     <text>one</text>
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[
            Text('one'),
          ], isVoid: true),
        ]);

        Transforms.delete(editor, at: Path([0, 0]), voids: true);

        // <editor>
        //   <block void>
        //     <text />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(children: <Node>[
          Block(children: <Node>[
            Text(''),
          ], isVoid: true),
        ]);

        expectEqual(editor, expected);
      });
    });
  });

  group('deselect', () {
    test('path', () {
      // <editor>
      //   <block>
      //     <cursor />
      //     one
      //   </block>
      // </editor>
      TestEditor editor = TestEditor(
          selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
          children: <Node>[
            Block(children: <Node>[
              Text('one'),
            ]),
          ]);

      Transforms.deselect(editor);

      // <editor>
      //   <block>one</block>
      // </editor>
      TestEditor expected = TestEditor(children: <Node>[
        Block(children: <Node>[
          Text('one'),
        ]),
      ]);

      expectEqual(editor, expected);
    });
  });

  group('insertFragment', () {
    group('of block', () {
      test('block end', () {
        // <editor>
        //   <block>
        //     word
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
            ]);

        // <fragment>
        //   <block>one</block>
        //   <block>two</block>
        //   <block>three</block>
        // </fragment>
        List<Node> fragment = [
          Block(children: <Node>[Text('one')]),
          Block(children: <Node>[Text('two')]),
          Block(children: <Node>[Text('three')]),
        ];

        Transforms.insertFragment(editor, fragment);

        // <editor>
        //   <block>wordone</block>
        //   <block>two</block>
        //   <block>
        //     three
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([2, 0]), 5), Point(Path([2, 0]), 5)),
            children: <Node>[
              Block(children: <Node>[
                Text('wordone'),
              ]),
              Block(children: <Node>[
                Text('two'),
              ]),
              Block(children: <Node>[
                Text('three'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('block hanging', () {
        // <editor>
        //   <block>
        //     <anchor />
        //     word
        //   </block>
        //   <block>
        //     <focus />
        //     another
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
              Block(children: <Node>[
                Text('another'),
              ]),
            ]);

        // <fragment>
        //   <block>one</block>
        //   <block>two</block>
        // </fragment>
        List<Node> fragment = [
          Block(children: <Node>[Text('one')]),
          Block(children: <Node>[Text('two')]),
        ];

        Transforms.insertFragment(editor, fragment);

        // <editor>
        //   <block>one</block>
        //   <block>
        //     two
        //     <cursor />
        //   </block>
        //   <block>another</block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([1, 0]), 3), Point(Path([1, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ]),
              Block(children: <Node>[
                Text('two'),
              ]),
              Block(children: <Node>[
                Text('another'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('block middle', () {
        // <editor>
        //   <block>
        //     wo
        //     <cursor />
        //     rd
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 2), Point(Path([0, 0]), 2)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
            ]);

        // <fragment>
        //   <block>one</block>
        //   <block>two</block>
        //   <block>three</block>
        // </fragment>
        List<Node> fragment = [
          Block(children: <Node>[Text('one')]),
          Block(children: <Node>[Text('two')]),
          Block(children: <Node>[Text('three')]),
        ];

        Transforms.insertFragment(editor, fragment);

        // <editor>
        //   <block>woone</block>
        //   <block>two</block>
        //   <block>
        //     three
        //     <cursor />
        //     rd
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([2, 0]), 5), Point(Path([2, 0]), 5)),
            children: <Node>[
              Block(children: <Node>[
                Text('woone'),
              ]),
              Block(children: <Node>[
                Text('two'),
              ]),
              Block(children: <Node>[
                Text('threerd'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('block nested', () {
        // <editor>
        //   <block>
        //     <block>
        //       word
        //       <cursor />
        //     </block>
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection:
                Range(Point(Path([0, 0, 0]), 4), Point(Path([0, 0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Block(children: <Node>[
                  Text('word'),
                ]),
              ]),
            ]);

        // <fragment>
        //   <block>one</block>
        //   <block>two</block>
        //   <block>three</block>
        // </fragment>
        List<Node> fragment = [
          Block(children: <Node>[Text('one')]),
          Block(children: <Node>[Text('two')]),
          Block(children: <Node>[Text('three')]),
        ];

        Transforms.insertFragment(editor, fragment);

        // <editor>
        //   <block>
        //     <block>wordone</block>
        //     <block>two</block>
        //     <block>
        //       three
        //       <cursor />
        //     </block>
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 2, 0]), 5), Point(Path([0, 2, 0]), 5)),
            children: <Node>[
              Block(children: <Node>[
                Block(children: <Node>[
                  Text('wordone'),
                ]),
                Block(children: <Node>[
                  Text('two'),
                ]),
                Block(children: <Node>[
                  Text('three'),
                ]),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('block start', () {
        // <editor>
        //   <block>
        //     <cursor />
        //     word
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
            ]);

        // <fragment>
        //   <block>one</block>
        //   <block>two</block>
        //   <block>three</block>
        // </fragment>
        List<Node> fragment = [
          Block(children: <Node>[Text('one')]),
          Block(children: <Node>[Text('two')]),
          Block(children: <Node>[Text('three')]),
        ];

        Transforms.insertFragment(editor, fragment);

        // <editor>
        //   <block>one</block>
        //   <block>two</block>
        //   <block>
        //     three
        //     <cursor />
        //     word
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([2, 0]), 5), Point(Path([2, 0]), 5)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ]),
              Block(children: <Node>[
                Text('two'),
              ]),
              Block(children: <Node>[
                Text('threeword'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('with inline', () {
        // <editor>
        //   <block>
        //     wo
        //     <cursor />
        //     rd
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 2), Point(Path([0, 0]), 2)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
            ]);

        // <fragment>
        //   <block>
        //     one<inline>two</inline>three
        //   </block>
        //   <block>
        //     four<inline>five</inline>six
        //   </block>
        //   <block>
        //     seven<inline>eight</inline>nine
        //   </block>
        // </fragment>
        List<Node> fragment = [
          Block(children: <Node>[
            Text('one'),
            Inline(children: <Node>[Text('two')]),
            Text('three'),
          ]),
          Block(children: <Node>[
            Text('four'),
            Inline(children: <Node>[Text('five')]),
            Text('six'),
          ]),
          Block(children: <Node>[
            Text('7'),
            Inline(children: <Node>[Text('eight')]),
            Text('nine'),
          ]),
        ];

        Transforms.insertFragment(editor, fragment);

        // <editor>
        //   <block>
        //     woone<inline>two</inline>three
        //   </block>
        //   <block>
        //     four<inline>five</inline>six
        //   </block>
        //   <block>
        //     seven<inline>eight</inline>nine
        //     <cursor />
        //     rd
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([2, 2]), 4), Point(Path([2, 2]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Text('woone'),
                Inline(children: <Node>[Text('two')]),
                Text('three'),
              ]),
              Block(children: <Node>[
                Text('four'),
                Inline(children: <Node>[Text('five')]),
                Text('six'),
              ]),
              Block(children: <Node>[
                Text('7'),
                Inline(children: <Node>[Text('eight')]),
                Text('ninerd'),
              ]),
            ]);

        expectEqual(editor, expected);
      });
    });

    group('of inlines', () {
      test('block empty', () {
        // <editor>
        //   <block>
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
              ]),
            ]);

        // <fragment>
        //   <inline>fragment</inline>
        // </fragment>
        List<Node> fragment = [
          Inline(children: <Node>[Text('fragment')]),
        ];

        Transforms.insertFragment(editor, fragment);

        // <editor>
        //   <block>
        //     <text />
        //     <inline>
        //       fragment
        //       <cursor />
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 8), Point(Path([0, 1, 0]), 8)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('fragment')]),
                Text(''),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('block end', () {
        // <editor>
        //   <block>
        //     word
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
            ]);

        // <fragment>
        //   <inline>fragment</inline>
        // </fragment>
        List<Node> fragment = [
          Inline(children: <Node>[Text('fragment')]),
        ];

        Transforms.insertFragment(editor, fragment);

        // <editor>
        //   <block>
        //     word
        //     <inline>
        //       fragment
        //       <cursor />
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        // TODO: this cursor placement seems off
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 8), Point(Path([0, 1, 0]), 8)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
                Inline(children: <Node>[Text('fragment')]),
                Text(''),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('block middle', () {
        // <editor>
        //   <block>
        //     wo
        //     <cursor />
        //     rd
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 2), Point(Path([0, 0]), 2)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
            ]);

        // <fragment>
        //   <inline>fragment</inline>
        // </fragment>
        List<Node> fragment = [
          Inline(children: <Node>[Text('fragment')]),
        ];

        Transforms.insertFragment(editor, fragment);

        // <editor>
        //   <block>
        //     wo
        //     <inline>
        //       fragment
        //       <cursor />
        //     </inline>
        //     rd
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 8), Point(Path([0, 1, 0]), 8)),
            children: <Node>[
              Block(children: <Node>[
                Text('wo'),
                Inline(children: <Node>[Text('fragment')]),
                Text('rd'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('block start', () {
        // <editor>
        //   <block>
        //     <cursor />
        //     word
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
            ]);

        // <fragment>
        //   <inline>fragment</inline>
        // </fragment>
        List<Node> fragment = [
          Inline(children: <Node>[Text('fragment')]),
        ];

        Transforms.insertFragment(editor, fragment);

        // <editor>
        //   <block>
        //     <text />
        //     <inline>
        //       fragment
        //       <cursor />
        //     </inline>
        //     word
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 8), Point(Path([0, 1, 0]), 8)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('fragment')]),
                Text('word'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('inline after', () {
        // <editor>
        //   <block>
        //     <text />
        //     <inline>word</inline>
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 2]), 0), Point(Path([0, 2]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('word')]),
                Text(''),
              ]),
            ]);

        // <fragment>
        //   <inline>fragment</inline>
        // </fragment>
        List<Node> fragment = [
          Inline(children: <Node>[Text('fragment')]),
        ];

        Transforms.insertFragment(editor, fragment);

        // <editor>
        //   <block>
        //     <text />
        //     <inline>word</inline>
        //     <text />
        //     <inline>
        //       fragment
        //       <cursor />
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 3, 0]), 8), Point(Path([0, 3, 0]), 8)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('word')]),
                Text(''),
                Inline(children: <Node>[Text('fragment')]),
                Text(''),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('inline before', () {
        // <editor>
        //   <block>
        //     <cursor />
        //     <inline>word</inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('word')]),
                Text(''),
              ]),
            ]);

        // <fragment>
        //   <inline>fragment</inline>
        // </fragment>
        List<Node> fragment = [
          Inline(children: <Node>[Text('fragment')]),
        ];

        Transforms.insertFragment(editor, fragment);

        // <editor>
        //   <block>
        //     <text />
        //     <inline>
        //       fragment
        //       <cursor />
        //     </inline>
        //     <text />
        //     <inline>word</inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 8), Point(Path([0, 1, 0]), 8)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('fragment')]),
                Text(''),
                Inline(children: <Node>[Text('word')]),
                Text(''),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('inline empty', () {
        // <editor>
        //   <block>
        //     <text />
        //     <inline>
        //       <cursor />
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 1]), 0), Point(Path([0, 1]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('')]),
                Text(''),
              ]),
            ]);

        // <fragment>
        //   <inline>fragment</inline>
        // </fragment>
        List<Node> fragment = [
          Inline(children: <Node>[Text('fragment')]),
        ];

        Transforms.insertFragment(editor, fragment);

        // <editor>
        //   <block>
        //     <text />
        //     <inline>
        //       <text />
        //     </inline>
        //     <text />
        //     <inline>
        //       fragment
        //       <cursor />
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 3, 0]), 8), Point(Path([0, 3, 0]), 8)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('')]),
                Text(''),
                Inline(children: <Node>[Text('fragment')]),
                Text(''),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('inline end', () {
        // <editor>
        //   <block>
        //     <text />
        //     <inline>
        //       word
        //       <cursor />
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 4), Point(Path([0, 1, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('word')]),
                Text(''),
              ]),
            ]);

        // <fragment>
        //   <inline>fragment</inline>
        // </fragment>
        List<Node> fragment = [
          Inline(children: <Node>[Text('fragment')]),
        ];

        Transforms.insertFragment(editor, fragment);

        // <editor>
        //   <block>
        //     <text />
        //     <inline>word</inline>
        //     <text />
        //     <inline>
        //       fragment
        //       <cursor />
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 3, 0]), 8), Point(Path([0, 3, 0]), 8)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('word')]),
                Text(''),
                Inline(children: <Node>[Text('fragment')]),
                Text(''),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('inline middle', () {
        // <editor>
        //   <block>
        //     <text />
        //     <inline>
        //       wo
        //       <cursor />
        //       rd
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 2), Point(Path([0, 1, 0]), 2)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('word')]),
                Text(''),
              ]),
            ]);

        // <fragment>
        //   <inline>fragment</inline>
        // </fragment>
        List<Node> fragment = [
          Inline(children: <Node>[Text('fragment')]),
        ];

        Transforms.insertFragment(editor, fragment);

        // <editor>
        //   <block>
        //     <text />
        //     <inline>wo</inline>
        //     <text />
        //     <inline>
        //       fragment
        //       <cursor />
        //     </inline>
        //     <text />
        //     <inline>rd</inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 3, 0]), 8), Point(Path([0, 3, 0]), 8)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('wo')]),
                Text(''),
                Inline(children: <Node>[Text('fragment')]),
                Text(''),
                Inline(children: <Node>[Text('rd')]),
                Text(''),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('inline start', () {
        // <editor>
        //   <block>
        //     <text />
        //     <inline>
        //       <cursor />
        //       word
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 0), Point(Path([0, 1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('word')]),
                Text(''),
              ]),
            ]);

        // <fragment>
        //   <inline>fragment</inline>
        // </fragment>
        List<Node> fragment = [
          Inline(children: <Node>[Text('fragment')]),
        ];

        Transforms.insertFragment(editor, fragment);

        // <editor>
        //   <block>
        //     <text />
        //     <inline>
        //       fragment
        //       <cursor />
        //     </inline>
        //     <text />
        //     <inline>word</inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 8), Point(Path([0, 1, 0]), 8)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('fragment')]),
                Text(''),
                Inline(children: <Node>[Text('word')]),
                Text(''),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('with multiple', () {
        // <editor>
        //   <block>
        //     <text />
        //     <inline>
        //       wo
        //       <cursor />
        //       rd
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 2), Point(Path([0, 1, 0]), 2)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('word')]),
                Text(''),
              ]),
            ]);

        // <fragment>
        //   <inline>one</inline>
        //   <inline>two</inline>
        //   <inline>three</inline>
        // </fragment>
        List<Node> fragment = [
          Inline(children: <Node>[Text('one')]),
          Inline(children: <Node>[Text('two')]),
          Inline(children: <Node>[Text('three')]),
        ];

        Transforms.insertFragment(editor, fragment);

        // <editor>
        //   <block>
        //     <text />
        //     <inline>wo</inline>
        //     <text />
        //     <inline>one</inline>
        //     <text />
        //     <inline>two</inline>
        //     <text />
        //     <inline>
        //       three
        //       <cursor />
        //     </inline>
        //     <text />
        //     <inline>rd</inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 7, 0]), 5), Point(Path([0, 7, 0]), 5)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('wo')]),
                Text(''),
                Inline(children: <Node>[Text('one')]),
                Text(''),
                Inline(children: <Node>[Text('two')]),
                Text(''),
                Inline(children: <Node>[Text('three')]),
                Text(''),
                Inline(children: <Node>[Text('rd')]),
                Text(''),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('with text', () {
        // <editor>
        //   <block>
        //     wo
        //     <cursor />
        //     rd
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 2), Point(Path([0, 0]), 2)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
            ]);

        // <fragment>
        //   one
        //   <inline>two</inline>
        //   three
        // </fragment>
        List<Node> fragment = [
          Text('one'),
          Inline(children: <Node>[Text('two')]),
          Text('three'),
        ];

        Transforms.insertFragment(editor, fragment);

        // <editor>
        //   <block>
        //     woone
        //     <inline>two</inline>
        //     three
        //     <cursor />
        //     rd
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 2]), 5), Point(Path([0, 2]), 5)),
            children: <Node>[
              Block(children: <Node>[
                Text('woone'),
                Inline(children: <Node>[Text('two')]),
                Text('threerd'),
              ]),
            ]);

        expectEqual(editor, expected);
      });
    });

    group('of lists', () {
      test('merge lists', () {
        // <editor>
        //   <block>
        //     <block>1</block>
        //     <block>
        //       2<cursor />
        //     </block>
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 1]), 1), Point(Path([0, 1]), 1)),
            children: <Node>[
              Block(children: <Node>[
                Block(children: <Node>[
                  Text('1'),
                ]),
                Block(children: <Node>[
                  Text('2'),
                ]),
              ]),
            ]);

        // <fragment>
        //   <block>3</block>
        //   <block>4</block>
        // </fragment>
        List<Node> fragment = [
          Block(children: <Node>[
            Text('3'),
          ]),
          Block(children: <Node>[
            Text('4'),
          ]),
        ];

        Transforms.insertFragment(editor, fragment);

        // <editor>
        //   <block>
        //     <block>1</block>
        //     <block>23</block>
        //     <block>
        //       4<cursor />
        //     </block>
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 2]), 5), Point(Path([0, 2]), 5)),
            children: <Node>[
              Block(children: <Node>[
                Text('woone'),
                Inline(children: <Node>[Text('two')]),
                Text('threerd'),
              ]),
            ]);

        expectEqual(editor, expected);
      }, skip: 'failure');
    });

    group('of tables', () {
      test('merge cells with nested blocks', () {
        // <editor>
        //   <block>
        //     <block>
        //       <block>
        //         <block>
        //           <block>
        //             <cursor />
        //           </block>
        //         </block>
        //         <block>
        //           <block>
        //             <text />
        //           </block>
        //         </block>
        //       </block>
        //     </block>
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0, 0, 0, 0, 0]), 0),
                Point(Path([0, 0, 0, 0, 0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Block(children: <Node>[
                  Block(children: <Node>[
                    Block(children: <Node>[
                      Block(children: <Node>[
                        Text(''),
                      ]),
                    ]),
                    Block(children: <Node>[
                      Block(children: <Node>[
                        Text(''),
                      ]),
                    ]),
                  ]),
                ]),
              ]),
            ]);

        // <fragment>
        //   <block>
        //     <block>
        //       <block>
        //         <block>1</block>
        //       </block>
        //       <block>
        //         <block>2</block>
        //       </block>
        //     </block>
        //   </block>
        // </fragment>
        List<Node> fragment = [
          Block(children: <Node>[
            Block(children: <Node>[
              Block(children: <Node>[
                Block(children: <Node>[
                  Text('1'),
                ]),
              ]),
              Block(children: <Node>[
                Block(children: <Node>[
                  Text('2'),
                ]),
              ]),
            ]),
          ]),
        ];

        Transforms.insertFragment(editor, fragment);

        // <editor>
        //   <block>
        //     <block>
        //       <block>
        //         <block>
        //           <block>1</block>
        //           <block>
        //             <block>
        //               2<cursor />
        //             </block>
        //           </block>
        //         </block>
        //         <block>
        //           <block>
        //             <text />
        //           </block>
        //         </block>
        //       </block>
        //     </block>
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0, 0, 0, 1, 0, 0]), 1),
                Point(Path([0, 0, 0, 0, 1, 0, 0]), 1)),
            children: <Node>[
              Block(children: <Node>[
                Block(children: <Node>[
                  Block(children: <Node>[
                    Block(children: <Node>[
                      Block(children: <Node>[
                        Text('1'),
                      ]),
                      Block(children: <Node>[
                        Block(children: <Node>[
                          Text('2'),
                        ]),
                      ]),
                    ]),
                    Block(children: <Node>[
                      Block(children: <Node>[
                        Text(''),
                      ]),
                    ]),
                  ]),
                ]),
              ]),
            ]);

        expectEqual(editor, expected);
      },
          skip:
              'Surely this is the wrong behavior. Ideally, paragraph with "2" goes into second cell');

      test('merge into empty cells', () {
        // <editor>
        //   <block>
        //     <block>
        //       <block>
        //         <block>
        //           <cursor />
        //         </block>
        //         <block>
        //           <text />
        //         </block>
        //       </block>
        //     </block>
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0, 0, 0, 0, 0]), 0),
                Point(Path([0, 0, 0, 0, 0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Block(children: <Node>[
                  Block(children: <Node>[
                    Block(children: <Node>[
                      Block(children: <Node>[
                        Text(''),
                      ]),
                    ]),
                    Block(children: <Node>[
                      Text(''),
                    ]),
                  ]),
                ]),
              ]),
            ]);

        // <fragment>
        //   <block>
        //     <block>
        //       <block>1</block>
        //       <block>2</block>
        //     </block>
        //   </block>
        // </fragment>
        List<Node> fragment = [
          Block(children: <Node>[
            Block(children: <Node>[
              Block(children: <Node>[
                Text('1'),
              ]),
              Block(children: <Node>[
                Text('2'),
              ]),
            ]),
          ]),
        ];

        Transforms.insertFragment(editor, fragment);

        // <editor>
        //   <block>
        //     <block>
        //       <block>
        //         <block>1</block>
        //         <block>
        //           2<cursor />
        //         </block>
        //         <block>
        //           <text />
        //         </block>
        //       </block>
        //     </block>
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0, 0, 0, 1, 0]), 0),
                Point(Path([0, 0, 0, 0, 1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Block(children: <Node>[
                  Block(children: <Node>[
                    Block(children: <Node>[
                      Text('1'),
                    ]),
                    Block(children: <Node>[
                      Text('2'),
                    ]),
                    Block(children: <Node>[
                      Text(''),
                    ]),
                  ]),
                ]),
              ]),
            ]);

        expectEqual(editor, expected);
      }, skip: 'Paste "2" into second cell instead of creating new one?');

      test('merge into full cells', () {
        // <editor>
        //   <block>
        //     <block>
        //       <block>
        //         <block>
        //           Existing 1
        //           <cursor />
        //         </block>
        //         <block>Existing 2</block>
        //       </block>
        //     </block>
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0, 0, 0, 0, 0]), 0),
                Point(Path([0, 0, 0, 0, 0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Block(children: <Node>[
                  Block(children: <Node>[
                    Block(children: <Node>[
                      Text('Existing 1'),
                    ]),
                    Block(children: <Node>[
                      Text('Existing 2'),
                    ]),
                  ]),
                ]),
              ]),
            ]);

        // <fragment>
        //   <block>
        //     <block>
        //       <block>New 1</block>
        //       <block>New 2</block>
        //     </block>
        //   </block>
        // </fragment>
        List<Node> fragment = [
          Block(children: <Node>[
            Block(children: <Node>[
              Block(children: <Node>[
                Text('New 1'),
              ]),
              Block(children: <Node>[
                Text('New 2'),
              ]),
            ]),
          ]),
        ];

        Transforms.insertFragment(editor, fragment);

        // <editor>
        //   <block>
        //     <block>
        //       <block>
        //         <block>Existing 1 New 1</block>
        //         <block>
        //           New 2<cursor />
        //         </block>
        //         <block>Existing 2</block>
        //       </block>
        //     </block>
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0, 0, 1, 0]), 4),
                Point(Path([0, 0, 0, 1, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Block(children: <Node>[
                  Block(children: <Node>[
                    Block(children: <Node>[
                      Text('Existing 1 New 1'),
                    ]),
                    Block(children: <Node>[
                      Text('New 2'),
                    ]),
                    Block(children: <Node>[
                      Text('Existing 2'),
                    ]),
                  ]),
                ]),
              ]),
            ]);

        expectEqual(editor, expected);
      }, skip: 'Paste "Existing 2" before / after "New 2" in second cell?');
    });

    group('of texts', () {
      test('block across', () {
        // <editor>
        //   <block>
        //     wo
        //     <anchor />
        //     rd
        //   </block>
        //   <block>
        //     an
        //     <focus />
        //     other
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 2), Point(Path([1, 0]), 2)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
              Block(children: <Node>[
                Text('another'),
              ]),
            ]);

        // <fragment>fragment</fragment>
        List<Node> fragment = [
          Text('fragment'),
        ];

        Transforms.insertFragment(editor, fragment);

        // <editor>
        //   <block>
        //     wofragment
        //     <cursor />
        //     other
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 10), Point(Path([0, 0]), 10)),
            children: <Node>[
              Block(children: <Node>[Text('wofragmentother')]),
            ]);

        expectEqual(editor, expected);
      });

      test('block empty', () {
        // <editor>
        //   <block>
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
              ]),
            ]);

        // <fragment>fragment</fragment>
        List<Node> fragment = [
          Text('fragment'),
        ];

        Transforms.insertFragment(editor, fragment);

        // <editor>
        //   <block>
        //     fragment
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 8), Point(Path([0, 0]), 8)),
            children: <Node>[
              Block(children: <Node>[Text('fragment')]),
            ]);

        expectEqual(editor, expected);
      });

      test('block end', () {
        // <editor>
        //   <block>
        //     word
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
            ]);

        // <fragment>fragment</fragment>
        List<Node> fragment = [
          Text('fragment'),
        ];

        Transforms.insertFragment(editor, fragment);

        // <editor>
        //   <block>
        //     wordfragment
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 12), Point(Path([0, 0]), 12)),
            children: <Node>[
              Block(children: <Node>[Text('wordfragment')]),
            ]);

        expectEqual(editor, expected);
      });

      test('block middle', () {
        // <editor>
        //   <block>
        //     wo
        //     <cursor />
        //     rd
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 2), Point(Path([0, 0]), 2)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
            ]);

        // <fragment>fragment</fragment>
        List<Node> fragment = [
          Text('fragment'),
        ];

        Transforms.insertFragment(editor, fragment);

        // <editor>
        //   <block>
        //     wofragment
        //     <cursor />
        //     rd
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 10), Point(Path([0, 0]), 10)),
            children: <Node>[
              Block(children: <Node>[Text('wofragmentrd')]),
            ]);

        expectEqual(editor, expected);
      });

      test('block middle', () {
        // <editor>
        //   <block>
        //     <cursor />
        //     word
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
            ]);

        // <fragment>fragment</fragment>
        List<Node> fragment = [
          Text('fragment'),
        ];

        Transforms.insertFragment(editor, fragment);

        // <editor>
        //   <block>
        //     fragment
        //     <cursor />
        //     word
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 8), Point(Path([0, 0]), 8)),
            children: <Node>[
              Block(children: <Node>[Text('fragmentword')]),
            ]);

        expectEqual(editor, expected);
      });

      test('inline after', () {
        // <editor>
        //   <block>
        //     <text />
        //     <inline>word</inline>
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 2]), 0), Point(Path([0, 2]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('word')]),
                Text(''),
              ]),
            ]);

        // <fragment>fragment</fragment>
        List<Node> fragment = [
          Text('fragment'),
        ];

        Transforms.insertFragment(editor, fragment);

        // <editor>
        //   <block>
        //     <text />
        //     <inline>word</inline>
        //     fragment
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 2]), 8), Point(Path([0, 2]), 8)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('word')]),
                Text('fragment'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('inline before', () {
        // <editor>
        //   <block>
        //     <cursor />
        //     <inline>word</inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('word')]),
                Text(''),
              ]),
            ]);

        // <fragment>fragment</fragment>
        List<Node> fragment = [
          Text('fragment'),
        ];

        Transforms.insertFragment(editor, fragment);

        // <editor>
        //   <block>
        //     fragment
        //     <cursor />
        //     <inline>word</inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 8), Point(Path([0, 0]), 8)),
            children: <Node>[
              Block(children: <Node>[
                Text('fragment'),
                Inline(children: <Node>[Text('word')]),
                Text(''),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('inline empty', () {
        // <editor>
        //   <block>
        //     <text />
        //     <inline>
        //       <cursor />
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 0), Point(Path([0, 1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('')]),
                Text(''),
              ]),
            ]);

        // <fragment>fragment</fragment>
        List<Node> fragment = [
          Text('fragment'),
        ];

        Transforms.insertFragment(editor, fragment);

        // TODO: argument to made that fragment should go into the inline
        // <editor>
        //   <block>
        //     <text />
        //     <inline>
        //       <text />
        //     </inline>
        //     fragment
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 2]), 8), Point(Path([0, 2]), 8)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('')]),
                Text('fragment'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('inline end', () {
        // <editor>
        //   <block>
        //     <text />
        //     <inline>
        //       word
        //       <cursor />
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 4), Point(Path([0, 1, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('word')]),
                Text(''),
              ]),
            ]);

        // <fragment>fragment</fragment>
        List<Node> fragment = [
          Text('fragment'),
        ];

        Transforms.insertFragment(editor, fragment);

        // <editor>
        //   <block>
        //     <text />
        //     <inline>word</inline>
        //     fragment
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 2]), 8), Point(Path([0, 2]), 8)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('word')]),
                Text('fragment'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('inline middle', () {
        // <editor>
        //   <block>
        //     <text />
        //     <inline>
        //       wo
        //       <cursor />
        //       rd
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 2), Point(Path([0, 1, 0]), 2)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('word')]),
                Text(''),
              ]),
            ]);

        // <fragment>fragment</fragment>
        List<Node> fragment = [
          Text('fragment'),
        ];

        Transforms.insertFragment(editor, fragment);

        // TODO: argument to made that fragment should go into the inline
        // <editor>
        //   <block>
        //     <text />
        //     <inline>wo</inline>
        //     fragment
        //     <cursor />
        //     <inline>rd</inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 2]), 8), Point(Path([0, 2]), 8)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('wo')]),
                Text('fragment'),
                Inline(children: <Node>[Text('rd')]),
                Text(''),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('inline start', () {
        // <editor>
        //   <block>
        //     <text />
        //     <inline>
        //       <cursor />
        //       word
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 0), Point(Path([0, 1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('word')]),
                Text(''),
              ]),
            ]);

        // <fragment>fragment</fragment>
        List<Node> fragment = [
          Text('fragment'),
        ];

        Transforms.insertFragment(editor, fragment);

        // <editor>
        //   <block>
        //     fragment
        //     <cursor />
        //     <inline>word</inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 8), Point(Path([0, 0]), 8)),
            children: <Node>[
              Block(children: <Node>[
                Text('fragment'),
                Inline(children: <Node>[Text('word')]),
                Text(''),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('with multiple', () {
        // <editor>
        //   <block>
        //     wo
        //     <cursor />
        //     rd
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 2), Point(Path([0, 0]), 2)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
            ]);

        // <fragment>
        //   <text>one</text>
        //   <text>two</text>
        // </fragment>
        List<Node> fragment = [
          Text('one'),
          Text('two'),
        ];

        Transforms.insertFragment(editor, fragment);

        // <editor>
        //   <block>
        //     woonetwo
        //     <cursor />
        //     rd
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 8), Point(Path([0, 0]), 8)),
            children: <Node>[
              Block(children: <Node>[
                Text('woonetword'),
              ]),
            ]);

        expectEqual(editor, expected);
      });
    });

    group('void false', () {
      test('block', () {
        // <editor>
        //   <block void>
        //     wo
        //     <cursor />
        //     rd
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 2), Point(Path([0, 0]), 2)),
            children: <Node>[
              Block(children: <Node>[Text('word')], isVoid: true),
            ]);

        // <fragment>fragment</fragment>
        List<Node> fragment = [
          Text('fragment'),
        ];

        Transforms.insertFragment(editor, fragment);

        // <editor>
        //   <block void>
        //     wo
        //     <cursor />
        //     rd
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 2), Point(Path([0, 0]), 2)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ], isVoid: true),
            ]);

        expectEqual(editor, expected);
      });

      test('inline', () {
        // <editor>
        //   <block>
        //     <text />
        //     <inline void>
        //       wo
        //       <cursor />
        //       rd
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 2), Point(Path([0, 1, 0]), 2)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('word')], isVoid: true),
                Text('')
              ]),
            ]);

        // <fragment>fragment</fragment>
        List<Node> fragment = [
          Text('fragment'),
        ];

        Transforms.insertFragment(editor, fragment);

        // TODO: argument to made that fragment should go into the inline
        // <editor>
        //   <block>
        //     <text />
        //     <inline void>
        //       wo
        //       <cursor />
        //       rd
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 2), Point(Path([0, 1, 0]), 2)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('word')], isVoid: true),
                Text('')
              ]),
            ]);

        expectEqual(editor, expected);
      });
    });

    group('void true', () {
      test('block', () {
        // <editor>
        //   <block void>
        //     wo
        //     <cursor />
        //     rd
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 2), Point(Path([0, 0]), 2)),
            children: <Node>[
              Block(children: <Node>[Text('word')], isVoid: true),
            ]);

        // <fragment>fragment</fragment>
        List<Node> fragment = [
          Text('fragment'),
        ];

        Transforms.insertFragment(editor, fragment, voids: true);

        // <editor>
        //   <block void>
        //     wo
        //     <cursor />
        //     rd
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 10), Point(Path([0, 0]), 10)),
            children: <Node>[
              Block(children: <Node>[
                Text('wofragmentrd'),
              ], isVoid: true),
            ]);

        expectEqual(editor, expected);
      });

      test('inline', () {
        // <editor>
        //   <block>
        //     <text />
        //     <inline void>
        //       wo
        //       <cursor />
        //       rd
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 2), Point(Path([0, 1, 0]), 2)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('word')], isVoid: true),
                Text('')
              ]),
            ]);

        // <fragment>fragment</fragment>
        List<Node> fragment = [
          Text('fragment'),
        ];

        Transforms.insertFragment(editor, fragment, voids: true);

        // TODO: argument to made that fragment should go into the inline
        // <editor>
        //   <block>
        //     <text />
        //     <inline void>wo</inline>
        //     fragment
        //     <cursor />
        //     <inline void>rd</inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 2]), 8), Point(Path([0, 2]), 8)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('wo')], isVoid: true),
                Text('fragment'),
                Inline(children: <Node>[Text('rd')], isVoid: true),
                Text(''),
              ]),
            ]);

        expectEqual(editor, expected);
      });
    });
  });

  group('insertNodes', () {
    group('block', () {
      test('block empty', () {
        // <editor>
        //   <block>
        //     <cursor />
        //   </block>
        //   <block>not empty</block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[Text('')]),
              Block(children: <Node>[Text('not empty')]),
            ]);

        // <block>
        //   <text />
        // </block>
        List<Node> nodes = [
          Block(children: <Node>[Text('')])
        ];

        Transforms.insertNodes(editor, nodes);

        // <editor>
        //   <block>
        //     <text />
        //   </block>
        //   <block>
        //     <cursor />
        //   </block>
        //   <block>not empty</block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([1, 0]), 0), Point(Path([1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[Text('')]),
              Block(children: <Node>[Text('')]),
              Block(children: <Node>[Text('not empty')]),
            ]);

        expectEqual(editor, expected);
      });

      test('block end', () {
        // <editor>
        //   <block>
        //     word
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[Text('word')]),
            ]);

        // <block>
        //   <text />
        // </block>
        List<Node> nodes = [
          Block(children: <Node>[Text('')])
        ];

        Transforms.insertNodes(editor, nodes);

        // <editor>
        //   <block>word</block>
        //   <block>
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([1, 0]), 0), Point(Path([1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[Text('word')]),
              Block(children: <Node>[Text('')]),
            ]);

        expectEqual(editor, expected);
      });

      test('block middle', () {
        // <editor>
        //   <block>
        //     wo
        //     <cursor />
        //     rd
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 2), Point(Path([0, 0]), 2)),
            children: <Node>[
              Block(children: <Node>[Text('word')]),
            ]);

        // <block>
        //   <text />
        // </block>
        List<Node> nodes = [
          Block(children: <Node>[Text('')])
        ];

        Transforms.insertNodes(editor, nodes);

        // <editor>
        //   <block>wo</block>
        //   <block>
        //     <cursor />
        //   </block>
        //   <block>rd</block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([1, 0]), 0), Point(Path([1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[Text('wo')]),
              Block(children: <Node>[Text('')]),
              Block(children: <Node>[Text('rd')]),
            ]);

        expectEqual(editor, expected);
      });

      test('block start', () {
        // <editor>
        //   <block>
        //     <cursor />
        //     word
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[Text('word')]),
            ]);

        // <block>
        //   <text />
        // </block>
        List<Node> nodes = [
          Block(children: <Node>[Text('')])
        ];

        Transforms.insertNodes(editor, nodes);

        // <editor>
        //   <block>
        //     <cursor />
        //   </block>
        //   <block>word</block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[Text('')]),
              Block(children: <Node>[Text('word')]),
            ]);

        expectEqual(editor, expected);
      });

      test('block void', () {
        // <editor>
        //   <block void>
        //     text
        //     <cursor />
        //   </block>
        //   <block>text</block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[Text('text')], isVoid: true),
              Block(children: <Node>[Text('text')]),
            ]);

        // <block>
        //   <text />
        // </block>
        List<Node> nodes = [
          Block(children: <Node>[Text('')])
        ];

        Transforms.insertNodes(editor, nodes);

        // <editor>
        //   <block void>text</block>
        //   <block>
        //     <cursor />
        //   </block>
        //   <block>text</block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([1, 0]), 0), Point(Path([1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[Text('text')], isVoid: true),
              Block(children: <Node>[Text('')]),
              Block(children: <Node>[Text('text')]),
            ]);

        expectEqual(editor, expected);
      });

      test('inline void', () {
        // <editor>
        //   <block>
        //     <text />
        //     <inline void>
        //       <cursor />
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 0), Point(Path([0, 1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('')], isVoid: true),
                Text(''),
              ]),
            ]);

        // <block>
        //   <text />
        // </block>
        List<Node> nodes = [
          Block(children: <Node>[Text('')])
        ];

        Transforms.insertNodes(editor, nodes);

        // <editor>
        //   <block>
        //     <text />
        //     <inline void>
        //       <text />
        //     </inline>
        //     <text />
        //   </block>
        //   <block>
        //     <cursor />
        //   </block>
        //   <block>
        //     <text />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([1, 0]), 0), Point(Path([1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('')], isVoid: true),
                Text(''),
              ]),
              Block(children: <Node>[
                Text(''),
              ]),
              Block(children: <Node>[
                Text(''),
              ]),
            ]);

        expectEqual(editor, expected);
      });
    });

    group('inline', () {
      test('block empty', () {
        // <editor>
        //   <block>
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[Text('')]),
            ]);

        // <inline void>
        //   <text />
        // </inline>
        List<Node> nodes = [
          Inline(children: <Node>[Text('')], isVoid: true)
        ];

        Transforms.insertNodes(editor, nodes);

        // <editor>
        //   <block>
        //     <text />
        //     <inline void>
        //       <cursor />
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 0), Point(Path([0, 1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('')], isVoid: true),
                Text(''),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('block end', () {
        // <editor>
        //   <block>
        //     word
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[Text('word')]),
            ]);

        // <inline void>
        //   <text />
        // </inline>
        List<Node> nodes = [
          Inline(children: <Node>[Text('')], isVoid: true)
        ];

        Transforms.insertNodes(editor, nodes);

        // <editor>
        //   <block>
        //     word
        //     <inline void>
        //       <cursor />
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 0), Point(Path([0, 1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
                Inline(children: <Node>[Text('')], isVoid: true),
                Text(''),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('block middle', () {
        // <editor>
        //   <block>
        //     wo
        //     <cursor />
        //     rd
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 2), Point(Path([0, 0]), 2)),
            children: <Node>[
              Block(children: <Node>[Text('word')]),
            ]);

        // <inline void>
        //   <text />
        // </inline>
        List<Node> nodes = [
          Inline(children: <Node>[Text('')], isVoid: true)
        ];

        Transforms.insertNodes(editor, nodes);

        // <editor>
        //   <block>
        //     wo
        //     <inline void>
        //       <cursor />
        //     </inline>
        //     rd
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 0), Point(Path([0, 1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('wo'),
                Inline(children: <Node>[Text('')], isVoid: true),
                Text('rd')
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('block start', () {
        // <editor>
        //   <block>
        //     <cursor />
        //     word
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[Text('word')]),
            ]);

        // <inline void>
        //   <text />
        // </inline>
        List<Node> nodes = [
          Inline(children: <Node>[Text('')], isVoid: true)
        ];

        Transforms.insertNodes(editor, nodes);

        // <editor>
        //   <block>
        //     <text />
        //     <inline void>
        //       <cursor />
        //     </inline>
        //     word
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 0), Point(Path([0, 1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('')], isVoid: true),
                Text('word')
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('block void', () {
        // <editor>
        //   <block void>
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[Text('')], isVoid: true),
            ]);

        // <inline void>
        //   <text />
        // </inline>
        List<Node> nodes = [
          Inline(children: <Node>[Text('')], isVoid: true)
        ];

        Transforms.insertNodes(editor, nodes);

        // <editor>
        //   <block void>
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[Text('')], isVoid: true),
            ]);

        expectEqual(editor, expected);
      });

      test('inline middle', () {
        // <editor>
        //   <block>
        //     <text />
        //     <inline>
        //       wo
        //       <cursor />
        //       rd
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 2), Point(Path([0, 1, 0]), 2)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('word')]),
                Text(''),
              ]),
            ]);

        // <inline void>
        //   <text />
        // </inline>
        List<Node> nodes = [
          Inline(children: <Node>[Text('')], isVoid: true)
        ];

        Transforms.insertNodes(editor, nodes);

        // <editor>
        //   <block>
        //     <text />
        //     <inline>
        //       wo
        //       <inline void>
        //         <cursor />
        //       </inline>
        //       rd
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(
                Point(Path([0, 1, 1, 0]), 0), Point(Path([0, 1, 1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[
                  Text('wo'),
                  Inline(children: <Node>[Text('')], isVoid: true),
                  Text('rd'),
                ]),
                Text(''),
              ]),
            ]);

        expectEqual(editor, expected);
      });
    });

    group('path', () {
      test('block', () {
        // <editor>
        //   <block>
        //     <cursor />
        //     one
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ]),
            ]);

        // <block>
        //   <text />
        // </block>
        List<Node> nodes = [
          Block(children: <Node>[Text('')])
        ];

        Transforms.insertNodes(editor, nodes, at: Path([0]));

        // <editor>
        //   <block>
        //     <text />
        //   </block>
        //   <block>
        //     <cursor />
        //     one
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([1, 0]), 0), Point(Path([1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
              ]),
              Block(children: <Node>[
                Text('one'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('inline', () {
        // <editor>
        //   <block>
        //     <cursor />
        //     word
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
            ]);

        // <inline>
        //   <text />
        // </inline>
        List<Node> nodes = [
          Inline(children: <Node>[Text('')])
        ];

        Transforms.insertNodes(editor, nodes, at: Path([0, 0]));

        // <editor>
        //   <block>
        //     <text />
        //     <inline>
        //       <text />
        //     </inline>
        //     <cursor />
        //     word
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 2]), 0), Point(Path([0, 2]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[Text('')]),
                Text('word'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('multiple', () {
        // <editor>
        //   <block>
        //     <cursor />
        //     one
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ]),
            ]);

        // <block>two</block>
        // <block>three</block>
        List<Node> nodes = [
          Block(children: <Node>[Text('two')]),
          Block(children: <Node>[Text('three')]),
        ];

        Transforms.insertNodes(editor, nodes, at: Path([0]));

        // <editor>
        //   <block>two</block>
        //   <block>three</block>
        //   <block>
        //     <cursor />
        //     one
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([2, 0]), 0), Point(Path([2, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('two'),
              ]),
              Block(children: <Node>[
                Text('three'),
              ]),
              Block(children: <Node>[
                Text('one'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('text', () {
        // <editor>
        //   <block>
        //     <cursor />
        //     word
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('word'),
              ]),
            ]);

        // <text>another</text>
        List<Node> nodes = [
          Text('another'),
        ];

        Transforms.insertNodes(editor, nodes, at: Path([0, 0]));

        // <editor>
        //   <block>
        //     another
        //     <cursor />
        //     word
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 7), Point(Path([0, 0]), 7)),
            children: <Node>[
              Block(children: <Node>[
                Text('anotherword'),
              ]),
            ]);

        expectEqual(editor, expected);
      });
    });

    group('select true', () {
      test('block', () {
        // <editor>
        //   <block>
        //     <cursor />
        //     one
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ]),
            ]);

        // <block>
        //   <text />
        // </block>
        List<Node> nodes = [
          Block(children: <Node>[Text('')])
        ];

        Transforms.insertNodes(editor, nodes, at: Path([0]), select: true);

        // <editor>
        //   <block>
        //     <cursor />
        //   </block>
        //   <block>
        //     one
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
              ]),
              Block(children: <Node>[
                Text('one'),
              ]),
            ]);

        expectEqual(editor, expected);
      });
    });

    group('selection', () {
      test('none empty', () {
        // <editor />
        TestEditor editor = TestEditor(children: <Node>[]);

        // <block>
        //   one
        // </block>
        List<Node> nodes = [
          Block(children: <Node>[Text('one')])
        ];

        Transforms.insertNodes(editor, nodes);

        // <editor>
        //   <block>
        //     one
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 3), Point(Path([0, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('none end', () {
        // <editor>
        //   <block>one</block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[
            Text('one'),
          ]),
        ]);

        // <block>
        //   two
        // </block>
        List<Node> nodes = [
          Block(children: <Node>[Text('two')])
        ];

        Transforms.insertNodes(editor, nodes);

        // <editor>
        //   <block>one</block>
        //   <block>
        //     two
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([1, 0]), 3), Point(Path([1, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ]),
              Block(children: <Node>[
                Text('two'),
              ]),
            ]);

        expectEqual(editor, expected);
      });
    });

    group('void', () {
      test('at path', () {
        // <editor>
        //   <block>
        //     one
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 3), Point(Path([0, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ]),
            ]);

        // <block void>
        //   <text>two</text>
        // </block>
        List<Node> nodes = [
          Block(children: <Node>[Text('two')], isVoid: true)
        ];

        Transforms.insertNodes(editor, nodes, at: Path([1]), select: true);

        // <editor>
        //   <block>one</block>
        //   <block void>
        //     two
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([1, 0]), 3), Point(Path([1, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ]),
              Block(children: <Node>[Text('two')], isVoid: true)
            ]);

        expectEqual(editor, expected);
      });

      test('block nested', () {
        // <editor>
        //   <block>
        //     one
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 3), Point(Path([0, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ]),
            ]);

        // <block void>
        //   <block>
        //     <text>two</text>
        //   </block>
        // </block>
        List<Node> nodes = [
          Block(children: <Node>[
            Block(children: <Node>[Text('two')])
          ], isVoid: true)
        ];

        Transforms.insertNodes(editor, nodes);

        // <editor>
        //   <block>one</block>
        //   <block void>
        //     <block>
        //       <text>
        //         two
        //         <cursor />
        //       </text>
        //     </block>
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([1, 0, 0]), 3), Point(Path([1, 0, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ]),
              Block(children: <Node>[
                Block(children: <Node>[Text('two')])
              ], isVoid: true)
            ]);

        expectEqual(editor, expected);
      });

      test('block', () {
        // <editor>
        //   <block>
        //     one
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 3), Point(Path([0, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ]),
            ]);

        // <block void>
        //   <text>two</text>
        // </block>
        List<Node> nodes = [
          Block(children: <Node>[Text('two')], isVoid: true)
        ];

        Transforms.insertNodes(editor, nodes);

        // <editor>
        //   <block>one</block>
        //   <block void>
        //     two
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([1, 0]), 3), Point(Path([1, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ]),
              Block(children: <Node>[Text('two')], isVoid: true)
            ]);

        expectEqual(editor, expected);
      });

      test('inline', () {
        // <editor>
        //   <block>
        //     one
        //     <inline>
        //       two
        //       <cursor />
        //     </inline>
        //     three
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 3), Point(Path([0, 1, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
                Inline(children: <Node>[
                  Text('two'),
                ]),
                Text('three'),
              ]),
            ]);

        // <inline void>
        //   <text>four</text>
        // </inline>
        List<Node> nodes = [
          Inline(children: <Node>[Text('four')], isVoid: true)
        ];

        Transforms.insertNodes(editor, nodes);

        // <editor>
        //   <block>
        //     one
        //     <inline>
        //       two
        //       <inline void>
        //         four
        //         <cursor />
        //       </inline>
        //       <text />
        //     </inline>
        //     three
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(
                Point(Path([0, 1, 1, 0]), 4), Point(Path([0, 1, 1, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
                Inline(children: <Node>[
                  Text('two'),
                  Inline(children: <Node>[
                    Text('four'),
                  ], isVoid: true),
                  Text(''),
                ]),
                Text('three'),
              ]),
            ]);

        expectEqual(editor, expected);
      });
    });

    group('voids true', () {
      test('block', () {
        // <editor>
        //   <block void>
        //     one
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 3), Point(Path([0, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ], isVoid: true),
            ]);

        // <text>two</text>
        List<Node> nodes = [Text('two')];

        Transforms.insertNodes(editor, nodes, at: Path([0, 1]), voids: true);

        // <editor>
        //   <block void>
        //     one
        //     <cursor />
        //     two
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 3), Point(Path([0, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[Text('onetwo')], isVoid: true)
            ]);

        expectEqual(editor, expected);
      });

      test('inline', () {
        // <editor>
        //   <block>
        //     one
        //     <inline void>
        //       two
        //       <cursor />
        //     </inline>
        //     three
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 3), Point(Path([0, 1, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
                Inline(children: <Node>[
                  Text('two'),
                ], isVoid: true),
                Text('three'),
              ]),
            ]);

        // <text>four</text>
        List<Node> nodes = [Text('four')];

        Transforms.insertNodes(editor, nodes, at: Path([0, 1, 1]), voids: true);

        // <editor>
        //   <block>
        //     one
        //     <inline void>
        //       two
        //       <cursor />
        //       four
        //     </inline>
        //     three
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 3), Point(Path([0, 1, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
                Inline(children: <Node>[
                  Text('twofour'),
                ], isVoid: true),
                Text('three'),
              ]),
            ]);

        expectEqual(editor, expected);
      });
    });
  });

  group('insertText', () {
    group('path', () {
      test('block', () {
        // <editor>
        //   <block>word</block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[Text('word')]),
        ]);

        Transforms.insertText(editor, 'x', at: Path([0]));

        // <editor>
        //   <block>x</block>
        // </editor>
        TestEditor expected = TestEditor(children: <Node>[
          Block(children: <Node>[Text('x')]),
        ]);

        expectEqual(editor, expected);
      });

      test('text', () {
        // <editor>
        //   <block>word</block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[Text('word')]),
        ]);

        Transforms.insertText(editor, 'x', at: Path([0, 0]));

        // <editor>
        //   <block>x</block>
        // </editor>
        TestEditor expected = TestEditor(children: <Node>[
          Block(children: <Node>[Text('x')]),
        ]);

        expectEqual(editor, expected);
      });
    });

    group('point', () {
      test('selection after', () {
        // <editor>
        //   <block>
        //     <text>
        //       w<anchor />
        //       or
        //       <focus />d
        //     </text>
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[Text('word')]),
            ]);

        Transforms.insertText(editor, 'x', at: Point(Path([0, 0]), 4));

        // <editor>
        //   <block>
        //     w<anchor />
        //     or
        //     <focus />
        //     dx
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[Text('wordx')]),
            ]);

        expectEqual(editor, expected);
      });

      test('selection before', () {
        // <editor>
        //   <block>
        //     <text>
        //       w<anchor />
        //       or
        //       <focus />d
        //     </text>
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[Text('word')]),
            ]);

        Transforms.insertText(editor, 'x', at: Point(Path([0, 0]), 0));

        // <editor>
        //   <block>
        //     xw<anchor />
        //     or
        //     <focus />
        //     d
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 2), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[Text('xword')]),
            ]);

        expectEqual(editor, expected);
      });

      test('selection end', () {
        // <editor>
        //   <block>
        //     <text>
        //       w<anchor />
        //       or
        //       <focus />d
        //     </text>
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[Text('word')]),
            ]);

        Transforms.insertText(editor, 'x', at: Point(Path([0, 0]), 3));

        // <editor>
        //   <block>
        //     w<anchor />
        //     orx
        //     <focus />
        //     d
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[Text('worxd')]),
            ]);

        expectEqual(editor, expected);
      });

      test('selection middle', () {
        // <editor>
        //   <block>
        //     <text>
        //       w<anchor />
        //       or
        //       <focus />d
        //     </text>
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[Text('word')]),
            ]);

        Transforms.insertText(editor, 'x', at: Point(Path([0, 0]), 2));

        // <editor>
        //   <block>
        //     w<anchor />
        //     oxr
        //     <focus />
        //     d
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[Text('woxrd')]),
            ]);

        expectEqual(editor, expected);
      });

      test('selection start', () {
        // <editor>
        //   <block>
        //     <text>
        //       w<anchor />
        //       or
        //       <focus />d
        //     </text>
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[Text('word')]),
            ]);

        Transforms.insertText(editor, 'x', at: Point(Path([0, 0]), 1));

        // <editor>
        //   <block>
        //     wx<anchor />
        //     or
        //     <focus />
        //     d
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 2), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[Text('wxord')]),
            ]);

        expectEqual(editor, expected);
      });

      test('text end', () {
        // <editor>
        //   <block>
        //     <text>word</text>
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[Text('word')]),
        ]);

        Transforms.insertText(editor, 'x', at: Point(Path([0, 0]), 4));

        // <editor>
        //   <block>wordx</block>
        // </editor>
        TestEditor expected = TestEditor(children: <Node>[
          Block(children: <Node>[Text('wordx')]),
        ]);

        expectEqual(editor, expected);
      });

      test('text middle', () {
        // <editor>
        //   <block>
        //     <text>word</text>
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[Text('word')]),
        ]);

        Transforms.insertText(editor, 'x', at: Point(Path([0, 0]), 2));

        // <editor>
        //   <block>woxrd</block>
        // </editor>
        TestEditor expected = TestEditor(children: <Node>[
          Block(children: <Node>[Text('woxrd')]),
        ]);

        expectEqual(editor, expected);
      });

      test('text start', () {
        // <editor>
        //   <block>
        //     <text>
        //       wo
        //       <cursor />
        //       rd
        //     </text>
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 2), Point(Path([0, 0]), 2)),
            children: <Node>[
              Block(children: <Node>[Text('word')]),
            ]);

        Transforms.insertText(editor, 'x', at: Point(Path([0, 0]), 0));

        // <editor>
        //   <block>
        //     xwo
        //     <cursor />
        //     rd
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 3), Point(Path([0, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[Text('xword')]),
            ]);

        expectEqual(editor, expected);
      });
    });

    group('selection', () {
      test('block end words', () {
        // <editor>
        //   <block>
        //     word
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[Text('word')]),
            ]);

        Transforms.insertText(editor, ' a few words');

        // <editor>
        //   <block>
        //     word a few words
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 16), Point(Path([0, 0]), 16)),
            children: <Node>[
              Block(children: <Node>[Text('word a few words')]),
            ]);

        expectEqual(editor, expected);
      });

      test('block end', () {
        // <editor>
        //   <block>
        //     word
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[Text('word')]),
            ]);

        Transforms.insertText(editor, 'a');

        // <editor>
        //   <block>
        //     worda
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 5), Point(Path([0, 0]), 5)),
            children: <Node>[
              Block(children: <Node>[Text('worda')]),
            ]);

        expectEqual(editor, expected);
      });

      test('block hanging across', () {
        // <editor>
        //   <block>
        //     <anchor />
        //     one
        //   </block>
        //   <block>two</block>
        //   <block>
        //     <focus />
        //     three
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([2, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[Text('one')]),
              Block(children: <Node>[Text('two')]),
              Block(children: <Node>[Text('three')]),
            ]);

        Transforms.insertText(editor, 'a');

        // <editor>
        //   <block>
        //     a<cursor />
        //     three
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 1)),
            children: <Node>[
              Block(children: <Node>[Text('athree')]),
            ]);

        expectEqual(editor, expected);
      }, skip: 'failure');

      test('block hanging', () {
        // <editor>
        //   <block>
        //     <anchor />
        //     one
        //   </block>
        //   <block>
        //     <focus />
        //     two
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[Text('one')]),
              Block(children: <Node>[Text('two')]),
            ]);

        Transforms.insertText(editor, 'a');

        // <editor>
        //   <block>
        //     a<cursor />
        //   </block>
        //   <block>two</block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 1)),
            children: <Node>[
              Block(children: <Node>[Text('a')]),
              Block(children: <Node>[Text('two')]),
            ]);

        expectEqual(editor, expected);
      }, skip: 'failure');

      test('block middle words', () {
        // <editor>
        //   <block>
        //     w<cursor />
        //     ord
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 1)),
            children: <Node>[
              Block(children: <Node>[Text('word')]),
            ]);

        Transforms.insertText(editor, ' a few words ');

        // <editor>
        //   <block>
        //     w a few words <cursor />
        //     ord
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 14), Point(Path([0, 0]), 14)),
            children: <Node>[
              Block(children: <Node>[Text('w a few words ord')]),
            ]);

        expectEqual(editor, expected);
      });

      test('block middle', () {
        // <editor>
        //   <block>
        //     w<cursor />
        //     ord
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 1)),
            children: <Node>[
              Block(children: <Node>[Text('word')]),
            ]);

        Transforms.insertText(editor, 'a');

        // <editor>
        //   <block>
        //     wa
        //     <cursor />
        //     ord
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 2), Point(Path([0, 0]), 2)),
            children: <Node>[
              Block(children: <Node>[Text('waord')]),
            ]);

        expectEqual(editor, expected);
      });

      test('block start words', () {
        // <editor>
        //   <block>
        //     <cursor />
        //     word
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[Text('word')]),
            ]);

        Transforms.insertText(editor, 'a few words');

        // <editor>
        //   <block>
        //     a few words
        //     <cursor />
        //     word
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 11), Point(Path([0, 0]), 11)),
            children: <Node>[
              Block(children: <Node>[Text('a few wordsword')]),
            ]);

        expectEqual(editor, expected);
      });

      test('block start', () {
        // <editor>
        //   <block>
        //     <cursor />
        //     word
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[Text('word')]),
            ]);

        Transforms.insertText(editor, 'a');

        // <editor>
        //   <block>
        //     a<cursor />
        //     word
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 1)),
            children: <Node>[
              Block(children: <Node>[Text('aword')]),
            ]);

        expectEqual(editor, expected);
      });

      test('block void', () {
        // <editor>
        //   <block void>
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[Text('')], isVoid: true),
            ]);

        Transforms.insertText(editor, 'a');

        // <editor>
        //   <block void>
        //     <cursor />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[Text('')], isVoid: true),
            ]);

        expectEqual(editor, expected);
      });

      test('inline end', () {
        // <editor>
        //   <block>
        //     one
        //     <inline>
        //       two
        //       <cursor />
        //     </inline>
        //     three
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 3), Point(Path([0, 1, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
                Inline(children: <Node>[Text('two')]),
                Text('three'),
              ]),
            ]);

        editor.insertText('four');

        // <editor>
        //   <block>
        //     one
        //     <inline>two</inline>
        //     four
        //     <cursor />
        //     three
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 2]), 4), Point(Path([0, 2]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
                Inline(children: <Node>[Text('two')]),
                Text('fourthree'),
              ]),
            ]);

        expectEqual(editor, expected);
      });
    });

    group('voids false', () {
      test('block', () {
        // <editor>
        //   <block void>word</block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[Text('word')], isVoid: true),
        ]);

        Transforms.insertText(editor, 'x', at: Path([0]));

        // <editor>
        //   <block void>word</block>
        // </editor>
        TestEditor expected = TestEditor(children: <Node>[
          Block(children: <Node>[Text('word')], isVoid: true),
        ]);

        expectEqual(editor, expected);
      });

      test('text', () {
        // <editor>
        //   <block void>word</block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[Text('word')], isVoid: true),
        ]);

        Transforms.insertText(editor, 'x', at: Path([0, 0]));

        // <editor>
        //   <block void>word</block>
        // </editor>
        TestEditor expected = TestEditor(children: <Node>[
          Block(children: <Node>[Text('word')], isVoid: true),
        ]);

        expectEqual(editor, expected);
      });
    });

    group('voids true', () {
      test('block', () {
        // <editor>
        //   <block void>word</block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[Text('word')], isVoid: true),
        ]);

        Transforms.insertText(editor, 'x', at: Path([0]), voids: true);

        // <editor>
        //   <block void>x</block>
        // </editor>
        TestEditor expected = TestEditor(children: <Node>[
          Block(children: <Node>[Text('x')], isVoid: true),
        ]);

        expectEqual(editor, expected);
      });

      test('text', () {
        // <editor>
        //   <block void>x</block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[Text('word')], isVoid: true),
        ]);

        Transforms.insertText(editor, 'x', at: Path([0, 0]), voids: true);

        // <editor>
        //   <block void>x</block>
        // </editor>
        TestEditor expected = TestEditor(children: <Node>[
          Block(children: <Node>[Text('x')], isVoid: true),
        ]);

        expectEqual(editor, expected);
      });
    });
  });

  group('liftNodes', () {
    group('path', () {
      test('block', () {
        // <editor>
        //   <block>
        //     <block>word</block>
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[
            Block(children: <Node>[Text('word')])
          ]),
        ]);

        Transforms.liftNodes(editor, at: Path([0, 0]));

        // <editor>
        //   <block>word</block>
        // </editor>
        TestEditor expected = TestEditor(children: <Node>[
          Block(children: <Node>[Text('word')])
        ]);

        expectEqual(editor, expected);
      });

      test('first block', () {
        // <editor>
        //   <block>
        //     <block>one</block>
        //     <block>two</block>
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[
            Block(children: <Node>[Text('one')]),
            Block(children: <Node>[Text('two')])
          ]),
        ]);

        Transforms.liftNodes(editor, at: Path([0, 0]));

        // <editor>
        //   <block>one</block>
        //   <block>
        //     <block>two</block>
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(children: <Node>[
          Block(children: <Node>[Text('one')]),
          Block(children: <Node>[
            Block(children: <Node>[Text('two')])
          ])
        ]);

        expectEqual(editor, expected);
      });

      test('last block', () {
        // <editor>
        //   <block>
        //     <block>one</block>
        //     <block>two</block>
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[
            Block(children: <Node>[Text('one')]),
            Block(children: <Node>[Text('two')])
          ]),
        ]);

        Transforms.liftNodes(editor, at: Path([0, 1]));

        // <editor>
        //   <block>
        //     <block>one</block>
        //   </block>
        //   <block>two</block>
        // </editor>
        TestEditor expected = TestEditor(children: <Node>[
          Block(children: <Node>[
            Block(children: <Node>[Text('one')])
          ]),
          Block(children: <Node>[Text('two')]),
        ]);

        expectEqual(editor, expected);
      });

      test('middle block', () {
        // <editor>
        //   <block>
        //     <block>one</block>
        //     <block>two</block>
        //     <block>three</block>
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[
            Block(children: <Node>[Text('one')]),
            Block(children: <Node>[Text('two')]),
            Block(children: <Node>[Text('three')])
          ]),
        ]);

        Transforms.liftNodes(editor, at: Path([0, 1]));

        // <editor>
        //   <block>
        //     <block>one</block>
        //   </block>
        //   <block>two</block>
        //   <block>
        //     <block>three</block>
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(children: <Node>[
          Block(children: <Node>[
            Block(children: <Node>[Text('one')])
          ]),
          Block(children: <Node>[Text('two')]),
          Block(children: <Node>[
            Block(children: <Node>[Text('three')])
          ]),
        ]);

        expectEqual(editor, expected);
      });
    });

    group('selection', () {
      test('block full', () {
        // <editor>
        //   <block>
        //     <block>
        //       <anchor />
        //       one
        //     </block>
        //     <block>two</block>
        //     <block>three</block>
        //     <block>four</block>
        //     <block>five</block>
        //     <block>
        //       six
        //       <focus />
        //     </block>
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection:
                Range(Point(Path([0, 0, 0]), 0), Point(Path([0, 5, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[
                Block(children: <Node>[Text('one')]),
                Block(children: <Node>[Text('two')]),
                Block(children: <Node>[Text('three')]),
                Block(children: <Node>[Text('four')]),
                Block(children: <Node>[Text('five')]),
                Block(children: <Node>[Text('six')]),
              ]),
            ]);

        Transforms.liftNodes(editor);

        // <editor>
        //   <block>
        //     <anchor />
        //     one
        //   </block>
        //   <block>two</block>
        //   <block>three</block>
        //   <block>four</block>
        //   <block>five</block>
        //   <block>
        //     six
        //     <focus />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([5, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[Text('one')]),
              Block(children: <Node>[Text('two')]),
              Block(children: <Node>[Text('three')]),
              Block(children: <Node>[Text('four')]),
              Block(children: <Node>[Text('five')]),
              Block(children: <Node>[Text('six')]),
            ]);

        expectEqual(editor, expected);
      });

      test('block nested', () {
        // <editor>
        //   <block a>
        //     <block b>
        //       <block c>
        //         <cursor />
        //         one
        //       </block>
        //     </block>
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(
                Point(Path([0, 0, 0, 0]), 0), Point(Path([0, 0, 0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Block(children: <Node>[
                  Block(children: <Node>[Text('one')], props: {'c': true})
                ], props: {
                  'b': true
                }),
              ], props: {
                'a': true
              }),
            ]);

        Transforms.liftNodes(editor, match: (node) {
          return node.props['c'] != null;
        });

        // <editor>
        //   <block a>
        //     <block c>
        //       <cursor />
        //       one
        //     </block>
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 0, 0]), 0), Point(Path([0, 0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Block(children: <Node>[Text('one')], props: {'c': true}),
              ], props: {
                'a': true
              }),
            ]);

        expectEqual(editor, expected);
      });
    });

    group('voids true', () {
      test('block', () {
        // <editor>
        //   <block void>
        //     <block>word</block>
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[
            Block(children: <Node>[Text('word')])
          ], isVoid: true),
        ]);

        Transforms.liftNodes(editor, at: Path([0, 0]), voids: true);

        // <editor>
        //   <block>word</block>
        // </editor>
        TestEditor expected = TestEditor(children: <Node>[
          Block(children: <Node>[Text('word')]),
        ]);

        expectEqual(editor, expected);
      });
    });
  });

  group('mergeNodes', () {
    group('depth block', () {
      test('block', () {
        // <editor>
        //   <block>one</block>
        //   <block>
        //     <cursor />
        //     two
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([1, 0]), 0), Point(Path([1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[Text('one')]),
              Block(children: <Node>[Text('two')])
            ]);

        Transforms.mergeNodes(editor, match: (node) {
          return EditorUtils.isBlock(editor, node);
        });

        // <editor>
        //   <block>
        //     one
        //     <cursor />
        //     two
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 3), Point(Path([0, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[Text('onetwo')]),
            ]);

        expectEqual(editor, expected);
      });
    });

    group('path', () {
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
          ])
        ]);

        Transforms.mergeNodes(editor, at: Path([1]));

        // <editor>
        //   <block>
        //     <block>one</block>
        //     <block>two</block>
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(children: <Node>[
          Block(children: <Node>[
            Block(children: <Node>[Text('one')]),
            Block(children: <Node>[Text('two')])
          ]),
        ]);

        expectEqual(editor, expected);
      });

      test('block', () {
        // <editor>
        //   <block>one</block>
        //   <block>two</block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[Text('one')]),
          Block(children: <Node>[Text('two')])
        ]);

        Transforms.mergeNodes(editor, at: Path([1]));

        // <editor>
        //   <block>
        //     onetwo
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(children: <Node>[
          Block(children: <Node>[Text('onetwo')]),
        ]);

        expectEqual(editor, expected);
      });

      test('text across', () {
        // <editor>
        //   <block>one</block>
        //   <block>two</block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[Text('one')]),
          Block(children: <Node>[Text('two')])
        ]);

        Transforms.mergeNodes(editor, at: Path([1, 0]), match: (node) {
          return node is Text;
        });

        // <editor>
        //   <block>
        //     onetwo
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(children: <Node>[
          Block(children: <Node>[Text('onetwo')]),
        ]);

        expectEqual(editor, expected);
      });
    });

    group('voids true', () {
      test('block', () {
        // <editor>
        //   <block void>
        //     <text>one</text>
        //     <text>two</text>
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[
            Text('one'),
            Text('two'),
          ], isVoid: true),
        ]);

        Transforms.mergeNodes(editor, at: Path([0, 1]), voids: true);

        // <editor>
        //   <block void>onetwo</block>
        // </editor>
        TestEditor expected = TestEditor(children: <Node>[
          Block(children: <Node>[Text('onetwo')], isVoid: true),
        ]);

        expectEqual(editor, expected);
      });
    });
  });

  group('move', () {
    group('anchor', () {
      test('backward', () {
        // <editor>
        //   <block>
        //     one <anchor />
        //     two th
        //     <focus />
        //     ree
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 10)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, edge: Edge.anchor);

        // <editor>
        //   <block>
        //     one t<anchor />
        //     wo th
        //     <focus />
        //     ree
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 5), Point(Path([0, 0]), 10)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('basic', () {
        // <editor>
        //   <block>
        //     one <anchor />
        //     tw
        //     <focus />o three
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 6)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, edge: Edge.anchor);

        // <editor>
        //   <block>
        //     one t<anchor />w<focus />o three
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 5), Point(Path([0, 0]), 6)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('collapsed', () {
        // <editor>
        //   <block>
        //     one two t<cursor />
        //     hree
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 9), Point(Path([0, 0]), 9)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, edge: Edge.anchor);

        // <editor>
        //   <block>
        //     one two t<focus />h<anchor />
        //     ree
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 10), Point(Path([0, 0]), 9)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('distance', () {
        // <editor>
        //   <block>
        //     one <anchor />
        //     two thr
        //     <focus />
        //     ee
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 11)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, edge: Edge.anchor, distance: 3);

        // <editor>
        //   <block>
        //     one two
        //     <anchor /> thr
        //     <focus />
        //     ee
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 7), Point(Path([0, 0]), 11)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('reverse backward', () {
        // <editor>
        //   <block>
        //     one <focus />
        //     two th
        //     <anchor />
        //     ree
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 10), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, edge: Edge.anchor, reverse: true);

        // <editor>
        //   <block>
        //     one <focus />
        //     two t<anchor />
        //     hree
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 9), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('reverse basic', () {
        // <editor>
        //   <block>
        //     one <anchor />
        //     tw
        //     <focus />o three
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 6)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, edge: Edge.anchor, reverse: true);

        // <editor>
        //   <block>
        //     one
        //     <anchor /> tw
        //     <focus />o three
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 3), Point(Path([0, 0]), 6)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('reverse collapsed', () {
        // <editor>
        //   <block>
        //     one two t<cursor />
        //     hree
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 9), Point(Path([0, 0]), 9)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, edge: Edge.anchor, reverse: true);

        // <editor>
        //   <block>
        //     one two <anchor />t<focus />
        //     hree
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 8), Point(Path([0, 0]), 9)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('reverse distance', () {
        // <editor>
        //   <block>
        //     one <anchor />
        //     tw
        //     <focus />o three
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 6)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, edge: Edge.anchor, reverse: true, distance: 3);

        // <editor>
        //   <block>
        //     o<anchor />
        //     ne tw
        //     <focus />o three
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 6)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });
    });

    group('both', () {
      test('backward reverse', () {
        // <editor>
        //   <block>
        //     one <focus />
        //     two th
        //     <anchor />
        //     ree
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 10), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, reverse: true);

        // <editor>
        //   <block>
        //     one
        //     <focus /> two t<anchor />
        //     hree
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 9), Point(Path([0, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('backward', () {
        // <editor>
        //   <block>
        //     one <focus />
        //     two th
        //     <anchor />
        //     ree
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 10), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor);

        // <editor>
        //   <block>
        //     one t<focus />
        //     wo thr
        //     <anchor />
        //     ee
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 11), Point(Path([0, 0]), 5)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('basic reverse', () {
        // <editor>
        //   <block>
        //     one <cursor />
        //     two three
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, reverse: true);

        // <editor>
        //   <block>
        //     one
        //     <cursor /> two three
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 3), Point(Path([0, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('collapsed', () {
        // <editor>
        //   <block>
        //     one <cursor />
        //     two three
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor);

        // <editor>
        //   <block>
        //     one t<cursor />
        //     wo three
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 5), Point(Path([0, 0]), 5)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('distance reverse', () {
        // <editor>
        //   <block>
        //     one two th
        //     <cursor />
        //     ree
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 10), Point(Path([0, 0]), 10)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, reverse: true, distance: 6);

        // <editor>
        //   <block>
        //     one <cursor />
        //     two three
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('distance', () {
        // <editor>
        //   <block>
        //     one <cursor />
        //     two three
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, distance: 6);

        // <editor>
        //   <block>
        //     one two th
        //     <cursor />
        //     ree
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 10), Point(Path([0, 0]), 10)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('expanded reverse', () {
        // <editor>
        //   <block>
        //     one <anchor />
        //     two th
        //     <focus />
        //     ree
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 10)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, reverse: true);

        // <editor>
        //   <block>
        //     one
        //     <anchor /> two t<focus />
        //     hree
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 3), Point(Path([0, 0]), 9)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('expanded', () {
        // <editor>
        //   <block>
        //     one <anchor />
        //     two th
        //     <focus />
        //     ree
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 10)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor);

        // <editor>
        //   <block>
        //     one t<anchor />
        //     wo thr
        //     <focus />
        //     ee
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 5), Point(Path([0, 0]), 11)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('unit word reverse', () {
        // <editor>
        //   <block>
        //     one tw
        //     <cursor />o three
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 6), Point(Path([0, 0]), 6)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, reverse: true, unit: Unit.word);

        // <editor>
        //   <block>
        //     one <cursor />
        //     two three
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('unit word', () {
        // <editor>
        //   <block>
        //     one <cursor />
        //     two three
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, unit: Unit.word);

        // <editor>
        //   <block>
        //     one two
        //     <cursor /> three
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 7), Point(Path([0, 0]), 7)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });
    });

    group('end', () {
      test('backward reverse', () {
        // <editor>
        //   <block>
        //     one <focus />
        //     two t<anchor />
        //     hree
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 9), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, edge: Edge.end, reverse: true);

        // <editor>
        //   <block>
        //     one <focus />
        //     two <anchor />
        //     three
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 8), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('backward', () {
        // <editor>
        //   <block>
        //     one <focus />
        //     two t<anchor />
        //     hree
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 9), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, edge: Edge.end);

        // <editor>
        //   <block>
        //     one <focus />
        //     two th
        //     <anchor />
        //     ree
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 10), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('collapsed reverse', () {
        // <editor>
        //   <block>
        //     one two t<cursor />
        //     hree
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 9), Point(Path([0, 0]), 9)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, edge: Edge.end, reverse: true);

        // <editor>
        //   <block>
        //     one two <focus />t<anchor />
        //     hree
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 9), Point(Path([0, 0]), 8)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('collapsed', () {
        // <editor>
        //   <block>
        //     one two t<cursor />
        //     hree
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 9), Point(Path([0, 0]), 9)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, edge: Edge.end);

        // <editor>
        //   <block>
        //     one two t<anchor />h<focus />
        //     ree
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 9), Point(Path([0, 0]), 10)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('distance reverse', () {
        // <editor>
        //   <block>
        //     one <anchor />
        //     two t<focus />
        //     hree
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 9)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, edge: Edge.end, reverse: true, distance: 3);

        // <editor>
        //   <block>
        //     one <anchor />
        //     tw
        //     <focus />o three
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 6)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('distance reverse', () {
        // <editor>
        //   <block>
        //     one <anchor />
        //     two t<focus />
        //     hree
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 9)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, edge: Edge.end, reverse: true, distance: 3);

        // <editor>
        //   <block>
        //     one <anchor />
        //     tw
        //     <focus />o three
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 6)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('distance', () {
        // <editor>
        //   <block>
        //     one <anchor />
        //     two t<focus />
        //     hree
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 9)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, edge: Edge.end, distance: 3);

        // <editor>
        //   <block>
        //     one <anchor />
        //     two thre
        //     <focus />e
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 12)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('expanded reverse', () {
        // <editor>
        //   <block>
        //     one <anchor />
        //     two t<focus />
        //     hree
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 9)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, edge: Edge.end, reverse: true);

        // <editor>
        //   <block>
        //     one <anchor />
        //     two <focus />
        //     three
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 8)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('expanded', () {
        // <editor>
        //   <block>
        //     one <anchor />
        //     two t<focus />
        //     hree
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 9)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, edge: Edge.end);

        // <editor>
        //   <block>
        //     one <anchor />
        //     two th
        //     <focus />
        //     ree
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 10)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('from backward reverse', () {
        // <editor>
        //   <block>
        //     one <focus />
        //     two <anchor />
        //     three
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 8), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, edge: Edge.end, reverse: true, distance: 7);

        // <editor>
        //   <block>
        //     o<anchor />
        //     ne <focus />
        //     two three
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('to backward reverse', () {
        // <editor>
        //   <block>
        //     one <anchor />
        //     two
        //     <focus /> three
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 7)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, edge: Edge.end, reverse: true, distance: 6);

        // <editor>
        //   <block>
        //     o<focus />
        //     ne <anchor />
        //     two three
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 1)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });
    });

    group('focus', () {
      test('backward', () {
        // <editor>
        //   <block>
        //     one <focus />
        //     two <anchor />
        //     three
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 8), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, edge: Edge.focus, distance: 7);

        // <editor>
        //   <block>
        //     one two <anchor />
        //     thr
        //     <focus />
        //     ee
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 8), Point(Path([0, 0]), 11)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('collapsed reverse', () {
        // <editor>
        //   <block>
        //     one two t<cursor />
        //     hree
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 9), Point(Path([0, 0]), 9)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, edge: Edge.focus, reverse: true);

        // <editor>
        //   <block>
        //     one two <focus />t<anchor />
        //     hree
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 9), Point(Path([0, 0]), 8)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('collapsed', () {
        // <editor>
        //   <block>
        //     one two t<cursor />
        //     hree
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 9), Point(Path([0, 0]), 9)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, edge: Edge.focus);

        // <editor>
        //   <block>
        //     one two t<anchor />h<focus />
        //     ree
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 9), Point(Path([0, 0]), 10)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('distance reverse', () {
        // <editor>
        //   <block>
        //     one <anchor />
        //     two thr
        //     <focus />
        //     ee
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 11)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, edge: Edge.focus, reverse: true, distance: 6);

        // <editor>
        //   <block>
        //     one <anchor />t<focus />
        //     wo three
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 5)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('distance', () {
        // <editor>
        //   <block>
        //     one <anchor />
        //     tw
        //     <focus />o three
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 6)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, edge: Edge.focus, distance: 4);

        // <editor>
        //   <block>
        //     one <anchor />
        //     two th
        //     <focus />
        //     ree
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 10)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('expanded reverse', () {
        // <editor>
        //   <block>
        //     one <anchor />
        //     tw
        //     <focus />o three
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 6)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, edge: Edge.focus, reverse: true);

        // <editor>
        //   <block>
        //     one <anchor />t<focus />
        //     wo three
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 5)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('expanded', () {
        // <editor>
        //   <block>
        //     one <anchor />
        //     tw
        //     <focus />o three
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 6)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, edge: Edge.focus);

        // <editor>
        //   <block>
        //     one <anchor />
        //     two
        //     <focus /> three
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 7)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('to backward reverse', () {
        // <editor>
        //   <block>
        //     one <anchor />
        //     two thr
        //     <focus />
        //     ee
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 11)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, edge: Edge.focus, reverse: true, distance: 10);

        // <editor>
        //   <block>
        //     o<focus />
        //     ne <anchor />
        //     two three
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 1)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });
    });

    group('start', () {
      test('backward reverse', () {
        // <editor>
        //   <block>
        //     one <focus />
        //     two t<anchor />
        //     hree
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 9), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, edge: Edge.start, reverse: true);

        // <editor>
        //   <block>
        //     one
        //     <focus /> two t<anchor />
        //     hree
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 9), Point(Path([0, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('backward', () {
        // <editor>
        //   <block>
        //     one <focus />
        //     two t<anchor />
        //     hree
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 9), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, edge: Edge.start);

        // <editor>
        //   <block>
        //     one t<focus />
        //     wo t<anchor />
        //     hree
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 9), Point(Path([0, 0]), 5)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('collapsed reverse', () {
        // <editor>
        //   <block>
        //     one two t<cursor />
        //     hree
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 9), Point(Path([0, 0]), 9)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, edge: Edge.start, reverse: true);

        // <editor>
        //   <block>
        //     one two <anchor />t<focus />
        //     hree
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 8), Point(Path([0, 0]), 9)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('collapsed', () {
        // <editor>
        //   <block>
        //     one two t<cursor />
        //     hree
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 9), Point(Path([0, 0]), 9)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, edge: Edge.start);

        // <editor>
        //   <block>
        //     one two t<focus />h<anchor />
        //     ree
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 10), Point(Path([0, 0]), 9)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('distance reverse', () {
        // <editor>
        //   <block>
        //     one <anchor />
        //     two t<focus />
        //     hree
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 9)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, edge: Edge.start, reverse: true, distance: 3);

        // <editor>
        //   <block>
        //     o<anchor />
        //     ne two t<focus />
        //     hree
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 9)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('distance', () {
        // <editor>
        //   <block>
        //     one <anchor />
        //     two t<focus />
        //     hree
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 9)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, edge: Edge.start, distance: 3);

        // <editor>
        //   <block>
        //     one two
        //     <anchor /> t<focus />
        //     hree
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 7), Point(Path([0, 0]), 9)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('expanded reverse', () {
        // <editor>
        //   <block>
        //     one <anchor />
        //     two t<focus />
        //     hree
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 9)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, edge: Edge.start, reverse: true);

        // <editor>
        //   <block>
        //     one
        //     <anchor /> two t<focus />
        //     hree
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 3), Point(Path([0, 0]), 9)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('expanded', () {
        // <editor>
        //   <block>
        //     one t<anchor />
        //     wo t<focus />
        //     hree
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 9)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, edge: Edge.start);

        // <editor>
        //   <block>
        //     one
        //     <anchor /> two t<focus />
        //     hree
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 5), Point(Path([0, 0]), 9)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('from backward', () {
        // <editor>
        //   <block>
        //     one <focus />
        //     two t<anchor />
        //     hree
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 9), Point(Path([0, 0]), 4)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, edge: Edge.start, distance: 7);

        // <editor>
        //   <block>
        //     one two t<anchor />
        //     hr
        //     <focus />
        //     ee
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 9), Point(Path([0, 0]), 11)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });

      test('to backward', () {
        // <editor>
        //   <block>
        //     one <focus />
        //     two t<anchor />
        //     hree
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 4), Point(Path([0, 0]), 9)),
            children: <Node>[
              Block(children: <Node>[
                Text('one two three'),
              ]),
            ]);

        Transforms.move(editor, edge: Edge.start, distance: 8);

        // <editor>
        //   <block>
        //     one two t<focus />
        //     hre
        //     <anchor />e
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 12), Point(Path([0, 0]), 9)),
            children: <Node>[
              Block(children: <Node>[Text('one two three')]),
            ]);

        expectEqual(editor, expected);
      });
    });
  });

  group('moveNodes', () {
    group('path', () {
      test('block', () {
        // <editor>
        //   <block>
        //     <cursor />
        //     one
        //   </block>
        //   <block>two</block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ]),
              Block(children: <Node>[
                Text('two'),
              ]),
            ]);

        Transforms.moveNodes(editor, at: Path([0]), to: Path([1]));

        // <editor>
        //   <block>two</block>
        //   <block>
        //     <cursor />
        //     one
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([1, 0]), 0), Point(Path([1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('two'),
              ]),
              Block(children: <Node>[
                Text('one'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('inline', () {
        // <editor>
        //   <block>
        //     <text />
        //     <inline>
        //       <cursor />
        //       one
        //     </inline>
        //     <text />
        //     <inline>two</inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 0), Point(Path([0, 1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[
                  Text('one'),
                ]),
                Text(''),
                Inline(children: <Node>[
                  Text('two'),
                ]),
                Text(''),
              ]),
            ]);

        Transforms.moveNodes(editor, at: Path([0, 1]), to: Path([0, 3]));

        // <editor>
        //   <block>
        //     <text />
        //     <inline>two</inline>
        //     <text />
        //     <inline>
        //       <cursor />
        //       one
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 3, 0]), 0), Point(Path([0, 3, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[
                  Text('two'),
                ]),
                Text(''),
                Inline(children: <Node>[
                  Text('one'),
                ]),
                Text(''),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('inside next', () {
        // <editor>
        //   <block>
        //     <cursor />
        //     one
        //   </block>
        //   <block>
        //     <block>two</block>
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ]),
              Block(children: <Node>[
                Block(children: <Node>[
                  Text('two'),
                ]),
              ]),
            ]);

        Transforms.moveNodes(editor, at: Path([0]), to: Path([1, 1]));

        // <editor>
        //   <block>
        //     <block>two</block>
        //     <block>
        //       <cursor />
        //       one
        //     </block>
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 0), Point(Path([0, 1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Block(children: <Node>[
                  Text('two'),
                ]),
                Block(children: <Node>[
                  Text('one'),
                ]),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('nested', () {
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
            Block(children: <Node>[
              Text('one'),
            ]),
          ]),
          Block(children: <Node>[
            Block(children: <Node>[
              Text('two'),
            ]),
          ]),
        ]);

        Transforms.moveNodes(editor, at: Path([0, 0]), to: Path([1, 0]));

        // <editor>
        //   <block>
        //     <text />
        //   </block>
        //   <block>
        //     <block>one</block>
        //     <block>two</block>
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(children: <Node>[
          Block(children: <Node>[
            Text(''),
          ]),
          Block(children: <Node>[
            Block(children: <Node>[
              Text('one'),
            ]),
            Block(children: <Node>[
              Text('two'),
            ]),
          ]),
        ]);

        expectEqual(editor, expected);
      });

      test('noop equal', () {
        // <editor>
        //   <block>1</block>
        //   <block>2</block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[
            Text('1'),
          ]),
          Block(children: <Node>[
            Text('2'),
          ]),
        ]);

        Transforms.moveNodes(editor, at: Path([1]), to: Path([1]));

        // <editor>
        //   <block>1</block>
        //   <block>2</block>
        // </editor>
        TestEditor expected = TestEditor(children: <Node>[
          Block(children: <Node>[
            Text('1'),
          ]),
          Block(children: <Node>[
            Text('2'),
          ]),
        ]);

        expectEqual(editor, expected);
      });

      test('sibling swap', () {
        // <editor>
        //   <block>
        //     <cursor />
        //     one
        //   </block>
        //   <block>two</block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ]),
              Block(children: <Node>[
                Text('two'),
              ]),
            ]);

        Transforms.moveNodes(editor, at: Path([0]), to: Path([1]));

        // <editor>
        //   <block>two</block>
        //   <block>
        //     <cursor />
        //     one
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([1, 0]), 0), Point(Path([1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('two'),
              ]),
              Block(children: <Node>[
                Text('one'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('text nodes', () {
        // <editor>
        //   <block>one</block>
        //   <block>
        //     <cursor />
        //     two
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([1, 0]), 0), Point(Path([1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ]),
              Block(children: <Node>[
                Text('two'),
              ]),
            ]);

        Transforms.moveNodes(editor, at: Path([0, 0]), to: Path([1, 0]));

        // <editor>
        //   <block>
        //     <text />
        //   </block>
        //   <block>
        //     one
        //     <cursor />
        //     two
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([1, 0]), 3), Point(Path([1, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
              ]),
              Block(children: <Node>[
                Text('onetwo'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('text', () {
        // <editor>
        //   <block>one</block>
        //   <block>two</block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[
            Text('one'),
          ]),
          Block(children: <Node>[
            Text('two'),
          ]),
        ]);

        Transforms.moveNodes(editor, at: Path([1, 0]), to: Path([0, 1]));

        // <editor>
        //   <block>onetwo</block>
        //   <block>
        //     <text />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(children: <Node>[
          Block(children: <Node>[
            Text('onetwo'),
          ]),
          Block(children: <Node>[
            Text(''),
          ]),
        ]);

        expectEqual(editor, expected);
      });

      test('to sibling', () {
        // <editor>
        //   <block>
        //     <cursor />
        //     one
        //   </block>
        //   <block>
        //     <block>two</block>
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ]),
              Block(children: <Node>[
                Block(children: <Node>[
                  Text('two'),
                ]),
              ]),
            ]);

        Transforms.moveNodes(editor, at: Path([0]), to: Path([1, 1]));

        // <editor>
        //   <block>
        //     <block>two</block>
        //     <block>
        //       <cursor />
        //       one
        //     </block>
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 0), Point(Path([0, 1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Block(children: <Node>[
                  Text('two'),
                ]),
                Block(children: <Node>[
                  Text('one'),
                ]),
              ]),
            ]);

        expectEqual(editor, expected);
      });
    });

    group('selection', () {
      test('block nested after', () {
        // <editor>
        //   <block>
        //     <block>one</block>
        //     <block>
        //       <anchor />
        //       two
        //     </block>
        //     <block>
        //       three
        //       <focus />
        //     </block>
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 0), Point(Path([0, 2, 0]), 5)),
            children: <Node>[
              Block(children: <Node>[
                Block(children: <Node>[
                  Text('one'),
                ]),
                Block(children: <Node>[
                  Text('two'),
                ]),
                Block(children: <Node>[
                  Text('three'),
                ]),
              ]),
            ]);

        Transforms.moveNodes(editor, to: Path([1]), match: (node) {
          return node is Block;
        });

        // <editor>
        //   <block>
        //     <block>one</block>
        //   </block>
        //   <block>
        //     <anchor />
        //     two
        //   </block>
        //   <block>
        //     three
        //     <focus />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([1, 0]), 0), Point(Path([2, 0]), 5)),
            children: <Node>[
              Block(children: <Node>[
                Block(children: <Node>[
                  Text('one'),
                ]),
              ]),
              Block(children: <Node>[
                Text('two'),
              ]),
              Block(children: <Node>[
                Text('three'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('block nested before', () {
        // <editor>
        //   <block>
        //     <block>
        //       <anchor />
        //       one
        //     </block>
        //     <block>
        //       two
        //       <focus />
        //     </block>
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection:
                Range(Point(Path([0, 0, 0]), 0), Point(Path([0, 1, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[
                Block(children: <Node>[
                  Text('one'),
                ]),
                Block(children: <Node>[
                  Text('two'),
                ]),
              ]),
            ]);

        Transforms.moveNodes(editor, to: Path([0]), match: (node) {
          return node is Block;
        });

        // <editor>
        //   <block>
        //     <anchor />
        //     one
        //   </block>
        //   <block>
        //     two
        //     <focus />
        //   </block>
        //   <block>
        //     <text />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([1, 0]), 3)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ]),
              Block(children: <Node>[
                Text('two'),
              ]),
              Block(children: <Node>[
                Text(''),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('block', () {
        // <editor>
        //   <block>
        //     <cursor />
        //     one
        //   </block>
        //   <block>two</block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ]),
              Block(children: <Node>[
                Text('two'),
              ]),
            ]);

        Transforms.moveNodes(editor, to: Path([1]), match: (node) {
          return node is Block;
        });

        // <editor>
        //   <block>two</block>
        //   <block>
        //     <cursor />
        //     one
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([1, 0]), 0), Point(Path([1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('two'),
              ]),
              Block(children: <Node>[
                Text('one'),
              ]),
            ]);

        expectEqual(editor, expected);
      });
    });

    group('voids true', () {
      test('block', () {
        // <editor>
        //   <block void>one</block>
        //   <block void>two</block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[
            Text('one'),
          ], isVoid: true),
          Block(children: <Node>[
            Text('two'),
          ], isVoid: true),
        ]);

        Transforms.moveNodes(editor,
            at: Path([0, 0]), to: Path([1, 0]), voids: true);

        // <editor>
        //   <block void>
        //     <text />
        //   </block>
        //   <block void>onetwo</block>
        // </editor>
        TestEditor expected = TestEditor(children: <Node>[
          Block(children: <Node>[
            Text(''),
          ], isVoid: true),
          Block(children: <Node>[
            Text('onetwo'),
          ], isVoid: true),
        ]);

        expectEqual(editor, expected);
      });

      test('inline', () {
        // <editor>
        //   <block>
        //     <text />
        //     <inline>
        //       <cursor />
        //       one
        //     </inline>
        //     <text />
        //     <inline>two</inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection:
                Range(Point(Path([0, 1, 0]), 0), Point(Path([0, 1, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[
                  Text('one'),
                ]),
                Text(''),
                Inline(children: <Node>[
                  Text('two'),
                ]),
                Text(''),
              ]),
            ]);

        Transforms.moveNodes(editor,
            at: Path([0, 1]), to: Path([0, 3]), voids: true);

        // <editor>
        //   <block>
        //     <text />
        //     <inline>two</inline>
        //     <text />
        //     <inline>
        //       <cursor />
        //       one
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection:
                Range(Point(Path([0, 3, 0]), 0), Point(Path([0, 3, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text(''),
                Inline(children: <Node>[
                  Text('two'),
                ]),
                Text(''),
                Inline(children: <Node>[
                  Text('one'),
                ]),
                Text(''),
              ]),
            ]);

        expectEqual(editor, expected);
      });
    });
  });

  group('removeNodes', () {
    group('path', () {
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
            Block(children: <Node>[
              Text('one'),
            ]),
          ]),
          Block(children: <Node>[
            Block(children: <Node>[
              Text('two'),
            ]),
          ]),
        ]);

        Transforms.removeNodes(editor, at: Path([0, 0]));

        // <editor>
        //   <block>
        //     <text />
        //   </block>
        //   <block>
        //     <block>two</block>
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(children: <Node>[
          Block(children: <Node>[
            Text(''),
          ]),
          Block(children: <Node>[
            Block(children: <Node>[
              Text('two'),
            ]),
          ]),
        ]);

        expectEqual(editor, expected);
      });

      test('block', () {
        // <editor>
        //   <block>one</block>
        //   <block>two</block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[
            Text('one'),
          ]),
          Block(children: <Node>[
            Text('two'),
          ]),
        ]);

        Transforms.removeNodes(editor, at: Path([0]));

        // <editor>
        //   <block>two</block>
        // </editor>
        TestEditor expected = TestEditor(children: <Node>[
          Block(children: <Node>[
            Text('two'),
          ]),
        ]);

        expectEqual(editor, expected);
      });

      test('inline', () {
        // <editor>
        //   <block>
        //     <text />
        //     <inline>one</inline>
        //     <text />
        //     <inline>two</inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[
            Text(''),
            Inline(children: <Node>[
              Text('one'),
            ]),
            Text(''),
            Inline(children: <Node>[
              Text('two'),
            ]),
            Text(''),
          ]),
        ]);

        Transforms.removeNodes(editor, at: Path([0, 1]));

        // <editor>
        //   <block>
        //     <text />
        //     <inline>two</inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(children: <Node>[
          Block(children: <Node>[
            Text(''),
            Inline(children: <Node>[
              Text('two'),
            ]),
            Text(''),
          ]),
        ]);

        expectEqual(editor, expected);
      });

      test('text', () {
        // <editor>
        //   <block>one</block>
        //   <block>two</block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[
            Text('one'),
          ]),
          Block(children: <Node>[
            Text('two'),
          ]),
        ]);

        Transforms.removeNodes(editor, at: Path([1, 0]));

        // <editor>
        //   <block>one</block>
        //   <block>
        //     <text />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(children: <Node>[
          Block(children: <Node>[
            Text('one'),
          ]),
          Block(children: <Node>[
            Text(''),
          ]),
        ]);

        expectEqual(editor, expected);
      });
    });

    group('select', () {
      test('block only void', () {
        // <editor>
        //   <block void>
        //     <cursor />
        //     one
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[
            Text('one'),
          ], isVoid: true),
        ]);

        Transforms.removeNodes(editor, at: Path([0]));

        // <editor />
        TestEditor expected = TestEditor(children: <Node>[]);

        expectEqual(editor, expected);
      });

      test('block void multiple texts', () {
        // <editor>
        //   <block void>
        //     <text>
        //       <cursor />
        //       one
        //     </text>
        //     <text>two</text>
        //   </block>
        //   <block>three</block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
                Text('two'),
              ], isVoid: true),
              Block(children: <Node>[
                Text('three'),
              ]),
            ]);

        Transforms.removeNodes(editor, at: Path([0]));

        // <editor>
        //   <block>
        //     <cursor />
        //     three
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('three'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('block void', () {
        // <editor>
        //   <block void>
        //     <cursor />
        //     one
        //   </block>
        //   <block>two</block>
        //   <block>three</block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ], isVoid: true),
              Block(children: <Node>[
                Text('two'),
              ]),
              Block(children: <Node>[
                Text('three'),
              ]),
            ]);

        Transforms.removeNodes(editor, at: Path([0]));

        // <editor>
        //   <block>
        //     <cursor />
        //     two
        //   </block>
        //   <block>three</block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('two'),
              ]),
              Block(children: <Node>[
                Text('three'),
              ]),
            ]);

        expectEqual(editor, expected);
      });
    });

    group('selection', () {
      test('block across', () {
        // <editor>
        //   <block>
        //     on
        //     <anchor />e
        //   </block>
        //   <block>
        //     t<focus />
        //     wo
        //   </block>
        //   <block>three</block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 2), Point(Path([1, 0]), 1)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ]),
              Block(children: <Node>[
                Text('two'),
              ]),
              Block(children: <Node>[
                Text('three'),
              ]),
            ]);

        Transforms.removeNodes(editor);

        // <editor>
        //   <block>
        //     <cursor />
        //     three
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(
            selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
            children: <Node>[
              Block(children: <Node>[
                Text('three'),
              ]),
            ]);

        expectEqual(editor, expected);
      });

      test('block all', () {
        // <editor>
        //   <block>
        //     on
        //     <anchor />e
        //   </block>
        //   <block>
        //     t<focus />
        //     wo
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(
            selection: Range(Point(Path([0, 0]), 2), Point(Path([1, 0]), 1)),
            children: <Node>[
              Block(children: <Node>[
                Text('one'),
              ]),
              Block(children: <Node>[
                Text('two'),
              ]),
            ]);

        Transforms.removeNodes(editor);

        // <editor />
        TestEditor expected = TestEditor(children: <Node>[]);

        expectEqual(editor, expected);
      });
    });

    group('voids true', () {
      test('block', () {
        // <editor>
        //   <block void>one</block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[
            Text('one'),
          ], isVoid: true),
        ]);

        Transforms.removeNodes(editor, at: Path([0, 0]), voids: true);

        // <editor>
        //   <block void>
        //     <text />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(children: <Node>[
          Block(children: <Node>[
            Text(''),
          ], isVoid: true),
        ]);

        expectEqual(editor, expected);
      });

      test('inline', () {
        // <editor>
        //   <block>
        //     <text />
        //     <inline void>one</inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor editor = TestEditor(children: <Node>[
          Block(children: <Node>[
            Text(''),
            Inline(children: <Node>[
              Text('one'),
            ], isVoid: true),
            Text(''),
          ]),
        ]);

        Transforms.removeNodes(editor, at: Path([0, 1, 0]), voids: true);

        // <editor>
        //   <block>
        //     <text />
        //     <inline void>
        //       <text />
        //     </inline>
        //     <text />
        //   </block>
        // </editor>
        TestEditor expected = TestEditor(children: <Node>[
          Block(children: <Node>[
            Text(''),
            Inline(children: <Node>[
              Text(''),
            ], isVoid: true),
            Text(''),
          ]),
        ]);

        expectEqual(editor, expected);
      });
    });
  });

  group('select', () {
    test('path', () {
      // <editor>
      //   <block>
      //     <cursor />
      //     one
      //   </block>
      // </editor>
      TestEditor editor = TestEditor(
          selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
          children: <Node>[
            Block(children: <Node>[
              Text('one'),
            ]),
          ]);

      Transforms.select(editor, Path([0, 0]));

      // <editor>
      //   <block>
      //     <anchor />
      //     one
      //     <focus />
      //   </block>
      // </editor>
      TestEditor expected = TestEditor(
          selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 3)),
          children: <Node>[
            Block(children: <Node>[
              Text('one'),
            ]),
          ]);

      expectEqual(editor, expected);
    });

    test('point', () {
      // <editor>
      //   <block>
      //     <cursor />
      //     one
      //   </block>
      // </editor>
      TestEditor editor = TestEditor(
          selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
          children: <Node>[
            Block(children: <Node>[
              Text('one'),
            ]),
          ]);

      Transforms.select(editor, Point(Path([0, 0]), 1));

      // <editor>
      //   <block>
      //     o<cursor />
      //     ne
      //   </block>
      // </editor>
      TestEditor expected = TestEditor(
          selection: Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 1)),
          children: <Node>[
            Block(children: <Node>[
              Text('one'),
            ]),
          ]);

      expectEqual(editor, expected);
    });

    test('range', () {
      // <editor>
      //   <block>
      //     <cursor />
      //     one
      //   </block>
      // </editor>
      TestEditor editor = TestEditor(
          selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 0)),
          children: <Node>[
            Block(children: <Node>[
              Text('one'),
            ]),
          ]);

      Transforms.select(
          editor, Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 3)));

      // <editor>
      //   <block>
      //     <anchor />
      //     one
      //     <focus />
      //   </block>
      // </editor>
      TestEditor expected = TestEditor(
          selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 3)),
          children: <Node>[
            Block(children: <Node>[
              Text('one'),
            ]),
          ]);

      expectEqual(editor, expected);
    });
  });
}
