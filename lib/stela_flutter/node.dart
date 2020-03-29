import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class StelaNode extends SingleChildRenderObjectWidget {
  StelaNode({
    this.child,
    this.registerRenderObject,
    this.deregisterRenderObject,
  });

  final Widget child;
  final void Function(RenderObject) registerRenderObject;
  final void Function(RenderObject) deregisterRenderObject;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderStelaNode(
        registerRenderObject: registerRenderObject,
        deregisterRenderObject: deregisterRenderObject);
  }
}

class RenderStelaNode extends RenderBox
    with RenderObjectWithChildMixin<RenderBox>, RenderProxyBoxMixin<RenderBox> {
  RenderStelaNode({
    this.registerRenderObject,
    this.deregisterRenderObject,
  });

  void Function(RenderObject) registerRenderObject;
  void Function(RenderObject) deregisterRenderObject;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    registerRenderObject(this);
  }

  @override
  void detach() {
    deregisterRenderObject(this);
    super.detach();
  }
}
