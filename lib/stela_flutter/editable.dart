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

// The time it takes for the cursor to fade from fully opaque to fully
// transparent and vice versa. A full cursor blink, from transparent to opaque
// to transparent, is twice this duration.
const Duration _kCursorBlinkHalfPeriod = Duration(milliseconds: 500);

// The time the cursor is static in opacity before animating to become
// transparent.
const Duration _kCursorBlinkWaitForStart = Duration(milliseconds: 150);

class StelaEditable extends StatefulWidget {
  StelaEditable({
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
    @required this.cursorColor,
    @required this.backgroundCursorColor,
    this.cursorWidth = 2.0,
    this.cursorRadius,
    this.paintCursorAboveText = false,
  })  : assert(focusNode != null),
        assert(autofocus != null),
        assert(cursorColor != null),
        assert(cursorOpacityAnimates != null),
        assert(paintCursorAboveText != null),
        assert(backgroundCursorColor != null),
        showCursor = showCursor ?? !readOnly,
        super(key: key);

  final bool showCursor;
  final Color cursorColor;
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
  _StelaEditableState createState() => _StelaEditableState();
}

class _StelaEditableState extends State<StelaEditable>
    with
        AutomaticKeepAliveClientMixin<StelaEditable>,
        TickerProviderStateMixin<StelaEditable> {
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
  void didUpdateWidget(StelaEditable oldWidget) {
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
    StelaEditorScope scope = StelaEditorScope.of(context);
    Stela.Range selection = scope.controller.selection;

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
    StelaEditorScope scope = StelaEditorScope.of(context);

    // We return early if the selection is not valid. This can happen when the
    // text of [EditableText] is updated at the same time as the selection is
    // changed by a gesture event.
    // if (!widget.controller.isSelectionWithinTextBounds(selection)) {
    //   return;
    // }
    if (selection.isCollapsed) {
      Stela.Point p = Stela.Point(entry.path, selection.baseOffset);
      scope.controller.selection = Stela.Range(p, p);
    } else {
      Stela.Point a = Stela.Point(entry.path, selection.baseOffset);
      Stela.Point f = Stela.Point(entry.path, selection.extentOffset);
      scope.controller.selection = Stela.Range(a, f);
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

  @override
  Widget build(BuildContext context) {
    _focusAttachment.reparent();
    super.build(context); // See AutomaticKeepAliveClientMixin.
    StelaEditorScope scope = StelaEditorScope.of(context);
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

    return StelaEditableProvider(
      scope: StelaEditableScope(
          onSelectionChange: _handleSelectionChange,
          onTapUp: _handleTapUp,
          focusNode: widget.focusNode,
          showCursor: StelaEditable.debugDeterministicCursor
              ? ValueNotifier<bool>(widget.showCursor)
              : _cursorVisibilityNotifier,
          cursorColor: _cursorColor ?? widget.cursorColor,
          backgroundCursorColor: widget.backgroundCursorColor,
          forcePressEnabled: forcePressEnabled,
          selectionEnabled: selectionEnabled,
          cursorWidth: widget.cursorWidth,
          hasFocus: _hasFocus,
          cursorRadius: widget.cursorRadius),
      child: StelaChildren(
        node: scope.controller.editor,
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
    this.onTapUp,
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
    @required this.focusNode,
    this.showCursor,
    this.cursorColor,
    this.hasFocus,
    this.backgroundCursorColor,
    this.forcePressEnabled,
    this.selectionEnabled,
    this.cursorWidth,
    this.cursorRadius,
  });

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
  void Function(Stela.NodeEntry entry, TextSelection selection,
      SelectionChangedCause cause) onSelectionChange;
  bool ignorePointer;

  FocusNode focusNode;
  ValueNotifier<bool> showCursor;
  Color cursorColor;
  bool hasFocus;
  bool forcePressEnabled;
  bool selectionEnabled;
  Color backgroundCursorColor;
  double cursorWidth;
  Radius cursorRadius;

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
