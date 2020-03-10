import 'package:inday/stela/editor.dart';
import 'package:inday/stela/element.dart';
import 'package:inday/stela/location.dart';
import 'package:inday/stela/node.dart';
import 'package:inday/stela/operation.dart';
import 'package:inday/stela/path.dart';
import 'package:inday/stela/path_ref.dart';
import 'package:inday/stela/point.dart';
import 'package:inday/stela/point_ref.dart';
import 'package:inday/stela/range.dart';
import 'package:inday/stela/range_ref.dart';
import 'package:inday/stela/text.dart';

class Transforms {
  /// Insert nodes at a specific location in the Editor.
  ///
  /// [select] when true, after inserting the nodes the user selection
  /// will be moved to the inserted nodes
  static void insertNodes(
    Editor editor,
    List<Node> nodes, {
    Location at,
    NodeMatch match,
    Mode mode = Mode.lowest,
    bool hanging = false,
    bool select,
    bool voids = false,
  }) {
    EditorUtils.withoutNormalizing(editor, () {
      if (nodes.isEmpty) {
        return;
      }

      Node node = nodes.first;

      // By default, use the selection as the target location. But if there is
      // no selection, insert at the end of the document since that is such a
      // common use case when inserting from a non-selected state.
      if (at == null) {
        if (editor.selection != null) {
          at = editor.selection;
        } else if (editor.children.length > 0) {
          at = EditorUtils.end(editor, Path([]));
        } else {
          at = Path([0]);
        }

        select = true;
      }

      if (select == null) {
        select = false;
      }

      if (at is Range) {
        if (!hanging) {
          at = EditorUtils.unhangRange(editor, at);
        }

        if (RangeUtils.isCollapsed(at)) {
          at = (at as Range).anchor;
        } else {
          Edges edges = RangeUtils.edges(at);
          Point end = edges.end;

          PointRef pointRef = EditorUtils.pointRef(editor, end);

          Transforms.delete(editor, at: at);

          Set<PointRef> editorPointRefs = EditorUtils.pointRefs(editor);
          at = pointRef.unref(editorPointRefs);
        }
      }

      if (at is Point) {
        if (match == null) {
          if (node is Text) {
            match = (n) {
              return (n is Text);
            };
          } else if (node is Inline) {
            match = (n) {
              return (n is Text) || EditorUtils.isInline(editor, n);
            };
          } else {
            match = (n) {
              return n is Block;
            };
          }
        }

        List<NodeEntry> entries = List.from(EditorUtils.nodes(editor,
            at: (at as Point).path, match: match, mode: mode, voids: voids));

        if (entries.isEmpty) {
          return;
        }

        NodeEntry entry = entries.first;

        Path matchPath = entry.path;
        PathRef pathRef = EditorUtils.pathRef(editor, matchPath);
        bool isAtEnd = EditorUtils.isEnd(editor, at, matchPath);
        Transforms.splitNodes(editor,
            at: at, match: match, mode: mode, voids: voids);

        Set<PathRef> editorPathRefs = EditorUtils.pathRefs(editor);
        Path path = pathRef.unref(editorPathRefs);
        at = isAtEnd ? PathUtils.next(path) : path;
      }

      Path parentPath = PathUtils.parent(at);
      int index = (at as Path).last;

      if (!voids && EditorUtils.matchVoid(editor, at: parentPath) != null) {
        return;
      }

      for (Node node in nodes) {
        Path path = PathUtils.copy(parentPath);
        path.add(index);

        index++;

        editor.apply(InsertNodeOperation(path, node));
      }

      if (select != false) {
        Point point = EditorUtils.end(editor, at);

        if (point != null) {
          Transforms.select(editor, point);
        }
      }
    });
  }

  /// Lift nodes at a specific location upwards in the document tree, splitting
  /// their parent in two if necessary.
  static void liftNodes(Editor editor,
      {Location at,
      NodeMatch match,
      Mode mode = Mode.lowest,
      bool voids = false}) {
    EditorUtils.withoutNormalizing(editor, () {
      at = at ?? editor.selection;

      if (match == null) {
        match = (at is Path)
            ? matchPath(editor, at)
            : (n) {
                return n is Block;
              };
      }

      if (at == null) {
        return;
      }

      List<NodeEntry> matches = [];

      for (NodeEntry entry in EditorUtils.nodes(editor,
          at: at, match: match, mode: mode, voids: voids)) {
        matches.add(entry);
      }

      Set<PathRef> pathRefs = Set();

      for (NodeEntry match in matches) {
        PathRef pathRef = EditorUtils.pathRef(editor, match.path);
        pathRefs.add(pathRef);
      }

      Set<PathRef> editorPathRefs = EditorUtils.pathRefs(editor);

      for (PathRef pathRef in pathRefs) {
        Path path = pathRef.unref(editorPathRefs);

        if (path.length < 2) {
          throw Exception(
              'Cannot lift node at a path [$path] because it has a depth of less than \`2\`.');
        }

        NodeEntry parentEntry =
            EditorUtils.node(editor, PathUtils.parent(path));
        Ancestor parent = parentEntry.node;
        Path parentPath = parentEntry.path;

        int index = path[path.length - 1];
        int length = parent.children.length;

        if (length == 1) {
          Path toPath = PathUtils.next(parentPath);
          Transforms.moveNodes(editor, at: path, to: toPath, voids: voids);
          Transforms.removeNodes(editor, at: parentPath, voids: voids);
        } else if (index == 0) {
          Transforms.moveNodes(editor, at: path, to: parentPath, voids: voids);
        } else if (index == length - 1) {
          Path toPath = PathUtils.next(parentPath);
          Transforms.moveNodes(editor, at: path, to: toPath, voids: voids);
        } else {
          Path splitPath = PathUtils.next(path);
          Path toPath = PathUtils.next(parentPath);
          Transforms.splitNodes(editor, at: splitPath, voids: voids);
          Transforms.moveNodes(editor, at: path, to: toPath, voids: voids);
        }
      }
    });
  }

