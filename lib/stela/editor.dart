import 'package:inday/stela/element.dart';
import 'package:inday/stela/location.dart';
import 'package:inday/stela/node.dart';
import 'package:inday/stela/operation.dart';
import 'package:inday/stela/path.dart';
import 'package:inday/stela/point.dart';
import 'package:inday/stela/range.dart';
import 'package:inday/stela/text.dart';
import 'package:inday/stela/transforms.dart';

/// The `Editor` interface stores all the state of a Stela editor. It is extended
/// by plugins that wish to add their own helpers and implement new behaviors.
class Editor implements Ancestor {
  Editor(
      {List<Node> children,
      Range selection,
      List<Operation> operations,
      Map<String, dynamic> marks,
      Map<String, dynamic> props})
      : children = children ?? [],
        selection = selection,
        operations = operations ?? [],
        marks = marks ?? {},
        props = props ?? {};

  List<Path> _dirtyPaths = [];
  bool _isFlushing = false;
  bool _isNormalizing = true;
  Set<PathRef> pathRefs = Set();
  Set<PointRef> pointRefs = Set();
  Set<RangeRef> rangeRefs = Set();

  /// Custom properties that can extend the `Element` behavior
  Map<String, dynamic> props;

  /// The `children` property contains the document tree of nodes that make up the editor's content
  List<Node> children;

  /// The `selection` property contains the user's current selection, if any
  Range selection;

  /// The `operations` property contains all of the operations that have been applied since the last 'change' was flushed. (Since Slate batches operations up into ticks of the event loop.)
  List<Operation> operations;

  /// The `marks` property stores formatting that is attached to the cursor, and that will be applied to the text that is inserted next
  Map<String, dynamic> marks;

  @override
  String toString() {
    String str = '';

    for (Node child in children) {
      str += child.toString() + ', ';
    }

    return 'Editor(children:[$str])';
  }

  void onChange() {
    return;
  }

  void normalizeNode(NodeEntry entry) {
    Node node = entry.node;
    Path path = entry.path;

    // There are no core normalizations for text nodes.
    if (node is Text) {
      return;
    }

    // Ensure that block and inline nodes have at least one text child.
    if (node is Element && node.children.isEmpty) {
      Text child = Text('');
      Path at = path.copyAndAdd(0);

      Transforms.insertNodes(
        this,
        [child],
        at: at,
        voids: true,
      );
      return;
    }

    // Determine whether the node should have block or inline children.
    bool shouldHaveInlines = node is Editor
        ? false
        : node is Element &&
            (node is Inline ||
                node.children.isEmpty ||
                (node.children.first is Text) ||
                node.children.first is Inline);

    // Since we'll be applying operations while iterating, keep track of an
    // index that accounts for any added/removed nodes.
    int n = 0;

    // We want to batch the transforms first before executing them.
    // The reason is that each transform mutates the editor,
    // but we should not allow simultaneous mutation and iteration of the its nodes.
    // By first iterating and collecting mutations and executing them one by one at the end
    // we avoid concurrent modification errors
    List<void Function()> transforms = [];

    for (int i = 0; i < (node as Ancestor).children.length; i++, n++) {
      Descendant child = (node as Ancestor).children[i];
      Descendant prev = i - 1 >= 0 ? (node as Ancestor).children[i - 1] : null;

      bool isLast = i == (node as Ancestor).children.length - 1;
      bool isInlineOrText = child is Text || child is Inline;

      // Only allow block nodes in the top-level children and parent blocks
      // that only contain block nodes. Similarly, only allow inline nodes in
      // other inline nodes, or parent blocks that only contain inlines and
      // text.
      if (isInlineOrText != shouldHaveInlines) {
        Path at = path.copyAndAdd(n);

        transforms.add(() {
          Transforms.removeNodes(this, at: at, voids: true);
        });
        n--;
      } else if (child is Element) {
        // Ensure that inline nodes are surrounded by text nodes.
        if (child is Inline) {
          if (prev == null || !(prev is Text)) {
            Path at = path.copyAndAdd(n);
            Text newChild = Text('');
            transforms.add(() {
              Transforms.insertNodes(this, [newChild], at: at, voids: true);
            });
            n++;
          } else if (isLast) {
            Path at = path.copyAndAdd(n + 1);
            Text newChild = Text('');
            transforms.add(() {
              Transforms.insertNodes(
                this,
                [newChild],
                at: at,
                voids: true,
              );
            });
            n++;
          }
        }
      } else {
        // Merge adjacent text nodes that are empty or match.
        if (prev != null && prev is Text) {
          if (TextUtils.propsEquals(child, prev)) {
            Path at = path.copyAndAdd(n);
            transforms.add(() {
              Transforms.mergeNodes(this, at: at, voids: true);
            });
            n--;
          } else if (prev.text == '') {
            Path at = path.copyAndAdd(n - 1);
            transforms.add(() {
              Transforms.removeNodes(
                this,
                at: at,
                voids: true,
              );
            });
            n--;
          } else if (isLast && (child as Text).text == '') {
            Path at = path.copyAndAdd(n);
            transforms.add(() {
              Transforms.removeNodes(
                this,
                at: at,
                voids: true,
              );
            });
            n--;
          }
        }
      }
    }

    for (void Function() transform in transforms) {
      transform();
    }
  }

  /// Add a custom property to the leaf text nodes in the current selection.
  ///
  /// If the selection is currently collapsed, the marks will be added to the
  /// `editor.marks` property instead, and applied when text is inserted next.
  void addMark(String key, dynamic value) {
    Map<String, dynamic> props = Map.from({
      [key]: value
    });

    if (selection != null) {
      if (selection.isExpanded) {
        Transforms.setNodes(this, props, match: (n) {
          return n is Text;
        }, split: true);
      } else {
        marks.addAll(props);
        onChange();
      }
    }
  }

