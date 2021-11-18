import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:inday/stela/stela.dart' as Stela;
import 'package:inday/stela_flutter/bulleted_list.dart';
import 'package:flutter/scheduler.dart';
import 'package:inday/stela_flutter/image.dart';
import 'package:inday/stela_flutter/link.dart';
import 'package:inday/stela_flutter/list_item.dart';
import 'package:inday/stela_flutter/mention.dart';
import 'package:inday/stela_flutter/node.dart';
import 'package:inday/stela_flutter/paragraph.dart';
import 'package:inday/stela_flutter/rich.dart';
import 'package:inday/stela_flutter/selection.dart';

Map<Stela.Node, int> nodeToIndex = Map();
Map<Stela.Node, Stela.Ancestor> nodeToParent = Map();

class TextNodeEntry {
  TextNodeEntry({
    this.position,
    this.length,
    this.path,
    this.node,
  });
  TextPosition position;
  int length;
  Stela.Path path;
  Stela.Text node;
}

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

  get isNotEmpty {
    return _editor.children.isNotEmpty;
  }

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

typedef ElementBuilder = Widget Function(Stela.Element, List<Widget>);

class NodeWidgetEntry {
  NodeWidgetEntry({this.key, this.node});

  final GlobalKey key;
  final Stela.Node node;
}

class StelaEditor extends StatefulWidget {
  StelaEditor({
    Key key,
    @required this.focusNode,
    this.readOnly = false,
    this.autofocus = false,
    this.textBuilder = defaultTextBuilder,
    this.elementBuilder = defaultElementBuilder,
    this.enableInteractiveSelection = true,
    this.cursorOpacityAnimates = false,
    bool showCursor,
    this.cursorOffset,
    this.dragStartBehavior = DragStartBehavior.start,
    @required this.controller,
    @required this.cursorColor,
    @required this.selectionColor,
    @required this.backgroundCursorColor,
    this.cursorWidth = 2.0,
    this.cursorRadius,
    this.textDirection = TextDirection.ltr,
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

  final TextDirection textDirection;
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
  final DragStartBehavior dragStartBehavior;
  final bool paintCursorAboveText;
  final FocusNode focusNode;
  final bool readOnly;
  final ElementBuilder elementBuilder;
  final TextSpan Function(Stela.Text, Stela.Element) textBuilder;

  static bool debugDeterministicCursor = false;

  @override
  _StelaEditorState createState() => _StelaEditorState();
}

class _StelaEditorState extends State<StelaEditor>
    with
        AutomaticKeepAliveClientMixin<StelaEditor>,
        TickerProviderStateMixin<StelaEditor> {
  EditorEditingValue get _value => widget.controller.value;
  set _value(EditorEditingValue value) {
    widget.controller.value = value;
  }

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

    // #region value
    widget.controller.addListener(_didChangeEditorEditingValue);
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
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_didChangeEditorEditingValue);
      widget.controller.addListener(_didChangeEditorEditingValue);
      // _updateRemoteEditingValueIfNeeded();
    }
    if (widget.controller.selection != oldWidget.controller.selection) {
      _selectionOverlay?.update(_value);
    }
    _selectionOverlay?.handlesVisible = _showSelectionHandles;
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