  /// Merge a node at a location with the previous node of the same depth,
  /// removing any empty containing nodes after the merge if necessary.
  static void mergeNodes(Editor editor,
      {Location at,
      NodeMatch match,
      Mode mode = Mode.lowest,
      bool hanging = false,
      bool voids = false}) {
    EditorUtils.withoutNormalizing(editor, () {
      Location prevAt = at;
      at = at ?? editor.selection;

      if (at == null) {
        return;
      }

      if (match == null) {
        if (at is Path) {
          NodeEntry<Ancestor> entry = EditorUtils.parent(editor, at);
          Ancestor parent = entry.node;
          match = (n) {
            return parent.children.contains(n);
          };
        } else {
          match = (n) {
            return n is Block;
          };
        }
      }

      if (!hanging && at is Range) {
        at = EditorUtils.unhangRange(editor, at);
      }

      if (at is Range) {
        if (RangeUtils.isCollapsed(at)) {
          at = (at as Range).anchor;
        } else {
          Edges edge = RangeUtils.edges(at);
          Point end = edge.end;
          PointRef pointRef = EditorUtils.pointRef(editor, end);
          Transforms.delete(editor, at: at);
          Set<PointRef> editorPointRefs = EditorUtils.pointRefs(editor);
          at = pointRef.unref(editorPointRefs);

          if (prevAt == null) {
            Transforms.select(editor, at);
          }
        }
      }

      List<NodeEntry> currentNodes = List.from(EditorUtils.nodes(editor,
          at: at, match: match, voids: voids, mode: mode));
      NodeEntry current = currentNodes.first;
      NodeEntry prev = EditorUtils.previous(editor,
          at: at, match: match, voids: voids, mode: mode);

      if (current == null || prev == null) {
        return;
      }

      Node node = current.node;
      Path path = current.path;
      Node prevNode = prev.node;
      Path prevPath = prev.path;

      if (path.length == 0 || prevPath.length == 0) {
        return;
      }

      Path newPath = PathUtils.next(prevPath);
      Path commonPath = PathUtils.common(path, prevPath);
      bool isPreviousSibling = PathUtils.isSibling(path, prevPath);

      List<NodeEntry> entries = List.from(EditorUtils.levels(editor, at: path));
      List<Node> levels = [];

      for (int i = 0; i < entries.length; i++) {
        NodeEntry entry = entries[i];
        levels.add(entry.node);
      }

      levels = levels.sublist(commonPath.length);
      levels.removeLast();

      // Determine if the merge will leave an ancestor of the path empty as a
      // result, in which case we'll want to remove it after merging.
      NodeEntry emptyAncestor =
          EditorUtils.above(editor, at: path, mode: Mode.highest, match: (n) {
        return levels.contains(n) && (n is Element) && n.children.length == 1;
      });

      PathRef emptyRef;
      if (emptyAncestor != null) {
        emptyRef = EditorUtils.pathRef(editor, emptyAncestor.path);
      }
      Map<String, dynamic> props;
      int position;

      // Ensure that the nodes are equivalent, and figure out what the position
      // and extra props of the merge will be.
      if (node is Text && prevNode is Text) {
        position = prevNode.text.length;
        props = node.props;
      } else if ((node is Element) && prevNode is Element) {
        position = prevNode.children.length;
        props = node.props;
      } else {
        throw Exception(
            'Cannot merge the node at path [$path] with the previous sibling because it is not the same kind: ${node.toString()} ${prevNode.toString()}');
      }

      // If the node isn't already the next sibling of the previous node, move
      // it so that it is before merging.
      if (!isPreviousSibling) {
        Transforms.moveNodes(editor, at: path, to: newPath, voids: voids);
      }

      // If there was going to be an empty ancestor of the node that was merged,
      // we remove it from the tree.
      if (emptyRef != null) {
        Transforms.removeNodes(editor, at: emptyRef.current, voids: voids);
      }

      // If the target node that we're merging with is empty, remove it instead
      // of merging the two. This is a common rich text editor behavior to
      // prevent losing formatting when deleting entire nodes when you have a
      // hanging selection.
      if ((prevNode is Element && EditorUtils.isEmpty(editor, prevNode)) ||
          (prevNode is Text && prevNode.text == '')) {
        Transforms.removeNodes(editor, at: prevPath, voids: voids);
      } else {
        editor.apply(MergeNodeOperation(newPath, position, null, props));
      }

      if (emptyRef != null) {
        Set<PathRef> editorPathRefs = EditorUtils.pathRefs(editor);
        emptyRef.unref(editorPathRefs);
      }
    });
  }

