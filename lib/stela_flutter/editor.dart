import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:inday/stela/stela.dart' as Stela;
import 'package:inday/stela_flutter/block_text.dart';

class EditorEditingController extends ValueNotifier<Stela.Editor> {
  EditorEditingController({Stela.Editor editor})
      : super(editor == null ? Stela.Editor(children: []) : editor);

  EditorEditingController.fromValue(Stela.Editor value)
      : super(value ?? Stela.Editor(children: []));

  Stela.Editor get editor => value;

  set editor(Stela.Editor editor) {
    value = editor;
  }
}

class StelaEditor extends StatefulWidget {
  StelaEditor({
    Key key,
    @required this.controller,
    @required this.focusNode,
    this.readOnly = false,
    this.autocorrect = true,
    SmartDashesType smartDashesType,
    SmartQuotesType smartQuotesType,
    this.enableSuggestions = true,
    @required this.style,
    StrutStyle strutStyle,
    @required this.cursorColor,
    @required this.backgroundCursorColor,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.locale,
    this.textScaleFactor,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.forceLine = true,
    this.textWidthBasis = TextWidthBasis.parent,
    this.autofocus = false,
    bool showCursor,
    this.showSelectionHandles = false,
    this.selectionColor,
    this.selectionControls,
    TextInputType keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.onSelectionChanged,
    this.onSelectionHandleTapped,
    this.rendererIgnoresPointer = false,
    this.cursorWidth = 2.0,
    this.cursorRadius,
    this.cursorOpacityAnimates = false,
    this.cursorOffset,
    this.paintCursorAboveText = false,
    this.selectionHeightStyle = ui.BoxHeightStyle.tight,
    this.selectionWidthStyle = ui.BoxWidthStyle.tight,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.keyboardAppearance = Brightness.light,
    this.dragStartBehavior = DragStartBehavior.start,
    this.enableInteractiveSelection = true,
    this.scrollController,
    this.scrollPhysics,
    this.toolbarOptions = const ToolbarOptions(
      copy: true,
      cut: true,
      paste: true,
      selectAll: true,
    ),
  })  : assert(controller != null),
        assert(focusNode != null),
        assert(autocorrect != null),
        smartDashesType = smartDashesType ?? SmartDashesType.enabled,
        smartQuotesType = smartQuotesType ?? SmartQuotesType.enabled,
        assert(enableSuggestions != null),
        assert(showSelectionHandles != null),
        assert(enableInteractiveSelection != null),
        assert(readOnly != null),
        assert(forceLine != null),
        assert(style != null),
        assert(cursorColor != null),
        assert(cursorOpacityAnimates != null),
        assert(paintCursorAboveText != null),
        assert(backgroundCursorColor != null),
        assert(selectionHeightStyle != null),
        assert(selectionWidthStyle != null),
        assert(textAlign != null),
        assert(maxLines == null || maxLines > 0),
        assert(minLines == null || minLines > 0),
        assert(
          (maxLines == null) || (minLines == null) || (maxLines >= minLines),
          "minLines can't be greater than maxLines",
        ),
        assert(expands != null),
        assert(
          !expands || (maxLines == null && minLines == null),
          'minLines and maxLines must be null when expands is true.',
        ),
        assert(autofocus != null),
        assert(rendererIgnoresPointer != null),
        assert(scrollPadding != null),
        assert(dragStartBehavior != null),
        assert(toolbarOptions != null),
        _strutStyle = strutStyle,
        showCursor = showCursor ?? !readOnly,
        super(key: key);

  /// Controls the text being edited.
  final EditorEditingController controller;

  /// Controls whether this widget has keyboard focus.
  final FocusNode focusNode;

  /// {@macro flutter.widgets.text.DefaultTextStyle.textWidthBasis}
  final TextWidthBasis textWidthBasis;

  final bool readOnly;

  final bool forceLine;

  final ToolbarOptions toolbarOptions;

  final bool showSelectionHandles;

  final bool showCursor;

  final bool autocorrect;

  /// {@macro flutter.services.textInput.smartDashesType}
  final SmartDashesType smartDashesType;

  /// {@macro flutter.services.textInput.smartQuotesType}
  final SmartQuotesType smartQuotesType;

  /// {@macro flutter.services.textInput.enableSuggestions}
  final bool enableSuggestions;

  /// The text style to use for the editable text.
  final TextStyle style;

  /// {@macro flutter.widgets.editableText.strutStyle}
  StrutStyle get strutStyle {
    if (_strutStyle == null) {
      return style != null
          ? StrutStyle.fromTextStyle(style, forceStrutHeight: true)
          : const StrutStyle();
    }
    return _strutStyle.inheritFromTextStyle(style);
  }

  final StrutStyle _strutStyle;

