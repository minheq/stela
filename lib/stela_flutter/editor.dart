import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:inday/stela/stela.dart' as Stela;
import 'package:inday/stela_flutter/block_text.dart';

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

  static Stela.Editor empty = Stela.Editor();
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

  final Widget Function(
    Stela.Element element, {
    Stela.Editor editor,
  }) elementBuilder;

  final TextSpan Function(
    Stela.Text text, {
    Stela.Editor editor,
  }) textBuilder;

  final EditorEditingController controller;

  final FocusNode focusNode;

  final bool readOnly;

  @override
  _StelaEditorState createState() => _StelaEditorState();
}

class _StelaEditorState extends State<StelaEditor> {
  @override
  Widget build(BuildContext context) {
    return Column(children: _buildChildren(widget.controller.value));
  }
}

TextSpan defaultTextBuilder(Stela.Text text, {Stela.Editor editor}) {
  return TextSpan(text: text.text);
}

Widget defaultElementBuilder(Stela.Element element, {Stela.Editor editor}) {
  if (element is Stela.Inline) {
    return Text('inline');
  }

  if (element is Stela.Block) {
    return Column(children: _buildChildren(element));
  }

  throw Exception('Unidentified element ${element.toString()}');
}

List<Widget> _buildChildren(Stela.Ancestor ancestor) {
  List<Widget> children = [];

  for (Stela.Node child in ancestor.children) {
    bool isBlockText =
        child is Stela.Block && child.children.first is Stela.Text;

    if (isBlockText) {
      children.add(_buildBlockText(child));
    }
  }

  return children;
}

Widget _buildBlockText(Stela.Block block) {
  List<InlineSpan> children = [];

  for (Stela.Node blockChild in block.children) {
    if (blockChild is Stela.Text) {
      children.add(TextSpan(
          text: blockChild.text,
          style: TextStyle(color: Colors.black, fontSize: 16)));
    }

    if (blockChild is Stela.Inline) {
      // TODO: implement inline stuff for things like hyperlinks
      children.add(WidgetSpan(child: Text('inline')));
    }
  }

  TextSpan textSpan = TextSpan(children: children);

  return BlockText(text: textSpan);
}

class BlockText extends LeafRenderObjectWidget {
  BlockText({@required this.text}) : assert(text != null);

  final TextSpan text;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderParagraph(
      text,
      textDirection: Directionality.of(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderParagraph renderObject) {
    renderObject..text = text;
  }
}
