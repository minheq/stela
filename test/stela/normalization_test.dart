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
    return element is Void;
  }
}

void main() {
  group('block', () {
    test('insert text', () {
      // <editor>
      //   <block />
      // </editor>
      Block block = Block(children: <Node>[]);
      TestEditor editor = TestEditor(children: <Node>[block]);

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
      TestEditor editor = TestEditor(children: <Node>[block]);

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
      TestEditor editor = TestEditor(children: <Node>[block]);

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
}
