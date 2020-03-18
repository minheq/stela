import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:inday/stela/stela.dart' as Stela;
import 'package:inday/stela_flutter/rich_text.dart';
import 'package:inday/stela_flutter/children.dart';

class StelaElement extends StatefulWidget {
  StelaElement(
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
  _StelaElementState createState() => _StelaElementState();
}

class _StelaElementState extends State<StelaElement> {
  @override
  Widget build(BuildContext context) {
    bool isRichText =
        widget.node is Stela.Block && widget.node.children.first is Stela.Text;

    if (isRichText == false) {
      StelaChildren children = StelaChildren(
        node: widget.node,
        elementBuilder: widget.elementBuilder,
        textBuilder: widget.textBuilder,
        selection: widget.selection,
      );

      return widget.elementBuilder(widget.node, children);
    }

    List<InlineSpan> inlineSpans = [];

    for (Stela.Node child in widget.node.children) {
      if (child is Stela.Text) {
        inlineSpans.add(widget.textBuilder(child));
      } else {
        throw Exception('Inline not supported');
      }
    }

    return StelaRichText(
      text: TextSpan(children: inlineSpans),
    );
  }
}

class DefaultElement extends StatelessWidget {
  DefaultElement({this.element, this.children});

  final Stela.Element element;
  final StelaChildren children;

  @override
  Widget build(BuildContext context) {
    return Container(child: children);
  }
}