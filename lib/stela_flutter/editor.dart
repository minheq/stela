import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:inday/stela/stela.dart' as Stela;
import 'package:inday/stela_flutter/block_text.dart';

class StelaEditor extends StatefulWidget {
  StelaEditor(this.editor);

  final Stela.Editor editor;

  @override
  _StelaEditorState createState() => _StelaEditorState();
}

class _StelaEditorState extends State<StelaEditor> {
  Widget _buildBlockText(Stela.Block block) {
    List<TextSpan> children = [];

    for (Stela.Node blockChild in block.children) {
      if (blockChild is Stela.Text) {
        children.add(TextSpan(text: blockChild.text));
      }

      if (blockChild is Stela.Inline) {
        // TODO
      }
    }

    TextSpan text =
        TextSpan(children: children, style: DefaultTextStyle.of(context).style);

    return StelaBlockText(text: text, selectionColor: Colors.blue);
  }

  List<Widget> _buildWidgets(Stela.Editor editor) {
    List<Widget> children = [];

    /// There are 2 kind of blocks, ones that contain text and ones that nest other blocks.
    for (Stela.Node child in editor.children) {
      bool isBlockText =
          child is Stela.Block && child.children.first is Stela.Text;

      if (isBlockText) {
        children.add(_buildBlockText(child));
      }
    }

    return children;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: _buildWidgets(widget.editor));
  }
}
