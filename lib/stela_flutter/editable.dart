import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:inday/stela/stela.dart' as Stela;
import 'package:inday/stela_flutter/children.dart';
import 'package:inday/stela_flutter/editor.dart';
import 'package:inday/stela_flutter/element.dart';
import 'package:inday/stela_flutter/rich_text.dart' as KRichText;

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
  // void _requestKeyboard() {
  //   _editableText?.requestKeyboard();
  // }

  // bool _shouldShowSelectionHandles(SelectionChangedCause cause) {
  //   // When the text field is activated by something that doesn't trigger the
  //   // selection overlay, we shouldn't show the handles either.
  //   if (!_selectionGestureDetectorBuilder.shouldShowSelectionToolbar)
  //     return false;

  //   if (cause == SelectionChangedCause.keyboard)
  //     return false;

  //   if (widget.readOnly && _effectiveController.selection.isCollapsed)
  //     return false;

  //   if (cause == SelectionChangedCause.longPress)
  //     return true;

  //   if (_effectiveController.text.isNotEmpty)
  //     return true;

  //   return false;
  // }

  _handleSelectionChanged(TextSelection selection,
      KRichText.RenderStelaRichText renderObject, SelectionChangedCause cause) {
    // final bool willShowSelectionHandles = _shouldShowSelectionHandles(cause);
    // if (willShowSelectionHandles != _showSelectionHandles) {
    //   setState(() {
    //     _showSelectionHandles = willShowSelectionHandles;
    //   });
    // }

    // switch (Theme.of(context).platform) {
    //   case TargetPlatform.iOS:
    //   case TargetPlatform.macOS:
    //     if (cause == SelectionChangedCause.longPress) {
    //       _editableText?.bringIntoView(selection.base);
    //     }
    //     return;
    //   case TargetPlatform.android:
    //   case TargetPlatform.fuchsia:
    //   case TargetPlatform.linux:
    //   case TargetPlatform.windows:
    //     // Do nothing.
    // }
  }

  @override
  Widget build(BuildContext context) {
    StelaEditorScope scope = StelaEditorScope.of(context);

    return StelaEditableProvider(
      scope: StelaEditableScope(onSelectionChanged: _handleSelectionChanged),
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
    this.onSelectionChanged,
    this.ignorePointer = false,
  });

  KRichText.SelectionChangedHandler onSelectionChanged;
  bool ignorePointer;

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
