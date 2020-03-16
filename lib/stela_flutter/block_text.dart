import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class StelaBlockText extends MultiChildRenderObjectWidget {
  StelaBlockText({
    Key key,
    this.textSpan,
    this.startHandleLayerLink,
    this.endHandleLayerLink,
    this.cursorColor,
    this.backgroundCursorColor,
    this.showCursor,
    this.forceLine,
    this.readOnly,
    this.textWidthBasis,
    this.hasFocus,
    this.maxLines,
    this.minLines,
    this.expands,
    this.strutStyle,
    this.selectionColor,
    this.textScaleFactor,
    this.textAlign,
    @required this.textDirection,
    this.locale,
    this.autocorrect,
    this.smartDashesType,
    this.smartQuotesType,
    this.enableSuggestions,
    this.offset,
    this.onSelectionChanged,
    this.onCaretChanged,
    this.rendererIgnoresPointer = false,
    this.cursorWidth,
    this.cursorRadius,
    this.cursorOffset,
    this.paintCursorAboveText,
    this.selectionHeightStyle = ui.BoxHeightStyle.tight,
    this.selectionWidthStyle = ui.BoxWidthStyle.tight,
    this.textHeightBehavior,
    this.enableInteractiveSelection = true,
    this.textSelectionDelegate,
    this.devicePixelRatio,
  })  : assert(textDirection != null),
        assert(rendererIgnoresPointer != null),
        super(key: key, children: _extractChildren(textSpan));

  // Traverses the InlineSpan tree and depth-first collects the list of
  // child widgets that are created in WidgetSpans.
  static List<Widget> _extractChildren(InlineSpan span) {
    final List<Widget> result = <Widget>[];
    span.visitChildren((InlineSpan span) {
      if (span is WidgetSpan) {
        result.add(span.child);
      }
      return true;
    });
    return result;
  }

  final TextSpan textSpan;
  final Color cursorColor;
  final LayerLink startHandleLayerLink;
  final LayerLink endHandleLayerLink;
  final Color backgroundCursorColor;
  final ValueNotifier<bool> showCursor;
  final bool forceLine;
  final bool readOnly;
  final bool hasFocus;
  final int maxLines;
  final int minLines;
  final bool expands;
  final StrutStyle strutStyle;
  final Color selectionColor;
  final double textScaleFactor;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final Locale locale;
  final TextWidthBasis textWidthBasis;
  final bool autocorrect;
  final SmartDashesType smartDashesType;
  final SmartQuotesType smartQuotesType;
  final bool enableSuggestions;
  final ViewportOffset offset;
  final SelectionChangedHandler onSelectionChanged;
  final CaretChangedHandler onCaretChanged;
  final bool rendererIgnoresPointer;
  final double cursorWidth;
  final Radius cursorRadius;
  final Offset cursorOffset;
  final bool paintCursorAboveText;
  final ui.BoxHeightStyle selectionHeightStyle;
  final ui.BoxWidthStyle selectionWidthStyle;
  final ui.TextHeightBehavior textHeightBehavior;
  final bool enableInteractiveSelection;
  final TextSelectionDelegate textSelectionDelegate;
  final double devicePixelRatio;

  @override
  RenderBlockText createRenderObject(BuildContext context) {
    return RenderBlockText(
      text: textSpan,
      cursorColor: cursorColor,
      startHandleLayerLink: startHandleLayerLink,
      endHandleLayerLink: endHandleLayerLink,
      backgroundCursorColor: backgroundCursorColor,
      showCursor: showCursor,
      forceLine: forceLine,
      readOnly: readOnly,
      hasFocus: hasFocus,
      maxLines: maxLines,
      minLines: minLines,
      expands: expands,
      strutStyle: strutStyle,
      selectionColor: selectionColor,
      textScaleFactor: textScaleFactor,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale ?? Localizations.localeOf(context, nullOk: true),
      selection: TextSelection(baseOffset: 1, extentOffset: 10),
      offset: offset,
      onSelectionChanged: onSelectionChanged,
      onCaretChanged: onCaretChanged,
      ignorePointer: rendererIgnoresPointer,
      textWidthBasis: textWidthBasis,
      cursorWidth: cursorWidth,
      cursorRadius: cursorRadius,
      cursorOffset: cursorOffset,
      paintCursorAboveText: paintCursorAboveText,
      selectionHeightStyle: selectionHeightStyle,
      selectionWidthStyle: selectionWidthStyle,
      enableInteractiveSelection: enableInteractiveSelection,
      textHeightBehavior: textHeightBehavior,
      textSelectionDelegate: textSelectionDelegate,
      devicePixelRatio: devicePixelRatio,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderBlockText renderObject) {
    renderObject
      ..text = textSpan
      ..cursorColor = cursorColor
      ..startHandleLayerLink = startHandleLayerLink
      ..endHandleLayerLink = endHandleLayerLink
      ..showCursor = showCursor
      ..readOnly = readOnly
      ..hasFocus = hasFocus
      ..maxLines = maxLines
      ..minLines = minLines
      ..expands = expands
      ..strutStyle = strutStyle
      ..selectionColor = selectionColor
      ..textScaleFactor = textScaleFactor
      ..textAlign = textAlign
      ..textDirection = textDirection
      ..locale = locale ?? Localizations.localeOf(context, nullOk: true)
      ..selection = TextSelection(baseOffset: 1, extentOffset: 10)
      ..offset = offset
      ..onSelectionChanged = onSelectionChanged
      ..onCaretChanged = onCaretChanged
      ..ignorePointer = rendererIgnoresPointer
      ..textWidthBasis = textWidthBasis
      ..cursorWidth = cursorWidth
      ..cursorRadius = cursorRadius
      ..cursorOffset = cursorOffset
      ..selectionHeightStyle = selectionHeightStyle
      ..selectionWidthStyle = selectionWidthStyle
      ..textSelectionDelegate = textSelectionDelegate
      ..textHeightBehavior = textHeightBehavior
      ..devicePixelRatio = devicePixelRatio
      ..paintCursorAboveText = paintCursorAboveText;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<TextAlign>('textAlign', textAlign,
        defaultValue: TextAlign.start));
    properties.add(EnumProperty<TextDirection>('textDirection', textDirection,
        defaultValue: null));
    properties.add(
        DoubleProperty('textScaleFactor', textScaleFactor, defaultValue: 1.0));
    properties.add(EnumProperty<TextWidthBasis>(
        'textWidthBasis', textWidthBasis,
        defaultValue: TextWidthBasis.parent));
    properties.add(StringProperty('text', textSpan.toPlainText()));
  }
}