  void apply(Operation op) {
    Set<PathRef> unrefPathRefs = Set();
    Set<RangeRef> unrefRangeRefs = Set();
    Set<PointRef> unrefPointRefs = Set();

    for (PathRef ref in pathRefs) {
      Path path = PathRef.transform(pathRefs, ref, op);
      if (path == null) {
        unrefPathRefs.add(ref);
      }
    }

    for (PathRef unrefPath in unrefPathRefs) {
      unrefPath.unref(pathRefs);
    }

    for (PointRef ref in pointRefs) {
      Point point = PointRef.transform(pointRefs, ref, op);
      if (point == null) {
        unrefPointRefs.add(ref);
      }
    }

    for (PointRef unrefPoint in unrefPointRefs) {
      unrefPoint.unref(pointRefs);
    }

    for (RangeRef ref in rangeRefs) {
      Range range = RangeRef.transform(rangeRefs, ref, op);
      if (range == null) {
        unrefRangeRefs.add(ref);
      }
    }

    for (RangeRef unrefRange in unrefRangeRefs) {
      unrefRange.unref(rangeRefs);
    }

    Set cache = Set();
    List<Path> dirtyPaths = [];

    Function(Path) add = (Path path) {
      if (path != null) {
        String key = path.join(',');

        if (!cache.contains(key)) {
          cache.add(key);
          dirtyPaths.add(path);
        }
      }
    };

    List<Path> oldDirtyPaths = _dirtyPaths ?? [];
    List<Path> newDirtyPaths = getDirtyPaths(op);

    for (Path path in oldDirtyPaths) {
      Path newPath = path.transform(op);
      add(newPath);
    }

    for (Path path in newDirtyPaths) {
      add(path);
    }

    _dirtyPaths = dirtyPaths;
    transform(op);
    operations.add(op);
    normalize();

    // Clear any formats applied to the cursor if the selection changes.
    if (op is SetSelectionOperation) {
      marks = null;
    }

    if (_isFlushing == false) {
      _isFlushing = true;

      Future.microtask(() {
        _isFlushing = false;
        onChange();
        operations = [];
      });
    }
  }

  /// Delete content in the editor backward from the current selection.
  void deleteBackward(Unit unit) {
    if (selection != null && selection.isCollapsed) {
      Transforms.delete(this, unit: unit, reverse: true);
    }
  }

  /// Delete content in the editor forward from the current selection.
  void deleteForward(Unit unit) {
    if (selection != null && selection.isCollapsed) {
      Transforms.delete(this, unit: unit);
    }
  }

  /// Delete the content in the current selection.
  void deleteFragment() {
    if (selection != null && selection.isExpanded) {
      Transforms.delete(this);
    }
  }

  /// Insert a block break at the current selection.
  ///
  /// If the selection is currently expanded, it will be deleted first.
  void insertBreak() {
    Transforms.splitNodes(this, always: true);
  }

  /// Insert a fragment at the current selection.
  ///
  /// If the selection is currently expanded, it will be deleted first.
  void insertFragment(List<Node> fragment) {
    Transforms.insertFragment(this, fragment);
  }

  /// Insert a node at the current selection.
  ///
  /// If the selection is currently expanded, it will be deleted first.
  void insertNode(Node node) {
    Transforms.insertNodes(this, [node]);
  }

  /// Insert text at the current selection.
  ///
  /// If the selection is currently expanded, it will be deleted first.
  void insertText(String text) {
    if (selection != null) {
      // If the cursor is at the end of an inline, move it outside of
      // the inline before inserting
      if (selection.isCollapsed) {
        NodeEntry inline = above(
            match: (n) {
              return isInline(n);
            },
            mode: Mode.highest);

        if (inline != null) {
          Path inlinePath = inline.path;

          if (isEnd(selection.anchor, inlinePath)) {
            Point point = after(inlinePath);
            Transforms.setSelection(this, Range(point, point));
          }
        }
      }

      if (marks != null) {
        Text node = Text(text, props: marks);
        Transforms.insertNodes(this, [node]);
      } else {
        Transforms.insertText(this, text);
      }

      marks = null;
    }
  }

  /// Remove a custom property from all of the leaf text nodes in the current
  /// selection.
  ///
  /// If the selection is currently collapsed, the removal will be stored on
  /// `editor.marks` and applied to the text inserted next.
  void removeMark(String key) {
    if (selection != null) {
      if (selection.isExpanded) {
        Transforms.unsetNodes(
          this,
          [key],
          match: (n) {
            return n is Text;
          },
          split: true,
        );
      } else {
        marks.remove(key);
        onChange();
      }
    }
  }

  /// Get the ancestor above a location in the document.
  NodeEntry<T> above<T extends Ancestor>(
      {Location at,
      NodeMatch<T> match,
      Mode mode = Mode.lowest,
      bool voids = false}) {
    at = at ?? selection;

    if (at == null) {
      return null;
    }

    Path p = path(at);
    bool reverse = mode == Mode.lowest;
    List<NodeEntry> ls =
        List.from(levels(at: p, voids: voids, match: match, reverse: reverse));

    for (NodeEntry entry in ls) {
      if (!(entry.node is Text) && !p.equals(entry.path)) {
        return NodeEntry(entry.node, entry.path);
      }
    }

    return null;
  }

  /// Get the point after a location.
  Point after(Location at, {int distance = 1, Unit unit = Unit.offset}) {
    Point anchor = point(at, edge: Edge.end);
    Point focus = end(Path([]));
    Range range = Range(anchor, focus);
    int d = 0;
    Point target;

    List<Point> ps = List.from(positions(at: range, unit: unit));

    for (Point p in ps) {
      if (d > distance) {
        break;
      }

      if (d != 0) {
        target = p;
      }

      d++;
    }

    return target;
  }

  /// Get the point before a location.
  Point before(Location at, {int distance = 1, Unit unit = Unit.offset}) {
    Point anchor = start(Path([]));
    Point focus = point(at, edge: Edge.start);
    Range range = Range(anchor, focus);

    int d = 0;
    Point target;

    for (Point p in positions(at: range, reverse: true, unit: unit)) {
      if (d > distance) {
        break;
      }

      if (d != 0) {
        target = p;
      }

      d++;
    }

    return target;
  }

  /// Get the start and end points of a location.
  Edges edges(Location at) {
    return Edges(start(at), end(at));
  }

  /// Get the end point of a location.
  Point end(Location at) {
    return point(at, edge: Edge.end);
  }

