import 'package:inday/stela/editor.dart';
import 'package:inday/stela/element.dart';
import 'package:inday/stela/location.dart';
import 'package:inday/stela/node.dart';
import 'package:inday/stela/operation.dart';
import 'package:inday/stela/path.dart';
import 'package:inday/stela/point.dart';
import 'package:inday/stela/range.dart';
import 'package:inday/stela/text.dart';

class Transforms {
  // #region Node transforms

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
    editor.withoutNormalizing(() {
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
          at = editor.end(Path([]));
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
          at = editor.unhangRange(at);
        }

        if ((at as Range).isCollapsed) {
          at = (at as Range).anchor;
        } else {
          Edges edges = (at as Range).edges();
          Point end = edges.end;

          PointRef pointRef = editor.pointRef(end);

          Transforms.delete(editor, at: at);

          at = pointRef.unref(editor.pointRefs);
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
              return (n is Text) || editor.isInline(n);
            };
          } else {
            match = (n) {
              return n is Block;
            };
          }
        }

        List<NodeEntry> entries = List.from(editor.nodes(
            at: (at as Point).path, match: match, mode: mode, voids: voids));

        if (entries.isEmpty) {
          return;
        }

        NodeEntry entry = entries.first;

        Path matchPath = entry.path;
        PathRef pathRef = editor.pathRef(matchPath);
        bool isAtEnd = editor.isEnd(at, matchPath);
        Transforms.splitNodes(editor,
            at: at, match: match, mode: mode, voids: voids);

        Path path = pathRef.unref(editor.pathRefs);
        at = isAtEnd ? path.next : path;
      }

      Path parentPath = (at as Path).parent;
      int index = (at as Path).last;

      if (!voids && editor.matchVoid(at: parentPath) != null) {
        return;
      }

      for (Node node in nodes) {
        Path path = parentPath.copyAndAdd(index);

        index++;

        editor.apply(InsertNodeOperation(path, node));
      }

      if (select != false) {
        Point point = editor.end(at);

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
    editor.withoutNormalizing(() {
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

      for (NodeEntry entry
          in editor.nodes(at: at, match: match, mode: mode, voids: voids)) {
        matches.add(entry);
      }

      Set<PathRef> pathRefs = Set();

      for (NodeEntry match in matches) {
        PathRef pathRef = editor.pathRef(match.path);
        pathRefs.add(pathRef);
      }

      for (PathRef pathRef in pathRefs) {
        Path path = pathRef.unref(editor.pathRefs);

        if (path.length < 2) {
          throw Exception(
              'Cannot lift node at a path [$path] because it has a depth of less than \`2\`.');
        }

        NodeEntry parentEntry = editor.node(path.parent);
        Ancestor parent = parentEntry.node;
        Path parentPath = parentEntry.path;

        int index = path[path.length - 1];
        int length = parent.children.length;

        if (length == 1) {
          Path toPath = parentPath.next;
          Transforms.moveNodes(editor, at: path, to: toPath, voids: voids);
          Transforms.removeNodes(editor, at: parentPath, voids: voids);
        } else if (index == 0) {
          Transforms.moveNodes(editor, at: path, to: parentPath, voids: voids);
        } else if (index == length - 1) {
          Path toPath = parentPath.next;
          Transforms.moveNodes(editor, at: path, to: toPath, voids: voids);
        } else {
          Path splitPath = path.next;
          Path toPath = parentPath.next;
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
    editor.withoutNormalizing(() {
      Location prevAt = at;
      at = at ?? editor.selection;

      if (at == null) {
        return;
      }

      if (match == null) {
        if (at is Path) {
          NodeEntry<Ancestor> entry = editor.parent(at);
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
        at = editor.unhangRange(at);
      }

      if (at is Range) {
        if ((at as Range).isCollapsed) {
          at = (at as Range).anchor;
        } else {
          Edges edge = (at as Range).edges();
          Point end = edge.end;
          PointRef pointRef = editor.pointRef(end);
          Transforms.delete(editor, at: at);
          at = pointRef.unref(editor.pointRefs);

          if (prevAt == null) {
            Transforms.select(editor, at);
          }
        }
      }

      List<NodeEntry> currentNodes = List.from(
          editor.nodes(at: at, match: match, voids: voids, mode: mode));
      NodeEntry current = currentNodes.first;
      NodeEntry prev =
          editor.previous(at: at, match: match, voids: voids, mode: mode);

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

      Path newPath = prevPath.next;
      Path commonPath = path.common(prevPath);
      bool isPreviousSibling = path.isSibling(prevPath);

      List<NodeEntry> entries = List.from(editor.levels(at: path));
      List<Node> levels = [];

      for (int i = 0; i < entries.length; i++) {
        NodeEntry entry = entries[i];
        levels.add(entry.node);
      }

      levels = levels.sublist(commonPath.length);
      levels.removeLast();

      // Determine if the merge will leave an ancestor of the path empty as a
      // result, in which case we'll want to remove it after merging.
      NodeEntry emptyAncestor = editor.above(
          at: path,
          mode: Mode.highest,
          match: (n) {
            return levels.contains(n) &&
                (n is Element) &&
                n.children.length == 1;
          });

      PathRef emptyRef;
      if (emptyAncestor != null) {
        emptyRef = editor.pathRef(emptyAncestor.path);
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
      if ((prevNode is Element && editor.isEmpty(prevNode)) ||
          (prevNode is Text && prevNode.text == '')) {
        Transforms.removeNodes(editor, at: prevPath, voids: voids);
      } else {
        editor.apply(MergeNodeOperation(newPath, position, null, props));
      }

      if (emptyRef != null) {
        emptyRef.unref(editor.pathRefs);
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
    editor.withoutNormalizing(() {
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

      PathRef toRef = editor.pathRef(to);
      List<NodeEntry> targets = List.from(
          editor.nodes(at: at, match: match, mode: mode, voids: voids));
      List<PathRef> pathRefs = [];

      for (NodeEntry entry in targets) {
        pathRefs.add(editor.pathRef(entry.path));
      }

      for (PathRef pathRef in pathRefs) {
        Path path = pathRef.unref(editor.pathRefs);
        Path newPath = toRef.current;

        if (path.isNotEmpty) {
          editor.apply(MoveNodeOperation(path, newPath));
        }
      }

      toRef.unref(editor.pathRefs);
    });
  }

  /// Remove the nodes at a specific location in the document.
  static void removeNodes(Editor editor,
      {Location at,
      NodeMatch match,
      Mode mode = Mode.lowest,
      bool hanging = false,
      bool voids = false}) {
    editor.withoutNormalizing(() {
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
        at = editor.unhangRange(at);
      }

      List<NodeEntry> depths = List.from(
          editor.nodes(at: at, match: match, mode: mode, voids: voids));

      Set<PathRef> pathRefs = Set();

      for (NodeEntry depth in depths) {
        PathRef pathRef = editor.pathRef(depth.path);
        pathRefs.add(pathRef);
      }

      for (PathRef pathRef in pathRefs) {
        Path path = pathRef.unref(editor.pathRefs);

        if (path != null) {
          NodeEntry entry = editor.node(path);
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
    editor.withoutNormalizing(() {
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
        at = editor.unhangRange(at);
      }

      if (split && at is Range) {
        RangeRef rangeRef = editor.rangeRef(at, affinity: Affinity.inward);
        Edges edges = (at as Range).edges();
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

        at = rangeRef.unref(editor.rangeRefs);

        if (prevAt == null) {
          Transforms.select(editor, at);
        }
      }

      Map<String, dynamic> argProps = props;

      for (NodeEntry entry in editor.nodes(
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
    editor.withoutNormalizing(() {
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
        Point point = editor.point(path);
        NodeEntry<Ancestor> entry = editor.parent(path);
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

      PointRef beforeRef = editor.pointRef(at, affinity: Affinity.backward);
      List<NodeEntry> entries = List.from(
          editor.nodes(at: at, match: match, mode: mode, voids: voids));
      NodeEntry highest = entries.first;

      if (highest == null) {
        return;
      }

      NodeEntry<Element> voidMatch =
          editor.matchVoid(at: at, mode: Mode.highest);
      int nudge = 0;

      if (voids == false && voidMatch != null) {
        Node voidNode = voidMatch.node;
        Path voidPath = voidMatch.path;

        if (voidNode is Element && voidNode is Inline) {
          Point after = editor.after(voidPath);

          if (after == null) {
            Text text = Text('');
            Path afterPath = voidPath.next;
            Transforms.insertNodes(editor, [text], at: afterPath, voids: voids);
            after = editor.point(afterPath);
          }

          at = after;
          always = true;
        }

        int siblingHeight = (at as Point).path.length - voidPath.length;
        height = siblingHeight + 1;
        always = true;
      }

      PointRef afterRef = editor.pointRef(at);
      int depth = (at as Point).path.length - height;
      Path highestPath = highest.path;
      Path lowestPath = (at as Point).path.slice(0, depth);
      int position = height == 0
          ? (at as Point).offset
          : (at as Point).path[depth] + nudge;
      int target;

      for (NodeEntry entry
          in editor.levels(at: lowestPath, reverse: true, voids: voids)) {
        Node node = entry.node;
        Path path = entry.path;
        bool split = false;

        if (path.length < highestPath.length ||
            path.length == 0 ||
            (node is Element && !voids && node.isVoid)) {
          break;
        }

        Point point = beforeRef.current;
        bool isEnd = editor.isEnd(point, path);

        if (always || beforeRef == null || !editor.isEdge(point, path)) {
          split = true;
          editor.apply(SplitNodeOperation(path, position, target, node.props));
        }

        target = position;
        position = path[path.length - 1] + (split || isEnd ? 1 : 0);
      }

      if (prevAt == null) {
        Point point = afterRef.current ?? editor.end(Path([]));
        Transforms.select(editor, point);
      }

      beforeRef.unref(editor.pointRefs);
      afterRef.unref(editor.pointRefs);
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
    editor.withoutNormalizing(() {
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
        at = editor.range(at, null);
      }

      RangeRef rangeRef = (at is Range) ? editor.rangeRef(at) : null;

      List<NodeEntry> matches = [];

      for (NodeEntry entry
          in editor.nodes(at: at, match: match, mode: mode, voids: voids)) {
        matches.add(entry);
      }

      Set<PathRef> pathRefs = Set();

      for (NodeEntry match in matches) {
        PathRef pathRef = editor.pathRef(match.path);
        pathRefs.add(pathRef);
      }

      for (PathRef pathRef in pathRefs) {
        Path path = pathRef.unref(editor.pathRefs);
        NodeEntry entry = editor.node(path);
        Ancestor node = entry.node;
        Range range = editor.range(path, null);

        if (split && rangeRef != null) {
          range = rangeRef.current.intersection(range);
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

      if (rangeRef != null) {
        rangeRef.unref(editor.rangeRefs);
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
    editor.withoutNormalizing(() {
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
            return editor.isInline(n) || (n is Text);
          };
        } else {
          match = (n) {
            return n is Block;
          };
        }
      }

      if (split && at is Range) {
        Edges edges = (at as Range).edges();
        Point start = edges.start;
        Point end = edges.end;

        RangeRef rangeRef = editor.rangeRef(at, affinity: Affinity.inward);
        Transforms.splitNodes(editor, at: end, match: match, voids: voids);
        Transforms.splitNodes(editor, at: start, match: match, voids: voids);
        at = rangeRef.unref(editor.rangeRefs);

        if (prevAt == null) {
          Transforms.select(editor, at);
        }
      }

      List<NodeEntry> roots = List.from(editor.nodes(
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
        Location a = at is Range
            ? (at as Range).intersection(editor.range(root.path, null))
            : at;

        if (a == null) {
          continue;
        }

        List<NodeEntry> matches = List.from(
            editor.nodes(at: a, match: match, mode: mode, voids: voids));

        if (matches.length > 0) {
          NodeEntry first = matches.first;
          NodeEntry last = matches.last;
          Path firstPath = first.path;
          Path lastPath = last.path;

          Path commonPath = firstPath.equals(lastPath)
              ? firstPath.parent
              : firstPath.common(lastPath);

          Range range = editor.range(firstPath, lastPath);
          NodeEntry common = editor.node(commonPath);
          Ancestor commonNode = common.node;
          int depth = commonPath.length + 1;
          Path wrapperPath = lastPath.slice(0, depth).next;

          // TODO: Figure out how to create new node with any class inherting from either
          Element wrapper;

          if (element is Inline) {
            wrapper = Inline(
                children: [], props: element.props, isVoid: element.isVoid);
          } else if (element is Block) {
            wrapper = Block(
                children: [], props: element.props, isVoid: element.isVoid);
          }

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
      Edges edges = selection.edges();
      Point start = edges.start;
      Transforms.select(editor, start);
    } else if (edge == Edge.end) {
      Edges edges = selection.edges();
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
      edge = selection.isBackward ? Edge.focus : Edge.anchor;
    }

    if (edge == Edge.end) {
      edge = selection.isBackward ? Edge.anchor : Edge.focus;
    }

    Point anchor = selection.anchor;
    Point focus = selection.focus;
    Range newSelection = Range(null, null);

    if (edge == null || edge == Edge.anchor) {
      Point point = reverse
          ? editor.before(anchor, distance: distance, unit: unit)
          : editor.after(anchor, distance: distance, unit: unit);

      if (point != null) {
        newSelection.anchor = point;
      }
    }

    if (edge == null || edge == Edge.focus) {
      Point point = reverse
          ? editor.before(focus, distance: distance, unit: unit)
          : editor.after(focus, distance: distance, unit: unit);

      if (point != null) {
        newSelection.focus = point;
      }
    }

    Transforms.setSelection(editor, newSelection);
  }

  /// Set the selection to a new value.
  static void select(Editor editor, Location target) {
    Range selection = editor.selection;
    target = editor.range(target, null);

    if (selection != null) {
      Transforms.setSelection(editor, target);
      return;
    }

    if (target is Range == false) {
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
      edge = selection.isBackward ? Edge.focus : Edge.anchor;
    }

    if (edge == Edge.end) {
      edge = selection.isBackward ? Edge.anchor : Edge.focus;
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
        !selection.anchor.equals(newSelection.anchor) ||
        !selection.focus.equals(newSelection.focus);

    if (hasSelectionChanges) {
      selection = Range(selection.anchor, selection.focus, props: oldProps);
      newSelection =
          Range(newSelection.anchor, newSelection.focus, props: newProps);

      editor.apply(SetSelectionOperation(selection, newSelection));
    }
  }

  // #endregion

  // #region Text transforms

  /// Delete content in the editor.
  static void delete(Editor editor,
      {Location at,
      int distance = 1,
      Unit unit = Unit.character,
      bool reverse = false,
      bool hanging = false,
      bool voids = false}) {
    editor.withoutNormalizing(() {
      Location prevAt = at;
      at = at ?? editor.selection;

      if (at == null) {
        return;
      }

      if (at is Range && (at as Range).isCollapsed) {
        at = (at as Range).anchor;
      }

      if (at is Point) {
        NodeEntry<Element> furthestVoid =
            editor.matchVoid(at: at, mode: Mode.highest);

        if (voids == false && furthestVoid != null) {
          Path voidPath = furthestVoid.path;
          at = voidPath;
        } else {
          Point target = reverse
              ? editor.before(at, unit: unit, distance: distance) ??
                  editor.start(Path([]))
              : editor.after(at, unit: unit, distance: distance) ??
                  editor.end(Path([]));
          at = Range(at, target);
          hanging = true;
        }
      }

      if (at is Path) {
        Transforms.removeNodes(editor, at: at, voids: voids);
        return;
      }

      if ((at as Range).isCollapsed) {
        return;
      }

      if (!hanging) {
        at = editor.unhangRange(at, voids: voids);
      }

      Edges edges = (at as Range).edges();
      Point start = edges.start;
      Point end = edges.end;

      NodeEntry<Block> startBlock = editor.above(
          match: (n) {
            return n is Block;
          },
          at: start,
          voids: voids);
      NodeEntry<Block> endBlock = editor.above(
          match: (n) {
            return n is Block;
          },
          at: end,
          voids: voids);
      bool isAcrossBlocks = startBlock != null &&
          endBlock != null &&
          !startBlock.path.equals(endBlock.path);
      bool isSingleText = start.path.equals(end.path);
      NodeEntry<Element> startVoid =
          voids ? null : editor.matchVoid(at: start, mode: Mode.highest);
      NodeEntry<Element> endVoid =
          voids ? null : editor.matchVoid(at: end, mode: Mode.highest);

      // If the start or end points are inside an inline void, nudge them out.
      if (startVoid != null) {
        Point before = editor.before(start);

        if (before != null &&
            startBlock != null &&
            startBlock.path.isAncestor(before.path)) {
          start = before;
        }
      }

      if (endVoid != null) {
        Point after = editor.after(end);

        if (after != null &&
            endBlock != null &&
            endBlock.path.isAncestor(after.path)) {
          end = after;
        }
      }

      // Get the highest nodes that are completely inside the range, as well as
      // the start and end nodes.
      List<NodeEntry> matches = [];
      Path lastPath;

      for (NodeEntry entry in editor.nodes(at: at, voids: voids)) {
        Node node = entry.node;
        Path path = entry.path;

        if (lastPath != null && path.compare(lastPath) == 0) {
          continue;
        }

        if ((node is Element && !voids && node.isVoid) ||
            (!path.isCommon(start.path) && !path.isCommon(end.path))) {
          matches.add(entry);
          lastPath = path;
        }
      }

      Set<PathRef> pathRefs = Set();

      for (NodeEntry match in matches) {
        PathRef pathRef = editor.pathRef(match.path);
        pathRefs.add(pathRef);
      }

      PointRef startRef = editor.pointRef(start);
      PointRef endRef = editor.pointRef(end);

      if (!isSingleText && startVoid == null) {
        Point point = startRef.current;
        NodeEntry<Text> entry = editor.leaf(point);
        Text node = entry.node;
        Path path = point.path;
        int offset = start.offset;

        String text = node.text.substring(offset);

        editor.apply(RemoveTextOperation(path, offset, text));
      }

      for (PathRef pathRef in pathRefs) {
        Path path = pathRef.unref(editor.pathRefs);
        Transforms.removeNodes(editor, at: path, voids: voids);
      }

      if (endVoid == null) {
        Point point = endRef.current;
        NodeEntry<Text> entry = editor.leaf(point);
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

      Point point =
          endRef.unref(editor.pointRefs) ?? startRef.unref(editor.pointRefs);

      if (prevAt == null && point != null) {
        Transforms.select(editor, point);
      }
    });
  }

  /// Insert a fragment at a specific location in the editor.
  static void insertFragment(Editor editor, List<Node> fragment,
      {Location at, bool hanging = false, bool voids = false}) {
    editor.withoutNormalizing(() {
      Location prevAt = at;
      at = at ?? editor.selection;

      if (fragment.isEmpty) {
        return;
      }

      if (at == null) {
        return;
      } else if (at is Range) {
        if (hanging == false) {
          at = editor.unhangRange(at);
        }

        if ((at as Range).isCollapsed) {
          at = (at as Range).anchor;
        } else {
          Edges edges = (at as Range).edges();
          Point end = edges.end;

          if (!voids && editor.matchVoid(at: end) != null) {
            return;
          }

          PointRef pointRef = editor.pointRef(end);
          Transforms.delete(editor, at: at);

          at = pointRef.unref(editor.pointRefs);
        }
      } else if (at is Path) {
        at = editor.start(at);
      }

      if (!voids && editor.matchVoid(at: at) != null) {
        return;
      }

      // If the insert point is at the edge of an inline node, move it outside
      // instead since it will need to be split otherwise.
      NodeEntry inlineElementMatch = editor.above(
          at: at,
          match: (n) {
            return editor.isInline(n);
          },
          mode: Mode.highest,
          voids: voids);

      if (inlineElementMatch != null) {
        Path inlinePath = inlineElementMatch.path;

        if (editor.isEnd(at, inlinePath)) {
          Point after = editor.after(inlinePath);
          at = after;
        } else if (editor.isStart(at, inlinePath)) {
          Point before = editor.before(inlinePath);
          at = before;
        }
      }

      NodeEntry blockMatch = editor.above(
        match: (n) {
          return n is Block;
        },
        at: at,
        voids: voids,
      );

      Path blockPath = blockMatch.path;
      bool isBlockStart = editor.isStart(at, blockPath);
      bool isBlockEnd = editor.isEnd(at, blockPath);
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
            p.isAncestor(firstPath) &&
            n is Element &&
            !n.isVoid &&
            !(n is Inline)) {
          return false;
        }

        if (mergeEnd &&
            p.isAncestor(lastPath) &&
            n is Element &&
            !n.isVoid &&
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

      List<NodeEntry> inlines = List.from(editor.nodes(
          at: at,
          match: (n) {
            return (n is Text) || editor.isInline(n);
          },
          mode: Mode.highest,
          voids: voids));

      NodeEntry inlineMatch = inlines.first;
      Path inlinePath = inlineMatch.path;

      bool isInlineStart = editor.isStart(at, inlinePath);
      bool isInlineEnd = editor.isEnd(at, inlinePath);

      PathRef middleRef =
          editor.pathRef(isBlockEnd ? blockPath.next : blockPath);

      PathRef endRef =
          editor.pathRef(isInlineEnd ? inlinePath.next : inlinePath);

      Transforms.splitNodes(editor, at: at, match: (n) {
        return hasBlocks ? n is Block : n is Text || n is Inline;
      }, mode: hasBlocks ? Mode.lowest : Mode.highest, voids: voids);

      PathRef startRef = editor.pathRef(
          !isInlineStart || (isInlineStart && isInlineEnd)
              ? inlinePath.next
              : inlinePath);

      Transforms.insertNodes(
        editor,
        starts,
        at: startRef.current,
        match: (n) {
          return (n is Text) || editor.isInline(n);
        },
        mode: Mode.highest,
        voids: voids,
      );

      Transforms.insertNodes(editor, middles, at: middleRef.current,
          match: (n) {
        return n is Block;
      }, mode: Mode.lowest, voids: voids);

      Transforms.insertNodes(editor, ends, at: endRef.current, match: (n) {
        return (n is Text) || editor.isInline(n);
      }, mode: Mode.highest, voids: voids);

      if (prevAt == null) {
        Path path;

        if (ends.length > 0) {
          path = endRef.current.previous;
        } else if (middles.length > 0) {
          path = middleRef.current.previous;
        } else {
          path = startRef.current.previous;
        }

        Point end = editor.end(path);
        Transforms.select(editor, end);
      }

      startRef.unref(editor.pathRefs);
      middleRef.unref(editor.pathRefs);
      endRef.unref(editor.pathRefs);
    });
  }

  /// Insert a string of text in the Editor.
  static void insertText(Editor editor, String text,
      {Location at, bool voids = false}) {
    editor.withoutNormalizing(() {
      at = at ?? editor.selection;

      if (at == null) {
        return;
      }

      if (at is Path) {
        at = editor.range(at, null);
      }

      if (at is Range) {
        if ((at as Range).isCollapsed) {
          at = (at as Range).anchor;
        } else {
          Point end = (at as Range).end;

          if (!voids && editor.matchVoid(at: end) != null) {
            return;
          }

          PointRef pointRef = editor.pointRef(end);
          Transforms.delete(editor, at: at, voids: voids);
          at = pointRef.unref(editor.pointRefs);
          Transforms.setSelection(editor, Range(at, at));
        }
      }

      if (!voids && editor.matchVoid(at: at) != null) {
        return;
      }

      Path path = (at as Point).path;
      int offset = (at as Point).offset;
      editor.apply(InsertTextOperation(path, offset, text));
    });
  }

  // #endregion
}

/// Convert a range into a point by deleting it's content.
Point Function(Editor editor, Range range) deleteRange =
    (Editor editor, Range range) {
  if (range.isCollapsed) {
    return range.anchor;
  } else {
    Edges edges = range.edges();
    Point end = edges.end;

    PointRef pointRef = editor.pointRef(end);
    Transforms.delete(editor, at: range);

    return pointRef.unref(editor.pointRefs);
  }
};

bool Function(Node node) Function(Editor editor, Path path) matchPath =
    (Editor editor, Path path) {
  NodeEntry entry = editor.node(path);
  Node node = entry.node;

  return (n) {
    return n == node;
  };
};
