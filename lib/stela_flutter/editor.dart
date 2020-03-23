import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:inday/stela/stela.dart' as Stela;
import 'package:inday/stela_flutter/children.dart';
import 'package:inday/stela_flutter/editor.dart';
import 'package:inday/stela_flutter/element.dart';
import 'package:inday/stela_flutter/children.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:inday/stela_flutter/element.dart';
import 'package:inday/stela_flutter/selection.dart';
import 'package:inday/stela_flutter/rich_text.dart' as KRichText;

Map<Stela.Node, int> nodeToIndex = Map();
Map<Stela.Node, Stela.Ancestor> nodeToParent = Map();

class EditorEditingValue {
  EditorEditingValue(
      {List<Stela.Node> children,
      Stela.Range selection,
      List<Stela.Operation> operations,
      Map<String, dynamic> marks,
      Map<String, dynamic> props})
      : _editor = Stela.Editor(
            children: children,
            selection: selection,
            operations: operations,
            marks: marks,
            props: props);

  Stela.Editor _editor;

  Stela.Editor get editor => _editor;
  List<Stela.Node> get children => _editor.children;
  Stela.Range get selection => _editor.selection;
  List<Stela.Operation> get operations => _editor.operations;
  Map<String, dynamic> get marks => _editor.marks;
  Map<String, dynamic> get props => _editor.props;

  static EditorEditingValue empty = EditorEditingValue(children: []);

  factory EditorEditingValue.fromJSON(Map<String, dynamic> encoded) {
    return EditorEditingValue(
      children: encoded['children'] as List<Stela.Node>,
    );
  }

  /// Returns a representation of this object as a JSON object.
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'children': _editor.children,
    };
  }

  EditorEditingValue copyWith(
      {List<Stela.Node> children,
      Stela.Range selection,
      List<Stela.Operation> operations,
      Map<String, dynamic> marks,
      Map<String, dynamic> props}) {
    return EditorEditingValue(
      props: props ?? _editor.props,
      children: children ?? _editor.children,
      selection: selection ?? _editor.selection,
      operations: operations ?? _editor.operations,
      marks: marks ?? _editor.marks,
    );
  }
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
  Stela.Editor get editor => value.editor;

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

// The time it takes for the cursor to fade from fully opaque to fully
// transparent and vice versa. A full cursor blink, from transparent to opaque
// to transparent, is twice this duration.
const Duration _kCursorBlinkHalfPeriod = Duration(milliseconds: 500);

// The time the cursor is static in opacity before animating to become
// transparent.
const Duration _kCursorBlinkWaitForStart = Duration(milliseconds: 150);

class StelaEditor extends StatefulWidget {
  StelaEditor({
    Key key,
    @required this.focusNode,
    this.readOnly = false,
    this.autofocus = false,
    this.elementBuilder = defaultElementBuilder,
    this.textBuilder = defaultTextBuilder,
    this.enableInteractiveSelection = true,
    this.cursorOpacityAnimates = false,
    bool showCursor,
    this.cursorOffset,
    @required this.controller,
    @required this.cursorColor,
    @required this.selectionColor,
    @required this.backgroundCursorColor,
    this.cursorWidth = 2.0,
    this.cursorRadius,
    this.paintCursorAboveText = false,
  })  : assert(focusNode != null),
        assert(autofocus != null),
        assert(cursorColor != null),
        assert(selectionColor != null),
        assert(cursorOpacityAnimates != null),
        assert(paintCursorAboveText != null),
        assert(backgroundCursorColor != null),
        showCursor = showCursor ?? !readOnly,
        super(key: key);

  final EditorEditingController controller;
  final bool showCursor;
  final Color cursorColor;
  final Color selectionColor;
  final Color backgroundCursorColor;
  final double cursorWidth;
  final Radius cursorRadius;
  final bool autofocus;
  final bool cursorOpacityAnimates;
  final bool enableInteractiveSelection;
  final Offset cursorOffset;
  final bool paintCursorAboveText;
  final FocusNode focusNode;
  final bool readOnly;
  final Widget Function(Stela.Element element, StelaChildren children)
      elementBuilder;
  final TextSpan Function(Stela.Text text) textBuilder;

  static bool debugDeterministicCursor = false;

  @override
  _StelaEditorState createState() => _StelaEditorState();
}