  /// Move the nodes at a location to a new location.
  static void moveNodes(Editor editor,
      {Location at,
      NodeMatch match,
      Mode mode = Mode.lowest,
      Path to,
      bool voids = false}) {
    EditorUtils.withoutNormalizing(editor, () {
      at = at ?? editor.selection;

      if (at == null) {
        return;
      }

      if (match == null) {
        match = at is Path
            ? matchPath(editor, at)
            : (n) {
                return n is Block;
              };
      }

      PathRef toRef = EditorUtils.pathRef(editor, to);
      List<NodeEntry> targets = List.from(EditorUtils.nodes(editor,
          at: at, match: match, mode: mode, voids: voids));
      List<PathRef> pathRefs = [];

      for (NodeEntry entry in targets) {
        pathRefs.add(EditorUtils.pathRef(editor, entry.path));
      }

      Set<PathRef> editorPathRefs = EditorUtils.pathRefs(editor);
      for (PathRef pathRef in pathRefs) {
        Path path = pathRef.unref(editorPathRefs);
        Path newPath = toRef.current;

        if (path.isNotEmpty) {
          editor.apply(MoveNodeOperation(path, newPath));
        }
      }

      toRef.unref(editorPathRefs);
    });
  }

  /// Remove the nodes at a specific location in the document.
  static void removeNodes(Editor editor,
      {Location at,
      NodeMatch match,
      Mode mode = Mode.lowest,
      bool hanging = false,
      bool voids = false}) {
    EditorUtils.withoutNormalizing(editor, () {
      at = at ?? editor.selection;

      if (at == null) {
        return;
      }

      if (match == null) {
        match = at is Path
            ? matchPath(editor, at)
            : (n) {
                return n is Block;
              };
      }

      if (!hanging && at is Range) {
        at = EditorUtils.unhangRange(editor, at);
      }

      List<NodeEntry> depths = List.from(EditorUtils.nodes(editor,
          at: at, match: match, mode: mode, voids: voids));

      Set<PathRef> pathRefs = Set();

      for (NodeEntry depth in depths) {
        PathRef pathRef = EditorUtils.pathRef(editor, depth.path);
        pathRefs.add(pathRef);
      }

      Set<PathRef> editorPathRefs = EditorUtils.pathRefs(editor);

      for (PathRef pathRef in pathRefs) {
        Path path = pathRef.unref(editorPathRefs);

        if (path != null) {
          NodeEntry entry = EditorUtils.node(editor, path);
          Node node = entry.node;

          editor.apply(RemoveNodeOperation(path, node));
        }
      }
    });
  }

  /// Set new properties on the nodes at a location.
  static void setNodes(Editor editor, Map<String, dynamic> props,
      {Location at,
      NodeMatch match,
      Mode mode = Mode.lowest,
      bool hanging = false,
      bool split = false,
      bool voids = false}) {
    EditorUtils.withoutNormalizing(editor, () {
      Location prevAt = at;
      at = at ?? editor.selection;

      if (at == null) {
        return;
      }

      if (match == null) {
        match = at is Path
            ? matchPath(editor, at)
            : (n) {
                return n is Block;
              };
      }

      if (!hanging && at is Range) {
        at = EditorUtils.unhangRange(editor, at);
      }

      if (split && at is Range) {
        RangeRef rangeRef =
            EditorUtils.rangeRef(editor, at, affinity: Affinity.inward);
        Edges edges = RangeUtils.edges(at);
        Point start = edges.start;
        Point end = edges.end;
        Mode splitMode = mode == Mode.lowest ? Mode.lowest : Mode.highest;

        Transforms.splitNodes(
          editor,
          at: end,
          match: match,
          mode: splitMode,
          voids: voids,
        );
        Transforms.splitNodes(editor,
            at: start, match: match, mode: splitMode, voids: voids);

        Set<RangeRef> editorRangeRefs = EditorUtils.rangeRefs(editor);
        at = rangeRef.unref(editorRangeRefs);

        if (prevAt == null) {
          Transforms.select(editor, at);
        }
      }

      Map<String, dynamic> argProps = props;

      for (NodeEntry entry in EditorUtils.nodes(
        editor,
        at: at,
        match: match,
        mode: mode,
        voids: voids,
      )) {
        Node node = entry.node;
        Path path = entry.path;
        Map<String, dynamic> props = {};
        Map<String, dynamic> newProps = {};

        // You can't set props on the editor node.
        if (path.length == 0) {
          continue;
        }

        for (String k in argProps.keys) {
          if (argProps[k] != node.props[k]) {
            props[k] = node.props[k];
            newProps[k] = argProps[k];
          }
        }

        if (newProps.keys.isNotEmpty) {
          editor.apply(SetNodeOperation(path, props, newProps));
        }
      }
    });
  }

