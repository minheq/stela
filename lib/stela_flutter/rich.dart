import 'dart:collection';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:inday/stela/stela.dart' as Stela;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:inday/stela_flutter/editor.dart';

const double _kCaretGap = 1.0; // pixels
const double _kCaretHeightOffset = 2.0; // pixels

// The additional size on the x and y axis with which to expand the prototype
// cursor to render the floating cursor in pixels.
const Offset _kFloatingCaretSizeIncrease = Offset(0.5, 1.0);

// The corner radius of the floating cursor in pixels.
const double _kFloatingCaretRadius = 1.0;

typedef SelectionChangedHandler = void Function(TextSelection selection,
    RenderStelaRichText renderObject, SelectionChangedCause cause);

class StelaRichText extends MultiChildRenderObjectWidget {
  StelaRichText({
    // RichText
    Key key,
    @required this.text,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.softWrap = true,
    this.overflow = TextOverflow.clip,
    this.textScaleFactor = 1.0,
    this.maxLines,
    this.locale,
    this.strutStyle,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textHeightBehavior,

    // Editable
    this.backgroundCursorColor,
    this.cursorColor,
    this.cursorOffset,
    this.cursorRadius,
    this.cursorWidth = 1.0,
    this.devicePixelRatio = 1.0,
    this.hasFocus,
    this.ignorePointer = false,
    this.onCaretChanged,
    this.onSelectionChanged,
    this.paintCursorAboveText = false,
    this.selection,
    this.selectionColor,
    this.selectionHeightStyle = ui.BoxHeightStyle.tight,
    this.selectionWidthStyle = ui.BoxWidthStyle.tight,
    this.showCursor,
    this.startHandleLayerLink,
    this.endHandleLayerLink,

    // Custom
    @required this.textNodeEntries,
    @required this.node,
  }) : super(key: key, children: _extractChildren(text));

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

  // RichText
  final InlineSpan text;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final bool softWrap;
  final TextOverflow overflow;
  final double textScaleFactor;
  final int maxLines;
  final Locale locale;
  final StrutStyle strutStyle;
  final TextWidthBasis textWidthBasis;
  final ui.TextHeightBehavior textHeightBehavior;

  // Editable
  final Color backgroundCursorColor;
  final Color cursorColor;
  final Offset cursorOffset;
  final Radius cursorRadius;
  final double cursorWidth;
  final double devicePixelRatio;
  final bool hasFocus;
  final bool ignorePointer;
  final CaretChangedHandler onCaretChanged;
  final SelectionChangedHandler onSelectionChanged;
  final bool paintCursorAboveText;
  final TextSelection selection;
  final Color selectionColor;
  final ui.BoxHeightStyle selectionHeightStyle;
  final ui.BoxWidthStyle selectionWidthStyle;
  final ValueNotifier<bool> showCursor;
  final LayerLink startHandleLayerLink;
  final LayerLink endHandleLayerLink;

  // Custom
  final List<TextNodeEntry> textNodeEntries;
  final Stela.Element node;

  @override
  RenderStelaRichText createRenderObject(BuildContext context) {
    assert(textDirection != null || debugCheckHasDirectionality(context));
    return RenderStelaRichText(
      // RichText
      text,
      textAlign: textAlign,
      textDirection: textDirection ?? Directionality.of(context),
      softWrap: softWrap,
      textScaleFactor: textScaleFactor,
      maxLines: maxLines,
      strutStyle: strutStyle,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      locale: locale ?? Localizations.localeOf(context, nullOk: true),
      overflow: overflow,

      // Editable
      backgroundCursorColor: backgroundCursorColor,
      cursorColor: cursorColor,
      cursorOffset: cursorOffset,
      cursorRadius: cursorRadius,
      cursorWidth: cursorWidth,
      devicePixelRatio: devicePixelRatio,
      hasFocus: hasFocus,
      ignorePointer: ignorePointer,
      onCaretChanged: onCaretChanged,
      onSelectionChanged: onSelectionChanged,
      paintCursorAboveText: paintCursorAboveText,
      selection: selection,
      selectionColor: selectionColor,
      selectionHeightStyle: selectionHeightStyle,
      selectionWidthStyle: selectionWidthStyle,
      showCursor: showCursor,
      startHandleLayerLink: startHandleLayerLink,
      endHandleLayerLink: endHandleLayerLink,

      // Custom
      textNodeEntries: textNodeEntries,
      node: node,
      // backgroundCursorColor: backgroundCursorColor,
      // showCursor: showCursor,
      // selection: selection,
      // selectionColor: selectionColor,
      // onCaretChanged: onCaretChanged,
      // cursorWidth: cursorWidth,
      // cursorRadius: cursorRadius,
      // cursorOffset: cursorOffset,
      // paintCursorAboveText: paintCursorAboveText,
      // selectionHeightStyle: selectionHeightStyle,
      // selectionWidthStyle: selectionWidthStyle,
      // devicePixelRatio: devicePixelRatio,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderStelaRichText renderObject) {
    assert(textDirection != null || debugCheckHasDirectionality(context));
    renderObject
      // RichText
      ..text = text
      ..textAlign = textAlign
      ..textDirection = textDirection ?? Directionality.of(context)
      ..softWrap = softWrap
      ..textScaleFactor = textScaleFactor
      ..maxLines = maxLines
      ..strutStyle = strutStyle
      ..textWidthBasis = textWidthBasis
      ..textHeightBehavior = textHeightBehavior
      ..locale = locale ?? Localizations.localeOf(context, nullOk: true)
      ..overflow = overflow

      // Editable
      ..backgroundCursorColor = backgroundCursorColor
      ..cursorColor = cursorColor
      ..cursorOffset = cursorOffset
      ..cursorRadius = cursorRadius
      ..cursorWidth = cursorWidth
      ..devicePixelRatio = devicePixelRatio
      ..hasFocus = hasFocus
      ..ignorePointer = ignorePointer
      ..onCaretChanged = onCaretChanged
      ..onSelectionChanged = onSelectionChanged
      ..paintCursorAboveText = paintCursorAboveText
      ..selection = selection
      ..selectionColor = selectionColor
      ..selectionHeightStyle = selectionHeightStyle
      ..selectionWidthStyle = selectionWidthStyle
      ..showCursor = showCursor

      // Custom
      ..textNodeEntries = textNodeEntries
      ..node = node;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<TextAlign>('textAlign', textAlign,
        defaultValue: TextAlign.start));
    properties.add(EnumProperty<TextDirection>('textDirection', textDirection,
        defaultValue: null));
    properties.add(FlagProperty('softWrap',
        value: softWrap,
        ifTrue: 'wrapping at box width',
        ifFalse: 'no wrapping except at line break characters',
        showName: true));
    properties.add(EnumProperty<TextOverflow>('overflow', overflow,
        defaultValue: TextOverflow.clip));
    properties.add(
        DoubleProperty('textScaleFactor', textScaleFactor, defaultValue: 1.0));
    properties.add(IntProperty('maxLines', maxLines, ifNull: 'unlimited'));
    properties.add(EnumProperty<TextWidthBasis>(
        'textWidthBasis', textWidthBasis,
        defaultValue: TextWidthBasis.parent));
    properties.add(StringProperty('text', text.toPlainText()));
  }
}

