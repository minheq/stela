import 'package:flutter/widgets.dart';
import 'package:inday/stela/stela.dart' as Stela;

class StelaListItem extends StatefulWidget {
  StelaListItem({
    Key key,
    @required this.node,
    @required this.children,
  });

  final Stela.Block node;
  final List<Widget> children;

  @override
  _StelaListItemState createState() => _StelaListItemState();
}

class _StelaListItemState extends State<StelaListItem> {
  @override
  Widget build(BuildContext context) {
    return Column(children: widget.children);
  }
}
