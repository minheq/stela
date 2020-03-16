import 'package:flutter/material.dart';
import 'package:inday/stela/stela.dart' as Stela;
import 'package:inday/stela_flutter/editor.dart';

void main() => runApp(MyApp());

class Editor extends Stela.Editor {
  Editor(
      {List<Stela.Node> children,
      Stela.Range selection,
      List<Stela.Operation> operations,
      Map<String, dynamic> marks,
      Map<String, dynamic> props})
      : super(
            children: children,
            selection: selection,
            operations: operations,
            marks: marks,
            props: props);

  @override
  bool isVoid(Stela.Element element) {
    return element.isVoid;
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Editor editor = Editor(
        selection: Stela.Range(Stela.Point(Stela.Path([0, 0]), 1),
            Stela.Point(Stela.Path([0, 0]), 5)),
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
            StelaEditor(editor),
          ],
        )),
      ),
    );
  }
}
