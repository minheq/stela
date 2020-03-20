import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:inday/stela/stela.dart' as Stela;
import 'package:inday/stela_flutter/children.dart';
import 'package:inday/stela_flutter/editor.dart';
import 'package:inday/stela_flutter/element.dart';

class StelaEditable extends StatefulWidget {
  StelaEditable({
    this.elementBuilder = defaultElementBuilder,
    this.textBuilder = defaultTextBuilder,
  });

  final Widget Function(Stela.Element element, StelaChildren children)
      elementBuilder;
  final TextSpan Function(Stela.Text text) textBuilder;

  @override
  _StelaEditableState createState() => _StelaEditableState();
}

class _StelaEditableState extends State<StelaEditable> {
  @override
  Widget build(BuildContext context) {
    StelaEditorScope scope = StelaEditorScope.of(context);

    return StelaEditableProvider(
      scope: StelaEditableScope(),
      child: StelaChildren(
        node: scope.controller.value,
        elementBuilder: widget.elementBuilder,
        textBuilder: widget.textBuilder,
        selection: scope.controller.value.selection,
      ),
    );
  }
}

TextSpan defaultTextBuilder(Stela.Text text) {
  return TextSpan(
      text: text.text, style: TextStyle(color: Colors.black, fontSize: 16));
}

Widget defaultElementBuilder(Stela.Element element, StelaChildren children) {
  return DefaultElement(
    element: element,
    children: children,
  );
}

class StelaEditableScope {
  StelaEditableScope({
    this.addBox,
    this.removeBox,
  });

  void Function(RenderBox box) addBox;
  void Function(RenderBox box) removeBox;

  static StelaEditableScope of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<StelaEditableProvider>()
        .scope;
  }
}

class StelaEditableProvider extends InheritedWidget {
  final StelaEditableScope scope;

  StelaEditableProvider({
    Key key,
    @required this.scope,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(StelaEditableProvider old) => true;
}