  /// Split the nodes at a specific location.
  static void splitNodes(
    Editor editor, {
    Location at,
    NodeMatch match,
    Mode mode = Mode.lowest,
    bool always = false,
    int height = 0,
    bool voids = false,
  }) {
    EditorUtils.withoutNormalizing(editor, () {
      Location prevAt = at;
      at = at ?? editor.selection;

      if (match == null) {
        match = (n) {
          return n is Block;
        };
      }

      if (at is Range) {
        at = deleteRange(editor, at);
      }

      // If the target is a path, the default height-skipping and position
      // counters need to account for us potentially splitting at a non-leaf.
      if (at is Path) {
        Path path = at;
        Point point = EditorUtils.point(editor, path);
        NodeEntry<Ancestor> entry = EditorUtils.parent(editor, path);
        Ancestor parent = entry.node;
        match = (n) {
          return n == parent;
        };
        height = point.path.length - path.length + 1;
        at = point;
        always = true;
      }

      if (at == null) {
        return;
      }

      PointRef beforeRef =
          EditorUtils.pointRef(editor, at, affinity: Affinity.backward);
      List<NodeEntry> entries = List.from(EditorUtils.nodes(editor,
          at: at, match: match, mode: mode, voids: voids));
      NodeEntry highest = entries.first;

      if (highest == null) {
        return;
      }

      NodeEntry<Element> voidMatch =
          EditorUtils.matchVoid(editor, at: at, mode: Mode.highest);
      int nudge = 0;

      if (voids == false && voidMatch != null) {
        Node voidNode = voidMatch.node;
        Path voidPath = voidMatch.path;

        if (voidNode is Element && voidNode is Inline) {
          Point after = EditorUtils.after(editor, voidPath);

          if (after == null) {
            Text text = Text('');
            Path afterPath = PathUtils.next(voidPath);
            Transforms.insertNodes(editor, [text], at: afterPath, voids: voids);
            after = EditorUtils.point(editor, afterPath);
          }

          at = after;
          always = true;
        }

        int siblingHeight = (at as Point).path.length - voidPath.length;
        height = siblingHeight + 1;
        always = true;
      }

      PointRef afterRef = EditorUtils.pointRef(editor, at);
      int depth = (at as Point).path.length - height;
      Path highestPath = highest.path;
      Path lowestPath = (at as Point).path.slice(0, depth);
      int position = height == 0
          ? (at as Point).offset
          : (at as Point).path[depth] + nudge;
      int target;

      for (NodeEntry entry in EditorUtils.levels(editor,
          at: lowestPath, reverse: true, voids: voids)) {
        Node node = entry.node;
        Path path = entry.path;
        bool split = false;

        if (path.length < highestPath.length ||
            path.length == 0 ||
            (!voids && EditorUtils.isVoid(editor, node))) {
          break;
        }

        Point point = beforeRef.current;
        bool isEnd = EditorUtils.isEnd(editor, point, path);

        if (always ||
            beforeRef == null ||
            !EditorUtils.isEdge(editor, point, path)) {
          split = true;
          editor.apply(SplitNodeOperation(path, position, target, node.props));
        }

        target = position;
        position = path[path.length - 1] + (split || isEnd ? 1 : 0);
      }

      if (prevAt == null) {
        Point point = afterRef.current ?? EditorUtils.end(editor, Path([]));
        Transforms.select(editor, point);
      }

      Set<PointRef> editorPointRefs = EditorUtils.pointRefs(editor);
      beforeRef.unref(editorPointRefs);
      afterRef.unref(editorPointRefs);
    });
  }

  /// Unset properties on the nodes at a location.
  static void unsetNodes(Editor editor, List<String> props,
      {Location at,
      NodeMatch match,
      Mode mode = Mode.lowest,
      bool split = false,
      bool voids = false}) {
    Map<String, dynamic> obj = {};

    for (String key in props) {
      obj[key] = null;
    }

    Transforms.setNodes(
      editor,
      obj,
      at: at,
      match: match,
      mode: mode,
      split: split,
      voids: voids,
    );
  }

  /// Unwrap the nodes at a location from a parent node, splitting the parent if
  /// necessary to ensure that only the content in the range is unwrapped.
  static void unwrapNodes(Editor editor,
      {Location at,
      NodeMatch match,
      Mode mode = Mode.lowest,
      bool split = false,
      bool voids = false}) {
    EditorUtils.withoutNormalizing(editor, () {
      at = at ?? editor.selection;

      if (at == null) {
        return;
      }

      if (match == null) {
        match = at is Path
            ? matchPath(editor, at)
            : (n) {
                return n is Block;
              };
      }

      if (at is Path) {
        at = EditorUtils.range(editor, at, null);
      }

      RangeRef rangeRef =
          (at is Range) ? EditorUtils.rangeRef(editor, at) : null;

      List<NodeEntry> matches = [];

      for (NodeEntry entry in EditorUtils.nodes(editor,
          at: at, match: match, mode: mode, voids: voids)) {
        matches.add(entry);
      }

      Set<PathRef> pathRefs = Set();

      for (NodeEntry match in matches) {
        PathRef pathRef = EditorUtils.pathRef(editor, match.path);
        pathRefs.add(pathRef);
      }

      Set<PathRef> editorPathRefs = EditorUtils.pathRefs(editor);

      for (PathRef pathRef in pathRefs) {
        Path path = pathRef.unref(editorPathRefs);
        NodeEntry entry = EditorUtils.node(editor, path);
        Ancestor node = entry.node;
        Range range = EditorUtils.range(editor, path, null);

        if (split && rangeRef != null) {
          range = RangeUtils.intersection(rangeRef.current, range);
        }

        Transforms.liftNodes(
          editor,
          at: range,
          match: (n) {
            return node.children.contains(n);
          },
          voids: voids,
        );
      }

      Set<RangeRef> editorRangeRefs = EditorUtils.rangeRefs(editor);

      if (rangeRef != null) {
        rangeRef.unref(editorRangeRefs);
      }
    });
  }

