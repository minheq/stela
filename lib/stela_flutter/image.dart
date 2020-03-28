import 'package:flutter/widgets.dart';
import 'package:inday/stela/stela.dart' as Stela;

class StelaImage extends StatefulWidget {
  StelaImage({
    Key key,
    @required this.node,
  });

  final Stela.Block node;

  @override
  _StelaImageState createState() => _StelaImageState();
}

class _StelaImageState extends State<StelaImage> {
  @override
  Widget build(BuildContext context) {
    String url = widget.node.props['url'];

    return Image(
      image: NetworkImage(url),
    );
  }
}
