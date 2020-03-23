import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inday/stela/stela.dart' as Stela;
import 'package:inday/stela_flutter/editable.dart';
import 'package:inday/stela_flutter/editor.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    Stela.Editor editor = Stela.Editor(children: [
      Stela.Block(children: [
        Stela.Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam eu scelerisque dolor, in semper turpis.'),
      ]),
    ]);

    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
            child: Column(
          children: <Widget>[
            StelaEditor(
              controller: EditorEditingController.fromEditor(editor),
              children: [
                StelaEditable(
                  cursorColor: themeData.cursorColor,
                  showCursor: true,
                  backgroundCursorColor: CupertinoColors.inactiveGray,
                  // cursorOpacityAnimates: true,
                  focusNode: FocusNode(),
                )
              ],
            ),
            TextFormField(
              initialValue:
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam eu scelerisque dolor, in semper turpis.',
            ),
            // GestureDetector(
            //   behavior: HitTestBehavior.translucent,
            //   onTapUp: (TapUpDetails details) {
            //     print('go');
            //   },
            //   onLongPressStart: (LongPressStartDetails details) {
            //     print('long');
            //   },
            //   child: Text('hello'),
            // )
          ],
        )),
      ),
    );
  }
}