const double _kCaretGap = 1.0; // pixels
const double _kCaretHeightOffset = 2.0; // pixels

class RenderBlockText extends RenderParagraph {
  RenderBlockText({
    TextSpan text,
    @required TextDirection textDirection,
    TextAlign textAlign = TextAlign.start,
    Color cursorColor,
    Color backgroundCursorColor,
    ValueNotifier<bool> showCursor,
    bool hasFocus,
    @required LayerLink startHandleLayerLink,
    @required LayerLink endHandleLayerLink,
    int maxLines = 1,
    int minLines,
    bool expands = false,
    StrutStyle strutStyle,
    Color selectionColor,
    double textScaleFactor = 1.0,
    TextSelection selection,
    @required ViewportOffset offset,
    this.onSelectionChanged,
    this.onCaretChanged,
    this.ignorePointer = false,
    bool readOnly = false,
    bool forceLine = true,
    TextWidthBasis textWidthBasis = TextWidthBasis.parent,
    bool obscureText = false,
    Locale locale,
    double cursorWidth = 1.0,
    Radius cursorRadius,
    bool paintCursorAboveText = false,
    Offset cursorOffset,
    double devicePixelRatio = 1.0,
    ui.BoxHeightStyle selectionHeightStyle = ui.BoxHeightStyle.tight,
    ui.BoxWidthStyle selectionWidthStyle = ui.BoxWidthStyle.tight,
    ui.TextHeightBehavior textHeightBehavior,
    bool enableInteractiveSelection,
    EdgeInsets floatingCursorAddedMargin =
        const EdgeInsets.fromLTRB(4, 4, 4, 5),
    @required this.textSelectionDelegate,
  })  : assert(textAlign != null),
        assert(textDirection != null,
            'RenderEditable created without a textDirection.'),
        assert(maxLines == null || maxLines > 0),
        assert(minLines == null || minLines > 0),
        // assert(startHandleLayerLink != null),
        // assert(endHandleLayerLink != null),
        assert(
          (maxLines == null) || (minLines == null) || (maxLines >= minLines),
          "minLines can't be greater than maxLines",
        ),
        assert(expands != null),
        assert(
          !expands || (maxLines == null && minLines == null),
          'minLines and maxLines must be null when expands is true.',
        ),
        assert(textScaleFactor != null),
        // assert(offset != null),
        assert(ignorePointer != null),
        assert(textWidthBasis != null),
        assert(paintCursorAboveText != null),
        assert(obscureText != null),
        // assert(textSelectionDelegate != null),
        assert(cursorWidth != null && cursorWidth >= 0.0),
        assert(readOnly != null),
        assert(forceLine != null),
        assert(devicePixelRatio != null),
        assert(selectionHeightStyle != null),
        assert(selectionWidthStyle != null),
        _selection = selection,
        _selectionColor = selectionColor,
        _backgroundCursorColor = backgroundCursorColor,
        _selectionHeightStyle = selectionHeightStyle,
        _devicePixelRatio = devicePixelRatio,
        _selectionWidthStyle = selectionWidthStyle,
        _cursorColor = cursorColor,
        _cursorWidth = cursorWidth,
        _cursorRadius = cursorRadius,
        _showCursor = showCursor ?? ValueNotifier<bool>(false),
        _textPrototype = TextPainter(
          text: TextSpan(text: '.', style: text.style),
          textAlign: textAlign,
          textDirection: textDirection,
          textScaleFactor: textScaleFactor,
          locale: locale,
          strutStyle: strutStyle,
          textWidthBasis: textWidthBasis,
          textHeightBehavior: textHeightBehavior,
        ),
        super(
          text,
          textAlign: textAlign,
          textDirection: textDirection,
          textScaleFactor: textScaleFactor,
          locale: locale,
          strutStyle: strutStyle,
          textWidthBasis: textWidthBasis,
          textHeightBehavior: textHeightBehavior,
        ) {
    assert(_showCursor != null);
    assert(!_showCursor.value || cursorColor != null);
  }

