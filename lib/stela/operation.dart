import 'package:inday/stela/node.dart';
import 'package:inday/stela/path.dart';
import 'package:inday/stela/range.dart';

class Operation {
  static Operation inverse(Operation op) {
    if (op is InsertNodeOperation) {
      return RemoveNodeOperation(op.path, op.node);
    }

    if (op is InsertTextOperation) {
      return RemoveTextOperation(op.path, op.offset, op.text);
    }

    if (op is MergeNodeOperation) {
      return SplitNodeOperation(
          op.path.previous, op.position, op.target, op.props);
    }

    if (op is MoveNodeOperation) {
      Path path = op.path;
      Path newPath = op.newPath;

      // PERF: in this case the move operation is a no-op anyways.
      if (newPath.equals(path)) {
        return op;
      }

      // We need to get the original path here, but sometimes the `newPath`
      // is a younger sibling of (or ends before) the original, and this
      // accounts for it.
      Path inversePath = path.transform(op);
      Path inverseNewPath = path.next.transform(op);

      return MoveNodeOperation(inversePath, inverseNewPath);
    }

    if (op is RemoveNodeOperation) {
      return InsertNodeOperation(op.path, op.node);
    }

    if (op is RemoveTextOperation) {
      return InsertTextOperation(op.path, op.offset, op.text);
    }

    if (op is SetNodeOperation) {
      Map<String, dynamic> props = op.props;
      Map<String, dynamic> newProps = op.newProps;

      return SetNodeOperation(op.path, newProps, props);
    }

    if (op is SetSelectionOperation) {
      Range selection = op.selection;
      Range newSelection = op.newSelection;

      if (selection == null) {
        return SetSelectionOperation(newSelection, null);
      }

      if (newSelection == null) {
        return SetSelectionOperation(null, selection);
      }

      return SetSelectionOperation(newSelection, selection);
    }

    if (op is SplitNodeOperation) {
      return MergeNodeOperation(op.path.next, op.position, op.target, op.props);
    }

    return null;
  }
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
  SetSelectionOperation(this.selection, this.newSelection);

  final Range selection;
  final Range newSelection;
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
