import 'package:flutter_test/flutter_test.dart';
import 'package:inday/stela/element.dart';
import 'package:inday/stela/node.dart';
import 'package:inday/stela/path.dart';
import 'package:inday/stela/point.dart';
import 'package:inday/stela/text.dart';
import 'package:inday/stela/range.dart';

void main() {
  group('decorations', () {
    test('end', () {
      Range decoration = Range(Point(Path([0]), 2), Point(Path([0]), 3),
          props: {'decoration': 'decoration'});

      Text text = Text('abc', props: {'mark': 'mark'});
      List<Text> leaves = TextUtils.decorations(text, [decoration]);

      expect(leaves[0].text, 'ab');
      expect(leaves[0].props['mark'], 'mark');

      expect(leaves[1].text, 'c');
      expect(leaves[1].props['mark'], 'mark');
      expect(leaves[1].props['decoration'], 'decoration');
    });

    test('end', () {
      Range decoration = Range(Point(Path([0]), 1), Point(Path([0]), 2),
          props: {'decoration': 'decoration'});

      Text text = Text('abc', props: {'mark': 'mark'});
      List<Text> leaves = TextUtils.decorations(text, [decoration]);

      expect(leaves[0].text, 'a');
      expect(leaves[0].props['mark'], 'mark');

      expect(leaves[1].text, 'b');
      expect(leaves[1].props['mark'], 'mark');
      expect(leaves[1].props['decoration'], 'decoration');

      expect(leaves[2].text, 'c');
      expect(leaves[2].props['mark'], 'mark');
    });

    test('overlapping', () {
      Range decoration1 = Range(Point(Path([0]), 1), Point(Path([0]), 2),
          props: {'decoration1': 'decoration1'});

      Range decoration2 = Range(Point(Path([0]), 0), Point(Path([0]), 3),
          props: {'decoration2': 'decoration2'});

      Text text = Text('abc', props: {'mark': 'mark'});
      List<Text> leaves =
          TextUtils.decorations(text, [decoration1, decoration2]);

      expect(leaves[0].text, 'a');
      expect(leaves[0].props['mark'], 'mark');
      expect(leaves[0].props['decoration2'], 'decoration2');

      expect(leaves[1].text, 'b');
      expect(leaves[1].props['mark'], 'mark');
      expect(leaves[1].props['decoration1'], 'decoration1');
      expect(leaves[0].props['decoration2'], 'decoration2');

      expect(leaves[2].text, 'c');
      expect(leaves[2].props['mark'], 'mark');
      expect(leaves[2].props['decoration2'], 'decoration2');
    });

    test('start', () {
      Range decoration = Range(Point(Path([0]), 0), Point(Path([0]), 1),
          props: {'decoration': 'decoration'});

      Text text = Text('abc', props: {'mark': 'mark'});
      List<Text> leaves = TextUtils.decorations(text, [decoration]);

      expect(leaves[0].text, 'a');
      expect(leaves[0].props['mark'], 'mark');
      expect(leaves[0].props['decoration'], 'decoration');

      expect(leaves[1].text, 'bc');
      expect(leaves[1].props['mark'], 'mark');
    });
  });

  group('isTextList', () {
    test('should succeed with valid text node list', () {
      Text text = Text('string');

      expect(TextUtils.isTextList([text]), true);
    });

    test('should fail with an element in node list', () {
      Text text = Text('string');
      Element element = Element(children: []);
      List<Node> nodes = [text, element];

      expect(TextUtils.isTextList(nodes), false);
    });
  });

  group('equals', () {
    test('should succeed when both text nodes contain same text', () {
      Text text = Text('string');
      Text another = Text('string');

      expect(TextUtils.equals(text, another), true);
    });

    test('should fail when text nodes have different texts', () {
      Text text = Text('string');
      Text another = Text('number');

      expect(TextUtils.equals(text, another), false);
    });
  });
}
