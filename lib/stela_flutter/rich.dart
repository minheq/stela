import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:inday/stela/stela.dart' as Stela;

class StelaRichText extends StatefulWidget {
  StelaRichText({
    Key key,
    @required this.text,
  });

  final TextSpan text;

  @override
  _StelaRichTextState createState() => _StelaRichTextState();
}

class _StelaRichTextState extends State<StelaRichText> {
  @override
  Widget build(BuildContext context) {
    // ThemeData themeData = Theme.of(context);

    return RichText(
      text: widget.text,
      // cursorColor: themeData.cursorColor,
      // selectionColor: themeData.textSelectionColor,
      // backgroundCursorColor: CupertinoColors.inactiveGray,
      // ignorePointer: false,
    );
  }
}