  /// {@macro flutter.widgets.editableText.textAlign}
  final TextAlign textAlign;

  /// {@macro flutter.widgets.editableText.textDirection}
  final TextDirection textDirection;

  /// {@macro flutter.widgets.editableText.textCapitalization}
  final TextCapitalization textCapitalization;

  final Locale locale;

  final double textScaleFactor;

  final Color cursorColor;

  final Color backgroundCursorColor;

  /// {@macro flutter.widgets.editableText.maxLines}
  final int maxLines;

  /// {@macro flutter.widgets.editableText.minLines}
  final int minLines;

  /// {@macro flutter.widgets.editableText.expands}
  final bool expands;

  /// {@macro flutter.widgets.editableText.autofocus}
  final bool autofocus;

  /// The color to use when painting the selection.
  final Color selectionColor;

  final TextSelectionControls selectionControls;

  /// The type of action button to use with the soft keyboard.
  final TextInputAction textInputAction;

  /// {@macro flutter.widgets.editableText.onChanged}
  final ValueChanged<String> onChanged;

  /// {@macro flutter.widgets.editableText.onEditingComplete}
  final VoidCallback onEditingComplete;

  /// {@macro flutter.widgets.editableText.onSubmitted}
  final ValueChanged<String> onSubmitted;

  /// Called when the user changes the selection of text (including the cursor
  /// location).
  final SelectionChangedCallback onSelectionChanged;

  /// {@macro flutter.widgets.textSelection.onSelectionHandleTapped}
  final VoidCallback onSelectionHandleTapped;

  /// If true, the [RenderEditable] created by this widget will not handle
  /// pointer events, see [renderEditable] and [RenderEditable.ignorePointer].
  ///
  /// This property is false by default.
  final bool rendererIgnoresPointer;

  /// {@macro flutter.widgets.editableText.cursorWidth}
  final double cursorWidth;

  /// {@macro flutter.widgets.editableText.cursorRadius}
  final Radius cursorRadius;

  /// Whether the cursor will animate from fully transparent to fully opaque
  /// during each cursor blink.
  ///
  /// By default, the cursor opacity will animate on iOS platforms and will not
  /// animate on Android platforms.
  final bool cursorOpacityAnimates;

  ///{@macro flutter.rendering.editable.cursorOffset}
  final Offset cursorOffset;

  ///{@macro flutter.rendering.editable.paintCursorOnTop}
  final bool paintCursorAboveText;

  /// Controls how tall the selection highlight boxes are computed to be.
  ///
  /// See [ui.BoxHeightStyle] for details on available styles.
  final ui.BoxHeightStyle selectionHeightStyle;

  /// Controls how wide the selection highlight boxes are computed to be.
  ///
  /// See [ui.BoxWidthStyle] for details on available styles.
  final ui.BoxWidthStyle selectionWidthStyle;

  /// The appearance of the keyboard.
  ///
  /// This setting is only honored on iOS devices.
  ///
  /// Defaults to [Brightness.light].
  final Brightness keyboardAppearance;

  /// {@macro flutter.widgets.editableText.scrollPadding}
  final EdgeInsets scrollPadding;

  /// {@macro flutter.widgets.editableText.enableInteractiveSelection}
  final bool enableInteractiveSelection;

  /// Setting this property to true makes the cursor stop blinking or fading
  /// on and off once the cursor appears on focus. This property is useful for
  /// testing purposes.
  ///
  /// It does not affect the necessity to focus the StelaEditor for the cursor
  /// to appear in the first place.
  ///
  /// Defaults to false, resulting in a typical blinking cursor.
  static bool debugDeterministicCursor = false;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  /// {@macro flutter.widgets.editableText.scrollController}
  final ScrollController scrollController;

  /// {@macro flutter.widgets.editableText.scrollPhysics}
  final ScrollPhysics scrollPhysics;

  /// {@macro flutter.rendering.editable.selectionEnabled}
  bool get selectionEnabled => enableInteractiveSelection;