  Rect _caretPrototype;
  Rect _lastCaretRect;
  TextPainter _textPrototype;

  /// Called when the selection changes.
  ///
  /// If this is null, then selection changes will be ignored.
  SelectionChangedHandler onSelectionChanged;

  double _textLayoutLastMaxWidth;
  double _textLayoutLastMinWidth;

  /// Called during the paint phase when the caret location changes.
  CaretChangedHandler onCaretChanged;

  /// If true [handleEvent] does nothing and it's assumed that this
  /// renderer will be notified of input gestures via [handleTapDown],
  /// [handleTap], [handleDoubleTap], and [handleLongPress].
  ///
  /// The default value of this property is false.
  bool ignorePointer;

  /// The pixel ratio of the current device.
  ///
  /// Should be obtained by querying MediaQuery for the devicePixelRatio.
  double get devicePixelRatio => _devicePixelRatio;
  double _devicePixelRatio;
  set devicePixelRatio(double value) {
    if (devicePixelRatio == value) return;
    _devicePixelRatio = value;
    markNeedsTextLayout();
  }

  /// The object that controls the text selection, used by this render object
  /// for implementing cut, copy, and paste keyboard shortcuts.
  ///
  /// It must not be null. It will make cut, copy and paste functionality work
  /// with the most recently set [TextSelectionDelegate].
  TextSelectionDelegate textSelectionDelegate;

