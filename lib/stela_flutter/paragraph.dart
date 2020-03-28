import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:inday/stela/stela.dart' as Stela;

typedef CaretChangedHandler = void Function(Rect caretRect);

class StelaParagraph extends StatefulWidget {
  StelaParagraph({
    Key key,
    @required this.node,
    @required this.children,
  });

  final Stela.Block node;
  final List<Widget> children;

  @override
  _StelaParagraphState createState() => _StelaParagraphState();
}

class _StelaParagraphState extends State<StelaParagraph> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Column(children: widget.children));
  }
}
