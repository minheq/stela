import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:inday/stela/stela.dart' as Stela;

class StelaNode extends SingleChildRenderObjectWidget {
  StelaNode({
    Key key,
    @required this.child,
    @required this.node,
    @required this.path,
    @required this.addBox,
    @required this.removeBox,
  }) : super(key: key);

  final Widget child;
  final Stela.Node node;
  final Stela.Path path;
  final void Function(RenderObject) addBox;
  final void Function(RenderObject) removeBox;

  @override
  RenderStelaNode createRenderObject(BuildContext context) {
    return RenderStelaNode(node: node, addBox: addBox, removeBox: removeBox);
  }

  @override
  void updateRenderObject(BuildContext context, RenderStelaNode renderObject) {
    renderObject
      ..node = node
      ..addBox = addBox
      ..removeBox = removeBox;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(StringProperty('path', path.toString()));
    properties.add(StringProperty('node', node.toString()));
  }
}

class RenderStelaNode extends RenderBox
    with RenderObjectWithChildMixin<RenderBox>, RenderProxyBoxMixin<RenderBox> {
  RenderStelaNode({
    this.node,
    this.addBox,
    this.removeBox,
  });

  Stela.Node node;
  void Function(RenderObject) addBox;
  void Function(RenderObject) removeBox;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    addBox(this);
  }

  @override
  void detach() {
    removeBox(this);
    super.detach();
  }
}