  /// Get the first node at a location.
  NodeEntry first(Location at) {
    Path p = path(at, edge: Edge.start);
    return node(p);
  }

  /// Get the fragment at a location.
  List<Descendant> fragment(Location at) {
    Range r = range(at, null);
    List<Descendant> fragment = NodeUtils.fragment(this, r);
    return fragment;
  }

  /// Check if a node has block children.
  bool hasBlocks(Element element) {
    bool hasBlocks = false;

    for (Node node in element.children) {
      if (node is Block) {
        hasBlocks = true;
        break;
      }
    }

    return hasBlocks;
  }

  /// Check if a node has inline and text children.
  bool hasInlines(Element element) {
    bool hasInlines = false;

    for (Node node in element.children) {
      if (node is Text || isInline(node)) {
        hasInlines = true;
        break;
      }
    }

    return hasInlines;
  }

  /// Check if a node has text children.
  bool hasTexts(Element element) {
    bool hasTexts = false;

    for (Node node in element.children) {
      if (node is Text) {
        hasTexts = true;
        break;
      }
    }

    return hasTexts;
  }

  /// Check if a point is the end point of a location.

  bool isEnd(Point point, Location at) {
    return point.equals(end(at));
  }

  /// Check if a point is an edge of a location.
  bool isEdge(Point point, Location at) {
    return isStart(point, at) || isEnd(point, at);
  }

  /// Check if an element is empty, accounting for void nodes.
  bool isEmpty(Element element) {
    List<Node> children = element.children;
    return (children.isEmpty ||
        (children.length == 1 &&
            (children.first is Text) &&
            (children.first as Text).text == '' &&
            !element.isVoid));
  }

  /// Check if a value is an inline `Element` object.
  bool isInline(Node node) {
    return (node is Element) && node is Inline;
  }

  /// Check if a point is the start point of a location.
  bool isStart(Point point, Location at) {
    // PERF: If the offset isn't `0` we know it's not the start.
    if (point.offset != 0) {
      return false;
    }

    Point s = start(at);

    return point.equals(s);
  }

  /// Get the last node at a location.
  NodeEntry last(Location at) {
    return node(path(at, edge: Edge.end));
  }

  /// Get the leaf text node at a location.
  NodeEntry<Text> leaf(
    Location at, {
    int depth,
    Edge edge,
  }) {
    Path p = path(at, depth: depth, edge: edge);
    Node node = NodeUtils.leaf(this, p);

    return NodeEntry(node, p);
  }

  /// Iterate through all of the levels at a location.
  Iterable<NodeEntry<T>> levels<T extends Node>({
    Location at,
    NodeMatch<T> match,
    bool reverse = false,
    bool voids = false,
  }) sync* {
    at = at ?? selection;

    if (match == null) {
      match = (node) {
        return true;
      };
    }

    if (at == null) {
      return;
    }

    List<NodeEntry<T>> levels = [];
    Path p = path(at);

    for (NodeEntry entry in NodeUtils.levels(this, p)) {
      Node n = entry.node;

      if (!match(n)) {
        continue;
      }

      levels.add(entry);

      if (n is Element && !voids && n.isVoid) {
        break;
      }
    }

    if (reverse) {
      for (int i = levels.length - 1; i >= 0; i--) {
        yield levels[i];
      }
    } else {
      for (NodeEntry<T> level in levels) {
        yield level;
      }
    }
  }

  /// Get the marks that would be added to text at the current selection.
  Map<String, dynamic> selectionMarks() {
    if (selection == null) {
      return null;
    }

    if (marks != null) {
      return marks;
    }

    if (selection.isExpanded) {
      List<NodeEntry> ns = List.from(nodes(match: (node) {
        return (node is Text);
      }));
      NodeEntry match = ns[0];

      if (match != null) {
        Text node = match.node;

        return node.props;
      } else {
        return {};
      }
    }

    Point anchor = selection.anchor;
    Path path = anchor.path;

    NodeEntry entry = leaf(path);
    Text node = entry.node;

    if (anchor.offset == 0) {
      NodeEntry prev = previous(
          at: path,
          match: (node) {
            return (node is Text);
          });
      NodeEntry block = above(match: (node) {
        return node is Block;
      });

      if (prev != null && block != null) {
        Node prevNode = prev.node;
        Path prevPath = prev.path;
        Path blockPath = block.path;

        if (blockPath.isAncestor(prevPath)) {
          node = prevNode;
        }
      }
    }

    return node.props;
  }

  /// Get the matching node in the branch of the document after a location.
  NodeEntry<T> next<T extends Node>(
      {Location at,
      NodeMatch<T> match,
      Mode mode = Mode.lowest,
      bool voids = false}) {
    at = at ?? selection;

    if (at == null) {
      return null;
    }

    NodeEntry fromNode = last(at);
    Path from = fromNode.path;

    NodeEntry toNode = last(Path([]));
    Path to = toNode.path;

    Span span = Span(from, to);

    if ((at is Path) && at.length == 0) {
      throw Exception('Cannot get the next node from the root node!');
    }

    if (match == null) {
      if (at is Path) {
        NodeEntry<Ancestor> entry = parent(at);
        Ancestor p = entry.node;

        match = (node) {
          return p.children.contains(node);
        };
      } else {
        match = (node) {
          return true;
        };
      }
    }

    List<NodeEntry> ns =
        List.from(nodes(at: span, match: match, mode: mode, voids: voids));
    NodeEntry next = ns[1];

    return next;
  }

  /// Get the node at a location.
  NodeEntry<T> node<T extends Node>(
    Location at, {
    int depth,
    Edge edge,
  }) {
    Path p = path(at, edge: edge, depth: depth);
    Node node = NodeUtils.get(this, p);

    return NodeEntry(node, p);
  }

