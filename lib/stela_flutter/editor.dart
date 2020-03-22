import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:inday/stela/stela.dart' as Stela;

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

class StelaEditor extends StatefulWidget {
  StelaEditor({
    Key key,
    @required this.controller,
    this.children,
  })  : assert(controller != null),
        assert(children != null),
        super(key: key);

  final List<Widget> children;

  final EditorEditingController controller;

  @override
  StelaEditorState createState() => StelaEditorState();
}

class StelaEditorState extends State<StelaEditor> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_didChangeTextEditingValue);
  }

  @override
  void didUpdateWidget(StelaEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_didChangeTextEditingValue);
      widget.controller.addListener(_didChangeTextEditingValue);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_didChangeTextEditingValue);
    super.dispose();
  }

  void _didChangeTextEditingValue() {
    setState(() {/* We use widget.controller.value in build(). */});
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
    return StelaEditorScopeProvider(
      scope: StelaEditorScope(
        controller: widget.controller,
        findPath: findPath,
      ),
      child: ListBody(
        children: widget.children,
      ),
    );
  }
}

class StelaEditorScope extends ChangeNotifier {
  StelaEditorScope({
    @required this.controller,
    this.findPath,
  });

  EditorEditingController controller;
  Stela.Path Function(Stela.Node) findPath;

  static StelaEditorScope of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<StelaEditorScopeProvider>()
        .scope;
  }
}

class StelaEditorScopeProvider extends InheritedWidget {
  final StelaEditorScope scope;

  StelaEditorScopeProvider({
    Key key,
    @required this.scope,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(StelaEditorScopeProvider old) => true;
}
