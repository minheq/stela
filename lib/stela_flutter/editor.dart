import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:inday/stela/stela.dart' as Stela;
import 'package:inday/stela_flutter/children.dart';
import 'package:inday/stela_flutter/element.dart';
import 'package:inday/stela_flutter/selection.dart';

class EditorEditingValue extends Stela.Editor {
  EditorEditingValue(
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

  static EditorEditingValue empty = EditorEditingValue(children: []);
}

class EditorEditingController extends ValueNotifier<EditorEditingValue> {
  EditorEditingController({EditorEditingValue value})
      : super(value == null ? EditorEditingValue.empty : value);

  EditorEditingController.fromValue(EditorEditingValue value)
      : super(value ?? EditorEditingValue.empty);

  EditorEditingController.fromEditor(Stela.Editor value)
      : super(value == null
            ? EditorEditingValue.empty
            : EditorEditingValue(
                children: value.children,
                selection: value.selection,
                operations: value.operations,
                marks: value.marks,
                props: value.props));

  Stela.Range get selection => value.selection;

  set selection(Stela.Range newSelection) {
    if (!isSelectionWithinTextBounds(newSelection)) {
      throw FlutterError('invalid editor selection: $newSelection');
    }

    value = value.copyWith(selection: newSelection);
  }

  void clear() {
    value = EditorEditingValue.empty;
  }

  /// Check that the [selection] is inside of the bounds of [editor].
  bool isSelectionWithinTextBounds(Stela.Range selection) {
    // TODO: validate selection
    return true;
    // return selection. <= editor.length && selection.end <= text.length;
  }
}

class StelaEditor extends StatefulWidget {
  StelaEditor({
    Key key,
    @required this.controller,
    @required this.focusNode,
    this.readOnly = false,
    this.elementBuilder = defaultElementBuilder,
    this.textBuilder = defaultTextBuilder,
  })  : assert(controller != null),
        assert(focusNode != null),
        super(key: key);

  final Widget Function(Stela.Element element) elementBuilder;
  final TextSpan Function(Stela.Text text) textBuilder;

  final EditorEditingController controller;

  final FocusNode focusNode;

  final bool readOnly;

  @override
  _StelaEditorState createState() => _StelaEditorState();
}

class _StelaEditorState extends State<StelaEditor>
    implements EditorSelectionDelegate {
  EditorEditingValue get _value => widget.controller.value;
  set _value(EditorEditingValue value) {
    widget.controller.value = value;
  }

  @override
  void hideToolbar() {
    // TODO
  }

  @override
  EditorEditingValue get editorEditingValue => _value;
  set editorEditingValue(EditorEditingValue value) {
    // TODO
  }

  @override
  bool get cutEnabled => true;

  @override
  bool get copyEnabled => true;

  @override
  bool get pasteEnabled => true;

  @override
  bool get selectAllEnabled => true;

  @override
  Widget build(BuildContext context) {
    return StelaChildren(
      node: _value,
      elementBuilder: widget.elementBuilder,
      textBuilder: widget.textBuilder,
      selection: _value.selection,
    );
  }
}

TextSpan defaultTextBuilder(Stela.Text text) {
  return TextSpan(text: text.text);
}

Widget defaultElementBuilder(Stela.Element element) {
  if (element is Stela.Inline) {
    return Text('inline');
  }

  if (element is Stela.Block) {
    return StelaElement(node: element);
  }

  throw Exception('Unidentified element ${element.toString()}');
}

class EditorScope extends ChangeNotifier {
  static EditorScope of(BuildContext context) {
    final EditorScopeAccess widget =
        context.dependOnInheritedWidgetOfExactType<EditorScopeAccess>();

    return widget.scope;
  }
}

class EditorScopeAccess extends InheritedWidget {
  final EditorScope scope;

  EditorScopeAccess({Key key, @required this.scope, @required Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(EditorScopeAccess oldWidget) {
    return scope != oldWidget.scope;
  }
}