  /// Iterate through all of the nodes in the Editor.
  ///
  /// [universal] ensures that the match occurs in every branch
  Iterable<NodeEntry<T>> nodes<T extends Node>({
    Location at,
    NodeMatch<T> match,
    Mode mode = Mode.all,
    bool universal = false,
    bool reverse = false,
    bool voids = false,
  }) sync* {
    at = at ?? selection;

    if (match == null) {
      match = (node) {
        return true;
      };
    }

    if (at == null) {
      return;
    }

    Path from;
    Path to;

    if (at is Span) {
      from = at.path0;
      to = at.path1;
    } else {
      Path first = path(at, edge: Edge.start);
      Path last = path(at, edge: Edge.end);
      from = reverse ? last : first;
      to = reverse ? first : last;
    }

    Iterable<NodeEntry<Node>> iterable = NodeUtils.nodes(this,
        reverse: reverse, from: from, to: to, pass: (entry) {
      Node n = entry.node;
      return (voids ? false : n is Element && n.isVoid);
    });

    List<NodeEntry<T>> matches = [];
    NodeEntry<T> hit;

    for (NodeEntry entry in iterable) {
      Node node = entry.node;
      Path path = entry.path;

      bool isLower = hit != null && path.compare(hit.path) == 0;

      // In highest mode any node lower than the last hit is not a match.
      if (mode == Mode.highest && isLower) {
        continue;
      }

      if (!match(node)) {
        // If we've arrived at a leaf text node that is not lower than the last
        // hit, then we've found a branch that doesn't include a match, which
        // means the match is not universal.
        if (universal && !isLower && (node is Text)) {
          return;
        } else {
          continue;
        }
      }

      // If there's a match and it's lower than the last, update the hit.
      if (mode == Mode.lowest && isLower) {
        hit = NodeEntry(node, path);
        continue;
      }

      // In lowest mode we emit the last hit, once it's guaranteed lowest.
      NodeEntry<T> emit = mode == Mode.lowest ? hit : NodeEntry(node, path);

      if (emit != null) {
        if (universal) {
          matches.add(emit);
        } else {
          yield emit;
        }
      }

      hit = NodeEntry(node, path);
    }

    // Since lowest is always emitting one behind, catch up at the end.
    if (mode == Mode.lowest && hit != null) {
      if (universal) {
        matches.add(hit);
      } else {
        yield hit;
      }
    }

    // Universal defers to ensure that the match occurs in every branch, so we
    // yield all of the matches after iterating.
    if (universal) {
      for (NodeEntry<T> match in matches) {
        yield match;
      }
    }
  }

  /// Normalize any dirty objects in the editor.
  void normalize({bool force = false}) {
    if (_isNormalizing == false) {
      return null;
    }

    if (force) {
      List<NodeEntry> nodes = List.from(NodeUtils.nodes(this));
      List<Path> allPaths = [];
      for (NodeEntry node in nodes) {
        allPaths.add(node.path);
      }
      _dirtyPaths = allPaths;
    }

    if (_dirtyPaths.isEmpty) {
      return null;
    }

    withoutNormalizing(() {
      // HACK: better way?
      int max = _dirtyPaths.length * 42;
      int m = 0;

      while (_dirtyPaths.isNotEmpty) {
        if (m > max) {
          throw Exception(
              'Could not completely normalize the editor after $max iterations! This is usually due to incorrect normalization logic that leaves a node in an invalid state.');
        }

        Path path = _dirtyPaths.removeLast();
        NodeEntry entry = node(path);
        normalizeNode(entry);
        m++;
      }
    });
  }

  /// Get the parent node of a location.
  NodeEntry<Ancestor> parent(
    Location at, {
    int depth,
    Edge edge,
  }) {
    Path p = path(at, edge: edge, depth: depth);
    Path parentPath = p.parent;
    NodeEntry<Ancestor> entry = node<Ancestor>(parentPath);
    return entry;
  }

  /// Get the path of a location.
  Path path(
    Location at, {
    int depth,
    Edge edge,
  }) {
    if (at is Path) {
      if (edge == Edge.start) {
        NodeEntry<Node> first = NodeUtils.first(this, at);
        at = first.path;
      } else if (edge == Edge.end) {
        NodeEntry<Node> last = NodeUtils.last(this, at);
        at = last.path;
      }
    }

    if (at is Range) {
      if (edge == Edge.start) {
        at = (at as Range).start;
      } else if (edge == Edge.end) {
        at = (at as Range).end;
      } else {
        at = (at as Range).anchor.path.common((at as Range).focus.path);
      }
    }

    if (at is Point) {
      at = (at as Point).path;
    }

    if (depth != null) {
      at = (at as Path).slice(0, depth);
    }

    return at;
  }

  /// Create a mutable ref for a `Path` object, which will stay in sync as new
  /// operations are applied to the editor.
  PathRef pathRef(Path path, {Affinity affinity = Affinity.forward}) {
    PathRef ref = PathRef(current: path, affinity: affinity);

    pathRefs.add(ref);
    return ref;
  }

  /// Get the start or end point of a location.
  Point point(Location at, {Edge edge = Edge.start}) {
    if (at is Path) {
      Path path;

      if (edge == Edge.end) {
        NodeEntry<Node> last = NodeUtils.last(this, at);
        path = last.path;
      } else {
        NodeEntry<Node> first = NodeUtils.first(this, at);
        path = first.path;
      }

      Node node = NodeUtils.get(this, path);

      if (!(node is Text)) {
        throw Exception(
            'Cannot get the ${edge.toString()} point in the node at path [${at.toString()}] because it has no ${edge.toString()} text node.');
      }

      return Point(path, edge == Edge.end ? (node as Text).text.length : 0);
    }

    if (at is Range) {
      Edges edges = at.edges();
      return edge == Edge.start ? edges.start : edges.end;
    }

    return at;
  }

  /// Create a mutable ref for a `Point` object, which will stay in sync as new
  /// operations are applied to the editor.
  PointRef pointRef(Point point, {Affinity affinity = Affinity.forward}) {
    PointRef ref = PointRef(current: point, affinity: affinity);

    pointRefs.add(ref);
    return ref;
  }