enum TextOverflow {
  /// Clip the overflowing text to fix its container.
  clip,

  /// Fade the overflowing text to transparent.
  fade,

  /// Use an ellipsis to indicate that the text has overflowed.
  ellipsis,

  /// Render overflowing text outside of its container.
  visible,
}

const String _kEllipsis = '\u2026';

/// Parent data for use with [RenderStelaRichText].
class TextParentData extends ContainerBoxParentData<RenderBox> {
  /// The scaling of the text.
  double scale;

  @override
  String toString() {
    final List<String> values = <String>[
      if (offset != null) 'offset=$offset',
      if (scale != null) 'scale=$scale',
      super.toString(),
    ];
    return values.join('; ');
  }
}

/// A render object that displays a paragraph of text.
class RenderStelaRichText extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, TextParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, TextParentData>,
        RelayoutWhenSystemFontsChangeMixin {
  RenderStelaRichText(
    // RichText
    InlineSpan text, {
    TextAlign textAlign = TextAlign.start,
    @required TextDirection textDirection,
    bool softWrap = true,
    TextOverflow overflow = TextOverflow.clip,
    double textScaleFactor = 1.0,
    int maxLines,
    Locale locale,
    StrutStyle strutStyle,
    TextWidthBasis textWidthBasis = TextWidthBasis.parent,
    ui.TextHeightBehavior textHeightBehavior,
    List<RenderBox> children,

    // Editable
    Color backgroundCursorColor,
    Color cursorColor,
    double cursorWidth = 1.0,
    Radius cursorRadius,
    Offset cursorOffset,
    double devicePixelRatio = 1.0,
    bool hasFocus,
    this.ignorePointer = false,
    this.onCaretChanged,
    this.onSelectionChanged,
    bool paintCursorAboveText = false,
    TextSelection selection,
    Color selectionColor,
    ui.BoxHeightStyle selectionHeightStyle = ui.BoxHeightStyle.tight,
    ui.BoxWidthStyle selectionWidthStyle = ui.BoxWidthStyle.tight,
    ValueNotifier<bool> showCursor,
    @required LayerLink startHandleLayerLink,
    @required LayerLink endHandleLayerLink,

    // Custom
    @required this.textNodeEntries,
    @required this.node,
  })  :
        // RichText
        assert(text != null),
        assert(text.debugAssertIsValid()),
        assert(textAlign != null),
        assert(textDirection != null),
        assert(softWrap != null),
        assert(overflow != null),
        assert(textScaleFactor != null),
        assert(maxLines == null || maxLines > 0),
        assert(textWidthBasis != null),

        // Editable
        assert(ignorePointer != null),
        assert(selectionColor != null),
        assert(maxLines == null || maxLines > 0),
        assert(textWidthBasis != null),
        assert(paintCursorAboveText != null),
        assert(selectionHeightStyle != null),
        assert(selectionWidthStyle != null),
        assert(startHandleLayerLink != null),
        assert(endHandleLayerLink != null),

        // Custom
        assert(textNodeEntries != null),
        assert(node != null),

        // RichText
        _softWrap = softWrap,
        _overflow = overflow,
        _textPainter = TextPainter(
            text: text,
            textAlign: textAlign,
            textDirection: textDirection,
            textScaleFactor: textScaleFactor,
            maxLines: maxLines,
            ellipsis: overflow == TextOverflow.ellipsis ? _kEllipsis : null,
            locale: locale,
            strutStyle: strutStyle,
            textWidthBasis: textWidthBasis,
            textHeightBehavior: textHeightBehavior),
        // Editable
        _cursorColor = cursorColor,
        _backgroundCursorColor = backgroundCursorColor,
        _showCursor = showCursor ?? ValueNotifier<bool>(false),
        _selectionColor = selectionColor,
        _selection = selection,
        _cursorWidth = cursorWidth,
        _cursorRadius = cursorRadius,
        _paintCursorOnTop = paintCursorAboveText,
        _cursorOffset = cursorOffset,
        _devicePixelRatio = devicePixelRatio,
        _selectionHeightStyle = selectionHeightStyle,
        _selectionWidthStyle = selectionWidthStyle,
        _startHandleLayerLink = startHandleLayerLink,
        _endHandleLayerLink = endHandleLayerLink {
    // RichText
    addAll(children);
    _extractPlaceholderSpans(text);

    // Editable
    assert(_showCursor != null);
    assert(!_showCursor.value || cursorColor != null);
    this.hasFocus = hasFocus ?? false;
  }

  // #region RichText

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! TextParentData)
      child.parentData = TextParentData();
  }

  final TextPainter _textPainter;

  /// The text to display.
  InlineSpan get text => _textPainter.text;
  set text(InlineSpan value) {
    assert(value != null);
    switch (_textPainter.text.compareTo(value)) {
      case RenderComparison.identical:
      case RenderComparison.metadata:
        return;
      case RenderComparison.paint:
        _textPainter.text = value;
        _extractPlaceholderSpans(value);
        markNeedsPaint();
        markNeedsSemanticsUpdate();
        break;
      case RenderComparison.layout:
        _textPainter.text = value;
        _overflowShader = null;
        _extractPlaceholderSpans(value);
        markNeedsLayout();
        break;
    }
  }

  List<PlaceholderSpan> _placeholderSpans;
  void _extractPlaceholderSpans(InlineSpan span) {
    _placeholderSpans = <PlaceholderSpan>[];
    span.visitChildren((InlineSpan span) {
      if (span is PlaceholderSpan) {
        final PlaceholderSpan placeholderSpan = span;
        _placeholderSpans.add(placeholderSpan);
      }
      return true;
    });
  }

  /// How the text should be aligned horizontally.
  TextAlign get textAlign => _textPainter.textAlign;
  set textAlign(TextAlign value) {
    assert(value != null);
    if (_textPainter.textAlign == value) return;
    _textPainter.textAlign = value;
    markNeedsPaint();
  }

  /// The directionality of the text.
  ///
  /// This decides how the [TextAlign.start], [TextAlign.end], and
  /// [TextAlign.justify] values of [textAlign] are interpreted.
  ///
  /// This is also used to disambiguate how to render bidirectional text. For
  /// example, if the [text] is an English phrase followed by a Hebrew phrase,
  /// in a [TextDirection.ltr] context the English phrase will be on the left
  /// and the Hebrew phrase to its right, while in a [TextDirection.rtl]
  /// context, the English phrase will be on the right and the Hebrew phrase on
  /// its left.
  ///
  /// This must not be null.
  TextDirection get textDirection => _textPainter.textDirection;
  set textDirection(TextDirection value) {
    assert(value != null);
    if (_textPainter.textDirection == value) return;
    _textPainter.textDirection = value;
    markNeedsLayout();
  }

  /// Whether the text should break at soft line breaks.
  ///
  /// If false, the glyphs in the text will be positioned as if there was
  /// unlimited horizontal space.
  ///
  /// If [softWrap] is false, [overflow] and [textAlign] may have unexpected
  /// effects.
  bool get softWrap => _softWrap;
  bool _softWrap;
  set softWrap(bool value) {
    assert(value != null);
    if (_softWrap == value) return;
    _softWrap = value;
    markNeedsLayout();
  }

  /// How visual overflow should be handled.
  TextOverflow get overflow => _overflow;
  TextOverflow _overflow;
  set overflow(TextOverflow value) {
    assert(value != null);
    if (_overflow == value) return;
    _overflow = value;
    _textPainter.ellipsis = value == TextOverflow.ellipsis ? _kEllipsis : null;
    markNeedsLayout();
  }

  /// The number of font pixels for each logical pixel.
  ///
  /// For example, if the text scale factor is 1.5, text will be 50% larger than
  /// the specified font size.
  double get textScaleFactor => _textPainter.textScaleFactor;
  set textScaleFactor(double value) {
    assert(value != null);
    if (_textPainter.textScaleFactor == value) return;
    _textPainter.textScaleFactor = value;
    _overflowShader = null;
    markNeedsLayout();
  }

  /// An optional maximum number of lines for the text to span, wrapping if
  /// necessary. If the text exceeds the given number of lines, it will be
  /// truncated according to [overflow] and [softWrap].
  int get maxLines => _textPainter.maxLines;

  /// The value may be null. If it is not null, then it must be greater than
  /// zero.
  set maxLines(int value) {
    assert(value == null || value > 0);
    if (_textPainter.maxLines == value) return;
    _textPainter.maxLines = value;
    _overflowShader = null;
    markNeedsLayout();
  }

  /// Used by this paragraph's internal [TextPainter] to select a
  /// locale-specific font.
  ///
  /// In some cases the same Unicode character may be rendered differently
  /// depending
  /// on the locale. For example the '骨' character is rendered differently in
  /// the Chinese and Japanese locales. In these cases the [locale] may be used
  /// to select a locale-specific font.
  Locale get locale => _textPainter.locale;

  /// The value may be null.
  set locale(Locale value) {
    if (_textPainter.locale == value) return;
    _textPainter.locale = value;
    _overflowShader = null;
    markNeedsLayout();
  }

  /// {@macro flutter.painting.textPainter.strutStyle}
  StrutStyle get strutStyle => _textPainter.strutStyle;

  /// The value may be null.
  set strutStyle(StrutStyle value) {
    if (_textPainter.strutStyle == value) return;
    _textPainter.strutStyle = value;
    _overflowShader = null;
    markNeedsLayout();
  }

  /// {@macro flutter.widgets.basic.TextWidthBasis}
  TextWidthBasis get textWidthBasis => _textPainter.textWidthBasis;
  set textWidthBasis(TextWidthBasis value) {
    assert(value != null);
    if (_textPainter.textWidthBasis == value) return;
    _textPainter.textWidthBasis = value;
    _overflowShader = null;
    markNeedsLayout();
  }

  /// {@macro flutter.dart:ui.textHeightBehavior}
  ui.TextHeightBehavior get textHeightBehavior =>
      _textPainter.textHeightBehavior;
  set textHeightBehavior(ui.TextHeightBehavior value) {
    if (_textPainter.textHeightBehavior == value) return;
    _textPainter.textHeightBehavior = value;
    _overflowShader = null;
    markNeedsLayout();
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    if (!_canComputeIntrinsics()) {
      return 0.0;
    }
    _computeChildrenWidthWithMinIntrinsics(height);
    _layoutText(); // layout with infinite width.
    return _textPainter.minIntrinsicWidth;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    if (!_canComputeIntrinsics()) {
      return 0.0;
    }
    _computeChildrenWidthWithMaxIntrinsics(height);
    _layoutText(); // layout with infinite width.
    return _textPainter.maxIntrinsicWidth;
  }

  double _computeIntrinsicHeight(double width) {
    if (!_canComputeIntrinsics()) {
      return 0.0;
    }
    _computeChildrenHeightWithMinIntrinsics(width);
    _layoutText(minWidth: width, maxWidth: width);
    return _textPainter.height;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _computeIntrinsicHeight(width);
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return _computeIntrinsicHeight(width);
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    assert(!debugNeedsLayout);
    assert(constraints != null);
    assert(constraints.debugAssertIsValid());
    _layoutTextWithConstraints(constraints);
    // TODO(garyq): Since our metric for ideographic baseline is currently
    // inaccurate and the non-alphabetic baselines are based off of the
    // alphabetic baseline, we use the alphabetic for now to produce correct
    // layouts. We should eventually change this back to pass the `baseline`
    // property when the ideographic baseline is properly implemented
    // (https://github.com/flutter/flutter/issues/22625).
    return _textPainter
        .computeDistanceToActualBaseline(TextBaseline.alphabetic);
  }

  // Intrinsics cannot be calculated without a full layout for
  // alignments that require the baseline (baseline, aboveBaseline,
  // belowBaseline).
  bool _canComputeIntrinsics() {
    for (final PlaceholderSpan span in _placeholderSpans) {
      switch (span.alignment) {
        case ui.PlaceholderAlignment.baseline:
        case ui.PlaceholderAlignment.aboveBaseline:
        case ui.PlaceholderAlignment.belowBaseline:
          {
            assert(
                RenderObject.debugCheckingIntrinsics,
                'Intrinsics are not available for PlaceholderAlignment.baseline, '
                'PlaceholderAlignment.aboveBaseline, or PlaceholderAlignment.belowBaseline,');
            return false;
          }
        case ui.PlaceholderAlignment.top:
        case ui.PlaceholderAlignment.middle:
        case ui.PlaceholderAlignment.bottom:
          {
            continue;
          }
      }
    }
    return true;
  }

  void _computeChildrenWidthWithMaxIntrinsics(double height) {
    RenderBox child = firstChild;
    final List<PlaceholderDimensions> placeholderDimensions =
        List<PlaceholderDimensions>(childCount);
    int childIndex = 0;
    while (child != null) {
      // Height and baseline is irrelevant as all text will be laid
      // out in a single line.
      placeholderDimensions[childIndex] = PlaceholderDimensions(
        size: Size(child.getMaxIntrinsicWidth(height), height),
        alignment: _placeholderSpans[childIndex].alignment,
        baseline: _placeholderSpans[childIndex].baseline,
      );
      child = childAfter(child);
      childIndex += 1;
    }
    _textPainter.setPlaceholderDimensions(placeholderDimensions);
  }

  void _computeChildrenWidthWithMinIntrinsics(double height) {
    RenderBox child = firstChild;
    final List<PlaceholderDimensions> placeholderDimensions =
        List<PlaceholderDimensions>(childCount);
    int childIndex = 0;
    while (child != null) {
      final double intrinsicWidth = child.getMinIntrinsicWidth(height);
      final double intrinsicHeight =
          child.getMinIntrinsicHeight(intrinsicWidth);
      placeholderDimensions[childIndex] = PlaceholderDimensions(
        size: Size(intrinsicWidth, intrinsicHeight),
        alignment: _placeholderSpans[childIndex].alignment,
        baseline: _placeholderSpans[childIndex].baseline,
      );
      child = childAfter(child);
      childIndex += 1;
    }
    _textPainter.setPlaceholderDimensions(placeholderDimensions);
  }

  void _computeChildrenHeightWithMinIntrinsics(double width) {
    RenderBox child = firstChild;
    final List<PlaceholderDimensions> placeholderDimensions =
        List<PlaceholderDimensions>(childCount);
    int childIndex = 0;
    while (child != null) {
      final double intrinsicHeight = child.getMinIntrinsicHeight(width);
      final double intrinsicWidth = child.getMinIntrinsicWidth(intrinsicHeight);
      placeholderDimensions[childIndex] = PlaceholderDimensions(
        size: Size(intrinsicWidth, intrinsicHeight),
        alignment: _placeholderSpans[childIndex].alignment,
        baseline: _placeholderSpans[childIndex].baseline,
      );
      child = childAfter(child);
      childIndex += 1;
    }
    _textPainter.setPlaceholderDimensions(placeholderDimensions);
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    RenderBox child = firstChild;
    while (child != null) {
      final TextParentData textParentData = child.parentData as TextParentData;
      final Matrix4 transform = Matrix4.translationValues(
        textParentData.offset.dx,
        textParentData.offset.dy,
        0.0,
      )..scale(
          textParentData.scale,
          textParentData.scale,
          textParentData.scale,
        );
      final bool isHit = result.addWithPaintTransform(
        transform: transform,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(() {
            final Offset manualPosition =
                (position - textParentData.offset) / textParentData.scale;
            return (transformed.dx - manualPosition.dx).abs() <
                    precisionErrorTolerance &&
                (transformed.dy - manualPosition.dy).abs() <
                    precisionErrorTolerance;
          }());
          return child.hitTest(result, position: transformed);
        },
      );
      if (isHit) {
        return true;
      }
      child = childAfter(child);
    }
    return false;
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (event is! PointerDownEvent) return;
    _layoutTextWithConstraints(constraints);
    final Offset offset = entry.localPosition;
    final TextPosition position = _textPainter.getPositionForOffset(offset);
    final InlineSpan span = _textPainter.text.getSpanForPosition(position);
    if (span == null) {
      return;
    }
    if (span is TextSpan) {
      final TextSpan textSpan = span;
      textSpan.recognizer?.addPointer(event as PointerDownEvent);
    }
  }

  bool _needsClipping = false;
  ui.Shader _overflowShader;

  /// Whether this paragraph currently has a [dart:ui.Shader] for its overflow
  /// effect.
  ///
  /// Used to test this object. Not for use in production.
  @visibleForTesting
  bool get debugHasOverflowShader => _overflowShader != null;

  void _layoutText({double minWidth = 0.0, double maxWidth = double.infinity}) {
    final bool widthMatters = softWrap || overflow == TextOverflow.ellipsis;
    _textPainter.layout(
      minWidth: minWidth,
      maxWidth: widthMatters ? maxWidth : double.infinity,
    );
  }

  @override
  void systemFontsDidChange() {
    super.systemFontsDidChange();
    _textPainter.markNeedsLayout();
  }

  // Placeholder dimensions representing the sizes of child inline widgets.
  //
  // These need to be cached because the text painter's placeholder dimensions
  // will be overwritten during intrinsic width/height calculations and must be
  // restored to the original values before final layout and painting.
  List<PlaceholderDimensions> _placeholderDimensions;

  void _layoutTextWithConstraints(BoxConstraints constraints) {
    _textPainter.setPlaceholderDimensions(_placeholderDimensions);
    _layoutText(minWidth: constraints.minWidth, maxWidth: constraints.maxWidth);
  }

  // Layout the child inline widgets. We then pass the dimensions of the
  // children to _textPainter so that appropriate placeholders can be inserted
  // into the LibTxt layout. This does not do anything if no inline widgets were
  // specified.
  void _layoutChildren(BoxConstraints constraints) {
    if (childCount == 0) {
      return;
    }
    RenderBox child = firstChild;
    _placeholderDimensions = List<PlaceholderDimensions>(childCount);
    int childIndex = 0;
    while (child != null) {
      // Only constrain the width to the maximum width of the paragraph.
      // Leave height unconstrained, which will overflow if expanded past.
      child.layout(
        BoxConstraints(
          maxWidth: constraints.maxWidth,
        ),
        parentUsesSize: true,
      );
      double baselineOffset;
      switch (_placeholderSpans[childIndex].alignment) {
        case ui.PlaceholderAlignment.baseline:
          {
            baselineOffset = child
                .getDistanceToBaseline(_placeholderSpans[childIndex].baseline);
            break;
          }
        default:
          {
            baselineOffset = null;
            break;
          }
      }
      _placeholderDimensions[childIndex] = PlaceholderDimensions(
        size: child.size,
        alignment: _placeholderSpans[childIndex].alignment,
        baseline: _placeholderSpans[childIndex].baseline,
        baselineOffset: baselineOffset,
      );
      child = childAfter(child);
      childIndex += 1;
    }
  }

  // Iterate through the laid-out children and set the parentData offsets based
  // off of the placeholders inserted for each child.
  void _setParentData() {
    RenderBox child = firstChild;
    int childIndex = 0;
    while (child != null &&
        childIndex < _textPainter.inlinePlaceholderBoxes.length) {
      final TextParentData textParentData = child.parentData as TextParentData;
      textParentData.offset = Offset(
        _textPainter.inlinePlaceholderBoxes[childIndex].left,
        _textPainter.inlinePlaceholderBoxes[childIndex].top,
      );
      textParentData.scale = _textPainter.inlinePlaceholderScales[childIndex];
      child = childAfter(child);
      childIndex += 1;
    }
  }

  @override
  void performLayout() {
    // RichText
    final BoxConstraints constraints = this.constraints;
    _layoutChildren(constraints);
    _layoutTextWithConstraints(constraints);
    _setParentData();

    // We grab _textPainter.size and _textPainter.didExceedMaxLines here because
    // assigning to `size` will trigger us to validate our intrinsic sizes,
    // which will change _textPainter's layout because the intrinsic size
    // calculations are destructive. Other _textPainter state will also be
    // affected. See also RenderEditable which has a similar issue.
    final Size textSize = _textPainter.size;
    final bool textDidExceedMaxLines = _textPainter.didExceedMaxLines;
    size = constraints.constrain(textSize);

    final bool didOverflowHeight =
        size.height < textSize.height || textDidExceedMaxLines;
    final bool didOverflowWidth = size.width < textSize.width;
    // TODO(abarth): We're only measuring the sizes of the line boxes here. If
    // the glyphs draw outside the line boxes, we might think that there isn't
    // visual overflow when there actually is visual overflow. This can become
    // a problem if we start having horizontal overflow and introduce a clip
    // that affects the actual (but undetected) vertical overflow.
    final bool hasVisualOverflow = didOverflowWidth || didOverflowHeight;
    if (hasVisualOverflow) {
      switch (_overflow) {
        case TextOverflow.visible:
          _needsClipping = false;
          _overflowShader = null;
          break;
        case TextOverflow.clip:
        case TextOverflow.ellipsis:
          _needsClipping = true;
          _overflowShader = null;
          break;
        case TextOverflow.fade:
          assert(textDirection != null);
          _needsClipping = true;
          final TextPainter fadeSizePainter = TextPainter(
            text: TextSpan(style: _textPainter.text.style, text: '\u2026'),
            textDirection: textDirection,
            textScaleFactor: textScaleFactor,
            locale: locale,
          )..layout();
          if (didOverflowWidth) {
            double fadeEnd, fadeStart;
            switch (textDirection) {
              case TextDirection.rtl:
                fadeEnd = 0.0;
                fadeStart = fadeSizePainter.width;
                break;
              case TextDirection.ltr:
                fadeEnd = size.width;
                fadeStart = fadeEnd - fadeSizePainter.width;
                break;
            }
            _overflowShader = ui.Gradient.linear(
              Offset(fadeStart, 0.0),
              Offset(fadeEnd, 0.0),
              <Color>[const Color(0xFFFFFFFF), const Color(0x00FFFFFF)],
            );
          } else {
            final double fadeEnd = size.height;
            final double fadeStart = fadeEnd - fadeSizePainter.height / 2.0;
            _overflowShader = ui.Gradient.linear(
              Offset(0.0, fadeStart),
              Offset(0.0, fadeEnd),
              <Color>[const Color(0xFFFFFFFF), const Color(0x00FFFFFF)],
            );
          }
          break;
      }
    } else {
      _needsClipping = false;
      _overflowShader = null;
    }

    // Editable
    _caretPrototype = _getCaretPrototype;
    _selectionRects = null;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // assert(
    //     _textLayoutLastMaxWidth == constraints.maxWidth &&
    //         _textLayoutLastMinWidth == constraints.minWidth,
    //     'Last width ($_textLayoutLastMinWidth, $_textLayoutLastMaxWidth) not the same as max width constraint (${constraints.minWidth}, ${constraints.maxWidth}).');
    final Offset effectiveOffset = offset;
    // Ideally we could compute the min/max intrinsic width/height with a
    // non-destructive operation. However, currently, computing these values
    // will destroy state inside the painter. If that happens, we need to get
    // back the correct state by calling _layout again.
    //
    // TODO(abarth): Make computing the min/max intrinsic width/height a
    //  non-destructive operation.
    //
    // If you remove this call, make sure that changing the textAlign still
    // works properly.
    _layoutTextWithConstraints(constraints);

    bool showSelection = false;
    bool showCaret = false;

    if (_selection != null && !_floatingCursorOn) {
      if (_selection.isCollapsed && _showCursor.value && cursorColor != null) {
        showCaret = true;
      } else if (!_selection.isCollapsed && _selectionColor != null) {
        showSelection = true;
      }

      // _updateSelectionExtentsVisibility(effectiveOffset);
    }

    if (showSelection) {
      _selectionRects ??= _textPainter.getBoxesForSelection(_selection,
          boxHeightStyle: _selectionHeightStyle,
          boxWidthStyle: _selectionWidthStyle);
      _paintSelection(context.canvas, effectiveOffset);
    }

    assert(() {
      if (debugRepaintTextRainbowEnabled) {
        final Paint paint = Paint()..color = debugCurrentRepaintColor.toColor();
        context.canvas.drawRect(offset & size, paint);
      }
      return true;
    }());

    if (_needsClipping) {
      final Rect bounds = offset & size;
      if (_overflowShader != null) {
        // This layer limits what the shader below blends with to be just the
        // text (as opposed to the text and its background).
        context.canvas.saveLayer(bounds, Paint());
      } else {
        context.canvas.save();
      }
      context.canvas.clipRect(bounds);
    }

    // On iOS, the cursor is painted over the text, on Android, it's painted
    // under it.
    if (paintCursorAboveText) {
      _textPainter.paint(context.canvas, effectiveOffset);
    }

    if (showCaret) {
      _paintCaret(context.canvas, effectiveOffset, _selection.extent);
    }

    if (!paintCursorAboveText) {
      _textPainter.paint(context.canvas, effectiveOffset);
    }

    // if (_floatingCursorOn) {
    //   if (_resetFloatingCursorAnimationValue == null)
    //     _paintCaret(context.canvas, effectiveOffset, _floatingCursorTextPosition);
    //   _paintFloatingCaret(context.canvas, _floatingCursorOffset);
    // }

    RenderBox child = firstChild;
    int childIndex = 0;
    // childIndex might be out of index of placeholder boxes. This can happen
    // if engine truncates children due to ellipsis. Sadly, we would not know
    // it until we finish layout, and RenderObject is in immutable state at
    // this point.
    while (child != null &&
        childIndex < _textPainter.inlinePlaceholderBoxes.length) {
      final TextParentData textParentData = child.parentData as TextParentData;

      final double scale = textParentData.scale;
      context.pushTransform(
        needsCompositing,
        offset + textParentData.offset,
        Matrix4.diagonal3Values(scale, scale, scale),
        (PaintingContext context, Offset offset) {
          context.paintChild(
            child,
            offset,
          );
        },
      );
      child = childAfter(child);
      childIndex += 1;
    }
    if (_needsClipping) {
      if (_overflowShader != null) {
        context.canvas.translate(offset.dx, offset.dy);
        final Paint paint = Paint()
          ..blendMode = BlendMode.modulate
          ..shader = _overflowShader;
        context.canvas.drawRect(Offset.zero & size, paint);
      }
      context.canvas.restore();
    }

    if (selection != null) {
      _paintHandleLayers(context, getEndpointsForSelection(selection));
    }
  }

  List<TextSelectionPoint> getEndpointsForSelection(TextSelection selection) {
    assert(constraints != null);
    _layoutText(minWidth: constraints.minWidth, maxWidth: constraints.maxWidth);

    if (selection.isCollapsed) {
      // TODO(mpcomplete): This doesn't work well at an RTL/LTR boundary.
      final Offset caretOffset =
          _textPainter.getOffsetForCaret(selection.extent, _caretPrototype);
      final Offset start = Offset(0.0, preferredLineHeight) + caretOffset;
      return <TextSelectionPoint>[TextSelectionPoint(start, null)];
    } else {
      final List<ui.TextBox> boxes =
          _textPainter.getBoxesForSelection(selection);
      final Offset start = Offset(boxes.first.start, boxes.first.bottom);
      final Offset end = Offset(boxes.last.end, boxes.last.bottom);
      return <TextSelectionPoint>[
        TextSelectionPoint(start, boxes.first.direction),
        TextSelectionPoint(end, boxes.last.direction),
      ];
    }
  }

  /// Returns the offset at which to paint the caret.
  ///
  /// Valid only after [layout].
  Offset getOffsetForCaret(TextPosition position, Rect caretPrototype) {
    assert(!debugNeedsLayout);
    _layoutTextWithConstraints(constraints);
    return _textPainter.getOffsetForCaret(position, caretPrototype);
  }

  /// Returns a list of rects that bound the given selection.
  ///
  /// A given selection might have more than one rect if this text painter
  /// contains bidirectional text because logically contiguous text might not be
  /// visually contiguous.
  ///
  /// Valid only after [layout].
  List<ui.TextBox> getBoxesForSelection(TextSelection selection) {
    assert(!debugNeedsLayout);
    _layoutTextWithConstraints(constraints);
    return _textPainter.getBoxesForSelection(selection);
  }

  /// Returns the position within the text for the given pixel offset.
  ///
  /// Valid only after [layout].
  TextPosition getPositionForOffset(Offset offset) {
    assert(!debugNeedsLayout);
    _layoutTextWithConstraints(constraints);
    return _textPainter.getPositionForOffset(offset);
  }

  /// Returns the text range of the word at the given offset. Characters not
  /// part of a word, such as spaces, symbols, and punctuation, have word breaks
  /// on both sides. In such cases, this method will return a text range that
  /// contains the given text position.
  ///
  /// Word boundaries are defined more precisely in Unicode Standard Annex #29
  /// <http://www.unicode.org/reports/tr29/#Word_Boundaries>.
  ///
  /// Valid only after [layout].
  TextRange getWordBoundary(TextPosition position) {
    assert(!debugNeedsLayout);
    _layoutTextWithConstraints(constraints);
    return _textPainter.getWordBoundary(position);
  }

  /// Returns the size of the text as laid out.
  ///
  /// This can differ from [size] if the text overflowed or if the [constraints]
  /// provided by the parent [RenderObject] forced the layout to be bigger than
  /// necessary for the given [text].
  ///
  /// This returns the [TextPainter.size] of the underlying [TextPainter].
  ///
  /// Valid only after [layout].
  Size get textSize {
    assert(!debugNeedsLayout);
    return _textPainter.size;
  }

  /// Collected during [describeSemanticsConfiguration], used by
  /// [assembleSemanticsNode] and [_combineSemanticsInfo].
  List<InlineSpanSemanticsInformation> _semanticsInfo;

  /// Combines _semanticsInfo entries where permissible, determined by
  /// [InlineSpanSemanticsInformation.requiresOwnNode].
  List<InlineSpanSemanticsInformation> _combineSemanticsInfo() {
    assert(_semanticsInfo != null);
    final List<InlineSpanSemanticsInformation> combined =
        <InlineSpanSemanticsInformation>[];
    String workingText = '';
    String workingLabel;
    for (final InlineSpanSemanticsInformation info in _semanticsInfo) {
      if (info.requiresOwnNode) {
        if (workingText != null) {
          combined.add(InlineSpanSemanticsInformation(
            workingText,
            semanticsLabel: workingLabel ?? workingText,
          ));
          workingText = '';
          workingLabel = null;
        }
        combined.add(info);
      } else {
        workingText += info.text;
        workingLabel ??= '';
        if (info.semanticsLabel != null) {
          workingLabel += info.semanticsLabel;
        } else {
          workingLabel += info.text;
        }
      }
    }
    if (workingText != null) {
      combined.add(InlineSpanSemanticsInformation(
        workingText,
        semanticsLabel: workingLabel,
      ));
    } else {
      assert(workingLabel != null);
    }
    return combined;
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    _semanticsInfo = text.getSemanticsInformation();

    if (_semanticsInfo.any(
        (InlineSpanSemanticsInformation info) => info.recognizer != null)) {
      config.explicitChildNodes = true;
      config.isSemanticBoundary = true;
    } else {
      final StringBuffer buffer = StringBuffer();
      for (final InlineSpanSemanticsInformation info in _semanticsInfo) {
        buffer.write(info.semanticsLabel ?? info.text);
      }
      config.label = buffer.toString();
      config.textDirection = textDirection;
    }
  }

  // Caches [SemanticsNode]s created during [assembleSemanticsNode] so they
  // can be re-used when [assembleSemanticsNode] is called again. This ensures
  // stable ids for the [SemanticsNode]s of [TextSpan]s across
  // [assembleSemanticsNode] invocations.
  Queue<SemanticsNode> _cachedChildNodes;

  @override
  void assembleSemanticsNode(SemanticsNode node, SemanticsConfiguration config,
      Iterable<SemanticsNode> children) {
    assert(_semanticsInfo != null && _semanticsInfo.isNotEmpty);
    final List<SemanticsNode> newChildren = <SemanticsNode>[];
    TextDirection currentDirection = textDirection;
    Rect currentRect;
    double ordinal = 0.0;
    int start = 0;
    int placeholderIndex = 0;
    RenderBox child = firstChild;
    final Queue<SemanticsNode> newChildCache = Queue<SemanticsNode>();
    for (final InlineSpanSemanticsInformation info in _combineSemanticsInfo()) {
      final TextDirection initialDirection = currentDirection;
      final TextSelection selection = TextSelection(
        baseOffset: start,
        extentOffset: start + info.text.length,
      );
      final List<ui.TextBox> rects = getBoxesForSelection(selection);
      if (rects.isEmpty) {
        continue;
      }
      Rect rect = rects.first.toRect();
      currentDirection = rects.first.direction;
      for (final ui.TextBox textBox in rects.skip(1)) {
        rect = rect.expandToInclude(textBox.toRect());
        currentDirection = textBox.direction;
      }
      // Any of the text boxes may have had infinite dimensions.
      // We shouldn't pass infinite dimensions up to the bridges.
      rect = Rect.fromLTWH(
        math.max(0.0, rect.left),
        math.max(0.0, rect.top),
        math.min(rect.width, constraints.maxWidth),
        math.min(rect.height, constraints.maxHeight),
      );
      // round the current rectangle to make this API testable and add some
      // padding so that the accessibility rects do not overlap with the text.
      currentRect = Rect.fromLTRB(
        rect.left.floorToDouble() - 4.0,
        rect.top.floorToDouble() - 4.0,
        rect.right.ceilToDouble() + 4.0,
        rect.bottom.ceilToDouble() + 4.0,
      );

      if (info.isPlaceholder) {
        final SemanticsNode childNode = children.elementAt(placeholderIndex++);
        final TextParentData parentData = child.parentData as TextParentData;
        childNode.rect = Rect.fromLTWH(
          childNode.rect.left,
          childNode.rect.top,
          childNode.rect.width * parentData.scale,
          childNode.rect.height * parentData.scale,
        );
        newChildren.add(childNode);
        child = childAfter(child);
      } else {
        final SemanticsConfiguration configuration = SemanticsConfiguration()
          ..sortKey = OrdinalSortKey(ordinal++)
          ..textDirection = initialDirection
          ..label = info.semanticsLabel ?? info.text;
        final GestureRecognizer recognizer = info.recognizer;
        if (recognizer != null) {
          if (recognizer is TapGestureRecognizer) {
            configuration.onTap = recognizer.onTap;
            configuration.isLink = true;
          } else if (recognizer is LongPressGestureRecognizer) {
            configuration.onLongPress = recognizer.onLongPress;
          } else {
            assert(false);
          }
        }
        final SemanticsNode newChild = (_cachedChildNodes?.isNotEmpty == true)
            ? _cachedChildNodes.removeFirst()
            : SemanticsNode();
        newChild
          ..updateWith(config: configuration)
          ..rect = currentRect;
        newChildCache.addLast(newChild);
        newChildren.add(newChild);
      }
      start += info.text.length;
    }
    _cachedChildNodes = newChildCache;
    node.updateWith(config: config, childrenInInversePaintOrder: newChildren);
  }

  @override
  void clearSemantics() {
    super.clearSemantics();
    _cachedChildNodes = null;
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    return <DiagnosticsNode>[
      text.toDiagnosticsNode(
        name: 'text',
        style: DiagnosticsTreeStyle.transition,
      )
    ];
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<TextAlign>('textAlign', textAlign));
    properties.add(EnumProperty<TextDirection>('textDirection', textDirection));
    properties.add(FlagProperty(
      'softWrap',
      value: softWrap,
      ifTrue: 'wrapping at box width',
      ifFalse: 'no wrapping except at line break characters',
      showName: true,
    ));
    properties.add(EnumProperty<TextOverflow>('overflow', overflow));
    properties.add(DoubleProperty(
      'textScaleFactor',
      textScaleFactor,
      defaultValue: 1.0,
    ));
    properties.add(DiagnosticsProperty<Locale>(
      'locale',
      locale,
      defaultValue: null,
    ));
    properties.add(IntProperty('maxLines', maxLines, ifNull: 'unlimited'));
  }

  // #endregion

  // #region Editable

  TapGestureRecognizer _tap;
  LongPressGestureRecognizer _longPress;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _tap = TapGestureRecognizer(debugOwner: this)
      ..onTapDown = _handleTapDown
      ..onTap = _handleTap;
    _longPress = LongPressGestureRecognizer(debugOwner: this)
      ..onLongPress = _handleLongPress;
    // _offset.addListener(markNeedsPaint);
    _showCursor.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _showCursor.removeListener(markNeedsPaint);
    _tap.dispose();
    _longPress.dispose();
    // _offset.removeListener(markNeedsPaint);
    // if (_listenerAttached)
    //   RawKeyboard.instance.removeListener(_handleKeyEvent);
    super.detach();
  }

  /// Called when the selection changes.
  ///
  /// If this is null, then selection changes will be ignored.
  SelectionChangedHandler onSelectionChanged;

  /// If true [handleEvent] does nothing and it's assumed that this
  /// renderer will be notified of input gestures via [handleTapDown],
  /// [handleTap], [handleDoubleTap], and [handleLongPress].
  ///
  /// The default value of this property is false.
  bool ignorePointer;

  Offset _lastTapDownPosition;

  /// If [ignorePointer] is false (the default) then this method is called by
  /// the internal gesture recognizer's [TapGestureRecognizer.onTapDown]
  /// callback.
  ///
  /// When [ignorePointer] is true, an ancestor widget must respond to tap
  /// down events by calling this method.
  void handleTapDown(TapDownDetails details) {
    _lastTapDownPosition = details.globalPosition;
  }

  void _handleTapDown(TapDownDetails details) {
    assert(!ignorePointer);
    handleTapDown(details);
  }

  /// If [ignorePointer] is false (the default) then this method is called by
  /// the internal gesture recognizer's [TapGestureRecognizer.onTap]
  /// callback.
  ///
  /// When [ignorePointer] is true, an ancestor widget must respond to tap
  /// events by calling this method.
  void handleTap() {
    selectPosition(cause: SelectionChangedCause.tap);
  }

  void _handleTap() {
    assert(!ignorePointer);
    handleTap();
  }

  /// If [ignorePointer] is false (the default) then this method is called by
  /// the internal gesture recognizer's [DoubleTapGestureRecognizer.onDoubleTap]
  /// callback.
  ///
  /// When [ignorePointer] is true, an ancestor widget must respond to double
  /// tap events by calling this method.
  void handleDoubleTap() {
    selectWord(cause: SelectionChangedCause.doubleTap);
  }

  /// If [ignorePointer] is false (the default) then this method is called by
  /// the internal gesture recognizer's [LongPressGestureRecognizer.onLongPress]
  /// callback.
  ///
  /// When [ignorePointer] is true, an ancestor widget must respond to long
  /// press events by calling this method.
  void handleLongPress() {
    selectWord(cause: SelectionChangedCause.longPress);
  }

  void _handleLongPress() {
    assert(!ignorePointer);
    handleLongPress();
  }

  // Call through to onSelectionChanged.
  void _handleSelectionChange(
    TextSelection nextSelection,
    SelectionChangedCause cause,
  ) {
    // Changes made by the keyboard can sometimes be "out of band" for listening
    // components, so always send those events, even if we didn't think it
    // changed. Also, focusing an empty field is sent as a selection change even
    // if the selection offset didn't change.
    final bool focusingEmpty = nextSelection.baseOffset == 0 &&
        nextSelection.extentOffset == 0 &&
        !hasFocus;
    if (nextSelection == selection &&
        cause != SelectionChangedCause.keyboard &&
        !focusingEmpty) {
      return;
    }
    if (onSelectionChanged != null) {
      onSelectionChanged(nextSelection, this, cause);
    }
  }

  void selectPosition({@required SelectionChangedCause cause}) {
    selectPositionAt(from: _lastTapDownPosition, cause: cause);
  }

  /// Select text between the global positions [from] and [to].
  void selectPositionAt(
      {@required Offset from,
      Offset to,
      @required SelectionChangedCause cause}) {
    assert(cause != null);
    assert(from != null);
    _layoutText(minWidth: constraints.minWidth, maxWidth: constraints.maxWidth);
    if (onSelectionChanged == null) {
      return;
    }
    final TextPosition fromPosition =
        _textPainter.getPositionForOffset(globalToLocal(from));
    final TextPosition toPosition = to == null
        ? null
        : _textPainter.getPositionForOffset(globalToLocal(to));

    int baseOffset = fromPosition.offset;
    int extentOffset = fromPosition.offset;
    if (toPosition != null) {
      baseOffset = math.min(fromPosition.offset, toPosition.offset);
      extentOffset = math.max(fromPosition.offset, toPosition.offset);
    }

    final TextSelection newSelection = TextSelection(
      baseOffset: baseOffset,
      extentOffset: extentOffset,
      affinity: fromPosition.affinity,
    );
    // Call [onSelectionChanged] only when the selection actually changed.
    _handleSelectionChange(newSelection, cause);
  }

  /// Select a word around the location of the last tap down.
  ///
  /// {@macro flutter.rendering.editable.select}
  void selectWord({@required SelectionChangedCause cause}) {
    selectWordsInRange(from: _lastTapDownPosition, cause: cause);
  }

  /// Selects the set words of a paragraph in a given range of global positions.
  ///
  /// The first and last endpoints of the selection will always be at the
  /// beginning and end of a word respectively.
  ///
  /// {@macro flutter.rendering.editable.select}
  void selectWordsInRange(
      {@required Offset from,
      Offset to,
      @required SelectionChangedCause cause}) {
    assert(cause != null);
    assert(from != null);
    _layoutText(minWidth: constraints.minWidth, maxWidth: constraints.maxWidth);
    if (onSelectionChanged == null) {
      return;
    }
    final TextPosition firstPosition =
        _textPainter.getPositionForOffset(globalToLocal(from));
    final TextSelection firstWord = _selectWordAtOffset(firstPosition);
    final TextSelection lastWord = to == null
        ? firstWord
        : _selectWordAtOffset(
            _textPainter.getPositionForOffset(globalToLocal(to)));

    _handleSelectionChange(
      TextSelection(
        baseOffset: firstWord.base.offset,
        extentOffset: lastWord.extent.offset,
        affinity: firstWord.affinity,
      ),
      cause,
    );
  }

  /// Move the selection to the beginning or end of a word.
  ///
  /// {@macro flutter.rendering.editable.select}
  void selectWordEdge({@required SelectionChangedCause cause}) {
    assert(cause != null);
    _layoutText(minWidth: constraints.minWidth, maxWidth: constraints.maxWidth);
    assert(_lastTapDownPosition != null);
    if (onSelectionChanged == null) {
      return;
    }
    final TextPosition position =
        _textPainter.getPositionForOffset(globalToLocal(_lastTapDownPosition));
    final TextRange word = _textPainter.getWordBoundary(position);
    if (position.offset - word.start <= 1) {
      _handleSelectionChange(
        TextSelection.collapsed(
            offset: word.start, affinity: TextAffinity.downstream),
        cause,
      );
    } else {
      _handleSelectionChange(
        TextSelection.collapsed(
            offset: word.end, affinity: TextAffinity.upstream),
        cause,
      );
    }
  }

  TextSelection _selectWordAtOffset(TextPosition position) {
    // assert(
    //     _textLayoutLastMaxWidth == constraints.maxWidth &&
    //         _textLayoutLastMinWidth == constraints.minWidth,
    //     'Last width ($_textLayoutLastMinWidth, $_textLayoutLastMaxWidth) not the same as max width constraint (${constraints.minWidth}, ${constraints.maxWidth}).');
    final TextRange word = _textPainter.getWordBoundary(position);
    // When long-pressing past the end of the text, we want a collapsed cursor.
    if (position.offset >= word.end)
      return TextSelection.fromPosition(position);

    return TextSelection(baseOffset: word.start, extentOffset: word.end);
  }

  TextSelection _selectLineAtOffset(TextPosition position) {
    // assert(
    //     _textLayoutLastMaxWidth == constraints.maxWidth &&
    //         _textLayoutLastMinWidth == constraints.minWidth,
    //     'Last width ($_textLayoutLastMinWidth, $_textLayoutLastMaxWidth) not the same as max width constraint (${constraints.minWidth}, ${constraints.maxWidth}).');
    final TextRange line = _textPainter.getLineBoundary(position);
    if (position.offset >= line.end)
      return TextSelection.fromPosition(position);

    return TextSelection(baseOffset: line.start, extentOffset: line.end);
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
    assert(value != null);
    if (_showCursor == value) return;
    if (attached) _showCursor.removeListener(markNeedsPaint);
    _showCursor = value;
    if (attached) _showCursor.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  /// Controls how tall the selection highlight boxes are computed to be.
  ///
  /// See [ui.BoxHeightStyle] for details on available styles.
  ui.BoxHeightStyle get selectionHeightStyle => _selectionHeightStyle;
  ui.BoxHeightStyle _selectionHeightStyle;
  set selectionHeightStyle(ui.BoxHeightStyle value) {
    assert(value != null);
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
    assert(value != null);
    if (_selectionWidthStyle == value) return;
    _selectionWidthStyle = value;
    markNeedsPaint();
  }

  /// The color to use when painting the selection.
  Color get selectionColor => _selectionColor;
  Color _selectionColor;
  set selectionColor(Color value) {
    if (_selectionColor == value) return;
    _selectionColor = value;
    markNeedsPaint();
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

  /// How thick the cursor will be.
  double get cursorWidth => _cursorWidth;
  double _cursorWidth = 1.0;
  set cursorWidth(double value) {
    if (_cursorWidth == value) return;
    _cursorWidth = value;
    markNeedsLayout();
  }

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

  double _textLayoutLastMaxWidth;
  double _textLayoutLastMinWidth;

  /// Marks the render object as needing to be laid out again and have its text
  /// metrics recomputed.
  ///
  /// Implies [markNeedsTextLayout].
  @protected
  void markNeedsTextLayout() {
    _textLayoutLastMaxWidth = null;
    _textLayoutLastMinWidth = null;
    markNeedsTextLayout();
  }

  /// Whether the editable is currently focused.
  bool get hasFocus => _hasFocus;
  bool _hasFocus = false;
  bool _listenerAttached = false;
  set hasFocus(bool value) {
    assert(value != null);
    if (_hasFocus == value) return;
    _hasFocus = value;
    if (_hasFocus) {
      assert(!_listenerAttached);
      // TODO: Add keyboard support
      // RawKeyboard.instance.addListener(_handleKeyEvent);
      _listenerAttached = true;
    } else {
      assert(_listenerAttached);
      // TODO: Add keyboard support
      // RawKeyboard.instance.removeListener(_handleKeyEvent);
      _listenerAttached = false;
    }
    markNeedsSemanticsUpdate();
  }

  Rect _caretPrototype;
  Rect _lastCaretRect;

  bool _floatingCursorOn = false;
  Offset _floatingCursorOffset;
  TextPosition _floatingCursorTextPosition;

  /// Called during the paint phase when the caret location changes.
  CaretChangedHandler onCaretChanged;

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

  /// An estimate of the height of a line in the text. See [TextPainter.preferredLineHeight].
  /// This does not required the layout to be updated.
  double get preferredLineHeight => _textPainter.preferredLineHeight;

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

  void _paintSelection(Canvas canvas, Offset effectiveOffset) {
    // assert(
    //     _textLayoutLastMaxWidth == constraints.maxWidth &&
    //         _textLayoutLastMinWidth == constraints.minWidth,
    //     'Last width ($_textLayoutLastMinWidth, $_textLayoutLastMaxWidth) not the same as max width constraint (${constraints.minWidth}, ${constraints.maxWidth}).');
    assert(_selectionRects != null);
    final Paint paint = Paint()..color = _selectionColor;
    for (final ui.TextBox box in _selectionRects)
      canvas.drawRect(box.toRect().shift(effectiveOffset), paint);
  }

  void _paintCaret(
      Canvas canvas, Offset effectiveOffset, TextPosition textPosition) {
    // assert(
    //     _textLayoutLastMaxWidth == constraints.maxWidth &&
    //         _textLayoutLastMinWidth == constraints.minWidth,
    //     'Last width ($_textLayoutLastMinWidth, $_textLayoutLastMaxWidth) not the same as max width constraint (${constraints.minWidth}, ${constraints.maxWidth}).');

    // If the floating cursor is enabled, the text cursor's color is [backgroundCursorColor] while
    // the floating cursor's color is _cursorColor;
    final Paint paint = Paint()
      ..color = _floatingCursorOn ? backgroundCursorColor : _cursorColor;
    final Offset offsetForCaret =
        _textPainter.getOffsetForCaret(textPosition, _caretPrototype);
    final Offset caretOffset = offsetForCaret + effectiveOffset;
    Rect caretRect = _caretPrototype.shift(caretOffset);
    if (_cursorOffset != null) caretRect = caretRect.shift(_cursorOffset);

    final double caretHeight =
        _textPainter.getFullHeightForCaret(textPosition, _caretPrototype);
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
          // Override the height to take the full height of the glyph at the TextPosition
          // when not on iOS. iOS has special handling that creates a taller caret.
          // TODO(garyq): See the TODO for _getCaretPrototype.
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

  void _paintHandleLayers(
      PaintingContext context, List<TextSelectionPoint> endpoints) {
    Offset startPoint = endpoints[0].point;
    startPoint = Offset(
      startPoint.dx.clamp(0.0, size.width) as double,
      startPoint.dy.clamp(0.0, size.height) as double,
    );
    context.pushLayer(
      LeaderLayer(link: startHandleLayerLink, offset: startPoint),
      super.paint,
      Offset.zero,
    );
    if (endpoints.length == 2) {
      Offset endPoint = endpoints[1].point;
      endPoint = Offset(
        endPoint.dx.clamp(0.0, size.width) as double,
        endPoint.dy.clamp(0.0, size.height) as double,
      );
      context.pushLayer(
        LeaderLayer(link: endHandleLayerLink, offset: endPoint),
        super.paint,
        Offset.zero,
      );
    }
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

  // #endregion

  // #region Custom
  List<TextNodeEntry> textNodeEntries;
  Stela.Element node;
}
