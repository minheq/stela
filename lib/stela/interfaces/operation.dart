import 'package:inday/stela/interfaces/node.dart';
import 'package:inday/stela/interfaces/path.dart';
import 'package:inday/stela/interfaces/range.dart';

class Operation {
  static Operation inverse(Operation op) {}
}

class NodeOperation implements Operation {}

class InsertNodeOperation implements NodeOperation {
  InsertNodeOperation(this.path, this.node);

  final Path path;
  final Node node;
}

class MergeNodeOperation implements NodeOperation {
  MergeNodeOperation(this.path, this.position, this.target, this.props);

  final Path path;
  final int position;
  final int target;
  final Map<String, dynamic> props;
}

class MoveNodeOperation implements NodeOperation {
  MoveNodeOperation(this.path, this.newPath);

  final Path path;
  final Path newPath;
}

class RemoveNodeOperation implements NodeOperation {
  RemoveNodeOperation(this.path, this.node);

  final Path path;
  final Node node;
}

class SetNodeOperation implements NodeOperation {
  SetNodeOperation(this.path, this.props, this.newProps);

  final Path path;
  final Map<String, dynamic> props;
  final Map<String, dynamic> newProps;
}

class SplitNodeOperation implements NodeOperation {
  SplitNodeOperation(this.path, this.position, this.target, this.props);

  final Path path;
  final int position;
  final int target;
  final Map<String, dynamic> props;
}

class SelectionOperation implements Operation {}

class SetSelectionOperation implements SelectionOperation {
  SetSelectionOperation(this.props, this.newProps);

  final Range props;
  final Range newProps;
}

class TextOperation implements Operation {}

class InsertTextOperation implements TextOperation {
  InsertTextOperation(this.path, this.offset, this.text);

  final Path path;
  final int offset;
  final String text;
}

class RemoveTextOperation implements TextOperation {
  RemoveTextOperation(this.path, this.offset, this.text);

  final Path path;
  final int offset;
  final String text;
}

enum Affinity {
  forward,
  backward,
  outward,
  inward,
}