class _StelaEditorState extends State<StelaEditor>
    with
        AutomaticKeepAliveClientMixin<StelaEditor>,
        TickerProviderStateMixin<StelaEditor> {
  // #region State lifecycle
  @override
  void initState() {
    super.initState();
    // #region Cursor
    _cursorBlinkOpacityController =
        AnimationController(vsync: this, duration: _fadeDuration);
    _cursorBlinkOpacityController.addListener(_onCursorColorTick);
    _cursorVisibilityNotifier.value = widget.showCursor;
    // #endregion

    // #region Focus
    _focusAttachment = widget.focusNode.attach(context);
    widget.focusNode.addListener(_handleFocusChanged);
    // #endregion

    // _scrollController = widget.scrollController ?? ScrollController();
    // _scrollController.addListener(() { _selectionOverlay?.updateForScroll(); });
    // _floatingCursorResetController = AnimationController(vsync: this);
    // _floatingCursorResetController.addListener(_onFloatingCursorResetTick);
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
    // if (scope.controller != oldWidget.controller) {
    //   oldWidget.controller.removeListener(_didChangeTextEditingValue);
    //   scope.controller.addListener(_didChangeTextEditingValue);
    //   _updateRemoteEditingValueIfNeeded();
    // }
    // if (widget.controller.selection != oldWidget.controller.selection) {
    //   _selectionOverlay?.update(_value);
    // }
    // _selectionOverlay?.handlesVisible = widget.showSelectionHandles;
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode.removeListener(_handleFocusChanged);
      _focusAttachment?.detach();
      _focusAttachment = widget.focusNode.attach(context);
      widget.focusNode.addListener(_handleFocusChanged);
      updateKeepAlive();
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
    // #region Cursor
    _cursorBlinkOpacityController.removeListener(_onCursorColorTick);
    // #endregion

    // widget.controller.removeListener(_didChangeTextEditingValue);
    // _floatingCursorResetController.removeListener(_onFloatingCursorResetTick);
    // _closeInputConnectionIfNeeded();
    // assert(!_hasInputConnection);
    // _stopCursorTimer();
    assert(_cursorTimer == null);
    // _selectionOverlay?.dispose();
    // _selectionOverlay = null;
    _focusAttachment.detach();
    widget.focusNode.removeListener(_handleFocusChanged);
    super.dispose();
  }

  // #endregion

  // #region AutomaticKeepAliveClientMixin
  @override
  bool get wantKeepAlive => _hasFocus;
  // #endregion

  @override
  void hideToolbar() {
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
  FocusAttachment _focusAttachment;
  bool _didAutoFocus = false;

  bool get _hasFocus => widget.focusNode.hasFocus;

  void _handleTapUp(Stela.Node node, TapUpDetails details) {
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
  }

  void requestKeyboard() {
    if (widget.focusNode.hasFocus) {
      // _openInputConnection();
    } else {
      widget.focusNode.requestFocus();
    }
  }

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
    updateKeepAlive();
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

  Color _cursorColor;

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
    // TODO: Perf. change the cursor color directly in the render object
    // renderEditable.cursorColor = widget.cursorColor.withOpacity(_cursorBlinkOpacityController.value);
    setState(() {
      _cursorColor =
          widget.cursorColor.withOpacity(_cursorBlinkOpacityController.value);
      _cursorVisibilityNotifier.value =
          widget.showCursor && _cursorBlinkOpacityController.value > 0;
    });
  }

  void _cursorTick(Timer timer) {
    _targetCursorVisibility = !_targetCursorVisibility;
    final double targetOpacity = _targetCursorVisibility ? 1.0 : 0.0;

    if (widget.cursorOpacityAnimates) {
      _cursorBlinkOpacityController.animateTo(targetOpacity,
          curve: Curves.easeOut);
    } else {
      _cursorBlinkOpacityController.value = targetOpacity;
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
    if (EditableText.debugDeterministicCursor) {
      return;
    }

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
    if (EditableText.debugDeterministicCursor) {
      return;
    }
    if (widget.cursorOpacityAnimates) {
      _cursorBlinkOpacityController.stop();
      _cursorBlinkOpacityController.value = 0.0;
    }
  }

  void _startOrStopCursorTimerIfNeeded() {
    Stela.Range selection = widget.controller.selection;

    if (_cursorTimer == null && _hasFocus && selection.isCollapsed) {
      _startCursorTimer();
    } else if (_cursorTimer != null && (!_hasFocus || !selection.isCollapsed)) {
      _stopCursorTimer();
    }
  }
  // #endregion

  // #region Selection
  /// {@macro flutter.rendering.editable.selectionEnabled}
  bool get selectionEnabled => widget.enableInteractiveSelection;
  // #endregion

  // #region Gestures
  /// {@macro flutter.rendering.editable.selectionEnabled}
  bool forcePressEnabled;
  // #endregion

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

  _handleSelectionChange(Stela.NodeEntry entry, TextSelection selection,
      SelectionChangedCause cause) {
    // We return early if the selection is not valid. This can happen when the
    // text of [EditableText] is updated at the same time as the selection is
    // changed by a gesture event.
    // if (!widget.controller.isSelectionWithinTextBounds(selection)) {
    //   return;
    // }
    if (selection.isCollapsed) {
      Stela.Point p = Stela.Point(entry.path, selection.baseOffset);
      widget.controller.selection = Stela.Range(p, p);
    } else {
      Stela.Point a = Stela.Point(entry.path, selection.baseOffset);
      Stela.Point f = Stela.Point(entry.path, selection.extentOffset);
      widget.controller.selection = Stela.Range(a, f);
    }

    // This will show the keyboard for all selection changes on the
    // EditableWidget, not just changes triggered by user gestures.
    requestKeyboard();

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

  // #region Stela functions
  Stela.Path findPath(Stela.Node node) {
    Stela.Path path = Stela.Path([]);
    Stela.Node child = node;

    while (true) {
      Stela.Node parent = nodeToParent[child];

      if (parent == null) {
        if (child is Stela.Editor) {
          return path;
        } else {
          break;
        }
      }

      int i = nodeToIndex[child];

      if (i == null) {
        break;
      }

      path.prepend(i);
      child = parent;
    }

    throw Exception("Unable to find the path for node: ${node.toString()}");
  }
  // #endregion

  @override
  Widget build(BuildContext context) {
    _focusAttachment.reparent();
    super.build(context); // See AutomaticKeepAliveClientMixin.
    ThemeData themeData = Theme.of(context);

    TextSelectionControls textSelectionControls;
    bool paintCursorAboveText;
    bool cursorOpacityAnimates;
    Offset cursorOffset;
    Color cursorColor = widget.cursorColor;
    Radius cursorRadius = widget.cursorRadius;

    switch (themeData.platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        forcePressEnabled = true;
        textSelectionControls = cupertinoTextSelectionControls;
        paintCursorAboveText = true;
        cursorOpacityAnimates = true;
        cursorColor ??= CupertinoTheme.of(context).primaryColor;
        cursorRadius ??= const Radius.circular(2.0);
        cursorOffset = Offset(
            iOSHorizontalOffset / MediaQuery.of(context).devicePixelRatio, 0);
        break;

      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        forcePressEnabled = false;
        textSelectionControls = materialTextSelectionControls;
        paintCursorAboveText = false;
        cursorOpacityAnimates = false;
        cursorColor ??= themeData.cursorColor;
        break;
    }

    return StelaEditorProvider(
      scope: StelaEditorScope(
          controller: widget.controller,
          onSelectionChange: _handleSelectionChange,
          onTapUp: _handleTapUp,
          focusNode: widget.focusNode,
          showCursor: StelaEditor.debugDeterministicCursor
              ? ValueNotifier<bool>(widget.showCursor)
              : _cursorVisibilityNotifier,
          cursorColor: _cursorColor ?? widget.cursorColor,
          selectionColor: widget.selectionColor,
          backgroundCursorColor: widget.backgroundCursorColor,
          forcePressEnabled: forcePressEnabled,
          selectionEnabled: selectionEnabled,
          cursorWidth: widget.cursorWidth,
          hasFocus: _hasFocus,
          findPath: findPath,
          cursorRadius: widget.cursorRadius),
      child: StelaChildren(
        node: widget.controller.editor,
        elementBuilder: widget.elementBuilder,
        textBuilder: widget.textBuilder,
        selection: widget.controller.value.selection,
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

class StelaEditorScope {
  // StelaEditorScope({
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

  StelaEditorScope({
    this.onTapDown,
    this.onForcePressStart,
    this.controller,
    this.onForcePressEnd,
    this.onTapUp,
    this.onSingleTapCancel,
    this.onSingleLongTapStart,
    this.onSingleLongTapMoveUpdate,
    this.onSingleLongTapEnd,
    this.onDoubleTapDown,
    this.onDragSelectionStart,
    this.onDragSelectionUpdate,
    this.onDragSelectionEnd,
    this.findPath,
    this.onSelectionChange,
    this.ignorePointer = false,
    @required this.focusNode,
    this.showCursor,
    this.cursorColor,
    this.selectionColor,
    this.hasFocus,
    this.backgroundCursorColor,
    this.forcePressEnabled,
    this.selectionEnabled,
    this.cursorWidth,
    this.cursorRadius,
  });

  final EditorEditingController controller;
  void Function() onTapDown;
  void Function() onForcePressStart;
  void Function() onForcePressEnd;
  void Function(Stela.Node node, TapUpDetails details) onTapUp;
  void Function() onSingleTapCancel;
  void Function() onSingleLongTapStart;
  void Function() onSingleLongTapMoveUpdate;
  void Function() onSingleLongTapEnd;
  void Function() onDoubleTapDown;
  void Function() onDragSelectionStart;
  void Function() onDragSelectionUpdate;
  void Function() onDragSelectionEnd;
  Stela.Path Function(Stela.Node) findPath;
  void Function(Stela.NodeEntry entry, TextSelection selection,
      SelectionChangedCause cause) onSelectionChange;
  bool ignorePointer;

  FocusNode focusNode;
  ValueNotifier<bool> showCursor;
  Color cursorColor;
  Color selectionColor;
  bool hasFocus;
  bool forcePressEnabled;
  bool selectionEnabled;
  Color backgroundCursorColor;
  double cursorWidth;
  Radius cursorRadius;

  static StelaEditorScope of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<StelaEditorProvider>()
        .scope;
  }
}

class StelaEditorProvider extends InheritedWidget {
  final StelaEditorScope scope;

  StelaEditorProvider({
    Key key,
    @required this.scope,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(StelaEditorProvider old) => true;
}
