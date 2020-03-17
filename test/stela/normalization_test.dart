import 'package:flutter_test/flutter_test.dart';
import 'package:inday/stela/editor.dart';
import 'package:inday/stela/element.dart';
import 'package:inday/stela/node.dart';
import 'package:inday/stela/text.dart';

void main() {
  group('block', () {
    test('insert text', () {
      // <editor>
      //   <block />
      // </editor>
      Block block = Block(children: <Node>[]);
      Editor editor = Editor(children: <Node>[block]);

      EditorUtils.normalize(editor, force: true);

      // <editor>
      //   <block>
      //     <text />
      //   </block>
      // </editor>
      expect(block.children[0] is Text, true);
      expect((block.children[0] as Text).text, '');
    });

    test('remove block', () {
      // <editor>
      //   <block>
      //     <text>one</text>
      //     <block>two</block>
      //   </block>
      // </editor>
      Block block = Block(children: <Node>[
        Text('one'),
        Block(children: <Node>[Text('two')])
      ]);
      Editor editor = Editor(children: <Node>[block]);

      EditorUtils.normalize(editor, force: true);

      // <editor>
      //   <block>
      //     <text>one</text>
      //   </block>
      // </editor>
      expect(block.children.length, 1);
      expect(block.children[0] is Text, true);
      expect((block.children[0] as Text).text, 'one');
    });

    test('remove inline', () {
      // <editor>
      //   <block>
      //     <block>one</block>
      //     <inline>two</inline>
      //   </block>
      // </editor>
      Block block = Block(children: <Node>[
        Block(children: <Node>[Text('one')]),
        Inline(children: <Node>[Text('two')])
      ]);
      Editor editor = Editor(children: <Node>[block]);

      EditorUtils.normalize(editor, force: true);

      // <editor>
      //   <block>
      //     <block>one</block>
      //   </block>
      // </editor>
      Block innerBlock = block.children[0];
      expect(block.children.length, 1);
      expect((innerBlock.children[0] as Text).text, 'one');
    });
  });

  group('editor', () {
    test('remove inline', () {
      // <editor>
      //   <inline>one</inline>
      //   <block>two</block>
      // </editor>

      Editor editor = Editor(children: <Node>[
        Inline(children: <Node>[Text('one')]),
        Block(children: <Node>[Text('two')])
      ]);

      EditorUtils.normalize(editor, force: true);

      // <editor>
      //   <block>two</block>
      // </editor>
      Block block = editor.children[0];
      expect(editor.children.length, 1);
      expect((block.children[0] as Text).text, 'two');
    });

    test('remove text', () {
      // <editor>
      //   <text>one</text>
      //   <block>two</block>
      // </editor>

      Editor editor = Editor(children: <Node>[
        Text('one'),
        Block(children: <Node>[Text('two')])
      ]);

      EditorUtils.normalize(editor, force: true);

      // <editor>
      //   <block>two</block>
      // </editor>
      Block block = editor.children[0];
      expect(editor.children.length, 1);
      expect((block.children[0] as Text).text, 'two');
    });
  });

  group('inline', () {
    test('insert adjacent text', () {
      // <editor>
      //   <block>
      //     <inline>one</inline>
      //     <inline>two</inline>
      //   </block>
      // </editor>
      Block block = Block(children: <Node>[
        Inline(children: <Node>[Text('one')]),
        Inline(children: <Node>[Text('two')]),
      ]);
      Editor editor = Editor(children: <Node>[block]);

      EditorUtils.normalize(editor, force: true);

      // <editor>
      //   <block>
      //     <text />
      //     <inline>one</inline>
      //     <text />
      //     <inline>two</inline>
      //     <text />
      //   </block>
      // </editor>
      expect(block.children.length, 5);
      expect((block.children[0] as Text).text, '');
      expect(((block.children[1] as Inline).children[0] as Text).text, 'one');
      expect((block.children[2] as Text).text, '');
      expect(((block.children[3] as Inline).children[0] as Text).text, 'two');
      expect((block.children[4] as Text).text, '');
    });

    test('remove block', () {
      // <editor>
      //   <block>
      //     <text />
      //     <inline>
      //       <block>one</block>
      //       <text>two</text>
      //     </inline>
      //     <text />
      //   </block>
      // </editor>
      Block block = Block(children: <Node>[
        Text(''),
        Inline(children: <Node>[
          Block(children: <Node>[Text('one')]),
          Text('two'),
        ]),
        Text(''),
      ]);
      Editor editor = Editor(children: <Node>[block]);

      EditorUtils.normalize(editor, force: true);

      // <editor>
      //   <block>
      //     <text />
      //     <inline>
      //       <text>two</text>
      //     </inline>
      //     <text />
      //   </block>
      // </editor>
      expect(block.children.length, 3);
      expect((block.children[0] as Text).text, '');
      expect(((block.children[1] as Inline).children[0] as Text).text, 'two');
      expect((block.children[2] as Text).text, '');
    });
  });

  group('text', () {
    test('merge adjacent empty', () {
      // <editor>
      //   <block>
      //     <text />
      //     <text />
      //   </block>
      // </editor>
      Block block = Block(children: <Node>[
        Text(''),
        Text(''),
      ]);
      Editor editor = Editor(children: <Node>[block]);

      EditorUtils.normalize(editor, force: true);

      // <editor>
      //   <block>
      //     <text />
      //   </block>
      // </editor>
      expect(block.children.length, 1);
      expect((block.children[0] as Text).text, '');
    });

    test('merge adjacent match empty', () {
      // <editor>
      //   <block>
      //     <text>1</text>
      //     <text>2</text>
      //   </block>
      // </editor>
      Block block = Block(children: <Node>[
        Text('1'),
        Text('2'),
      ]);
      Editor editor = Editor(children: <Node>[block]);

      EditorUtils.normalize(editor, force: true);

      // <editor>
      //   <block>
      //     <text>12</text>
      //   </block>
      // </editor>
      expect(block.children.length, 1);
      expect((block.children[0] as Text).text, '12');
    });

    test('merge adjacent match', () {
      // <editor>
      //   <block>
      //     <text a>1</text>
      //     <text a>2</text>
      //   </block>
      // </editor>
      Block block = Block(children: <Node>[
        Text('1', props: {'a': true}),
        Text('2', props: {'a': true}),
      ]);
      Editor editor = Editor(children: <Node>[block]);

      EditorUtils.normalize(editor, force: true);

      // <editor>
      //   <block>
      //     <text>12</text>
      //   </block>
      // </editor>
      expect(block.children.length, 1);
      expect((block.children[0] as Text).text, '12');
    });
  });

  group('void', () {
    test('block insert text', () {
      // <editor>
      //   <block void />
      // </editor>
      Block block = Block(children: <Node>[], isVoid: true);
      Editor editor = Editor(children: <Node>[block]);

      EditorUtils.normalize(editor, force: true);

      // <editor>
      //   <void>
      //     <text />
      //   </void>
      // </editor>
      expect(block.children.length, 1);
      expect((block.children[0] as Text).text, '');
    });

    test('inline insert text', () {
      // <editor>
      //   <text />
      //   <inline void />
      //   <text />
      // </editor>
      Inline inline = Inline(children: <Node>[], isVoid: true);
      Editor editor = Editor(children: <Node>[Text(''), inline, Text('')]);

      EditorUtils.normalize(editor, force: true);

      // <editor>
      //   <block>
      //     <text />
      //     <inline void>
      //       <text />
      //     </inline>
      //     <text />
      //   </block>
      // </editor>
      expect(inline.children.length, 1);
      expect((inline.children[0] as Text).text, '');
    });
  });
}
