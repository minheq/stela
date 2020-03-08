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
    });
  });
}
