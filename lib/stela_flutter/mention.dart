import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:inday/stela/stela.dart' as Stela;

class StelaMention extends StatefulWidget {
  StelaMention({
    Key key,
    @required this.node,
    @required this.children,
  });

  final Stela.Inline node;
  final List<Widget> children;

  @override
  _StelaMentionState createState() => _StelaMentionState();
}

class _StelaMentionState extends State<StelaMention> {
  @override
  Widget build(BuildContext context) {
    String name = widget.node.props['name'];

    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (TapDownDetails details) {
          print('mention');
        },
        child: Container(
            color: Colors.black12,
            child: Text(
              name,
              style: DefaultTextStyle.of(context).style,
            )));
  }
}
