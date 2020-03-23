import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:inday/stela/stela.dart' as Stela;
import 'package:inday/stela_flutter/rich_text.dart';
import 'package:inday/stela_flutter/children.dart';
import 'package:inday/stela_flutter/editor.dart';

class StelaElement extends StatefulWidget {
  StelaElement(
      {Key key,
      @required this.node,
      this.elementBuilder,
      this.textBuilder,
      this.path,
      this.selection})
      : assert(node != null),
        assert(elementBuilder != null),
        assert(textBuilder != null),
        super(key: key);

  final Stela.Path path;
  final Stela.Ancestor node;
  final Widget Function(Stela.Element element, StelaChildren children)
      elementBuilder;
  final TextSpan Function(Stela.Text text) textBuilder;
  final Stela.Range selection;

  @override
  _StelaElementState createState() => _StelaElementState();
}

class TextNodeEntry {
  TextPosition position;
  int length;
  Stela.Path path;
  Stela.Text node;
}

class _StelaElementState extends State<StelaElement> {
  @override
  Widget build(BuildContext context) {
    bool isRichText =
        widget.node is Stela.Block && widget.node.children.first is Stela.Text;

    if (isRichText == false) {
      return widget.elementBuilder(
          widget.node,
          StelaChildren(
            node: widget.node,
            elementBuilder: widget.elementBuilder,
            textBuilder: widget.textBuilder,
            selection: widget.selection,
          ));
    }

    return _buildRichText();
  }

  Widget _buildRichText() {
    StelaEditorScope scope = StelaEditorScope.of(context);
    List<TextNodeEntry> textEntries = [];
    List<InlineSpan> children = [];

    TextPosition position = TextPosition(offset: 0);

    for (int i = 0; i < widget.node.children.length; i++) {
      Stela.Node child = widget.node.children[i];

      if (child is Stela.Text) {
        TextNodeEntry entry = TextNodeEntry();
        entry.length = child.text.length;
        entry.position = position;
        entry.path = widget.path.copyAndAdd(i);
        entry.node = child;
        TextSpan textSpan = widget.textBuilder(child);
        if (textSpan.children != null && textSpan.children.isNotEmpty) {
          throw Exception('Only single text is allowed. Use Text(text: '
              ') instead of children.');
        }
        children.add(textSpan);
        textEntries.add(entry);
        position = TextPosition(offset: position.offset + child.text.length);
      } else {
        throw Exception('Inline not supported');
      }
    }

    TextSelection textSelection;

    if (widget.selection != null) {
      textSelection = TextSelection(
          baseOffset: widget.selection.anchor.offset,
          extentOffset: widget.selection.focus.offset);
    }

    return StelaRichText(
      node: widget.node,
      text: TextSpan(children: children),
      selection: textSelection,
      showCursor: scope.showCursor,
      textEntries: textEntries,
      scope: scope,
      cursorColor: scope.cursorColor,
      selectionColor: scope.selectionColor,
      hasFocus: scope.hasFocus,
      cursorRadius: scope.cursorRadius,
    );
  }
}

class DefaultElement extends StatelessWidget {
  DefaultElement({this.element, this.children});

  final Stela.Element element;
  final StelaChildren children;

  @override
  Widget build(BuildContext context) {
    return Container(child: children);
  }
}