  /// Wrap the nodes at a location in a new container node, splitting the edges
  /// of the range first to ensure that only the content in the range is wrapped.
  static void wrapNodes(Editor editor, Element element,
      {Location at,
      NodeMatch match,
      Mode mode = Mode.lowest,
      bool split = false,
      bool voids = false}) {
    EditorUtils.withoutNormalizing(editor, () {
      Location prevAt = at;
      at = at ?? editor.selection;

      if (at == null) {
        return;
      }

      if (match == null) {
        if (at is Path) {
          match = matchPath(editor, at);
        } else if (element is Inline) {
          match = (n) {
            return EditorUtils.isInline(editor, n) || (n is Text);
          };
        } else {
          match = (n) {
            return n is Block;
          };
        }
      }

      if (split && at is Range) {
        Edges edges = RangeUtils.edges(at);
        Point start = edges.start;
        Point end = edges.end;

        RangeRef rangeRef =
            EditorUtils.rangeRef(editor, at, affinity: Affinity.inward);
        Transforms.splitNodes(editor, at: end, match: match, voids: voids);
        Transforms.splitNodes(editor, at: start, match: match, voids: voids);
        Set<RangeRef> editorRangeRefs = EditorUtils.rangeRefs(editor);
        at = rangeRef.unref(editorRangeRefs);

        if (prevAt == null) {
          Transforms.select(editor, at);
        }
      }

      List<NodeEntry> roots = List.from(EditorUtils.nodes(
        editor,
        at: at,
        match: element is Inline
            ? (n) {
                return n is Block;
              }
            : (n) {
                return n is Editor;
              },
        mode: Mode.highest,
        voids: voids,
      ));

      for (NodeEntry root in roots) {
        Path rootPath = root.path;
        Range a = (at is Range)
            ? RangeUtils.intersection(
                at, EditorUtils.range(editor, rootPath, null))
            : at;

        if (a == null) {
          continue;
        }

        List<NodeEntry> matches = List.from(EditorUtils.nodes(editor,
            at: a, match: match, mode: mode, voids: voids));

        if (matches.length > 0) {
          NodeEntry first = matches.first;
          NodeEntry last = matches.last;
          Path firstPath = first.path;
          Path lastPath = last.path;

          Path commonPath = PathUtils.equals(firstPath, lastPath)
              ? PathUtils.parent(firstPath)
              : PathUtils.common(firstPath, lastPath);

          Range range = EditorUtils.range(editor, firstPath, lastPath);
          NodeEntry common = EditorUtils.node(editor, commonPath);
          Ancestor commonNode = common.node;
          int depth = commonPath.length + 1;
          Path wrapperPath = PathUtils.next(lastPath.slice(0, depth));
          Block wrapper = Block(children: [], props: element.props);
          Transforms.insertNodes(editor, [wrapper],
              at: wrapperPath, voids: voids);

          wrapperPath.add(0);

          Transforms.moveNodes(
            editor,
            at: range,
            match: (n) {
              return commonNode.children.contains(n);
            },
            to: wrapperPath,
            voids: voids,
          );
        }
      }
    });
  }

  // selection transforms

  /// Collapse the selection.
  static void collapse(Editor editor, {Edge edge = Edge.anchor}) {
    Range selection = editor.selection;

    if (selection = null) {
      return;
    } else if (edge == Edge.anchor) {
      Transforms.select(editor, selection.anchor);
    } else if (edge == Edge.focus) {
      Transforms.select(editor, selection.focus);
    } else if (edge == Edge.start) {
      Edges edges = RangeUtils.edges(selection);
      Point start = edges.start;
      Transforms.select(editor, start);
    } else if (edge == Edge.end) {
      Edges edges = RangeUtils.edges(selection);
      Point end = edges.end;
      Transforms.select(editor, end);
    }
  }

  /// Unset the selection.
  static void deselect(Editor editor) {
    Range selection = editor.selection;

    if (selection != null) {
      editor.apply(SetSelectionOperation(selection, null));
    }
  }

  /// Move the selection's point forward or backward.
  static void move(
    Editor editor, {
    int distance = 1,
    Unit unit = Unit.character,
    bool reverse = false,
    Edge edge,
  }) {
    Range selection = editor.selection;

    if (selection == null) {
      return;
    }

    if (edge == Edge.start) {
      edge = RangeUtils.isBackward(selection) ? Edge.focus : Edge.anchor;
    }

    if (edge == Edge.end) {
      edge = RangeUtils.isBackward(selection) ? Edge.anchor : Edge.focus;
    }

    Point anchor = selection.anchor;
    Point focus = selection.focus;
    Range newSelection = Range(null, null);

    if (edge == null || edge == Edge.anchor) {
      Point point = reverse
          ? EditorUtils.before(editor, anchor, distance: distance, unit: unit)
          : EditorUtils.after(editor, anchor, distance: distance, unit: unit);

      if (point != null) {
        newSelection.anchor = point;
      }
    }

    if (edge == null || edge == Edge.focus) {
      Point point = reverse
          ? EditorUtils.before(editor, focus, distance: distance, unit: unit)
          : EditorUtils.after(editor, focus, distance: distance, unit: unit);

      if (point != null) {
        newSelection.focus = point;
      }
    }

    Transforms.setSelection(editor, newSelection);
  }

