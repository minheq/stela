import 'package:flutter_test/flutter_test.dart';
import 'package:inday/stela/element.dart';
import 'package:inday/stela/node.dart';
import 'package:inday/stela/text.dart';

void main() {
  group('isElementList', () {
    test('should succeed with valid element node list', () {
      Element element = Element(children: <Node>[]);

      expect(ElementUtils.isElementList([element]), true);
    });

    test('should fail with an text in node list', () {
      Text text = Text('string');
      Element element = Element(children: []);

      expect(ElementUtils.isElementList([text, element]), false);
    });
  });
}