  @override
  _StelaEditorState createState() => _StelaEditorState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
        DiagnosticsProperty<EditorEditingController>('controller', controller));
    properties.add(DiagnosticsProperty<FocusNode>('focusNode', focusNode));
    properties.add(DiagnosticsProperty<bool>('autocorrect', autocorrect,
        defaultValue: true));
    properties.add(EnumProperty<SmartDashesType>(
        'smartDashesType', smartDashesType,
        defaultValue: SmartDashesType.enabled));
    properties.add(EnumProperty<SmartQuotesType>(
        'smartQuotesType', smartQuotesType,
        defaultValue: SmartQuotesType.enabled));
    properties.add(DiagnosticsProperty<bool>(
        'enableSuggestions', enableSuggestions,
        defaultValue: true));
    style?.debugFillProperties(properties);
    properties.add(
        EnumProperty<TextAlign>('textAlign', textAlign, defaultValue: null));
    properties.add(EnumProperty<TextDirection>('textDirection', textDirection,
        defaultValue: null));
    properties
        .add(DiagnosticsProperty<Locale>('locale', locale, defaultValue: null));
    properties.add(
        DoubleProperty('textScaleFactor', textScaleFactor, defaultValue: null));
    properties.add(IntProperty('maxLines', maxLines, defaultValue: 1));
    properties.add(IntProperty('minLines', minLines, defaultValue: null));
    properties.add(
        DiagnosticsProperty<bool>('expands', expands, defaultValue: false));
    properties.add(
        DiagnosticsProperty<bool>('autofocus', autofocus, defaultValue: false));
    properties.add(DiagnosticsProperty<ScrollController>(
        'scrollController', scrollController,
        defaultValue: null));
    properties.add(DiagnosticsProperty<ScrollPhysics>(
        'scrollPhysics', scrollPhysics,
        defaultValue: null));
  }
}

class _StelaEditorState extends State<StelaEditor> {
  TextDirection get _textDirection {
    final TextDirection result =
        widget.textDirection ?? Directionality.of(context);
    assert(result != null,
        '$runtimeType created without a textDirection and with no ambient Directionality.');
    return result;
  }

  double get _devicePixelRatio =>
      MediaQuery.of(context).devicePixelRatio ?? 1.0;

  bool get _hasFocus => widget.focusNode.hasFocus;

  Stela.Editor get _value => widget.controller.value;
  set _value(Stela.Editor value) {
    widget.controller.value = value;
  }

  Widget _buildBlockText(Stela.Block block) {
    final ThemeData themeData = Theme.of(context);
    TextSelectionControls textSelectionControls;
    bool paintCursorAboveText;
    bool cursorOpacityAnimates;
    Offset cursorOffset;
    Color cursorColor = widget.cursorColor;
    Radius cursorRadius = widget.cursorRadius;

    switch (themeData.platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
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
        textSelectionControls = materialTextSelectionControls;
        paintCursorAboveText = false;
        cursorOpacityAnimates = false;
        cursorColor ??= themeData.cursorColor;
        break;
    }

    List<TextSpan> children = [];

    for (Stela.Node blockChild in block.children) {
      if (blockChild is Stela.Text) {
        children.add(TextSpan(text: blockChild.text));
      }

      if (blockChild is Stela.Inline) {
        // TODO
      }
    }

    TextSpan textSpan = TextSpan(children: children, style: widget.style);

    return StelaBlockText(
      // key: _editableKey,
      //         startHandleLayerLink: _startHandleLayerLink,
      //         endHandleLayerLink: _endHandleLayerLink,
      textSpan: textSpan,
      // value: _value,
      cursorColor: cursorColor,
      backgroundCursorColor: widget.backgroundCursorColor,
      showCursor: ValueNotifier<bool>(widget.showCursor),
      // showCursor: EditableText.debugDeterministicCursor
      //     ? ValueNotifier<bool>(widget.showCursor)
      //     : _cursorVisibilityNotifier,
      forceLine: widget.forceLine,
      readOnly: widget.readOnly,
      hasFocus: _hasFocus,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      expands: widget.expands,
      strutStyle: widget.strutStyle,
      selectionColor: widget.selectionColor,
      textScaleFactor:
          widget.textScaleFactor ?? MediaQuery.textScaleFactorOf(context),
      textAlign: widget.textAlign,
      textDirection: _textDirection,
      locale: widget.locale,
      textWidthBasis: widget.textWidthBasis,
      autocorrect: widget.autocorrect,
      smartDashesType: widget.smartDashesType,
      smartQuotesType: widget.smartQuotesType,
      enableSuggestions: widget.enableSuggestions,
      // offset: offset,
      // onSelectionChanged: _handleSelectionChanged,
      // onCaretChanged: _handleCaretChanged,
      rendererIgnoresPointer: widget.rendererIgnoresPointer,
      cursorWidth: widget.cursorWidth,
      cursorRadius: cursorRadius,
      cursorOffset: cursorOffset,
      selectionHeightStyle: widget.selectionHeightStyle,
      selectionWidthStyle: widget.selectionWidthStyle,
      paintCursorAboveText: paintCursorAboveText,
      enableInteractiveSelection: widget.enableInteractiveSelection,
      // textSelectionDelegate: this,
      devicePixelRatio: _devicePixelRatio,
    );
  }

  List<Widget> _buildChildren() {
    List<Widget> children = [];

    /// There are 2 kind of blocks, ones that contain text and ones that nest other blocks.
    for (Stela.Node child in widget.controller.value.children) {
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
    return Column(children: _buildChildren());
  }
}
