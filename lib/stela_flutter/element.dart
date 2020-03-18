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
  final Widget Function(Stela.Element element) elementBuilder;
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
      return Container(
          child: StelaChildren(
        node: widget.node,
        elementBuilder: widget.elementBuilder,
        textBuilder: widget.textBuilder,
        selection: widget.selection,
      ));
    }

    List<InlineSpan> children = [];

    for (Stela.Node blockChild in widget.node.children) {
      if (blockChild is Stela.Text) {
        children.add(TextSpan(
            text: blockChild.text,
            style: TextStyle(color: Colors.black, fontSize: 16)));
      }

      if (blockChild is Stela.Inline) {
        // TODO: implement inline stuff for things like hyperlinks
        children.add(WidgetSpan(child: Text('inline')));
      }
    }

    TextSpan textSpan = TextSpan(children: children);

    return StelaRichText(text: textSpan);
  }
}
