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
  /// Whether to show the selection toolbar.
  ///
  /// It is based on the signal source when a [onTapDown] is called. This getter
  /// will return true if current [onTapDown] event is triggered by a touch or
  /// a stylus.
  bool get shouldShowSelectionToolbar => _shouldShowSelectionToolbar;
  bool _shouldShowSelectionToolbar = true;

  /// Handler for [TextSelectionGestureDetector.onTapDown].
  ///
  /// By default, it forwards the tap to [RenderEditable.handleTapDown] and sets
  /// [shouldShowSelectionToolbar] to true if the tap was initiated by a finger or stylus.
  ///
  /// See also:
  ///
  ///  * [TextSelectionGestureDetector.onTapDown], which triggers this callback.
  @protected
  void onTapDown(TapDownDetails details) {
    // renderEditable.handleTapDown(details);
    // The selection overlay should only be shown when the user is interacting
    // through a touch screen (via either a finger or a stylus). A mouse shouldn't
    // trigger the selection overlay.
    // For backwards-compatibility, we treat a null kind the same as touch.
    final PointerDeviceKind kind = details.kind;
    _shouldShowSelectionToolbar = kind == null ||
        kind == PointerDeviceKind.touch ||
        kind == PointerDeviceKind.stylus;
  }

  /// Handler for [TextSelectionGestureDetector.onForcePressStart].
  ///
  /// By default, it selects the word at the position of the force press,
  /// if selection is enabled.
  ///
  /// This callback is only applicable when force press is enabled.
  ///
  /// See also:
  ///
  ///  * [TextSelectionGestureDetector.onForcePressStart], which triggers this
  ///    callback.
  @protected
  void onForcePressStart(ForcePressDetails details) {
    StelaScope scope = StelaScope.of(context);
    assert(scope.forcePressEnabled);
    _shouldShowSelectionToolbar = true;
    if (scope.selectionEnabled) {
      // renderEditable.selectWordsInRange(
      //   from: details.globalPosition,
      //   cause: SelectionChangedCause.forcePress,
      // );
    }
  }

  /// Handler for [TextSelectionGestureDetector.onForcePressEnd].
  ///
  /// By default, it selects words in the range specified in [details] and shows
  /// toolbar if it is necessary.
  ///
  /// This callback is only applicable when force press is enabled.
  ///
  /// See also:
  ///
  ///  * [TextSelectionGestureDetector.onForcePressEnd], which triggers this
  ///    callback.
  @protected
  void onForcePressEnd(ForcePressDetails details) {
    StelaScope scope = StelaScope.of(context);
    assert(scope.forcePressEnabled);
    // renderEditable.selectWordsInRange(
    //   from: details.globalPosition,
    //   cause: SelectionChangedCause.forcePress,
    // );
    if (shouldShowSelectionToolbar) {
      // editableText.showToolbar();
    }
  }

  /// Handler for [TextSelectionGestureDetector.onSingleTapUp].
  ///
  /// By default, it selects word edge if selection is enabled.
  ///
  /// See also:
  ///
  ///  * [TextSelectionGestureDetector.onSingleTapUp], which triggers
  ///    this callback.
  @protected
  void onSingleTapUp(TapUpDetails details) {
    StelaScope scope = StelaScope.of(context);
    if (scope.selectionEnabled) {
      // renderEditable.selectWordEdge(cause: SelectionChangedCause.tap);
    }
  }

  /// Handler for [TextSelectionGestureDetector.onSingleTapCancel].
  ///
  /// By default, it services as place holder to enable subclass override.
  ///
  /// See also:
  ///
  ///  * [TextSelectionGestureDetector.onSingleTapCancel], which triggers
  ///    this callback.
  @protected
  void onSingleTapCancel() {
    /* Subclass should override this method if needed. */
  }

  /// Handler for [TextSelectionGestureDetector.onSingleLongTapStart].
  ///
  /// By default, it selects text position specified in [details] if selection
  /// is enabled.
  ///
  /// See also:
  ///
  ///  * [TextSelectionGestureDetector.onSingleLongTapStart], which triggers
  ///    this callback.
  @protected
  void onSingleLongTapStart(LongPressStartDetails details) {
    StelaScope scope = StelaScope.of(context);
    if (scope.selectionEnabled) {
      // renderEditable.selectPositionAt(
      //   from: details.globalPosition,
      //   cause: SelectionChangedCause.longPress,
      // );
    }
  }

  /// Handler for [TextSelectionGestureDetector.onSingleLongTapMoveUpdate].
  ///
  /// By default, it updates the selection location specified in [details] if
  /// selection is enabled.
  ///
  /// See also:
  ///
  ///  * [TextSelectionGestureDetector.onSingleLongTapMoveUpdate], which
  ///    triggers this callback.
  @protected
  void onSingleLongTapMoveUpdate(LongPressMoveUpdateDetails details) {
    StelaScope scope = StelaScope.of(context);
    if (scope.selectionEnabled) {
      // renderEditable.selectPositionAt(
      //   from: details.globalPosition,
      //   cause: SelectionChangedCause.longPress,
      // );
    }
  }

  /// Handler for [TextSelectionGestureDetector.onSingleLongTapEnd].
  ///
  /// By default, it shows toolbar if necessary.
  ///
  /// See also:
  ///
  ///  * [TextSelectionGestureDetector.onSingleLongTapEnd], which triggers this
  ///    callback.
  @protected
  void onSingleLongTapEnd(LongPressEndDetails details) {
    // if (shouldShowSelectionToolbar) {
    //   editableText.showToolbar();
    // }
  }

  /// Handler for [TextSelectionGestureDetector.onDoubleTapDown].
  ///
  /// By default, it selects a word through [renderEditable.selectWord] if
  /// selectionEnabled and shows toolbar if necessary.
  ///
  /// See also:
  ///
  ///  * [TextSelectionGestureDetector.onDoubleTapDown], which triggers this
  ///    callback.
  @protected
  void onDoubleTapDown(TapDownDetails details) {
    StelaScope scope = StelaScope.of(context);
    // if (scope.selectionEnabled) {
    //   renderEditable.selectWord(cause: SelectionChangedCause.tap);
    //   if (shouldShowSelectionToolbar)
    //     editableText.showToolbar();
    // }
  }

  /// Handler for [TextSelectionGestureDetector.onDragSelectionStart].
  ///
  /// By default, it selects a text position specified in [details].
  ///
  /// See also:
  ///
  ///  * [TextSelectionGestureDetector.onDragSelectionStart], which triggers
  ///    this callback.
  @protected
  void onDragSelectionStart(DragStartDetails details) {
    // renderEditable.selectPositionAt(
    //   from: details.globalPosition,
    //   cause: SelectionChangedCause.drag,
    // );
  }

  /// Handler for [TextSelectionGestureDetector.onDragSelectionUpdate].
  ///
  /// By default, it updates the selection location specified in [details].
  ///
  /// See also:
  ///
  ///  * [TextSelectionGestureDetector.onDragSelectionUpdate], which triggers
  ///    this callback./lib/src/material/text_field.dart
  @protected
  void onDragSelectionUpdate(
      DragStartDetails startDetails, DragUpdateDetails updateDetails) {
    // renderEditable.selectPositionAt(
    //   from: startDetails.globalPosition,
    //   to: updateDetails.globalPosition,
    //   cause: SelectionChangedCause.drag,
    // );
  }

  @protected
  void onDragSelectionEnd(DragEndDetails details) {
    /* Subclass should override this method if needed. */
  }

  @override
  Widget build(BuildContext context) {
    StelaScope scope = StelaScope.of(context);

    return TextSelectionGestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: onTapDown,
      onForcePressStart: scope.forcePressEnabled ? onForcePressStart : null,
      onForcePressEnd: scope.forcePressEnabled ? onForcePressEnd : null,
      onSingleTapUp: onSingleTapUp,
      onSingleTapCancel: onSingleTapCancel,
      onSingleLongTapStart: onSingleLongTapStart,
      onSingleLongTapMoveUpdate: onSingleLongTapMoveUpdate,
      onSingleLongTapEnd: onSingleLongTapEnd,
      onDoubleTapDown: onDoubleTapDown,
      onDragSelectionStart: onDragSelectionStart,
      onDragSelectionUpdate: onDragSelectionUpdate,
      onDragSelectionEnd: onDragSelectionEnd,
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