  /// The color to use when painting the cursor.
  Color get cursorColor => _cursorColor;
  Color _cursorColor;
  set cursorColor(Color value) {
    if (_cursorColor == value) return;
    _cursorColor = value;
    markNeedsPaint();
  }

  /// The color to use when painting the cursor aligned to the text while
  /// rendering the floating cursor.
  ///
  /// The default is light grey.
  Color get backgroundCursorColor => _backgroundCursorColor;
  Color _backgroundCursorColor;
  set backgroundCursorColor(Color value) {
    if (backgroundCursorColor == value) return;
    _backgroundCursorColor = value;
    markNeedsPaint();
  }

  /// Whether to paint the cursor.
  ValueNotifier<bool> get showCursor => _showCursor;
  ValueNotifier<bool> _showCursor;
  set showCursor(ValueNotifier<bool> value) {
    // assert(value != null);
    if (_showCursor == value) return;
    if (attached) _showCursor.removeListener(markNeedsPaint);
    _showCursor = value;
    if (attached) _showCursor.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  /// Whether the editable is currently focused.
  bool get hasFocus => _hasFocus;
  bool _hasFocus = false;
  bool _listenerAttached = false;
  set hasFocus(bool value) {
    // assert(value != null);
    if (_hasFocus == value) return;
    _hasFocus = value;
    if (_hasFocus) {
      assert(!_listenerAttached);
      // TODO
      // RawKeyboard.instance.addListener(_handleKeyEvent);
      _listenerAttached = true;
    } else {
      assert(_listenerAttached);
      // TODO
      // RawKeyboard.instance.removeListener(_handleKeyEvent);
      _listenerAttached = false;
    }
    markNeedsSemanticsUpdate();
  }

  /// Whether this rendering object is read only.
  bool get readOnly => _readOnly;
  bool _readOnly = false;
  set readOnly(bool value) {
    // assert(value != null);
    if (_readOnly == value) return;
    _readOnly = value;
    markNeedsSemanticsUpdate();
  }

  /// The maximum number of lines for the text to span, wrapping if necessary.
  ///
  /// If this is 1 (the default), the text will not wrap, but will extend
  /// indefinitely instead.
  ///
  /// If this is null, there is no limit to the number of lines.
  ///
  /// When this is not null, the intrinsic height of the render object is the
  /// height of one line of text multiplied by this value. In other words, this
  /// also controls the height of the actual editing widget.
  int get maxLines => _maxLines;
  int _maxLines;

  /// The value may be null. If it is not null, then it must be greater than zero.
  set maxLines(int value) {
    assert(value == null || value > 0);
    if (maxLines == value) return;
    _maxLines = value;
    markNeedsTextLayout();
  }

  /// {@macro flutter.widgets.editableText.minLines}
  int get minLines => _minLines;
  int _minLines;

  /// The value may be null. If it is not null, then it must be greater than zero.
  set minLines(int value) {
    assert(value == null || value > 0);
    if (minLines == value) return;
    _minLines = value;
    markNeedsTextLayout();
  }

  /// {@macro flutter.widgets.editableText.expands}
  bool get expands => _expands;
  bool _expands;
  set expands(bool value) {
    // assert(value != null);
    if (expands == value) return;
    _expands = value;
    markNeedsTextLayout();
  }

  /// The color to use when painting the selection.
  Color get selectionColor => _selectionColor;
  Color _selectionColor;
  set selectionColor(Color value) {
    if (_selectionColor == value) return;
    _selectionColor = value;
    markNeedsPaint();
  }

  List<ui.TextBox> _selectionRects;

  /// The region of text that is selected, if any.
  TextSelection get selection => _selection;
  TextSelection _selection;
  set selection(TextSelection value) {
    if (_selection == value) return;
    _selection = value;
    _selectionRects = null;
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  /// The offset at which the text should be painted.
  ///
  /// If the text content is larger than the editable line itself, the editable
  /// line clips the text. This property controls which part of the text is
  /// visible by shifting the text by the given offset before clipping.
  ViewportOffset get offset => _offset;
  ViewportOffset _offset;
  set offset(ViewportOffset value) {
    // assert(value != null);
    if (_offset == value) return;
    if (attached) _offset.removeListener(markNeedsPaint);
    _offset = value;
    if (attached) _offset.addListener(markNeedsPaint);
    markNeedsLayout();
  }

  /// How thick the cursor will be.
  double get cursorWidth => _cursorWidth;
  double _cursorWidth = 1.0;
  set cursorWidth(double value) {
    if (_cursorWidth == value) return;
    _cursorWidth = value;
    markNeedsLayout();
  }

  /// {@template flutter.rendering.editable.paintCursorOnTop}
  /// If the cursor should be painted on top of the text or underneath it.
  ///
  /// By default, the cursor should be painted on top for iOS platforms and
  /// underneath for Android platforms.
  /// {@endtemplate}
  bool get paintCursorAboveText => _paintCursorOnTop;
  bool _paintCursorOnTop;
  set paintCursorAboveText(bool value) {
    if (_paintCursorOnTop == value) return;
    _paintCursorOnTop = value;
    markNeedsLayout();
  }

  /// {@template flutter.rendering.editable.cursorOffset}
  /// The offset that is used, in pixels, when painting the cursor on screen.
  ///
  /// By default, the cursor position should be set to an offset of
  /// (-[cursorWidth] * 0.5, 0.0) on iOS platforms and (0, 0) on Android
  /// platforms. The origin from where the offset is applied to is the arbitrary
  /// location where the cursor ends up being rendered from by default.
  /// {@endtemplate}
  Offset get cursorOffset => _cursorOffset;
  Offset _cursorOffset;
  set cursorOffset(Offset value) {
    if (_cursorOffset == value) return;
    _cursorOffset = value;
    markNeedsLayout();
  }

  /// How rounded the corners of the cursor should be.
  Radius get cursorRadius => _cursorRadius;
  Radius _cursorRadius;
  set cursorRadius(Radius value) {
    if (_cursorRadius == value) return;
    _cursorRadius = value;
    markNeedsPaint();
  }

  /// The [LayerLink] of start selection handle.
  ///
  /// [RenderEditable] is responsible for calculating the [Offset] of this
  /// [LayerLink], which will be used as [CompositedTransformTarget] of start handle.
  LayerLink get startHandleLayerLink => _startHandleLayerLink;
  LayerLink _startHandleLayerLink;
  set startHandleLayerLink(LayerLink value) {
    if (_startHandleLayerLink == value) return;
    _startHandleLayerLink = value;
    markNeedsPaint();
  }

  /// The [LayerLink] of end selection handle.
  ///
  /// [RenderEditable] is responsible for calculating the [Offset] of this
  /// [LayerLink], which will be used as [CompositedTransformTarget] of end handle.
  LayerLink get endHandleLayerLink => _endHandleLayerLink;
  LayerLink _endHandleLayerLink;
  set endHandleLayerLink(LayerLink value) {
    if (_endHandleLayerLink == value) return;
    _endHandleLayerLink = value;
    markNeedsPaint();
  }

  /// The padding applied to text field. Used to determine the bounds when
  /// moving the floating cursor.
  ///
  /// Defaults to a padding with left, top and right set to 4, bottom to 5.
  EdgeInsets get floatingCursorAddedMargin => _floatingCursorAddedMargin;
  EdgeInsets _floatingCursorAddedMargin;
  set floatingCursorAddedMargin(EdgeInsets value) {
    if (_floatingCursorAddedMargin == value) return;
    _floatingCursorAddedMargin = value;
    markNeedsPaint();
  }

  bool _floatingCursorOn = false;
  Offset _floatingCursorOffset;
  TextPosition _floatingCursorTextPosition;

  /// Controls how tall the selection highlight boxes are computed to be.
  ///
  /// See [ui.BoxHeightStyle] for details on available styles.
  ui.BoxHeightStyle get selectionHeightStyle => _selectionHeightStyle;
  ui.BoxHeightStyle _selectionHeightStyle;
  set selectionHeightStyle(ui.BoxHeightStyle value) {
    // assert(value != null);
    if (_selectionHeightStyle == value) return;
    _selectionHeightStyle = value;
    markNeedsPaint();
  }

  /// Controls how wide the selection highlight boxes are computed to be.
  ///
  /// See [ui.BoxWidthStyle] for details on available styles.
  ui.BoxWidthStyle get selectionWidthStyle => _selectionWidthStyle;
  ui.BoxWidthStyle _selectionWidthStyle;
  set selectionWidthStyle(ui.BoxWidthStyle value) {
    // assert(value != null);
    if (_selectionWidthStyle == value) return;
    _selectionWidthStyle = value;
    markNeedsPaint();
  }

  /// If false, [describeSemanticsConfiguration] will not set the
  /// configuration's cursor motion or set selection callbacks.
  ///
  /// True by default.
  bool get enableInteractiveSelection => _enableInteractiveSelection;
  bool _enableInteractiveSelection;
  set enableInteractiveSelection(bool value) {
    if (_enableInteractiveSelection == value) return;
    _enableInteractiveSelection = value;
    markNeedsTextLayout();
    markNeedsSemanticsUpdate();
  }

  /// {@template flutter.rendering.editable.selectionEnabled}
  /// True if interactive selection is enabled based on the values of
  /// [enableInteractiveSelection] and [obscureText].
  ///
  /// By default [enableInteractiveSelection] is null, obscureText is false,
  /// and this method returns true.
  /// If [enableInteractiveSelection] is null and obscureText is true, then this
  /// method returns false. This is the common case for password fields.
  /// If [enableInteractiveSelection] is non-null then its value is returned. An
  /// app might set it to true to enable interactive selection for a password
  /// field, or to false to unconditionally disable interactive selection.
  /// {@endtemplate}
  bool get selectionEnabled {
    return enableInteractiveSelection;
  }

  /// The maximum amount the text is allowed to scroll.
  ///
  /// This value is only valid after layout and can change as additional
  /// text is entered or removed in order to accommodate expanding when
  /// [expands] is set to true.
  double get maxScrollExtent => _maxScrollExtent;
  double _maxScrollExtent = 0;

  double get _caretMargin => _kCaretGap + cursorWidth;

  @override
  void systemFontsDidChange() {
    super.systemFontsDidChange();
    _textLayoutLastMaxWidth = null;
    _textLayoutLastMinWidth = null;
  }

  /// Marks the render object as needing to be laid out again and have its text
  /// metrics recomputed.
  ///
  /// Implies [markNeedsLayout].
  @protected
  void markNeedsTextLayout() {
    _textLayoutLastMaxWidth = null;
    _textLayoutLastMinWidth = null;
    markNeedsLayout();
  }

  // TODO(garyq): This is no longer producing the highest-fidelity caret
  // heights for Android, especially when non-alphabetic languages
  // are involved. The current implementation overrides the height set
  // here with the full measured height of the text on Android which looks
  // superior (subjectively and in terms of fidelity) in _paintCaret. We
  // should rework this properly to once again match the platform. The constant
  // _kCaretHeightOffset scales poorly for small font sizes.
  //
  /// On iOS, the cursor is taller than the cursor on Android. The height
  /// of the cursor for iOS is approximate and obtained through an eyeball
  /// comparison.
  Rect get _getCaretPrototype {
    assert(defaultTargetPlatform != null);

    double preferredLineHeight = _textPrototype.preferredLineHeight;

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return Rect.fromLTWH(0.0, 0.0, cursorWidth, preferredLineHeight + 2);
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return Rect.fromLTWH(0.0, _kCaretHeightOffset, cursorWidth,
            preferredLineHeight - 2.0 * _kCaretHeightOffset);
    }
    return null;
  }

  @override
  set text(InlineSpan value) {
    _textPrototype.text = TextSpan(text: '.', style: value.style);
    _selectionRects = null;
    super.text = value;
  }

  @override
  void performLayout() {
    super.performLayout();
    _caretPrototype = _getCaretPrototype;
    _textPrototype.layout(
        minWidth: constraints.minWidth, maxWidth: constraints.maxWidth);
  }

  Offset _getPixelPerfectCursorOffset(Rect caretRect) {
    final Offset caretPosition = localToGlobal(caretRect.topLeft);
    final double pixelMultiple = 1.0 / _devicePixelRatio;
    final int quotientX = (caretPosition.dx / pixelMultiple).round();
    final int quotientY = (caretPosition.dy / pixelMultiple).round();
    final double pixelPerfectOffsetX =
        quotientX * pixelMultiple - caretPosition.dx;
    final double pixelPerfectOffsetY =
        quotientY * pixelMultiple - caretPosition.dy;
    return Offset(pixelPerfectOffsetX, pixelPerfectOffsetY);
  }

  void _paintCaret(
      Canvas canvas, Offset effectiveOffset, TextPosition textPosition) {
    final Paint paint = Paint()
      ..color = _floatingCursorOn ? backgroundCursorColor : _cursorColor;
    final Offset caretOffset =
        getOffsetForCaret(textPosition, _caretPrototype) + effectiveOffset;
    Rect caretRect = _caretPrototype.shift(caretOffset);

    if (_cursorOffset != null) {
      caretRect = caretRect.shift(_cursorOffset);
    }

    final double caretHeight =
        _textPrototype.getFullHeightForCaret(textPosition, _caretPrototype);

    if (caretHeight != null) {
      switch (defaultTargetPlatform) {
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
          final double heightDiff = caretHeight - caretRect.height;
          // Center the caret vertically along the text.
          caretRect = Rect.fromLTWH(
            caretRect.left,
            caretRect.top + heightDiff / 2,
            caretRect.width,
            caretRect.height,
          );
          break;
        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
        case TargetPlatform.linux:
        case TargetPlatform.windows:
          caretRect = Rect.fromLTWH(
            caretRect.left,
            caretRect.top - _kCaretHeightOffset,
            caretRect.width,
            caretHeight,
          );
          break;
      }
    }

    caretRect = caretRect.shift(_getPixelPerfectCursorOffset(caretRect));

    if (cursorRadius == null) {
      canvas.drawRect(caretRect, paint);
    } else {
      final RRect caretRRect = RRect.fromRectAndRadius(caretRect, cursorRadius);
      canvas.drawRRect(caretRRect, paint);
    }

    if (caretRect != _lastCaretRect) {
      _lastCaretRect = caretRect;
      if (onCaretChanged != null) onCaretChanged(caretRect);
    }
  }

  void _paintSelection(Canvas canvas, Offset effectiveOffset) {
    assert(_selectionRects != null);
    final Paint paint = Paint()..color = _selectionColor;

    for (final ui.TextBox box in _selectionRects) {
      canvas.drawRect(box.toRect().shift(effectiveOffset), paint);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    bool showSelection = false;
    bool showCaret = false;

    if (_selection != null && !_floatingCursorOn) {
      if (_selection.isCollapsed && _showCursor.value && cursorColor != null) {
        showCaret = true;
      } else if (!_selection.isCollapsed && _selectionColor != null) {
        showSelection = true;
        // _updateSelectionExtentsVisibility(effectiveOffset);
      }
    }

    if (showSelection) {
      _selectionRects ??= getBoxesForSelection(_selection);
      _paintSelection(context.canvas, offset);
    }

    super.paint(context, offset);

    if (showCaret) {
      _paintCaret(context.canvas, offset, _selection.extent);
    }

    // // On iOS, the cursor is painted over the text, on Android, it's painted
    // // under it.
    // if (paintCursorAboveText)
    //   _textPainter.paint(context.canvas, effectiveOffset);

    // if (!paintCursorAboveText)
    //   _textPainter.paint(context.canvas, effectiveOffset);

    // if (_floatingCursorOn) {
    //   if (_resetFloatingCursorAnimationValue == null)
    //     _paintCaret(context.canvas, effectiveOffset, _floatingCursorTextPosition);
    //   _paintFloatingCaret(context.canvas, _floatingCursorOffset);
    // }
  }
}