  /// Iterate through all of the positions in the document where a `Point` can be
  /// placed.
  ///
  /// By default it will move forward by individual offsets at a time,  but you
  /// can pass the `unit: 'character'` option to moved forward one character, word,
  /// or line at at time.
  ///
  /// Note: void nodes are treated as a single point, and iteration will not
  /// happen inside their content.
  Iterable<Point> positions({
    Location at,
    Unit unit = Unit.offset,
    bool reverse = false,
  }) sync* {
    at = at ?? selection;

    if (at == null) {
      return;
    }

    Range r = range(at, null);
    Point es = r.edges().start;
    Point ee = r.edges().end;
    Point first = reverse ? ee : es;
    String s = '';
    int available = 0;
    int offset = 0;
    int distance;
    bool isNewBlock = false;

    void Function() advance = () {
      if (distance == null) {
        if (unit == Unit.character) {
          distance = StringUtils.getCharacterDistance(s);
        } else if (unit == Unit.word) {
          distance = StringUtils.getWordDistance(s);
        } else if (unit == Unit.line || unit == Unit.block) {
          distance = s.length;
        } else {
          distance = 1;
        }

        s = s.substring(distance);
      }

      // Add or subtract the offset.
      offset = reverse ? offset - distance : offset + distance;
      // Subtract the distance traveled from the available text.
      available = available - distance;
      // If the available had room to spare, reset the distance so that it will
      // advance again next time. Otherwise, set it to the overflow amount.
      distance = available >= 0 ? null : 0 - available;
    };

    List<NodeEntry> entries = List.from(nodes(at: at, reverse: reverse));

    for (NodeEntry entry in entries) {
      Path path = entry.path;
      Node node = entry.node;

      if (node is Element) {
        // Void nodes are a special case, since we don't want to iterate over
        // their content. We instead always just yield their first point.
        if (node.isVoid) {
          yield start(path);
          continue;
        }

        if (node is Inline) {
          continue;
        }

        if (hasInlines(node)) {
          Point ep = path.isAncestor(ee.path) ? ee : end(path);
          Point sp = path.isAncestor(es.path) ? es : start(path);

          String text = string(Range(sp, ep));
          s = reverse ? StringUtils.reverseText(text) : text;
          isNewBlock = true;
        }
      }

      if (node is Text) {
        bool isFirst = path.equals(first.path);
        available = node.text.length;
        offset = reverse ? available : 0;

        if (isFirst) {
          available = reverse ? first.offset : available - first.offset;
          offset = first.offset;
        }

        if (isFirst || isNewBlock || unit == Unit.offset) {
          yield Point(path, offset);
        }

        while (true) {
          // If there's no more string, continue to the next block.
          if (s == '') {
            break;
          } else {
            advance();
          }

          // If the available _space hasn't overflow, we have another point to
          // yield in the current text node.
          if (available >= 0) {
            yield Point(path, offset);
          } else {
            break;
          }
        }

        isNewBlock = false;
      }
    }
  }

  /// Get the matching node in the branch of the document before a location.
  NodeEntry<T> previous<T extends Node>(
      {Location at,
      NodeMatch<T> match,
      Mode mode = Mode.lowest,
      bool voids = false}) {
    at = at ?? selection;

    if (at == null) {
      return null;
    }

    NodeEntry fromEntry = first(at);
    Path from = fromEntry.path;

    NodeEntry toEntry = first(Path([]));
    Path to = toEntry.path;

    Span span = Span(from, to);

    if (at is Path && at.length == 0) {
      throw Exception('Cannot get the previous node from the root node!');
    }

    if (match == null) {
      if (at is Path) {
        NodeEntry entry = parent(at);
        Ancestor p = entry.node;

        match = (node) {
          return p.children.contains(node);
        };
      } else {
        match = (node) {
          return true;
        };
      }
    }

    List<NodeEntry> ns = List.from(nodes(
      reverse: true,
      at: span,
      match: match,
      mode: mode,
      voids: voids,
    ));

    NodeEntry previous = ns[1];

    return previous;
  }

  /// Get a range of a location.
  Range range(Location at, Location to) {
    if (at is Range && to == null) {
      return at;
    }

    Point s = start(at);
    Point e = end(to ?? at);

    return Range(s, e);
  }

  /// Create a mutable ref for a `Range` object, which will stay in sync as new
  /// operations are applied to the editor.
  RangeRef rangeRef(Range range, {Affinity affinity = Affinity.forward}) {
    RangeRef ref = RangeRef(
      current: range,
      affinity: affinity,
    );

    rangeRefs.add(ref);
    return ref;
  }

  /// Get the start point of a location.
  Point start(Location at) {
    return point(at, edge: Edge.start);
  }

  /// Get the text string content of a location.
  ///
  /// Note: the text of void nodes is presumed to be an empty string, regardless
  /// of what their actual content is.
  String string(Location at) {
    Range r = range(at, null);
    Edges edges = r.edges();
    Point start = edges.start;
    Point end = edges.end;
    String text = '';

    for (NodeEntry entry in nodes(
        at: r,
        match: (node) {
          return node is Text;
        })) {
      Text node = entry.node;
      Path path = entry.path;
      String t = node.text;

      if (path.equals(end.path)) {
        t = t.substring(0, end.offset);
      }

      if (path.equals(start.path)) {
        t = t.substring(start.offset);
      }

      text += t;
    }

    return text;
  }

