// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A paragraph of rich text.
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=rykDVh-QFfw}
///
/// The [RichText] widget displays text that uses multiple different styles. The
/// text to display is described using a tree of [TextSpan] objects, each of
/// which has an associated style that is used for that subtree. The text might
/// break across multiple lines or might all be displayed on the same line
/// depending on the layout constraints.
///
/// Text displayed in a [RichText] widget must be explicitly styled. When
/// picking which style to use, consider using [DefaultTextStyle.of] the current
/// [BuildContext] to provide defaults. For more details on how to style text in
/// a [RichText] widget, see the documentation for [TextStyle].
///
/// Consider using the [Text] widget to integrate with the [DefaultTextStyle]
/// automatically. When all the text uses the same style, the default constructor
/// is less verbose. The [Text.rich] constructor allows you to style multiple
/// spans with the default text style while still allowing specified styles per
/// span.
///
/// {@tool snippet}
///
/// This sample demonstrates how to mix and match text with different text
/// styles using the [RichText] Widget. It displays the text "Hello bold world,"
/// emphasizing the word "bold" using a bold font weight.
///
/// ![](https://flutter.github.io/assets-for-api-docs/assets/widgets/rich_text.png)
///
/// ```dart
/// RichText(
///   text: TextSpan(
///     text: 'Hello ',
///     style: DefaultTextStyle.of(context).style,
///     children: <TextSpan>[
///       TextSpan(text: 'bold', style: TextStyle(fontWeight: FontWeight.bold)),
///       TextSpan(text: ' world!'),
///     ],
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [TextStyle], which discusses how to style text.
///  * [TextSpan], which is used to describe the text in a paragraph.
///  * [Text], which automatically applies the ambient styles described by a
///    [DefaultTextStyle] to a single string.
///  * [Text.rich], a const text widget that provides similar functionality
///    as [RichText]. [Text.rich] will inherit [TextStyle] from [DefaultTextStyle].
class RichText extends MultiChildRenderObjectWidget {
  /// Creates a paragraph of rich text.
  ///
  /// The [text], [textAlign], [softWrap], [overflow], and [textScaleFactor]
  /// arguments must not be null.
  ///
  /// The [maxLines] property may be null (and indeed defaults to null), but if
  /// it is not null, it must be greater than zero.
  ///
  /// The [textDirection], if null, defaults to the ambient [Directionality],
  /// which in that case must not be null.
  RichText({
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
  })  : assert(text != null),
        assert(textAlign != null),
        assert(softWrap != null),
        assert(overflow != null),
        assert(textScaleFactor != null),
        assert(maxLines == null || maxLines > 0),
        assert(textWidthBasis != null),
        super(key: key, children: _extractChildren(text));

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

  /// The text to display in this widget.
  final InlineSpan text;

  /// How the text should be aligned horizontally.
  final TextAlign textAlign;

  /// The directionality of the text.
  ///
  /// This decides how [textAlign] values like [TextAlign.start] and
  /// [TextAlign.end] are interpreted.
  ///
  /// This is also used to disambiguate how to render bidirectional text. For
  /// example, if the [text] is an English phrase followed by a Hebrew phrase,
  /// in a [TextDirection.ltr] context the English phrase will be on the left
  /// and the Hebrew phrase to its right, while in a [TextDirection.rtl]
  /// context, the English phrase will be on the right and the Hebrew phrase on
  /// its left.
  ///
  /// Defaults to the ambient [Directionality], if any. If there is no ambient
  /// [Directionality], then this must not be null.
  final TextDirection textDirection;

  /// Whether the text should break at soft line breaks.
  ///
  /// If false, the glyphs in the text will be positioned as if there was unlimited horizontal space.
  final bool softWrap;

  /// How visual overflow should be handled.
  final TextOverflow overflow;

  /// The number of font pixels for each logical pixel.
  ///
  /// For example, if the text scale factor is 1.5, text will be 50% larger than
  /// the specified font size.
  final double textScaleFactor;

  /// An optional maximum number of lines for the text to span, wrapping if necessary.
  /// If the text exceeds the given number of lines, it will be truncated according
  /// to [overflow].
  ///
  /// If this is 1, text will not wrap. Otherwise, text will be wrapped at the
  /// edge of the box.
  final int maxLines;

  /// Used to select a font when the same Unicode character can
  /// be rendered differently, depending on the locale.
  ///
  /// It's rarely necessary to set this property. By default its value
  /// is inherited from the enclosing app with `Localizations.localeOf(context)`.
  ///
  /// See [RenderParagraph.locale] for more information.
  final Locale locale;

  /// {@macro flutter.painting.textPainter.strutStyle}
  final StrutStyle strutStyle;

  /// {@macro flutter.widgets.text.DefaultTextStyle.textWidthBasis}
  final TextWidthBasis textWidthBasis;

  /// {@macro flutter.dart:ui.textHeightBehavior}
  final ui.TextHeightBehavior textHeightBehavior;

  @override
  RenderParagraph createRenderObject(BuildContext context) {
    assert(textDirection != null || debugCheckHasDirectionality(context));
    return RenderParagraph(
      text,
      textAlign: textAlign,
      textDirection: textDirection ?? Directionality.of(context),
      softWrap: softWrap,
      overflow: overflow,
      textScaleFactor: textScaleFactor,
      maxLines: maxLines,
      strutStyle: strutStyle,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      locale: locale ?? Localizations.localeOf(context, nullOk: true),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderParagraph renderObject) {
    assert(textDirection != null || debugCheckHasDirectionality(context));
    renderObject
      ..text = text
      ..textAlign = textAlign
      ..textDirection = textDirection ?? Directionality.of(context)
      ..softWrap = softWrap
      ..overflow = overflow
      ..textScaleFactor = textScaleFactor
      ..maxLines = maxLines
      ..strutStyle = strutStyle
      ..textWidthBasis = textWidthBasis
      ..textHeightBehavior = textHeightBehavior
      ..locale = locale ?? Localizations.localeOf(context, nullOk: true);
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
