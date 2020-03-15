import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:inday/stela_flutter/block.dart';
import 'package:inday/stela_flutter/text.dart';

/// Widget for editing Zefyr documents.
class Stela extends StatefulWidget {
  @override
  _StelaState createState() => _StelaState();
}

class _StelaState extends State<Stela> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        StelaText(
          'World!',
          style: DefaultTextStyle.of(context)
              .style
              .copyWith(fontWeight: FontWeight.bold),
        ),
        // StelaBlock(
        //   children: [
        //     StelaText(
        //       'Hello ',
        //       style: DefaultTextStyle.of(context).style,
        //     ),
        //     StelaText(
        //       'World!',
        //       style: DefaultTextStyle.of(context)
        //           .style
        //           .copyWith(fontWeight: FontWeight.bold),
        //     )
        //   ],
        // ),
        RichText(
          text: TextSpan(
            text: 'Hello ',
            style: DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              TextSpan(
                  text: 'bold', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: ' world!'),
            ],
          ),
        )
      ],
    );
  }
}