  /// Transform the editor by an operation.
  void transform(Operation op) {
    if (op is InsertNodeOperation) {
      Path path = op.path;
      Node node = op.node;
      Ancestor parent = NodeUtils.parent(this, path);
      int index = path[path.length - 1];
      parent.children.insert(index, node);

      if (selection != null) {
        for (PointEntry entry in selection.points()) {
          Point point = entry.point;
          PointType type = entry.type;
          if (type == PointType.anchor) {
            selection.anchor = point.transform(op);
          } else {
            selection.focus = point.transform(op);
          }
        }
      }
    }

    if (op is InsertTextOperation) {
      Path path = op.path;
      int offset = op.offset;
      String text = op.text;
      Text node = NodeUtils.leaf(this, path);
      String before = node.text.substring(0, offset);
      String after = node.text.substring(offset);
      node.text = before + text + after;

      if (selection != null) {
        for (PointEntry entry in selection.points()) {
          Point point = entry.point;
          PointType type = entry.type;
          if (type == PointType.anchor) {
            selection.anchor = point.transform(op);
          } else {
            selection.focus = point.transform(op);
          }
        }
      }
    }

    if (op is MergeNodeOperation) {
      Path path = op.path;
      Node node = NodeUtils.get(this, path);
      Path prevPath = path.previous;
      Node prev = NodeUtils.get(this, prevPath);
      Ancestor parent = NodeUtils.parent(this, path);
      int index = path[path.length - 1];

      if (node is Text && prev is Text) {
        prev.text += node.text;
      } else if (node is Text == false && prev is Text == false) {
        (prev as Ancestor).children.addAll((node as Ancestor).children);
      } else {
        throw Exception(
            'Cannot apply a \'merge_node\' operation at path [${path.toString()}] to nodes of different interfaces: ${node.toString()} ${prev.toString()}');
      }

      parent.children.removeAt(index);

      if (selection != null) {
        for (PointEntry entry in selection.points()) {
          Point point = entry.point;
          PointType type = entry.type;
          if (type == PointType.anchor) {
            selection.anchor = point.transform(op);
          } else {
            selection.focus = point.transform(op);
          }
        }
      }
    }

    if (op is MoveNodeOperation) {
      Path path = op.path;
      Path newPath = op.newPath;

      if (path.isAncestor(newPath)) {
        throw Exception(
            'Cannot move a path [${path.toString()}] to new path [$newPath] because the destination is inside itself.');
      }

      Node node = NodeUtils.get(this, path);
      Ancestor parent = NodeUtils.parent(this, path);
      int index = path[path.length - 1];

      // This is tricky, but since the `path` and `newPath` both refer to
      // the same snapshot in time, there's a mismatch. After either
      // removing the original position, the second step's path can be out
      // of date. So instead of using the `op.newPath` directly, we
      // transform `op.path` to ascertain what the `newPath` would be after
      // the operation was applied.
      parent.children.removeAt(index);
      Path truePath = path.transform(op);
      Ancestor newParent = NodeUtils.get(this, truePath.parent);
      int newIndex = truePath[truePath.length - 1];

      newParent.children.insert(newIndex, node);

      if (selection != null) {
        for (PointEntry entry in selection.points()) {
          Point point = entry.point;
          PointType type = entry.type;
          if (type == PointType.anchor) {
            selection.anchor = point.transform(op);
          } else {
            selection.focus = point.transform(op);
          }
        }
      }
    }

    if (op is RemoveNodeOperation) {
      Path path = op.path;
      int index = path[path.length - 1];
      Ancestor parent = NodeUtils.parent(this, path);
      parent.children.removeAt(index);

      // Transform all of the points in the value, but if the point was in the
      // node that was removed we need to update the range or remove it.
      if (selection != null) {
        for (PointEntry entry in selection.points()) {
          Point point = entry.point;
          PointType type = entry.type;
          Point result = point.transform(op);

          if (selection != null && result != null) {
            if (type == PointType.anchor) {
              selection.anchor = result;
            } else {
              selection.focus = result;
            }
          } else {
            NodeEntry<Text> prev;
            NodeEntry<Text> next;

            for (NodeEntry entry in NodeUtils.texts(this)) {
              Text n = entry.node;
              Path p = entry.path;
              if (p.compare(path) == -1) {
                prev = NodeEntry(n, p);
              } else {
                next = NodeEntry(n, p);
                break;
              }
            }

            if (prev != null) {
              point.path = prev.path;
              point.offset = prev.node.text.length;
            } else if (next != null) {
              point.path = next.path;
              point.offset = 0;
            } else {
              selection = null;
            }
          }
        }
      }
    }

    if (op is RemoveTextOperation) {
      Path path = op.path;
      int offset = op.offset;
      String text = op.text;
      Text node = NodeUtils.leaf(this, path);
      String before = node.text.substring(0, offset);
      String after = node.text.substring(offset + text.length);
      node.text = before + after;

      if (selection != null) {
        for (PointEntry entry in selection.points()) {
          Point point = entry.point;
          PointType type = entry.type;
          if (type == PointType.anchor) {
            selection.anchor = point.transform(op);
          } else {
            selection.focus = point.transform(op);
          }
        }
      }
    }

    if (op is SetNodeOperation) {
      Path path = op.path;
      Map<String, dynamic> newProps = op.newProps;

      if (path.length == 0) {
        throw Exception('Cannot set properties on the root node!');
      }

      Node node = NodeUtils.get(this, path);

      for (String key in newProps.keys) {
        dynamic value = newProps[key];

        if (value == null) {
          node.props.remove(key);
        } else {
          node.props[key] = value;
        }
      }
    }

    if (op is SetSelectionOperation) {
      Range newSelection = op.newSelection;

      if (newSelection == null) {
        selection = null;
      } else if (selection == null) {
        selection = newSelection;
      } else {
        if (newSelection.anchor != null) {
          selection.anchor = newSelection.anchor;
        }

        if (newSelection.focus != null) {
          selection.focus = newSelection.focus;
        }

        selection.props.addAll(newSelection.props);
      }
    }

    if (op is SplitNodeOperation) {
      Path path = op.path;
      Map<String, dynamic> props = op.props;
      int position = op.position;

      if (path.length == 0) {
        throw Exception(
            'Cannot apply a SplitNodeOperation at path [${path.toString()}] because the root node cannot be split.');
      }

      Node node = NodeUtils.get(this, path);
      Ancestor parent = NodeUtils.parent(this, path);
      int index = path[path.length - 1];
      Descendant newNode;
      Map<String, dynamic> newProps = Map.from(node.props);
      newProps.addAll(props);

      if (node is Text) {
        String before = node.text.substring(0, position);
        String after = node.text.substring(position);
        node.text = before;

        newNode = Text(after, props: newProps);
      } else {
        List<Node> before = (node as Ancestor).children.sublist(0, position);
        List<Node> after = (node as Ancestor).children.sublist(position);
        (node as Ancestor).children = before;

        // TODO: Figure out how to create new node with any class inherting from either
        if (node is Block) {
          newNode =
              Block(children: after, props: newProps, isVoid: node.isVoid);
        } else if (node is Inline) {
          newNode =
              Inline(children: after, props: newProps, isVoid: node.isVoid);
        }
      }

      parent.children.insert(index + 1, newNode);

      if (selection != null) {
        for (PointEntry entry in selection.points()) {
          Point point = entry.point;
          PointType type = entry.type;
          if (type == PointType.anchor) {
            selection.anchor = point.transform(op);
          } else {
            selection.focus = point.transform(op);
          }
        }
      }
    }
  }

