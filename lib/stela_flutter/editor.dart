import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:inday/stela/stela.dart' as Stela;
import 'package:inday/stela_flutter/children.dart';
import 'package:inday/stela_flutter/element.dart';
import 'package:inday/stela_flutter/selection.dart';

// The time it takes for the cursor to fade from fully opaque to fully
// transparent and vice versa. A full cursor blink, from transparent to opaque
// to transparent, is twice this duration.
const Duration _kCursorBlinkHalfPeriod = Duration(milliseconds: 500);

// The time the cursor is static in opacity before animating to become
// transparent.
const Duration _kCursorBlinkWaitForStart = Duration(milliseconds: 150);

// Number of cursor ticks during which the most recently entered character
// is shown in an obscured text field.
const int _kObscureShowLatestCharCursorTicks = 3;

/// Signature for the callback that reports when the user changes the selection
/// (including the cursor location).
typedef SelectionChangedCallback = void Function(
    TextSelection selection, SelectionChangedCause cause);

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
    this.autofocus = false,
    bool showCursor,
    @required this.cursorColor,
    @required this.backgroundCursorColor,
    this.cursorWidth = 2.0,
    this.cursorRadius,
    this.children,
    this.cursorOpacityAnimates = false,
    this.cursorOffset,
    this.paintCursorAboveText = false,
  })  : assert(controller != null),
        assert(focusNode != null),
        assert(children != null),
        assert(autofocus != null),
        assert(cursorColor != null),
        assert(cursorOpacityAnimates != null),
        assert(paintCursorAboveText != null),
        assert(backgroundCursorColor != null),
        showCursor = showCursor ?? !readOnly,
        super(key: key);

  final List<Widget> children;
  final bool showCursor;
  final Color cursorColor;
  final Color backgroundCursorColor;
  final double cursorWidth;
  final Radius cursorRadius;
  final bool autofocus;
  final bool cursorOpacityAnimates;

  ///{@macro flutter.rendering.editable.cursorOffset}
  final Offset cursorOffset;

  ///{@macro flutter.rendering.editable.paintCursorOnTop}
  final bool paintCursorAboveText;

  final EditorEditingController controller;

  final FocusNode focusNode;

  final bool readOnly;

  @override
  StelaEditorState createState() => StelaEditorState();
}

