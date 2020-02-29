import 'package:flutter_test/flutter_test.dart';
import 'package:inday/stela/interfaces/element.dart';
import 'package:inday/stela/interfaces/text.dart';

void main() {
  group("isText", () {
    test('should succeed with valid text node', () {
      Text text = Text("string");

      expect(Text.isText(text), true);
    });

    test('should succeed with empty text node', () {
      Text text = Text("");

      expect(Text.isText(text), true);
    });

    test('should fail with element node', () {
      Element element = Element(children: []);

      expect(Text.isText(element), false);
    });
  });

  group("isTextList", () {
    test('should succeed with valid text node list', () {
      Text text = Text("string");

      expect(Text.isTextList([text]), true);
    });

    test('should fail with an element in node list', () {
      Text text = Text("string");
      Element element = Element(children: []);

      expect(Text.isTextList([text, element]), false);
    });
  });

  group("equals", () {
    test('should succeed when both text nodes contain same text', () {
      Text text = Text("string");
      Text another = Text("string");

      expect(Text.equals(text, another), true);
    });

    test('should fail when text nodes have different texts', () {
      Text text = Text("string");
      Text another = Text("number");

      expect(Text.equals(text, another), false);
    });
  });
}
