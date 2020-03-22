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

  _handleSingleTapUp(Stela.Node node, TapUpDetails details) {
    StelaEditorScope editorScope = StelaEditorScope.of(context);

    requestKeyboard();
    // editableText.hideToolbar();
    // if (delegate.selectionEnabled) {
    //   switch (Theme.of(_state.context).platform) {
    //     case TargetPlatform.iOS:
    //     case TargetPlatform.macOS:
    //       renderEditable.selectWordEdge(cause: SelectionChangedCause.tap);
    //       break;
    //     case TargetPlatform.android:
    //     case TargetPlatform.fuchsia:
    //     case TargetPlatform.linux:
    //     case TargetPlatform.windows:
    //       renderEditable.selectPosition(cause: SelectionChangedCause.tap);
    //       break;
    //   }
    // }
    // _state._requestKeyboard();
    // if (_state.widget.onTap != null)
    //   _state.widget.onTap();
  }

  void requestKeyboard() {
    StelaEditorScope editorScope = StelaEditorScope.of(context);
    if (editorScope.hasFocus) {
      // _openInputConnection();
    } else {
      editorScope.focusNode.requestFocus();
    }
  }

  _handleSelectionChange(
      Stela.Node node, TextSelection selection, SelectionChangedCause cause) {
    // We return early if the selection is not valid. This can happen when the
    // text of [EditableText] is updated at the same time as the selection is
    // changed by a gesture event.
    // if (!widget.controller.isSelectionWithinTextBounds(selection)) {
    //   return;
    // }

    // widget.controller.selection = selection;

    // // This will show the keyboard for all selection changes on the
    // // EditableWidget, not just changes triggered by user gestures.
    // requestKeyboard();

    // _selectionOverlay?.hide();
    // _selectionOverlay = null;

    // if (widget.selectionControls != null) {
    //   _selectionOverlay = TextSelectionOverlay(
    //     context: context,
    //     value: _value,
    //     debugRequiredFor: widget,
    //     toolbarLayerLink: _toolbarLayerLink,
    //     startHandleLayerLink: _startHandleLayerLink,
    //     endHandleLayerLink: _endHandleLayerLink,
    //     renderObject: renderObject,
    //     selectionControls: widget.selectionControls,
    //     selectionDelegate: this,
    //     dragStartBehavior: widget.dragStartBehavior,
    //     onSelectionHandleTapped: widget.onSelectionHandleTapped,
    //   );
    //   _selectionOverlay.handlesVisible = widget.showSelectionHandles;
    //   _selectionOverlay.showHandles();
    //   if (widget.onSelectionChanged != null)
    //     widget.onSelectionChanged(selection, cause);
    // }

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
      scope: StelaEditableScope(
          onSelectionChange: _handleSelectionChange,
          onSingleTapUp: _handleSingleTapUp),
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
  // StelaEditableScope({
  //   this.onBlur,
  //   this.onCompositionEnd,
  //   this.onCompositionStart,
  //   this.onCopy,
  //   this.onCut,
  //   this.onDragOver,
  //   this.onDragStart,
  //   this.onDrop,
  //   this.onFocus,
  //   this.onKeyDown,
  //   this.onPaste,
  //   this.onSelectionChange,
  //   this.onTap,
  //   this.ignorePointer = false,
  // });

  // void Function() onBlur;
  // void Function() onCompositionEnd;
  // void Function() onCompositionStart;
  // void Function() onCopy;
  // void Function() onCut;
  // void Function() onDragOver;
  // void Function() onDragStart;
  // void Function() onDrop;
  // void Function() onFocus;
  // void Function() onKeyDown;
  // void Function() onPaste;
  // void Function() onSelectionChange;
  // void Function() onTap;

  StelaEditableScope({
    this.onTapDown,
    this.onForcePressStart,
    this.onForcePressEnd,
    this.onSingleTapUp,
    this.onSingleTapCancel,
    this.onSingleLongTapStart,
    this.onSingleLongTapMoveUpdate,
    this.onSingleLongTapEnd,
    this.onDoubleTapDown,
    this.onDragSelectionStart,
    this.onDragSelectionUpdate,
    this.onDragSelectionEnd,
    this.onSelectionChange,
    this.ignorePointer = false,
  });

  void Function() onTapDown;
  void Function() onForcePressStart;
  void Function() onForcePressEnd;
  void Function(Stela.Node node, TapUpDetails details) onSingleTapUp;
  void Function() onSingleTapCancel;
  void Function() onSingleLongTapStart;
  void Function() onSingleLongTapMoveUpdate;
  void Function() onSingleLongTapEnd;
  void Function() onDoubleTapDown;
  void Function() onDragSelectionStart;
  void Function() onDragSelectionUpdate;
  void Function() onDragSelectionEnd;
  void Function(
          Stela.Node node, TextSelection selection, SelectionChangedCause cause)
      onSelectionChange;
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