  /// Set the selection to a new value.
  static void select(Editor editor, Location target) {
    Range selection = editor.selection;
    target = EditorUtils.range(editor, target, null);

    if (selection != null) {
      Transforms.setSelection(editor, target);
      return;
    }

    if (!RangeUtils.isRange(target)) {
      throw Exception(
          'When setting the selection and the current selection is \`null\` you must provide at least an \`anchor\` and \`focus\`, but you passed: ${target.toString()}');
    }

    editor.apply(SetSelectionOperation(selection, target));
  }

  /// Set new properties on one of the selection's points.
  static void setPoint(
    Editor editor,
    Map<String, dynamic> props, {
    Edge edge,
  }) {
    Range selection = editor.selection;

    if (selection != null) {
      return;
    }

    if (edge == Edge.start) {
      edge = RangeUtils.isBackward(selection) ? Edge.focus : Edge.anchor;
    }

    if (edge == Edge.end) {
      edge = RangeUtils.isBackward(selection) ? Edge.anchor : Edge.focus;
    }

    Point anchor = selection.anchor;
    Point focus = selection.focus;
    Point point = edge == Edge.anchor ? anchor : focus;
    Point newPoint = Point(point.path, point.offset, props: point.props);
    newPoint.props.addAll(props);

    if (edge == Edge.anchor) {
      Transforms.setSelection(editor, Range(newPoint, null));
    } else {
      Transforms.setSelection(editor, Range(null, newPoint));
    }
  }

  /// Set new properties on the selection.
  static void setSelection(Editor editor, Range newSelection) {
    Range selection = editor.selection;
    Map<String, dynamic> oldProps = {};
    Map<String, dynamic> newProps = {};

    if (selection == null) {
      return;
    }

    for (String key in newSelection.props.keys) {
      if (newSelection.props[key] != selection.props[key]) {
        oldProps[key] = selection.props[key];
        newProps[key] = newSelection.props[key];
      }
    }

    bool hasSelectionChanges = oldProps.length > 0 ||
        !PointUtils.equals(selection.anchor, newSelection.anchor) ||
        !PointUtils.equals(selection.focus, newSelection.focus);

    if (hasSelectionChanges) {
      selection = Range(selection.anchor, selection.focus, props: oldProps);
      newSelection =
          Range(newSelection.anchor, newSelection.focus, props: newProps);

      editor.apply(SetSelectionOperation(selection, newSelection));
    }
  }

  // Text transforms

  /// Delete content in the editor.
  static void delete(Editor editor,
      {Location at,
      int distance = 1,
      Unit unit = Unit.character,
      bool reverse = false,
      bool hanging = false,
      bool voids = false}) {
    EditorUtils.withoutNormalizing(editor, () {
      Location prevAt = at;
      at = at ?? editor.selection;

      if (at == null) {
        return;
      }

      if (at is Range && RangeUtils.isCollapsed(at)) {
        at = (at as Range).anchor;
      }

      if (at is Point) {
        NodeEntry<Element> furthestVoid =
            EditorUtils.matchVoid(editor, at: at, mode: Mode.highest);

        if (voids == false && furthestVoid != null) {
          Path voidPath = furthestVoid.path;
          at = voidPath;
        } else {
          Point target = reverse
              ? EditorUtils.before(editor, at,
                      unit: unit, distance: distance) ??
                  EditorUtils.start(editor, Path([]))
              : EditorUtils.after(editor, at, unit: unit, distance: distance) ??
                  EditorUtils.end(editor, Path([]));
          at = Range(at, target);
          hanging = true;
        }
      }

      if (at is Path) {
        Transforms.removeNodes(editor, at: at, voids: voids);
        return;
      }

      if (RangeUtils.isCollapsed(at)) {
        return;
      }

      if (!hanging) {
        at = EditorUtils.unhangRange(editor, at, voids: voids);
      }

      Edges edges = RangeUtils.edges(at);
      Point start = edges.start;
      Point end = edges.end;

      NodeEntry<Block> startBlock = EditorUtils.above(editor, match: (n) {
        return n is Block;
      }, at: start, voids: voids);
      NodeEntry<Block> endBlock = EditorUtils.above(editor, match: (n) {
        return n is Block;
      }, at: end, voids: voids);
      bool isAcrossBlocks = startBlock != null &&
          endBlock != null &&
          !PathUtils.equals(startBlock.path, endBlock.path);
      bool isSingleText = PathUtils.equals(start.path, end.path);
      NodeEntry<Element> startVoid = voids
          ? null
          : EditorUtils.matchVoid(editor, at: start, mode: Mode.highest);
      NodeEntry<Element> endVoid = voids
          ? null
          : EditorUtils.matchVoid(editor, at: end, mode: Mode.highest);

      // If the start or end points are inside an inline void, nudge them out.
      if (startVoid != null) {
        Point before = EditorUtils.before(editor, start);

        if (before != null &&
            startBlock != null &&
            PathUtils.isAncestor(startBlock.path, before.path)) {
          start = before;
        }
      }

      if (endVoid != null) {
        Point after = EditorUtils.after(editor, end);

        if (after != null &&
            endBlock != null &&
            PathUtils.isAncestor(endBlock.path, after.path)) {
          end = after;
        }
      }

      // Get the highest nodes that are completely inside the range, as well as
      // the start and end nodes.
      List<NodeEntry> matches = [];
      Path lastPath;

      for (NodeEntry entry in EditorUtils.nodes(editor, at: at, voids: voids)) {
        Node node = entry.node;
        Path path = entry.path;

        if (lastPath != null && PathUtils.compare(path, lastPath) == 0) {
          continue;
        }

        if ((!voids && EditorUtils.isVoid(editor, node)) ||
            (!PathUtils.isCommon(path, start.path) &&
                !PathUtils.isCommon(path, end.path))) {
          matches.add(entry);
          lastPath = path;
        }
      }

      Set<PathRef> pathRefs = Set();

      for (NodeEntry match in matches) {
        PathRef pathRef = EditorUtils.pathRef(editor, match.path);
        pathRefs.add(pathRef);
      }

      PointRef startRef = EditorUtils.pointRef(editor, start);
      PointRef endRef = EditorUtils.pointRef(editor, end);

      if (!isSingleText && startVoid == null) {
        Point point = startRef.current;
        NodeEntry<Text> entry = EditorUtils.leaf(editor, point);
        Text node = entry.node;
        Path path = point.path;
        int offset = start.offset;

        String text = node.text.substring(offset);

        editor.apply(RemoveTextOperation(path, offset, text));
      }

      Set<PathRef> editorPathRefs = EditorUtils.pathRefs(editor);

      for (PathRef pathRef in pathRefs) {
        Path path = pathRef.unref(editorPathRefs);
        Transforms.removeNodes(editor, at: path, voids: voids);
      }

      if (endVoid == null) {
        Point point = endRef.current;
        NodeEntry<Text> entry = EditorUtils.leaf(editor, point);
        Text node = entry.node;
        Path path = point.path;

        int offset = isSingleText ? start.offset : 0;
        String text = node.text.substring(offset, end.offset);

        editor.apply(RemoveTextOperation(path, offset, text));
      }

      if (!isSingleText &&
          isAcrossBlocks &&
          endRef.current != null &&
          startRef.current != null) {
        Transforms.mergeNodes(
          editor,
          at: endRef.current,
          hanging: true,
          voids: voids,
        );
      }

      Set<PointRef> editorPointRefs = EditorUtils.pointRefs(editor);
      Point point =
          endRef.unref(editorPointRefs) ?? startRef.unref(editorPointRefs);

      if (prevAt == null && point != null) {
        Transforms.select(editor, point);
      }
    });
  }

