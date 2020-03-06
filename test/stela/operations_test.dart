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
  group('move node', () {
    test('path equals new path', () {
      // <editor>
      //   <element>1</element>
      //   <element>2</element>
      // </editor>
      Element element1 = Element(children: <Node>[Text('1')]);
      Element element2 = Element(children: <Node>[Text('2')]);
      TestEditor editor = TestEditor(children: <Node>[element1, element2]);

      editor.apply(MoveNodeOperation(Path([0]), Path([0])));

      // <editor>
      //   <element>1</element>
      //   <element>2</element>
      // </editor>
      expect(editor.children[0], element1);
      expect(editor.children[1], element2);
    });
  });

  group('remove text', () {
    test('anchor after', () {
      // <editor>
      //   <element>
      //     wor
      //     <anchor />d<focus />
      //   </element>
      // </editor>
      Element element = Element(children: <Node>[Text('word')]);
      TestEditor editor = TestEditor(
          selection: Range(Point(Path([0, 0]), 3), Point(Path([0, 0]), 4)),
          children: <Node>[element]);

      editor.apply(RemoveTextOperation(Path([0, 0]), 1, 'or'));

      // <editor>
      //   <element>
      //     w<anchor />d<focus />
      //   </element>
      // </editor>
      expect((element.children[0] as Text).text, 'wd');
      expect(
          RangeUtils.equals(editor.selection,
              Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 2))),
          true);
    });

    test('anchor before', () {
      // <editor>
      //   <element>
      //     w<anchor />
      //     ord
      //     <focus />
      //   </element>
      // </editor>
      Element element = Element(children: <Node>[Text('word')]);
      TestEditor editor = TestEditor(
          selection: Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 4)),
          children: <Node>[element]);

      editor.apply(RemoveTextOperation(Path([0, 0]), 1, 'or'));

      // <editor>
      //   <element>
      //     w<anchor />d<focus />
      //   </element>
      // </editor>
      expect((element.children[0] as Text).text, 'wd');
      expect(
          RangeUtils.equals(editor.selection,
              Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 2))),
          true);
    });

    test('anchor middle', () {
      // <editor>
      //   <element>
      //     wo
      //     <anchor />
      //     rd
      //     <focus />
      //   </element>
      // </editor>
      Element element = Element(children: <Node>[Text('word')]);
      TestEditor editor = TestEditor(
          selection: Range(Point(Path([0, 0]), 2), Point(Path([0, 0]), 4)),
          children: <Node>[element]);

      editor.apply(RemoveTextOperation(Path([0, 0]), 1, 'or'));

      // <editor>
      //   <element>
      //     w<anchor />d<focus />
      //   </element>
      // </editor>
      expect((element.children[0] as Text).text, 'wd');
      expect(
          RangeUtils.equals(editor.selection,
              Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 2))),
          true);
    });

    test('cursor after', () {
      // <editor>
      //   <element>
      //     wor
      //     <cursor />d
      //   </element>
      // </editor>
      Element element = Element(children: <Node>[Text('word')]);
      TestEditor editor = TestEditor(
          selection: Range(Point(Path([0, 0]), 3), Point(Path([0, 0]), 3)),
          children: <Node>[element]);

      editor.apply(RemoveTextOperation(Path([0, 0]), 1, 'or'));

      // <editor>
      //   <element>
      //     w<cursor />d
      //   </element>
      // </editor>
      expect((element.children[0] as Text).text, 'wd');
      expect(
          RangeUtils.equals(editor.selection,
              Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 1))),
          true);
    });

    test('cursor before', () {
      // <editor>
      //   <element>
      //     w<cursor />
      //     ord
      //   </element>
      // </editor>
      Element element = Element(children: <Node>[Text('word')]);
      TestEditor editor = TestEditor(
          selection: Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 1)),
          children: <Node>[element]);

      editor.apply(RemoveTextOperation(Path([0, 0]), 1, 'or'));

      // <editor>
      //   <element>
      //     w<cursor />d
      //   </element>
      // </editor>
      expect((element.children[0] as Text).text, 'wd');
      expect(
          RangeUtils.equals(editor.selection,
              Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 1))),
          true);
    });

    test('cursor middle', () {
      // <editor>
      //   <element>
      //     wo
      //     <cursor />
      //     rd
      //   </element>
      // </editor>
      Element element = Element(children: <Node>[Text('word')]);
      TestEditor editor = TestEditor(
          selection: Range(Point(Path([0, 0]), 2), Point(Path([0, 0]), 2)),
          children: <Node>[element]);

      editor.apply(RemoveTextOperation(Path([0, 0]), 1, 'or'));

      // <editor>
      //   <element>
      //     w<cursor />d
      //   </element>
      // </editor>
      expect((element.children[0] as Text).text, 'wd');
      expect(
          RangeUtils.equals(editor.selection,
              Range(Point(Path([0, 0]), 1), Point(Path([0, 0]), 1))),
          true);
    });

    test('focus after', () {
      // <editor>
      //   <element>
      //     <anchor />
      //     wor
      //     <focus />d
      //   </element>
      // </editor>
      Element element = Element(children: <Node>[Text('word')]);
      TestEditor editor = TestEditor(
          selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 3)),
          children: <Node>[element]);

      editor.apply(RemoveTextOperation(Path([0, 0]), 1, 'or'));

      // <editor>
      //   <element>
      //     <anchor />w<focus />d
      //   </element>
      // </editor>
      expect((element.children[0] as Text).text, 'wd');
      expect(
          RangeUtils.equals(editor.selection,
              Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 1))),
          true);
    });

    test('focus before', () {
      // <editor>
      //   <element>
      //     <anchor />w<focus />
      //     ord
      //   </element>
      // </editor>
      Element element = Element(children: <Node>[Text('word')]);
      TestEditor editor = TestEditor(
          selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 1)),
          children: <Node>[element]);

      editor.apply(RemoveTextOperation(Path([0, 0]), 1, 'or'));

      // <editor>
      //   <element>
      //     <anchor />w<focus />d
      //   </element>
      // </editor>
      expect((element.children[0] as Text).text, 'wd');
      expect(
          RangeUtils.equals(editor.selection,
              Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 1))),
          true);
    });

    test('focus middle', () {
      // <editor>
      //   <element>
      //     <anchor />
      //     wo
      //     <focus />
      //     rd
      //   </element>
      // </editor>
      Element element = Element(children: <Node>[Text('word')]);
      TestEditor editor = TestEditor(
          selection: Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 2)),
          children: <Node>[element]);

      editor.apply(RemoveTextOperation(Path([0, 0]), 1, 'or'));

      // <editor>
      //   <element>
      //     w<anchor />d<focus />
      //   </element>
      // </editor>
      expect((element.children[0] as Text).text, 'wd');
      expect(
          RangeUtils.equals(editor.selection,
              Range(Point(Path([0, 0]), 0), Point(Path([0, 0]), 1))),
          true);
    });
  });
}
