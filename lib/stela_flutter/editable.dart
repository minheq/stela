import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:inday/stela/stela.dart' as Stela;
import 'package:inday/stela_flutter/rich_text.dart';

class StelaEditable extends MultiChildRenderObjectWidget {
  StelaEditable({
    Key key,
    Stela.Editor editor,
    Color cursorColor,
    Color backgroundCursorColor,
    ValueNotifier<bool> showCursor,
    bool hasFocus,
    bool selectionEnabled,
    Color selectionColor,
    TextSelection selection,
    double cursorWidth = 2.0,
    bool ignorePointer = false,
    Radius cursorRadius,
    Offset cursorOffset,
    bool paintCursorAboveText = false,
    double devicePixelRatio = 1.0,
    TextAlign textAlign = TextAlign.start,
    TextDirection textDirection,
    bool softWrap = true,
    double textScaleFactor = 1.0,
    int maxLines,
    Locale locale,
    StrutStyle strutStyle,
    TextWidthBasis textWidthBasis = TextWidthBasis.parent,
    Widget Function(Stela.Element element) elementBuilder,
    TextSpan Function(Stela.Text text) textBuilder,
    void Function(GlobalKey, TapDownDetails) onTapDown,
    void Function(GlobalKey, TapUpDetails) onSingleTapUp,
  })  : assert(editor != null),
        super(
            key: key,
            children: _extractChildren(
                node: editor,
                cursorColor: cursorColor,
                backgroundCursorColor: backgroundCursorColor,
                showCursor: showCursor,
                hasFocus: hasFocus,
                selectionColor: selectionColor,
                selection: selection,
                selectionEnabled: selectionEnabled,
                cursorWidth: cursorWidth,
                ignorePointer: ignorePointer,
                cursorRadius: cursorRadius,
                cursorOffset: cursorOffset,
                paintCursorAboveText: paintCursorAboveText,
                devicePixelRatio: devicePixelRatio,
                textAlign: textAlign,
                textDirection: textDirection,
                softWrap: softWrap,
                textScaleFactor: textScaleFactor,
                maxLines: maxLines,
                locale: locale,
                strutStyle: strutStyle,
                textWidthBasis: textWidthBasis,
                elementBuilder: elementBuilder,
                textBuilder: textBuilder,
                onTapDown: onTapDown,
                onSingleTapUp: onSingleTapUp));

  static List<Widget> _extractChildren({
    Stela.Ancestor node,
    Color cursorColor,
    Color backgroundCursorColor,
    ValueNotifier<bool> showCursor,
    bool hasFocus,
    Color selectionColor,
    TextSelection selection,
    bool selectionEnabled,
    double cursorWidth,
    bool ignorePointer,
    Radius cursorRadius,
    Offset cursorOffset,
    bool paintCursorAboveText,
    double devicePixelRatio,
    TextAlign textAlign,
    TextDirection textDirection,
    bool softWrap,
    double textScaleFactor,
    int maxLines,
    Locale locale,
    StrutStyle strutStyle,
    TextWidthBasis textWidthBasis,
    Widget Function(Stela.Element element) elementBuilder,
    TextSpan Function(Stela.Text text) textBuilder,
    void Function(GlobalKey, TapDownDetails) onTapDown,
    void Function(GlobalKey, TapUpDetails) onSingleTapUp,
  }) {
    List<Widget> result = <Widget>[];

    for (Stela.Node child in node.children) {
      bool isBlockText =
          child is Stela.Block && child.children.first is Stela.Text;

      if (isBlockText) {
        result.add(StelaBlockText(
          block: child,
          cursorColor: cursorColor,
          backgroundCursorColor: backgroundCursorColor,
          showCursor: showCursor,
          hasFocus: hasFocus,
          selectionColor: selectionColor,
          selection: selection,
          selectionEnabled: selectionEnabled,
          cursorWidth: cursorWidth,
          ignorePointer: ignorePointer,
          cursorRadius: cursorRadius,
          cursorOffset: cursorOffset,
          paintCursorAboveText: paintCursorAboveText,
          devicePixelRatio: devicePixelRatio,
          textAlign: textAlign,
          textDirection: textDirection,
          softWrap: softWrap,
          textScaleFactor: textScaleFactor,
          maxLines: maxLines,
          locale: locale,
          strutStyle: strutStyle,
          textWidthBasis: textWidthBasis,
          textBuilder: textBuilder,
          onTapDown: onTapDown,
          onSingleTapUp: onSingleTapUp,
        ));
      }
    }

    return result;
  }

  @override
  RenderStelaEditable createRenderObject(BuildContext context) {
    return RenderStelaEditable();
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderStelaEditable renderObject) {
    // renderObject
    //   ..text = text
    //   ..textAlign = textAlign
    //   ..textDirection = textDirection ?? Directionality.of(context)
    //   ..softWrap = softWrap
    //   ..overflow = overflow
    //   ..textScaleFactor = textScaleFactor
    //   ..maxLines = maxLines
    //   ..strutStyle = strutStyle
    //   ..textWidthBasis = textWidthBasis
    //   ..textHeightBehavior = textHeightBehavior
    //   ..locale = locale ?? Localizations.localeOf(context, nullOk: true);
  }
}

class EditableParentData extends ContainerBoxParentData<RenderBox> {
  @override
  String toString() => '${super.toString()};';
}

class RenderStelaEditable extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, EditableParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, EditableParentData> {
  RenderStelaEditable({
    List<RenderBox> children,
  }) {
    addAll(children);
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! EditableParentData) {
      child.parentData = EditableParentData();
    }
  }

  void handleTapDown({GlobalKey key, TapDownDetails details}) {
    RenderObject renderObject = key.currentContext.findRenderObject();

    if (renderObject is RenderStelaBlockText) {
      renderObject.handleTapDown(details);
    }
  }

  void handleSingleTapUp(
      {GlobalKey key, TapUpDetails details, SelectionChangedCause cause}) {
    RenderObject renderObject = key.currentContext.findRenderObject();
    if (renderObject is RenderStelaBlockText) {
      renderObject.selectWordEdge(cause: cause);
    }
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToFirstActualBaseline(baseline);
  }

  @override
  void performLayout() {
    RenderBox child = firstChild;

    List<RenderBox> children = getChildrenAsList();

    // Max width is the width of the widest child
    double maxWidth = constraints.minWidth;
    for (final RenderBox child in children) {
      maxWidth = child.getMaxIntrinsicWidth(double.infinity);
    }

    // Max height is accumulation of children's height
    double maxHeight = constraints.minHeight;
    for (final RenderBox child in children) {
      maxHeight += child.getMaxIntrinsicHeight(maxWidth);
    }

    // Place each child vertically, below one another
    double start = 0.0;
    while (child != null) {
      final EditableParentData childParentData =
          child.parentData as EditableParentData;
      final Offset childOffset = Offset(0.0, start);

      childParentData.offset = childOffset;
      child.layout(constraints, parentUsesSize: true);

      start += child.size.height;
      child = childAfter(child);
    }

    size = Size(constraints.maxWidth, maxHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    RenderBox child = firstChild;

    while (child != null) {
      final EditableParentData childParentData =
          child.parentData as EditableParentData;
      context.paintChild(child, childParentData.offset + offset);
      child = childAfter(child);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