  /// Convert a range into a non-hanging one.
  ///
  /// A hanging range is when it is not collapsed and its focus is at the start of a node
  Range unhangRange(Range range, {bool voids = false}) {
    Edges edges = range.edges();
    Point es = edges.start;
    Point ee = edges.end;

    // PERF: exit early if we can guarantee that the range isn't hanging.
    if (es.offset != 0 || ee.offset != 0 || range.isCollapsed) {
      return range;
    }

    NodeEntry endBlock = above(
      at: ee,
      match: (node) {
        return node is Block;
      },
    );

    Path blockPath = endBlock != null ? endBlock.path : Path([]);
    Point first = start(Path([]));
    Range before = Range(first, ee);
    bool skip = true;

    for (NodeEntry entry in nodes(
      at: before,
      match: (node) {
        return node is Text;
      },
      reverse: true,
      voids: voids,
    )) {
      Text node = entry.node;
      Path path = entry.path;

      if (skip) {
        skip = false;
        continue;
      }

      if (node.text != '' || path.isBefore(blockPath)) {
        ee = Point(path, node.text.length);
        break;
      }
    }

    return Range(es, ee);
  }

  /// Match a void node in the current branch of the editor.
  NodeEntry<Element> matchVoid({
    Location at,
    Mode mode,
    bool voids,
  }) {
    return above(
        at: at,
        mode: mode,
        match: (node) {
          return node is Element && node.isVoid;
        });
  }

  /// Call a function, deferring normalization until after it completes.
  void withoutNormalizing(void Function() fn) {
    bool prevIsNormalizing = _isNormalizing;
    _isNormalizing = false;
    fn();
    _isNormalizing = prevIsNormalizing;
    normalize();
  }
}

enum Prev {
  /// Surrogate pair
  SURR,

  /// Modifier (technically also surrogate pair)
  MOD,

  /// Zero width joiner
  ZWJ,

  /// Variation selector
  VAR,

  /// Sequenceable character from basic multilingual plane
  BMP,
}

class StringUtils {
  /// Get the distance to the end of the first character in a string of text.
  static int getCharacterDistance(String text) {
    int zeroWidthJoiner = 0x200d;
    int offset = 0;
    Prev prev;
    int charCode = text.codeUnitAt(0);

    while (charCode != null) {
      if (isSurrogate(charCode)) {
        bool modifier = StringUtils.isModifier(charCode, text, offset);

        // Early returns are the heart of this function, where we decide if previous and current
        // codepoints should form a single character (in terms of how many of them should selection
        // jump over).
        if (prev == Prev.SURR || prev == Prev.BMP) {
          break;
        }

        offset += 2;
        prev = modifier ? Prev.MOD : Prev.SURR;
        charCode = text.length - 1 < offset ? null : text.codeUnitAt(offset);
        // Absolutely fine to `continue` without any checks because if `charCode` is NaN (which
        // is the case when out of `text` range), next `while` loop won't execute and we're done.
        continue;
      }

      if (charCode == zeroWidthJoiner) {
        offset += 1;
        prev = Prev.ZWJ;
        charCode = text.codeUnitAt(offset);

        continue;
      }

      if (StringUtils.isBMPEmoji(charCode)) {
        if (prev != null && prev != Prev.ZWJ && prev != Prev.VAR) {
          break;
        }
        offset += 1;
        prev = Prev.BMP;
        charCode = text.codeUnitAt(offset);

        continue;
      }

      if (isVariationSelector(charCode)) {
        if (prev != null && prev != Prev.ZWJ) {
          break;
        }
        offset += 1;
        prev = Prev.VAR;
        charCode = text.codeUnitAt(offset);
        continue;
      }

      // Modifier 'groups up' with what ever character is before that (even whitespace), need to
      // look ahead.
      if (prev == Prev.MOD) {
        offset += 1;
        break;
      }

      // If while loop ever gets here, we're done (e.g latin chars).
      break;
    }

    return offset == 0 ? 1 : offset;
  }

  /// Get the distance to the end of the first word in a string of text.
  static int getWordDistance(String text) {
    int length = 0;
    int i = 0;
    bool started = false;
    String char;

    while (i < text.length) {
      char = text[i];
      int l = getCharacterDistance(char);
      char = text.substring(i, i + l);
      String rest = text.substring(i + l);

      if (StringUtils.isWordCharacter(char, rest)) {
        started = true;
        length += l;
      } else if (!started) {
        length += l;
      } else {
        break;
      }

      i += l;
    }

    return length;
  }

