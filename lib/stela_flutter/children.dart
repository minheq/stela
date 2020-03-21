import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:inday/stela/stela.dart' as Stela;
import 'package:inday/stela_flutter/element.dart';
import 'package:inday/stela_flutter/editor.dart';

class StelaChildren extends StatefulWidget {
  StelaChildren(
      {Key key,
      @required this.node,
      this.elementBuilder,
      this.textBuilder,
      this.selection})
      : assert(node != null),
        assert(elementBuilder != null),
        assert(textBuilder != null),
        super(key: key);

  final Stela.Ancestor node;
  final Widget Function(Stela.Element element, StelaChildren children)
      elementBuilder;
  final TextSpan Function(Stela.Text text) textBuilder;
  final Stela.Range selection;

  @override
  _StelaChildrenState createState() => _StelaChildrenState();
}

class _StelaChildrenState extends State<StelaChildren> {
  @override
  Widget build(BuildContext context) {
    StelaEditorScope scope = StelaEditorScope.of(context);
    Stela.Ancestor node = widget.node;
    Stela.Editor editor = scope.controller.value;
    Stela.Range selection = scope.controller.selection;
    Stela.Path path = scope.findPath(node);
    bool isLeafBlock = node is Stela.Element &&
        node is Stela.Inline == false &&
        editor.hasInlines(node);

    List<Widget> children = [];

    for (int i = 0; i < node.children.length; i++) {
      Stela.Descendant child = node.children[i];
      Stela.Path p = path.copyAndAdd(i);
      Stela.Descendant n = node.children[i];
      // const key = ReactEditor.findKey(editor, n)
      Stela.Range range = editor.range(p, null);
      Stela.Range subSelection;

      if (selection != null) {
        subSelection = range.intersection(selection);
      }

      if (child is Stela.Element) {
        children.add(StelaElement(
          node: child,
          elementBuilder: widget.elementBuilder,
          textBuilder: widget.textBuilder,
          selection: subSelection,
        ));
      } else {
        // Text nodes are handled within [StelaElement] instead of here.
        // The reason is that we want to rely on [TextPainter], and that forces us
        // to merge texts into a single [RenderStelaRichText] RenderObject
      }

      nodeToIndex[n] = i;
      nodeToParent[n] = node;
    }

    return ListBody(children: children);
  }
}