class StelaEditorState extends State<StelaEditor>
    with TickerProviderStateMixin<StelaEditor>
    implements EditorSelectionDelegate {
  // #region Scope
  StelaScope _scope;
  // #endregion

  // #region State lifecycle
  @override
  void initState() {
    super.initState();
    // widget.controller.addListener(_didChangeTextEditingValue);
    // _focusAttachment = widget.focusNode.attach(context);
    widget.focusNode.addListener(_handleFocusChanged);
    // _scrollController = widget.scrollController ?? ScrollController();
    // _scrollController.addListener(() { _selectionOverlay?.updateForScroll(); });
    // _floatingCursorResetController = AnimationController(vsync: this);
    // _floatingCursorResetController.addListener(_onFloatingCursorResetTick);

    // Cursor blink
    _cursorBlinkOpacityController =
        AnimationController(vsync: this, duration: _fadeDuration);
    _cursorBlinkOpacityController.addListener(_onCursorColorTick);
    _cursorVisibilityNotifier.value = widget.showCursor;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didAutoFocus && widget.autofocus) {
      _didAutoFocus = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          FocusScope.of(context).autofocus(widget.focusNode);
        }
      });
    }
  }

  @override
  void didUpdateWidget(StelaEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // if (widget.controller != oldWidget.controller) {
    //   oldWidget.controller.removeListener(_didChangeTextEditingValue);
    //   widget.controller.addListener(_didChangeTextEditingValue);
    //   _updateRemoteEditingValueIfNeeded();
    // }
    // if (widget.controller.selection != oldWidget.controller.selection) {
    //   _selectionOverlay?.update(_value);
    // }
    // _selectionOverlay?.handlesVisible = widget.showSelectionHandles;
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode.removeListener(_handleFocusChanged);
      // _focusAttachment?.detach();
      // _focusAttachment = widget.focusNode.attach(context);
      widget.focusNode.addListener(_handleFocusChanged);
      // updateKeepAlive();
    }
    // if (widget.readOnly) {
    //   _closeInputConnectionIfNeeded();
    // } else {
    //   if (oldWidget.readOnly && _hasFocus)
    //     _openInputConnection();
    // }
    // if (widget.style != oldWidget.style) {
    //   final TextStyle style = widget.style;
    //   // The _textInputConnection will pick up the new style when it attaches in
    //   // _openInputConnection.
    //   if (_textInputConnection != null && _textInputConnection.attached) {
    //     _textInputConnection.setStyle(
    //       fontFamily: style.fontFamily,
    //       fontSize: style.fontSize,
    //       fontWeight: style.fontWeight,
    //       textDirection: _textDirection,
    //       textAlign: widget.textAlign,
    //     );
    //   }
    // }
  }

  @override
  void dispose() {
    // widget.controller.removeListener(_didChangeTextEditingValue);
    _cursorBlinkOpacityController.removeListener(_onCursorColorTick);
    // _floatingCursorResetController.removeListener(_onFloatingCursorResetTick);
    // _closeInputConnectionIfNeeded();
    // assert(!_hasInputConnection);
    // _stopCursorTimer();
    assert(_cursorTimer == null);
    // _selectionOverlay?.dispose();
    // _selectionOverlay = null;
    // _focusAttachment.detach();
    widget.focusNode.removeListener(_handleFocusChanged);
    super.dispose();
  }

  // #endregion

  // #region EditorSelectionDelegate

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

  // #endregion

  // #region Focus
  bool _didAutoFocus = false;

  bool get _hasFocus => widget.focusNode.hasFocus;

  void _handleFocusChanged() {
    // _openOrCloseInputConnectionIfNeeded();
    _startOrStopCursorTimerIfNeeded();
    // _updateOrDisposeSelectionOverlayIfNeeded();
    if (_hasFocus) {
      // Listen for changing viewInsets, which indicates keyboard showing up.
      // WidgetsBinding.instance.addObserver(this);
      // _lastBottomViewInset = WidgetsBinding.instance.window.viewInsets.bottom;
      // _showCaretOnScreen();
      // if (!_value.selection.isValid) {
      //   // Place cursor at the end if the selection is invalid when we receive focus.
      //   _handleSelectionChanged(TextSelection.collapsed(offset: _value.text.length), renderEditable, null);
      // }
    } else {
      // WidgetsBinding.instance.removeObserver(this);
      // Clear the selection and composition state if this widget lost focus.
      // _value = TextEditingValue(text: _value.text);
    }
    // updateKeepAlive();
  }
  // #endregion

  // #region Cursor
  Timer _cursorTimer;
  bool _targetCursorVisibility = false;
  AnimationController _cursorBlinkOpacityController;
  final ValueNotifier<bool> _cursorVisibilityNotifier =
      ValueNotifier<bool>(true);

  // This value is an eyeball estimation of the time it takes for the iOS cursor
  // to ease in and out.
  static const Duration _fadeDuration = Duration(milliseconds: 250);

  Color get _cursorColor =>
      widget.cursorColor.withOpacity(_cursorBlinkOpacityController.value);

  /// Whether the blinking cursor is actually visible at this precise moment
  /// (it's hidden half the time, since it blinks).
  @visibleForTesting
  bool get cursorCurrentlyVisible => _cursorBlinkOpacityController.value > 0;

  /// The cursor blink interval (the amount of time the cursor is in the "on"
  /// state or the "off" state). A complete cursor blink period is twice this
  /// value (half on, half off).
  @visibleForTesting
  Duration get cursorBlinkInterval => _kCursorBlinkHalfPeriod;

  void _onCursorColorTick() {
    // renderEditable.cursorColor = widget.cursorColor.withOpacity(_cursorBlinkOpacityController.value);
    _cursorVisibilityNotifier.value =
        widget.showCursor && _cursorBlinkOpacityController.value > 0;
  }

  int _obscureShowCharTicksPending = 0;
  int _obscureLatestCharIndex;

  void _cursorTick(Timer timer) {
    _targetCursorVisibility = !_targetCursorVisibility;
    final double targetOpacity = _targetCursorVisibility ? 1.0 : 0.0;
    if (widget.cursorOpacityAnimates) {
      // If we want to show the cursor, we will animate the opacity to the value
      // of 1.0, and likewise if we want to make it disappear, to 0.0. An easing
      // curve is used for the animation to mimic the aesthetics of the native
      // iOS cursor.
      //
      // These values and curves have been obtained through eyeballing, so are
      // likely not exactly the same as the values for native iOS.
      _cursorBlinkOpacityController.animateTo(targetOpacity,
          curve: Curves.easeOut);
    } else {
      _cursorBlinkOpacityController.value = targetOpacity;
    }

    if (_obscureShowCharTicksPending > 0) {
      setState(() {
        _obscureShowCharTicksPending--;
      });
    }
  }

  void _cursorWaitForStart(Timer timer) {
    assert(_kCursorBlinkHalfPeriod > _fadeDuration);
    _cursorTimer?.cancel();
    _cursorTimer = Timer.periodic(_kCursorBlinkHalfPeriod, _cursorTick);
  }

  void _startCursorTimer() {
    _targetCursorVisibility = true;
    _cursorBlinkOpacityController.value = 1.0;
    if (EditableText.debugDeterministicCursor) return;
    if (widget.cursorOpacityAnimates) {
      _cursorTimer =
          Timer.periodic(_kCursorBlinkWaitForStart, _cursorWaitForStart);
    } else {
      _cursorTimer = Timer.periodic(_kCursorBlinkHalfPeriod, _cursorTick);
    }
  }

  void _stopCursorTimer({bool resetCharTicks = true}) {
    _cursorTimer?.cancel();
    _cursorTimer = null;
    _targetCursorVisibility = false;
    _cursorBlinkOpacityController.value = 0.0;
    if (EditableText.debugDeterministicCursor) return;
    if (resetCharTicks) _obscureShowCharTicksPending = 0;
    if (widget.cursorOpacityAnimates) {
      _cursorBlinkOpacityController.stop();
      _cursorBlinkOpacityController.value = 0.0;
    }
  }

  void _startOrStopCursorTimerIfNeeded() {
    if (_cursorTimer == null &&
        _hasFocus &&
        Stela.RangeUtils.isCollapsed(_value.selection))
      _startCursorTimer();
    else if (_cursorTimer != null &&
        (!_hasFocus || !Stela.RangeUtils.isCollapsed(_value.selection)))
      _stopCursorTimer();
  }

  // #endregion

  @override
  Widget build(BuildContext context) {
    return StelaScopeProvider(
      scope: StelaScope(
          controller: widget.controller, focusNode: widget.focusNode),
      child: ListBody(
        children: widget.children,
      ),
    );
  }
}

class StelaScope extends ChangeNotifier {
  StelaScope({
    @required EditorEditingController controller,
    @required FocusNode focusNode,
  })  : assert(controller != null),
        assert(focusNode != null),
        _controller = controller,
        _focusNode = focusNode;

  EditorEditingController _controller;
  EditorEditingController get controller => _controller;
  set controller(EditorEditingController value) {
    if (_controller != value) {
      _controller = value;
    }
  }

  FocusNode _focusNode;
  FocusNode get focusNode => _focusNode;
  set focusNode(FocusNode value) {
    if (_focusNode != value) {
      _focusNode = value;
    }
  }

  static StelaScope of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<StelaScopeProvider>()
        .scope;
  }
}

class StelaScopeProvider extends InheritedWidget {
  final StelaScope scope;

  StelaScopeProvider({
    Key key,
    @required this.scope,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(StelaScopeProvider old) => true;
}
