import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inday/stela/stela.dart' as Stela;
import 'package:inday/stela_flutter/editor.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    Stela.Editor editor = Stela.Editor(children: [
      Stela.Block(type: 'paragraph', children: [
        Stela.Text('Lorem ipsum dolor sit amet, consectetur '),
        Stela.Inline(type: 'link', children: [
          Stela.Text('adipiscing'),
        ]),
        Stela.Text(' elit.'),
      ]),
      Stela.Block(type: 'image', isVoid: true, props: {
        'url':
            'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg'
      }, children: [
        Stela.Text('')
      ]),
      Stela.Block(type: 'paragraph', children: [
        Stela.Text('Aliquam eu scelerisque dolor, in '),
        Stela.Inline(type: 'mention', isVoid: true, props: {
          'name': 'semper'
        }, children: [
          Stela.Text(''),
        ]),
        Stela.Text(' turpis.'),
      ]),
      Stela.Block(type: 'bulleted_list', children: [
        Stela.Block(type: 'list_item', children: [Stela.Text('item 1')]),
        Stela.Block(type: 'list_item', children: [Stela.Text('item 2')]),
      ]),
      Stela.Block(type: 'paragraph', children: [
        Stela.Text(
            'Nam hendrerit sem purus, sit amet finibus quam tincidunt ac.'),
      ]),
      Stela.Block(type: 'paragraph', children: [
        Stela.Text('tenword12.'),
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
              selectionColor: themeData.textSelectionColor,
              showCursor: true,
              backgroundCursorColor: CupertinoColors.inactiveGray,
              cursorOpacityAnimates: true,
              focusNode: FocusNode(),
            ),
            // TextFormField(
            //   initialValue:
            //       'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam eu scelerisque dolor, in semper turpis.',
            //   maxLines: null,
            // ),
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
