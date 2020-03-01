import 'package:flutter_test/flutter_test.dart';
import 'package:inday/stela/interfaces/element.dart';
import 'package:inday/stela/interfaces/text.dart';

void main() {
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
