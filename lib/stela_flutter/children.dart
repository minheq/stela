import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:inday/stela/stela.dart' as Stela;
import 'package:inday/stela_flutter/element.dart';

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
    List<Widget> children = [];

    for (Stela.Descendant child in widget.node.children) {
      if (child is Stela.Element) {
        children.add(StelaElement(
          node: child,
          elementBuilder: widget.elementBuilder,
          textBuilder: widget.textBuilder,
          selection: widget.selection,
        ));
      } else {
        // Text nodes are handled within [StelaElement] instead of here.
        // The reason is that we want to rely on [TextPainter], and that forces us
        // to merge texts into a single [RenderObject]
      }
    }

    return ListBody(children: children);
  }
}
