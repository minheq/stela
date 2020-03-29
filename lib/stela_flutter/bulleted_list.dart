import 'package:flutter/widgets.dart';
import 'package:inday/stela/stela.dart' as Stela;

class StelaBulletedList extends StatefulWidget {
  StelaBulletedList({
    Key key,
    @required this.node,
    @required this.children,
  });

  final Stela.Block node;
  final List<Widget> children;

  @override
  _StelaBulletedListState createState() => _StelaBulletedListState();
}

class _StelaBulletedListState extends State<StelaBulletedList> {
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    for (int i = 0; i < widget.children.length; i++) {
      Widget child = widget.children[i];

      children.add(Row(
        children: <Widget>[Text('${i + 1}. '), child],
      ));
    }

    return Column(children: children);
  }
}