    widget.controller.removeListener(_didChangeEditorEditingValue);
    // _floatingCursorResetController.removeListener(_onFloatingCursorResetTick);
    // _closeInputConnectionIfNeeded();
    // assert(!_hasInputConnection);
    _stopCursorTimer();
    assert(_cursorTimer == null);
    _selectionOverlay?.dispose();
    _selectionOverlay = null;
    _focusAttachment.detach();
    widget.focusNode.removeListener(_handleFocusChanged);
    super.dispose();
  }

  // #endregion

  // #region AutomaticKeepAliveClientMixin
  @override
  bool get wantKeepAlive => _hasFocus;
  // #endregion

  // #region Focus
  FocusAttachment _focusAttachment;
  bool _didAutoFocus = false;

  bool get _hasFocus => widget.focusNode.hasFocus;

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
    _updateOrDisposeSelectionOverlayIfNeeded();
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
      // _value = EditorEditingValue(text: _value.text);
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
    // TODO:
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

    if (selection == null) {
      return;
    }

    if (_cursorTimer == null && _hasFocus && selection.isCollapsed) {
      _startCursorTimer();
    } else if (_cursorTimer != null && (!_hasFocus || !selection.isCollapsed)) {
      _stopCursorTimer();
    }
  }
  // #endregion

  // #region Value
  void _didChangeEditorEditingValue() {
    // TODO
    // _updateRemoteEditingValueIfNeeded();
    _startOrStopCursorTimerIfNeeded();
    _updateOrDisposeSelectionOverlayIfNeeded();
    // _textChangedSinceLastCaretUpdate = true;
    // TODO(abarth): Teach RenderEditable about ValueNotifier<EditorEditingValue>
    // to avoid this setState().
    setState(() {/* We use widget.controller.value in build(). */});
  }
  // #endregion

  // #region SelectionOverlay

  final LayerLink _toolbarLayerLink = LayerLink();
  final LayerLink _startHandleLayerLink = LayerLink();
  final LayerLink _endHandleLayerLink = LayerLink();

  /// {@macro flutter.rendering.editable.selectionEnabled}
  bool get selectionEnabled => widget.enableInteractiveSelection;

  EditorSelectionOverlay _selectionOverlay;
  bool _showSelectionHandles = false;

  void _updateOrDisposeSelectionOverlayIfNeeded() {
    if (_selectionOverlay != null) {
      if (_hasFocus) {
        _selectionOverlay.update(_value);
      } else {
        _selectionOverlay.dispose();
        _selectionOverlay = null;
      }
    }
  }

  /// Shows the selection toolbar at the location of the current cursor.
  ///
  /// Returns `false` if a toolbar couldn't be shown, such as when the toolbar
  /// is already shown, or when no text selection currently exists.
  bool showToolbar() {
    // Web is using native dom elements to enable clipboard functionality of the
    // toolbar: copy, paste, select, cut. It might also provide additional
    // functionality depending on the browser (such as translate). Due to this
    // we should not show a Flutter toolbar for the editable text elements.
    if (kIsWeb) {
      return false;
    }

    if (_selectionOverlay == null || _selectionOverlay.toolbarIsVisible) {
      return false;
    }

    // TODO
    // _selectionOverlay.showToolbar();
    return true;
  }

  @override
  void hideToolbar() {
    _selectionOverlay?.hide();
  }

  /// Toggles the visibility of the toolbar.
  void toggleToolbar() {
    assert(_selectionOverlay != null);
    if (_selectionOverlay.toolbarIsVisible) {
      hideToolbar();
    } else {
      showToolbar();
    }
  }
  // #endregion

  // #region Gestures
  /// {@macro flutter.rendering.editable.selectionEnabled}
  bool forcePressEnabled;

  TextSelectionControls _getSelectionControls() {
    final ThemeData themeData = Theme.of(context);

    switch (themeData.platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return cupertinoTextSelectionControls;

      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return materialTextSelectionControls;
    }

    return null;
  }
  // #endregion

  // TODO
  // void _requestKeyboard() {
  //   _editableText?.requestKeyboard();
  // }

  bool _shouldShowSelectionHandles(SelectionChangedCause cause) {
    // When the text field is activated by something that doesn't trigger the
    // selection overlay, we shouldn't show the handles either.
    // TODO
    // if (!_selectionGestureDetectorBuilder.shouldShowSelectionToolbar)
    //   return false;

    if (cause == SelectionChangedCause.keyboard) return false;

    if (widget.readOnly && widget.controller.selection.isCollapsed)
      return false;

    if (cause == SelectionChangedCause.longPress) return true;

    if (widget.controller.value.isNotEmpty) return true;

    return false;
  }

  void _handleSelectionChanged(TextSelection selection,
      RenderStelaRichText renderObject, SelectionChangedCause cause) {
    TextNodeEntry selected;
    int anchorOffset;
    int focusOffset;

    // TODO
    // switch (Theme.of(context).platform) {
    //   case TargetPlatform.iOS:
    //   case TargetPlatform.macOS:
    //     if (cause == SelectionChangedCause.longPress) {
    //       // _editableText?.bringIntoView(selection.base);
    //     }
    //   case TargetPlatform.android:
    //   case TargetPlatform.fuchsia:
    //   case TargetPlatform.linux:
    //   case TargetPlatform.windows:
    //   // Do nothing.
    // }

    for (int i = renderObject.textNodeEntries.length - 1; i >= 0; i--) {
      TextNodeEntry textEntry = renderObject.textNodeEntries[i];

      if (selection.baseOffset >= textEntry.position.offset) {
        selected = textEntry;

        // We need to min to handle end of text cursor
        anchorOffset = selection.baseOffset - textEntry.position.offset;
        focusOffset = selection.extentOffset - textEntry.position.offset;
        break;
      }
    }

    Stela.Point anchor = Stela.Point(selected.path, anchorOffset);
    Stela.Point focus = Stela.Point(selected.path, focusOffset);
    Stela.Range range = Stela.Range(anchor, focus);
    // We return early if the selection is not valid. This can happen when the
    // text of [EditableText] is updated at the same time as the selection is
    // changed by a gesture event.
    // TODO
    // if (!widget.controller.isSelectionWithinTextBounds(selection))
    //   return;

    widget.controller.selection = range;

    // This will show the keyboard for all selection changes on the
    // EditableWidget, not just changes triggered by user gestures.
    // TODO
    // requestKeyboard();

    _selectionOverlay?.hide();
    _selectionOverlay = null;

    _selectionOverlay = EditorSelectionOverlay(
      context: context,
      value: _value,
      debugRequiredFor: widget,
      toolbarLayerLink: _toolbarLayerLink,
      startHandleLayerLink: _startHandleLayerLink,
      endHandleLayerLink: _endHandleLayerLink,
      selectionControls: _getSelectionControls(),
      // selectionDelegate: this, // TODO
      dragStartBehavior: widget.dragStartBehavior,
      textDirection: widget.textDirection,
      onSelectionHandleTapped: toggleToolbar,
      preferredLineHeight: 17, // TODO
    );
    _selectionOverlay.handlesVisible = _shouldShowSelectionHandles(cause);
    _selectionOverlay.showHandles();
    // TODO
    // if (widget.onSelectionChanged != null)
    //   widget.onSelectionChanged(selection, cause);
  }

  Set<RenderStelaNode> boxes = Set();

  Widget _buildRichText(
      Stela.Element node, Stela.Path path, Stela.Range selection) {
    ThemeData themeData = Theme.of(context);
    List<InlineSpan> children = [];
    List<TextNodeEntry> textNodeEntries = [];
    TextPosition position = TextPosition(offset: 0);

    for (int i = 0; i < node.children.length; i++) {
      Stela.Node child = node.children[i];

      if (child is Stela.Text) {
        TextNodeEntry entry = TextNodeEntry(
          length: child.text.length,
          position: position,
          path: path.copyAndAdd(i),
          node: child,
        );

        textNodeEntries.add(entry);
        children.add(_buildText(child, node));

        position = TextPosition(offset: position.offset + child.text.length);
      } else if (child is Stela.Inline) {
        children.add(WidgetSpan(
            child: _buildElement(child, path.copyAndAdd(i), selection)));
        position = TextPosition(offset: position.offset + 1);
      } else {
        throw Exception(
            'Element can only have either text and inlines or other blocks.');
      }
    }

    TextSelection textSelection;

    if (selection != null) {
      for (TextNodeEntry textNodeEntry in textNodeEntries) {
        if (selection.includes(textNodeEntry.path)) {
          textSelection = TextSelection(
              baseOffset:
                  textNodeEntry.position.offset + selection.anchor.offset,
              extentOffset:
                  textNodeEntry.position.offset + selection.focus.offset);
        }
      }
    }

    return StelaNode(
      node: node,
      addBox: _addBox,
      removeBox: _removeBox,
      path: path,
      child: StelaRichText(
        node: node,
        text: TextSpan(children: children),
        ignorePointer: false,
        onSelectionChanged: _handleSelectionChanged,
        hasFocus: true,
        textNodeEntries: textNodeEntries,
        selection: textSelection,
        selectionColor: themeData.textSelectionColor,
        backgroundCursorColor: CupertinoColors.inactiveGray,
        showCursor: _cursorVisibilityNotifier,
        cursorColor: themeData.cursorColor,
        startHandleLayerLink: _startHandleLayerLink,
        endHandleLayerLink: _endHandleLayerLink,
      ),
    );
  }

  _addBox(RenderObject object) {
    boxes.add(object);
  }

  _removeBox(RenderObject object) {
    boxes.remove(object);
  }

  TextSpan _buildText(Stela.Text node, Stela.Element parent) {
    TextSpan text = widget.textBuilder(node, parent);

    return text;
  }

  Widget _buildElement(
      Stela.Element node, Stela.Path path, Stela.Range selection) {
    Widget element =
        widget.elementBuilder(node, _buildChildren(node, path, selection));

    return StelaNode(
      node: node,
      child: element,
      addBox: _addBox,
      removeBox: _removeBox,
      path: path,
    );
  }

  List<Widget> _buildChildren(
      Stela.Ancestor node, Stela.Path path, Stela.Range selection) {
    List<Widget> children = [];
    Stela.Editor editor = widget.controller.value.editor;
    Stela.Range range = editor.range(path, null);

    Stela.Range sel;
    if (selection != null) {
      sel = range.intersection(selection);
    }

    // We gather text and inline nodes in a single StelaRichText widget.
    // Reason is we want to reuse [TextPainter]
    bool isRichText = node.children.first is Stela.Text;

    if (isRichText) {
      children.add(_buildRichText(node, path, sel));
    } else {
      for (int i = 0; i < node.children.length; i++) {
        Stela.Node child = node.children[i];

        if (child is Stela.Element) {
          children.add(_buildElement(child, path.copyAndAdd(i), sel));
        }
      }
    }

    return children;
  }

  void _handleSingleTapUp(TapUpDetails details) {
    RenderStelaNode box = boxForGlobalPoint(details.globalPosition);

    if (box.child is RenderStelaRichText) {
      RenderStelaRichText renderRichText = box.child;

      switch (Theme.of(context).platform) {
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
          renderRichText.selectWordEdge(cause: SelectionChangedCause.tap);
          break;
        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
        case TargetPlatform.linux:
        case TargetPlatform.windows:
          renderRichText.selectPosition(cause: SelectionChangedCause.tap);
          break;
      }
    }
  }

  void _handleSingleLongTapStart(LongPressStartDetails details) {
    RenderStelaNode box = boxForGlobalPoint(details.globalPosition);

    if (box.child is RenderStelaRichText) {
      RenderStelaRichText renderRichText = box.child;

      switch (Theme.of(context).platform) {
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
          renderRichText.selectPositionAt(
            from: details.globalPosition,
            cause: SelectionChangedCause.longPress,
          );
          break;
        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
        case TargetPlatform.linux:
        case TargetPlatform.windows:
          renderRichText.selectWord(cause: SelectionChangedCause.longPress);
          Feedback.forLongPress(context);
          break;
      }
    }
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    RenderStelaNode box = boxForGlobalPoint(details.globalPosition);

    if (box.child is RenderStelaRichText) {
      RenderStelaRichText renderRichText = box.child;
      renderRichText.selectWord(cause: SelectionChangedCause.tap);
      // if (shouldShowSelectionToolbar)
      //   editableText.showToolbar();
    }
  }

  void _handleSingleLongTapMoveUpdate(LongPressMoveUpdateDetails details) {
    RenderStelaNode box = boxForGlobalPoint(details.globalPosition);

    if (box.child is RenderStelaRichText) {
      RenderStelaRichText renderRichText = box.child;
      renderRichText.selectPositionAt(
        from: details.globalPosition,
        cause: SelectionChangedCause.longPress,
      );
    }
  }

  void _handleTapDown(TapDownDetails details) {
    RenderStelaNode box = boxForGlobalPoint(details.globalPosition);

    if (box.child is RenderStelaRichText) {
      RenderStelaRichText renderRichText = box.child;

      renderRichText.handleTapDown(details);
    }
  }

  RenderStelaNode boxForGlobalPoint(Offset point) {
    return boxes.lastWhere((p) {
      Offset localPoint = p.globalToLocal(point);
      return p.size.contains(localPoint);
    }, orElse: null);
  }

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

    return TextSelectionGestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: _handleTapDown,
        onSingleLongTapStart: _handleSingleLongTapStart,
        onSingleLongTapMoveUpdate: _handleSingleLongTapMoveUpdate,
        onDoubleTapDown: _handleDoubleTapDown,
        onSingleTapUp: _handleSingleTapUp,
        child: CompositedTransformTarget(
          link: _toolbarLayerLink,
          child: ListBody(
              children: _buildChildren(
            widget.controller.value.editor,
            Stela.Path([]),
            widget.controller.selection,
          )),
        ));
  }
}

TextSpan defaultTextBuilder(Stela.Text text, Stela.Element parent) {
  Color color = parent.type == 'link' ? Colors.blueAccent : Colors.black;

  return TextSpan(
      text: text.text, style: TextStyle(color: color, fontSize: 16));
}

Widget defaultElementBuilder(Stela.Element element, List<Widget> children) {
  switch (element.type) {
    case 'paragraph':
      return StelaParagraph(node: element, children: children);
    case 'image':
      return StelaImage(node: element);
    case 'link':
      return StelaLink(node: element, children: children);
    case 'mention':
      return StelaMention(node: element, children: children);
    case 'bulleted_list':
      return StelaBulletedList(node: element, children: children);
    case 'list_item':
      return StelaListItem(node: element, children: children);
    default:
      return StelaParagraph(node: element, children: children);
  }
}