  /// Insert a fragment at a specific location in the editor.
  static void insertFragment(Editor editor, List<Node> fragment,
      {Location at, bool hanging = false, bool voids = false}) {
    EditorUtils.withoutNormalizing(editor, () {
      Location prevAt = at;
      at = at ?? editor.selection;

      if (fragment.isEmpty) {
        return;
      }

      if (at == null) {
        return;
      } else if (at is Range) {
        if (hanging == false) {
          at = EditorUtils.unhangRange(editor, at);
        }

        if (RangeUtils.isCollapsed(at)) {
          at = (at as Range).anchor;
        } else {
          Edges edges = RangeUtils.edges(at);
          Point end = edges.end;

          if (!voids && EditorUtils.matchVoid(editor, at: end) != null) {
            return;
          }

          PointRef pointRef = EditorUtils.pointRef(editor, end);
          Transforms.delete(editor, at: at);

          Set<PointRef> editorPointRefs = EditorUtils.pointRefs(editor);
          at = pointRef.unref(editorPointRefs);
        }
      } else if (at is Path) {
        at = EditorUtils.start(editor, at);
      }

      if (!voids && EditorUtils.matchVoid(editor, at: at) != null) {
        return;
      }

      // If the insert point is at the edge of an inline node, move it outside
      // instead since it will need to be split otherwise.
      NodeEntry inlineElementMatch =
          EditorUtils.above(editor, at: at, match: (n) {
        return EditorUtils.isInline(editor, n);
      }, mode: Mode.highest, voids: voids);

      if (inlineElementMatch != null) {
        Path inlinePath = inlineElementMatch.path;

        if (EditorUtils.isEnd(editor, at, inlinePath)) {
          Point after = EditorUtils.after(editor, inlinePath);
          at = after;
        } else if (EditorUtils.isStart(editor, at, inlinePath)) {
          Point before = EditorUtils.before(editor, inlinePath);
          at = before;
        }
      }

      NodeEntry blockMatch = EditorUtils.above(
        editor,
        match: (n) {
          return n is Block;
        },
        at: at,
        voids: voids,
      );

      Path blockPath = blockMatch.path;
      bool isBlockStart = EditorUtils.isStart(editor, at, blockPath);
      bool isBlockEnd = EditorUtils.isEnd(editor, at, blockPath);
      bool mergeStart = !isBlockStart || (isBlockStart && isBlockEnd);
      bool mergeEnd = !isBlockEnd;
      NodeEntry first = NodeUtils.first(Element(children: fragment), Path([]));
      Path firstPath = first.path;
      NodeEntry last = NodeUtils.last(Element(children: fragment), Path([]));
      Path lastPath = last.path;

      List<NodeEntry> matches = [];

      bool Function(NodeEntry) matcher = (NodeEntry entry) {
        Node n = entry.node;
        Path p = entry.path;

        if (mergeStart &&
            PathUtils.isAncestor(p, firstPath) &&
            (n is Element) &&
            !editor.isVoid(n) &&
            !(n is Inline)) {
          return false;
        }

        if (mergeEnd &&
            PathUtils.isAncestor(p, lastPath) &&
            (n is Element) &&
            !editor.isVoid(n) &&
            !(n is Inline)) {
          return false;
        }

        return true;
      };

      for (NodeEntry entry
          in NodeUtils.nodes(Element(children: fragment), pass: matcher)) {
        if (entry.path.length > 0 && matcher(entry)) {
          matches.add(entry);
        }
      }

      List<Node> starts = [];
      List<Node> middles = [];
      List<Node> ends = [];
      bool starting = true;
      bool hasBlocks = false;

      for (NodeEntry entry in matches) {
        Node node = entry.node;

        if (node is Element && node is Inline == false) {
          starting = false;
          hasBlocks = true;
          middles.add(node);
        } else if (starting) {
          starts.add(node);
        } else {
          ends.add(node);
        }
      }

      List<NodeEntry> inlines =
          List.from(EditorUtils.nodes(editor, at: at, match: (n) {
        return (n is Text) || EditorUtils.isInline(editor, n);
      }, mode: Mode.highest, voids: voids));

      NodeEntry inlineMatch = inlines.first;
      Path inlinePath = inlineMatch.path;

      bool isInlineStart = EditorUtils.isStart(editor, at, inlinePath);
      bool isInlineEnd = EditorUtils.isEnd(editor, at, inlinePath);

      PathRef middleRef = EditorUtils.pathRef(
          editor, isBlockEnd ? PathUtils.next(blockPath) : blockPath);

      PathRef endRef = EditorUtils.pathRef(
          editor, isInlineEnd ? PathUtils.next(inlinePath) : inlinePath);

      Transforms.splitNodes(editor, at: at, match: (n) {
        return hasBlocks ? n is Block : n is Text || n is Inline;
      }, mode: hasBlocks ? Mode.lowest : Mode.highest, voids: voids);

      PathRef startRef = EditorUtils.pathRef(
          editor,
          !isInlineStart || (isInlineStart && isInlineEnd)
              ? PathUtils.next(inlinePath)
              : inlinePath);

      Transforms.insertNodes(
        editor,
        starts,
        at: startRef.current,
        match: (n) {
          return (n is Text) || EditorUtils.isInline(editor, n);
        },
        mode: Mode.highest,
        voids: voids,
      );

      Transforms.insertNodes(editor, middles, at: middleRef.current,
          match: (n) {
        return n is Block;
      }, mode: Mode.lowest, voids: voids);

      Transforms.insertNodes(editor, ends, at: endRef.current, match: (n) {
        return (n is Text) || EditorUtils.isInline(editor, n);
      }, mode: Mode.highest, voids: voids);

      if (prevAt == null) {
        Path path;

        if (ends.length > 0) {
          path = PathUtils.previous(endRef.current);
        } else if (middles.length > 0) {
          path = PathUtils.previous(middleRef.current);
        } else {
          path = PathUtils.previous(startRef.current);
        }

        Point end = EditorUtils.end(editor, path);
        Transforms.select(editor, end);
      }

      Set<PathRef> editorPathRefs = EditorUtils.pathRefs(editor);

      startRef.unref(editorPathRefs);
      middleRef.unref(editorPathRefs);
      endRef.unref(editorPathRefs);
    });
  }

