import 'package:flutter/widgets.dart';
import 'package:inday/stela/stela.dart' as Stela;

class StelaLink extends StatefulWidget {
  StelaLink({
    Key key,
    @required this.node,
    @required this.children,
  });

  final Stela.Inline node;
  final List<Widget> children;

  @override
  _StelaLinkState createState() => _StelaLinkState();
}

class _StelaLinkState extends State<StelaLink> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (TapDownDetails details) {
          print('link');
        },
        child: Column(children: widget.children));
  }
}
