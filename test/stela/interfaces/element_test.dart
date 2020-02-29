import 'package:flutter_test/flutter_test.dart';
import 'package:inday/stela/interfaces/element.dart';
import 'package:inday/stela/interfaces/node.dart';
import 'package:inday/stela/interfaces/text.dart';

void main() {
  group("isElement", () {
    test('should succeed with valid element node', () {
      Element element = Element(children: <Node>[Element(children: <Node>[])]);

      expect(Element.isElement(element), true);
    });

    test('should succeed with empty empty node', () {
      Element element = Element(children: <Node>[]);

      expect(Element.isElement(element), true);
    });

    test('should fail with text node', () {
      Text text = Text("string");

      expect(Element.isElement(text), false);
    });
  });

  group("isElementList", () {
    test('should succeed with valid element node list', () {
      Element element = Element(children: <Node>[]);

      expect(Element.isElementList([element]), true);
    });

    test('should fail with an text in node list', () {
      Text text = Text("string");
      Element element = Element(children: []);

      expect(Element.isElementList([text, element]), false);
    });
  });
}