  /// Insert a string of text in the Editor.
  static void insertText(Editor editor, String text,
      {Location at, bool voids = false}) {
    EditorUtils.withoutNormalizing(editor, () {
      at = at ?? editor.selection;

      if (at == null) {
        return;
      }

      if (at is Path) {
        at = EditorUtils.range(editor, at, null);
      }

      if (at is Range) {
        if (RangeUtils.isCollapsed(at)) {
          at = (at as Range).anchor;
        } else {
          Point end = RangeUtils.end(at);

          if (!voids && EditorUtils.matchVoid(editor, at: end) != null) {
            return;
          }

          PointRef pointRef = EditorUtils.pointRef(editor, end);
          Transforms.delete(editor, at: at, voids: voids);
          Set<PointRef> editorPointRefs = EditorUtils.pointRefs(editor);
          at = pointRef.unref(editorPointRefs);
          Transforms.setSelection(editor, Range(at, at));
        }
      }

      if (!voids && EditorUtils.matchVoid(editor, at: at) != null) {
        return;
      }

      Path path = (at as Point).path;
      int offset = (at as Point).offset;
      editor.apply(InsertTextOperation(path, offset, text));
    });
  }
}

/// Convert a range into a point by deleting it's content.
Point Function(Editor editor, Range range) deleteRange =
    (Editor editor, Range range) {
  if (RangeUtils.isCollapsed(range)) {
    return range.anchor;
  } else {
    Edges edges = RangeUtils.edges(range);
    Point end = edges.end;

    PointRef pointRef = EditorUtils.pointRef(editor, end);
    Transforms.delete(editor, at: range);

    Set<PointRef> editorPointRefs = EditorUtils.pointRefs(editor);
    return pointRef.unref(editorPointRefs);
  }
};

bool Function(Node node) Function(Editor editor, Path path) matchPath =
    (Editor editor, Path path) {
  NodeEntry entry = EditorUtils.node(editor, path);
  Node node = entry.node;

  return (n) {
    return n == node;
  };
};
