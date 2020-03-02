import 'package:flutter_test/flutter_test.dart';
import 'package:inday/stela/interfaces/element.dart';
import 'package:inday/stela/interfaces/node.dart';
import 'package:inday/stela/interfaces/text.dart';

void main() {
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