  /// Check if a character is a word character. The `remaining` argument is used
  /// because sometimes you must read subsequent characters to truly determine it.
  static bool isWordCharacter(String char, String remaining) {
    RegExp space = RegExp(r'\s');
    RegExp punctuation = RegExp(
        '[\u0021-\u0023\u0025-\u002A\u002C-\u002F\u003A\u003B\u003F\u0040\u005B-\u005D\u005F\u007B\u007D\u00A1\u00A7\u00AB\u00B6\u00B7\u00BB\u00BF\u037E\u0387\u055A-\u055F\u0589\u058A\u05BE\u05C0\u05C3\u05C6\u05F3\u05F4\u0609\u060A\u060C\u060D\u061B\u061E\u061F\u066A-\u066D\u06D4\u0700-\u070D\u07F7-\u07F9\u0830-\u083E\u085E\u0964\u0965\u0970\u0AF0\u0DF4\u0E4F\u0E5A\u0E5B\u0F04-\u0F12\u0F14\u0F3A-\u0F3D\u0F85\u0FD0-\u0FD4\u0FD9\u0FDA\u104A-\u104F\u10FB\u1360-\u1368\u1400\u166D\u166E\u169B\u169C\u16EB-\u16ED\u1735\u1736\u17D4-\u17D6\u17D8-\u17DA\u1800-\u180A\u1944\u1945\u1A1E\u1A1F\u1AA0-\u1AA6\u1AA8-\u1AAD\u1B5A-\u1B60\u1BFC-\u1BFF\u1C3B-\u1C3F\u1C7E\u1C7F\u1CC0-\u1CC7\u1CD3\u2010-\u2027\u2030-\u2043\u2045-\u2051\u2053-\u205E\u207D\u207E\u208D\u208E\u2329\u232A\u2768-\u2775\u27C5\u27C6\u27E6-\u27EF\u2983-\u2998\u29D8-\u29DB\u29FC\u29FD\u2CF9-\u2CFC\u2CFE\u2CFF\u2D70\u2E00-\u2E2E\u2E30-\u2E3B\u3001-\u3003\u3008-\u3011\u3014-\u301F\u3030\u303D\u30A0\u30FB\uA4FE\uA4FF\uA60D-\uA60F\uA673\uA67E\uA6F2-\uA6F7\uA874-\uA877\uA8CE\uA8CF\uA8F8-\uA8FA\uA92E\uA92F\uA95F\uA9C1-\uA9CD\uA9DE\uA9DF\uAA5C-\uAA5F\uAADE\uAADF\uAAF0\uAAF1\uABEB\uFD3E\uFD3F\uFE10-\uFE19\uFE30-\uFE52\uFE54-\uFE61\uFE63\uFE68\uFE6A\uFE6B\uFF01-\uFF03\uFF05-\uFF0A\uFF0C-\uFF0F\uFF1A\uFF1B\uFF1F\uFF20\uFF3B-\uFF3D\uFF3F\uFF5B\uFF5D\uFF5F-\uFF65]');
    RegExp chameleon = RegExp('/[\'\u2018\u2019]/');

    if (space.hasMatch(char)) {
      return false;
    }

    // Chameleons count as word characters as long as they're in a word, so
    // recurse to see if the next one is a word character or not.
    if (chameleon.hasMatch(char)) {
      String next = remaining[0];
      int length = getCharacterDistance(next);
      next = remaining.substring(0, length);
      String rest = remaining.substring(length);

      if (isWordCharacter(next, rest)) {
        return true;
      }
    }

    if (punctuation.hasMatch(char)) {
      return false;
    }

    return true;
  }

  /// Determines if `code` is a surrogate
  static bool isSurrogate(int code) {
    int surrogateStart = 0xd800;
    int surrogateEnd = 0xdfff;

    return surrogateStart <= code && code <= surrogateEnd;
  }

  /// Does `code` form Modifier with next one.
  ///
  /// https://emojipedia.org/modifiers/
  static bool isModifier(int code, String text, int offset) {
    if (code == 0xd83c) {
      int next = text.codeUnitAt(offset + 1);
      return next <= 0xdfff && next >= 0xdffb;
    }

    return false;
  }

  /// Is `code` a Variation Selector.
  ///
  /// https://codepoints.net/variation_selectors
  static bool isVariationSelector(int code) {
    return code <= 0xfe0f && code >= 0xfe00;
  }

  /// Is `code` one of the BMP codes used in emoji sequences.
  ///
  /// https://emojipedia.org/emoji-zwj-sequences/
  static bool isBMPEmoji(int code) {
    // This requires tiny bit of maintanance, better ideas?
    // Fortunately it only happens if new Unicode Standard
    // is released. Fails gracefully if upkeep lags behind,
    // same way Slate previously behaved with all emojis.
    return (code == 0x2764 || // heart (❤)
            code == 0x2642 || // male (♂)
            code == 0x2640 || // female (♀)
            code == 0x2620 || // scull (☠)
            code == 0x2695 || // medical (⚕)
            code == 0x2708 || // plane (✈️)
            code == 0x25ef // large circle (◯)
        );
  }

  static String reverseText(String text) {
    if (text.length == 0) {
      return '';
    }

    if (text.length == 1) {
      return text;
    }

    return text[text.length - 1] +
        StringUtils.reverseText(text.substring(0, text.length - 1));
  }
}

List<Path> Function(Operation) getDirtyPaths = (Operation op) {
  if (op is InsertTextOperation) {
    return op.path.levels();
  }

  if (op is RemoveTextOperation) {
    return op.path.levels();
  }

  if (op is SetNodeOperation) {
    return op.path.levels();
  }

  if (op is InsertNodeOperation) {
    Node node = op.node;
    Path path = op.path;
    List<Path> paths = [];
    List<Path> levels = path.levels();
    List<Path> descendants = [];

    if (node is Text == false) {
      List<NodeEntry> nodes = List.from(NodeUtils.nodes(node));

      for (NodeEntry node in nodes) {
        descendants.add(node.path);
      }
    }

    paths.addAll(levels);
    paths.addAll(descendants);

    return paths;
  }

  if (op is MergeNodeOperation) {
    Path path = op.path;
    List<Path> paths = [];
    List<Path> ancestors = path.ancestors();
    Path previousPath = path.previous;

    paths.addAll(ancestors);
    paths.add(previousPath);

    return paths;
  }

  if (op is MoveNodeOperation) {
    Path path = op.path;
    Path newPath = op.newPath;
    List<Path> paths = [];

    if (path.equals(newPath)) {
      return [];
    }

    List<Path> oldAncestors = [];
    List<Path> newAncestors = [];

    for (Path ancestor in path.ancestors()) {
      Path p = ancestor.transform(op);
      oldAncestors.add(p);
    }

    for (Path ancestor in newPath.ancestors()) {
      Path p = ancestor.transform(op);
      newAncestors.add(p);
    }

    paths.addAll(oldAncestors);
    paths.addAll(newAncestors);

    return paths;
  }

  if (op is RemoveNodeOperation) {
    Path path = op.path;
    List<Path> paths = [];
    List<Path> ancestors = path.ancestors();

    paths.addAll(ancestors);
    return paths;
  }

  if (op is SplitNodeOperation) {
    Path path = op.path;
    List<Path> paths = [];
    List<Path> levels = path.levels();
    Path nextPath = path.next;

    paths.addAll(levels);
    paths.add(nextPath);

    return paths;
  }

  return [];
};

typedef NodeMatch<T extends Node> = bool Function(Node node);

enum Mode { all, highest, lowest }

enum Unit {
  offset,
  character,
  word,
  line,
  block,
}

enum Edge { anchor, focus, start, end }
