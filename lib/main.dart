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

    Stela.Editor editor = Stela.Editor(
        selection: Stela.Range(Stela.Point(Stela.Path([0, 0]), 1),
            Stela.Point(Stela.Path([0, 0]), 1)),
        children: [
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
              cursorColor: themeData.cursorColor,
              showCursor: true,
              backgroundCursorColor: CupertinoColors.inactiveGray,
              // cursorOpacityAnimates: true,
              focusNode: FocusNode(),
              children: [StelaEditable()],
            ),
            // TextFormField(
            //   initialValue:
            //       'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam eu scelerisque dolor, in semper turpis.',
            // )
          ],
        )),
      ),
    );
  }
}
