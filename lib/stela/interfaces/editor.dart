import 'package:inday/stela/interfaces/element.dart';
import 'package:inday/stela/interfaces/location.dart';
import 'package:inday/stela/interfaces/node.dart';
import 'package:inday/stela/interfaces/operation.dart';
import 'package:inday/stela/interfaces/path.dart';
import 'package:inday/stela/interfaces/path_ref.dart';
import 'package:inday/stela/interfaces/point.dart';
import 'package:inday/stela/interfaces/point_ref.dart';
import 'package:inday/stela/interfaces/range.dart';
import 'package:inday/stela/interfaces/range_ref.dart';

Map<Editor, Path[]> DIRTY_PATHS = Map();
Map<Editor, bool> FLUSHING = Map();
Map<Editor, bool> NORMALIZING = Map();
Map<Editor, Set<PathRef>> PATH_REFS = Map();
Map<Editor, Set<PointRef>> POINT_REFS = Map();
Map<Editor, Set<RangeRef>> RANGE_REFS = Map();

/// The `Editor` interface stores all the state of a Stela editor. It is extended
/// by plugins that wish to add their own helpers and implement new behaviors.
class Editor implements Ancestor {
  Editor(
      {this.children = const <Node>[],
      this.selection,
      this.operations,
      this.marks});

  /// The `children` property contains the document tree of nodes that make up the editor's content
  List<Node> children;

  /// The `selection` property contains the user's current selection, if any
  Range selection;

  /// The `operations` property contains all of the operations that have been applied since the last "change" was flushed. (Since Slate batches operations up into ticks of the event loop.)
  List<Operation> operations;

  /// The `marks` property stores formatting that is attached to the cursor, and that will be applied to the text that is inserted next
  Map<String, dynamic> marks;

  // Schema-specific node behaviors.
  bool Function(Element element) isInline;
  bool Function(Element element) isVoid;
  void Function(NodeEntry entry) normalizeNode;
  void Function() onChange;

  // Overrideable core actions.
  void Function(String key, dynamic value) addMark;
  void Function(Operation op) apply;
  void Function(Unit unit) deleteBackward;
  void Function(Unit unit) deleteForward;
  void Function() deleteFragment;
  void Function() insertBreak;
  void Function(List<Node> fragment) insertFragment;
  void Function(Node node) insertNode;
  void Function(String text) insertText;
  void Function(String key) removeMark;
}

class EditorUtils {
  /**
   * Get the ancestor above a location in the document.
   */
  static NodeEntry<T> above<T extends Ancestor>(
    Editor editor,
    {
      Location at,
      NodeMatch<T> match,
      Mode mode = Mode.lowest,
      bool voids = false
    }
  ) {
    at = at ?? editor.selection;

    if (at == null) {
      return null;
    }

    Path path = EditorUtils.path(editor, at);
    const reverse = mode == Mode.lowest;

    for (const [n, p] of Editor.levels(editor, {
      at: path,
      voids,
      match,
      reverse,
    })) {
      if (!Text.isText(n) && !PathUtils.equals(path, p)) {
        return [n, p]
      }
    }
  }

  /**
   * Add a custom property to the leaf text nodes in the current selection.
   *
   * If the selection is currently collapsed, the marks will be added to the
   * `editor.marks` property instead, and applied when text is inserted next.
   */

  static void addMark(Editor editor, String key, dynamic value) {
    editor.addMark(key, value);
  }

  /**
   * Get the point after a location.
   */

  static Point after(
    Editor editor,
    Location at,
    {int distance = 1, Unit unit}
  ) {
    const anchor = EditorUtils.point(editor, at, edge: Edge.end)
    const focus = Editor.end(editor, [])
    const range = { anchor, focus }
    let d = 0
    let target

    for (const p of EditorUtils.positions(editor, { ...options, at: range })) {
      if (d > distance) {
        break
      }

      if (d != 0) {
        target = p
      }

      d++
    }

    return target;
  }

  /**
   * Get the point before a location.
   */

  Point before(
    Editor editor,
    Location at,
    {
      int distance = 1,
      Unit unit,
    }
  ) {
    Point anchor = EditorUtils.start(editor, []);
    Point focus = EditorUtils.point(editor, at, edge: Edge.start);
    Range range = Range(anchor, focus);

    int d = 0;
    Point target;

    for (Point p in EditorUtils.positions(editor, at: range, reverse: true, unit: unit)) {
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

  /**
   * Delete content in the editor backward from the current selection.
   */

  static void deleteBackward(
    Editor editor,
    {Unit unit = Unit.character}
  ) {
    editor.deleteBackward(unit)
  }

  /**
   * Delete content in the editor forward from the current selection.
   */

  static void deleteForward(
    Editor editor,
    {Unit unit = Unit.character}
  ) {
    editor.deleteForward(unit)
  }

  /**
   * Delete the content in the current selection.
   */

  static void deleteFragment(Editor editor) {
    editor.deleteFragment()
  }

  /**
   * Get the start and end points of a location.
   */

  static Edges edges(Editor editor, Location at) {
    return Edges(Editor.start(editor, at), Editor.end(editor, at));
  }

  /**
   * Get the end point of a location.
   */

  static Point end(Editor editor, Location at) {
    return Editor.point(editor, at, edge: Edge.end);
  }

  /**
   * Get the first node at a location.
   */

  static NodeEntry first(Editor editor, Location at) {
    Path path = EditorUtils.path(editor, at, edge: Edge.start);
    return EditorUtils.node(editor, path);
  }

  /**
   * Get the fragment at a location.
   */

  static List<Descendant> fragment(Editor editor, Location at) {
    Range range = EditorUtils.range(editor, at);
    List<Descendant> fragment = Node.fragment(editor, range);
    return fragment;
  }
  /**
   * Check if a node has block children.
   */

  hasBlocks(Editor editor, Element element): bool {
    return element.children.some(n => Editor.isBlock(editor, n));
  }

  /**
   * Check if a node has inline and text children.
   */

  hasInlines(Editor editor, Element element): bool {
    return element.children.some(
      n => Text.isText(n) || Editor.isInline(editor, n)
    );
  }

  /**
   * Check if a node has text children.
   */

  static bool hasTexts(Editor editor, Element element) {
    return element.children.every(n => Text.isText(n));
  }

  /**
   * Insert a block break at the current selection.
   *
   * If the selection is currently expanded, it will be deleted first.
   */

  static void insertBreak(Editor editor) {
    editor.insertBreak();
  }

  /**
   * Insert a fragment at the current selection.
   *
   * If the selection is currently expanded, it will be deleted first.
   */

  static void insertFragment(Editor editor, List<Node> fragment) {
    editor.insertFragment(fragment);
  }

  /**
   * Insert a node at the current selection.
   *
   * If the selection is currently expanded, it will be deleted first.
   */

  static void insertNode(Editor editor, Node node) {
    editor.insertNode(node);
  }

  /**
   * Insert text at the current selection.
   *
   * If the selection is currently expanded, it will be deleted first.
   */

  static void insertText(Editor editor, String text) {
    editor.insertText(text)
  }

  /**
   * Check if a value is a block `Element` object.
   */

  static bool isBlock(Editor editor, Node value) {
    return Element.isElement(value) && !editor.isInline(value)
  }

  /**
   * Check if a point is the end point of a location.
   */

  static bool isEnd(Editor editor, Point point, Location at) {
    const end = Editor.end(editor, at)
    return Point.equals(point, end)
  }

  /**
   * Check if a point is an edge of a location.
   */

  static bool isEdge(Editor editor, Point point, Location at) {
    return Editor.isStart(editor, point, at) || Editor.isEnd(editor, point, at)
  }

  /**
   * Check if an element is empty, accounting for void nodes.
   */

  static bool isEmpty(Editor editor, Element element) {
    List<Node> children = element.children;
    Node first = children[0];
    return (
      children.length == 0 ||
      (children.length == 1 &&
        Text.isText(first) &&
        first.text == '' &&
        !editor.isVoid(element))
    );
  }

  /**
   * Check if a value is an inline `Element` object.
   */

  static bool isInline(Editor editor, Node node) {
    return node is Element && editor.isInline(node);
  }

  /**
   * Check if the editor is currently normalizing after each operation.
   */

  static bool isNormalizing(Editor editor) {
    const isNormalizing = NORMALIZING.get(editor);
    return isNormalizing == undefined ? true : isNormalizing;
  }

  /**
   * Check if a point is the start point of a location.
   */

  static bool isStart(Editor editor, Point point, Location at) {
    // PERF: If the offset isn't `0` we know it's not the start.
    if (point.offset != 0) {
      return false;
    }

    Point start = EditorUtils.start(editor, at);

    return Point.equals(point, start)
  }

  /**
   * Check if a value is a void `Element` object.
   */

  static bool isVoid(Editor editor, Node node) {
    return node is Element && editor.isVoid(node);
  }

  /**
   * Get the last node at a location.
   */

  static NodeEntry last(Editor editor, Location at) {
    Path path = EditorUtils.path(editor, at, edge: Edge.end);

    return EditorUtils.node(editor, path);
  }

  /**
   * Get the leaf text node at a location.
   */

  static NodeEntry<Text> leaf(
    Editor editor,
    Location at,
    {
      int depth,
      Edge edge,
    }
  ) {
    Path path = EditorUtils.path(editor, at, depth: depth, edge: edge);
    Node node = Node.leaf(editor, path);

    return [node, path];
  }

  /**
   * Iterate through all of the levels at a location.
   */

  Iterable<NodeEntry<T>> levels<T extends Node>(
    Editor editor,
    {
      Location at,
      NodeMatch<T> match,
      bool reverse = false,
      bool voids = false,
    }
  ) sync* {
    at = at ?? editor.selection;
    match = match ?? () { return true; };

    if (at != null) {
      return null;
    }

    const levels: NodeEntry<T>[] = []
    Path path = EditorUtils.path(editor, at)

    for (const [n, p] of Node.levels(editor, path)) {
      if (!match(n)) {
        continue
      }

      levels.push([n, p])

      if (!voids && Editor.isVoid(editor, n)) {
        break;
      }
    }

    if (reverse) {
      levels.reverse();
    }

    yield levels;
  }

  /**
   * Get the marks that would be added to text at the current selection.
   */

  Map<String, dynamic> marks(Editor editor) {
    const { marks, selection } = editor

    if (!selection) {
      return null
    }

    if (marks) {
      return marks
    }

    if (Range.isExpanded(selection)) {
      const [match] = Editor.nodes(editor, { match: Text.isText })

      if (match) {
        const [node] = match as NodeEntry<Text>
        const { text, ...rest } = node
        return rest
      } else {
        return {}
      }
    }

    const { anchor } = selection
    const { path } = anchor
    let [node] = Editor.leaf(editor, path)

    if (anchor.offset == 0) {
      const prev = Editor.previous(editor, { at: path, match: Text.isText })
      const block = Editor.above(editor, {
        match: n => Editor.isBlock(editor, n),
      })

      if (prev && block) {
        const [prevNode, prevPath] = prev
        const [, blockPath] = block

        if (PathUtils.isAncestor(blockPath, prevPath)) {
          node = prevNode as Text
        }
      }
    }

    const { text, ...rest } = node
    return rest
  }

  /**
   * Get the matching node in the branch of the document after a location.
   */

  static NodeEntry<T> next<T extends Node>(
    Editor editor,
    {
      Location at,
      NodeMatch<T> match,
      Mode mode = Mode.lowest,
      bool voids = false
    }
  ) {
    at = at ?? editor.selection;

    if (at == null) {
      return null;
    }

    const [, from] = Editor.last(editor, at)
    const [, to] = Editor.last(editor, [])
    const span: Span = [from, to]

    if (PathUtils.isPath(at) && at.length == 0) {
      throw new Error(`Cannot get the next node from the root node!`)
    }

    if (match == null) {
      if (PathUtils.isPath(at)) {
        const [parent] = Editor.parent(editor, at)
        match = n => parent.children.includes(n)
      } else {
        match = () => true
      }
    }

    const [, next] = Editor.nodes(editor, { at: span, match, mode, voids })
    return next
  }

  /**
   * Get the node at a location.
   */

  static NodeEntry node(
    Editor editor,
    Location at,
    {
      int depth,
      Edge edge,
    }
  ) {
    Path path = EditorUtils.path(editor, at, edge: edge, depth: depth)
    Node node = Node.get(editor, path)

    return NodeEntry(node, path);
  }

  /**
   * Iterate through all of the nodes in the Editor.
   */

  Iterable<NodeEntry<T>> nodes<T extends Node>(
    Editor editor,
    {
      Location at?: Location | Span
      NodeMatch<T> match,
      Mode mode = Mode.all,
      bool universal = false,
      bool reverse = false,
      bool voids = false,
    }
  ) {
    const {
      at = editor.selection,
      mode = 'all',
      universal = false,
      reverse = false,
      voids = false,
    } = options
    let { match } = options

    if (!match) {
      match = () => true
    }

    if (at == null) {
      return
    }

    let from
    let to

    if (Span.isSpan(at)) {
      from = at[0]
      to = at[1]
    } else {
      const first = EditorUtils.path(editor, at, edge: Edge.start);
      const last = EditorUtils.path(editor, at, edge: Edge.end);
      from = reverse ? last : first
      to = reverse ? first : last
    }

    const iterable = Node.nodes(editor, {
      reverse,
      from,
      to,
      pass: ([n]) => (voids ? false : Editor.isVoid(editor, n)),
    })

    const matches: NodeEntry<T>[] = []
    let hit: NodeEntry<T> | undefined

    for (const [node, path] of iterable) {
      const isLower = hit && PathUtils.compare(path, hit[1]) == 0

      // In highest mode any node lower than the last hit is not a match.
      if (mode == 'highest' && isLower) {
        continue
      }

      if (!match(node)) {
        // If we've arrived at a leaf text node that is not lower than the last
        // hit, then we've found a branch that doesn't include a match, which
        // means the match is not universal.
        if (universal && !isLower && Text.isText(node)) {
          return
        } else {
          continue
        }
      }

      // If there's a match and it's lower than the last, update the hit.
      if (mode == 'lowest' && isLower) {
        hit = [node, path]
        continue
      }

      // In lowest mode we emit the last hit, once it's guaranteed lowest.
      const emit: NodeEntry<T> | undefined =
        mode == 'lowest' ? hit : [node, path]

      if (emit) {
        if (universal) {
          matches.push(emit)
        } else {
          yield emit
        }
      }

      hit = [node, path]
    }

    // Since lowest is always emitting one behind, catch up at the end.
    if (mode == 'lowest' && hit) {
      if (universal) {
        matches.push(hit)
      } else {
        yield hit
      }
    }

    // Universal defers to ensure that the match occurs in every branch, so we
    // yield all of the matches after iterating.
    if (universal) {
      yield* matches
    }
  }
  /**
   * Normalize any dirty objects in the editor.
   */

  normalize(
    Editor editor,
    {
      bool force = false
    }
  ) {
    const getDirtyPaths = (Editor editor) => {
      return DIRTY_PATHS.get(editor) || []
    }

    if (!EditorUtils.isNormalizing(editor)) {
      return null;
    }

    if (force) {
      const allPaths = Array.from(Node.nodes(editor), ([, p]) => p)
      DIRTY_PATHS.set(editor, allPaths)
    }

    if (getDirtyPaths(editor).length == 0) {
      return null;
    }

    Editor.withoutNormalizing(editor, () => {
      // HACK: better way?
      int max = getDirtyPaths(editor).length * 42;
      let m = 0

      while (getDirtyPaths(editor).length != 0) {
        if (m > max) {
          throw new Error(`
            Could not completely normalize the editor after ${max} iterations! This is usually due to incorrect normalization logic that leaves a node in an invalid state.
          `)
        }

        Path path = getDirtyPaths(editor).pop()!
        const entry = Editor.node(editor, path)
        editor.normalizeNode(entry)
        m++
      }
    });
  }

  /**
   * Get the parent node of a location.
   */

  static NodeEntry<Ancestor> parent(
    Editor editor,
    Location at,
    {
      int depth,
      Edge edge,
    }
  ) {
    Path path = EditorUtils.path(editor, at, edge: edge, depth: depth);
    Path parentPath = PathUtils.parent(path);
    Node entry = EditorUtils.node(editor, parentPath)
    return entry as NodeEntry<Ancestor>
  }

  /**
   * Get the path of a location.
   */

  static Path path(
    Editor editor,
    Location at,
    {
      int depth,
      Edge edge,
    }
  ) {
    if (at is Path) {
      if (edge == Edge.start) {
        NodeEntry<Node> firstNode = Node.first(editor, at);
        at = firstNode.path;
      } else if (edge == Edge.end) {
        const [, lastPath] = Node.last(editor, at)
        at = lastPath
      }
    }

    if (at is Range) {
      if (edge == Edge.start) {
        at = Range.start(at);
      } else if (edge == Edge.end) {
        at = Range.end(at);
      } else {
        at = PathUtils.common(at.anchor.path, at.focus.path)
      }
    }

    if (at is Point) {
      at = at.path;
    }

    if (depth != null) {
      at = at.slice(0, depth);
    }

    return at;
  }

  /**
   * Create a mutable ref for a `Path` object, which will stay in sync as new
   * operations are applied to the editor.
   */

  PathRef pathRef(
    Editor editor,
    path: Path,
    {
      Affinity affinity = Affinity.forward
    }
  ) {
    const ref: PathRef = {
      current: path,
      affinity,
      unref() {
        const { current } = ref
        Path pathRefs = EditorUtils.pathRefs(editor)
        pathRefs.delete(ref)
        ref.current = null
        return current
      }
    }

    const refs = EditorUtils.pathRefs(editor)
    refs.add(ref)
    return ref
  }

  /**
   * Get the set of currently tracked path refs of the editor.
   */

  static Set<PathRef> pathRefs(Editor editor) {
    let refs = PATH_REFS.get(editor);

    if (!refs) {
      refs = Set();
      PATH_REFS.set(editor, refs);
    }

    return refs;
  }

  /**
   * Get the start or end point of a location.
   */

  static Point point(
    Editor editor,
    Location at,
    {
      Edge edge = Edge.start
    }
  ) {
    if (PathUtils.isPath(at)) {
      let path

      if (edge == Edge.end) {
        const [, lastPath] = Node.last(editor, at)
        path = lastPath
      } else {
        const [, firstPath] = Node.first(editor, at)
        path = firstPath
      }

      Node node = Node.get(editor, path)

      if (!Text.isText(node)) {
        throw new Error(
          `Cannot get the ${edge} point in the node at path [${at}] because it has no ${edge} text node.`
        )
      }

      return { path, offset: edge == Edge.end ? node.text.length : 0 }
    }

    if (Range.isRange(at)) {
      const [start, end] = Range.edges(at)
      return edge == Edge.start ? start : end
    }

    return at
  }

  /**
   * Create a mutable ref for a `Point` object, which will stay in sync as new
   * operations are applied to the editor.
   */

  PointRef pointRef(
    Editor editor,
    Point point,
    {
      Affinity affinity = Affinity.forward
    }
  ) {
    PointRef ref = PointRef(
      current: point,
      affinity: affinity,
      unref: () {
        const { current } = ref;
        const pointRefs = Editor.pointRefs(editor);
        pointRefs.delete(ref)
        ref.current = null
        return current;
      }
    )

    Set<PointRef> refs = EditorUtils.pointRefs(editor)
    refs.add(ref)
    return ref
  }

  /**
   * Get the set of currently tracked point refs of the editor.
   */

  static Set<PointRef> pointRefs(Editor editor) {
    let refs = POINT_REFS.get(editor)

    if (!refs) {
      refs = new Set()
      POINT_REFS.set(editor, refs)
    }

    return refs
  }

  /**
   * Iterate through all of the positions in the document where a `Point` can be
   * placed.
   *
   * By default it will move forward by individual offsets at a time,  but you
   * can pass the `unit: 'character'` option to moved forward one character, word,
   * or line at at time.
   *
   * Note: void nodes are treated as a single point, and iteration will not
   * happen inside their content.
   */

  Iterable<Point> positions(
    Editor editor,
    {
      Location at,
      Unit unit = Unit.offset,
      bool reverse = false,
    }
  ) sync* {
    at = at ?? editor.selection;

    if (at == null) {
      return;
    }

    const range = Editor.range(editor, at);
    const [start, end] = Range.edges(range)
    const first = reverse ? end : start
    String string = '';
    int available = 0;
    int offset = 0;
    int distance;
    bool isNewBlock = false;

    const advance = () => {
      if (distance == null) {
        if (unit == 'character') {
          distance = getCharacterDistance(string)
        } else if (unit == 'word') {
          distance = getWordDistance(string)
        } else if (unit == 'line' || unit == 'block') {
          distance = string.length
        } else {
          distance = 1
        }

        string = string.slice(distance)
      }

      // Add or substract the offset.
      offset = reverse ? offset - distance : offset + distance
      // Subtract the distance traveled from the available text.
      available = available - distance!
      // If the available had room to spare, reset the distance so that it will
      // advance again next time. Otherwise, set it to the overflow amount.
      distance = available >= 0 ? null : 0 - available
    }

    for (const [node, path] of Editor.nodes(editor, { at, reverse })) {
      if (Element.isElement(node)) {
        // Void nodes are a special case, since we don't want to iterate over
        // their content. We instead always just yield their first point.
        if (editor.isVoid(node)) {
          yield Editor.start(editor, path)
          continue;
        }

        if (editor.isInline(node)) {
          continue
        }

        if (Editor.hasInlines(editor, node)) {
          const e = PathUtils.isAncestor(path, end.path)
            ? end
            : Editor.end(editor, path)
          const s = PathUtils.isAncestor(path, start.path)
            ? start
            : Editor.start(editor, path)

          const text = Editor.string(editor, { anchor: s, focus: e })
          string = reverse ? reverseText(text) : text
          isNewBlock = true
        }
      }

      if (Text.isText(node)) {
        const isFirst = PathUtils.equals(path, first.path)
        available = node.text.length
        offset = reverse ? available : 0

        if (isFirst) {
          available = reverse ? first.offset : available - first.offset
          offset = first.offset
        }

        if (isFirst || isNewBlock || unit == 'offset') {
          yield { path, offset }
        }

        while (true) {
          // If there's no more string, continue to the next block.
          if (string == '') {
            break
          } else {
            advance()
          }

          // If the available space hasn't overflow, we have another point to
          // yield in the current text node.
          if (available >= 0) {
            yield { path, offset }
          } else {
            break
          }
        }

        isNewBlock = false
      }
    }
  }

  /**
   * Get the matching node in the branch of the document before a location.
   */

  NodeEntry<T> previous<T extends Node>(
    Editor editor,
    {
      Location at,
      NodeMatch<T> match,
      Mode mode = Mode.lowest,
      bool voids = false
    }
  ) {
    at = at ?? editor.selection;

    if (at == null) {
      return
    }

    const [, from] = Editor.first(editor, at)
    const [, to] = Editor.first(editor, [])
    const span: Span = [from, to]

    if (PathUtils.isPath(at) && at.length == 0) {
      throw new Error(`Cannot get the previous node from the root node!`)
    }

    if (match == null) {
      if (PathUtils.isPath(at)) {
        const [parent] = Editor.parent(editor, at)
        match = n => parent.children.includes(n)
      } else {
        match = () => true
      }
    }

    const [, previous] = Editor.nodes(editor, {
      reverse: true,
      at: span,
      match,
      mode,
      voids,
    })

    return previous
  }

  /**
   * Get a range of a location.
   */
  static Range range(Editor editor, Location at, Location to) {
    if (at is Range && to != null) {
      return at;
    }

    Point start = EditorUtils.start(editor, at);
    Point end = EditorUtils.end(editor, to ?? at);

    return Range(start, end);
  }

  /**
   * Create a mutable ref for a `Range` object, which will stay in sync as new
   * operations are applied to the editor.
   */

  RangeRef rangeRef(
    Editor editor,
    Range range,
    {
      Affinity affinity = Affinity.forward
    }
  ) {
    RangeRef ref = RangeRef(
      current: range,
      affinity: affinity,
      unref: () {
        const { current } = ref
        const rangeRefs = Editor.rangeRefs(editor)
        rangeRefs.delete(ref)
        ref.current = null
        return current
      }
    );

    Set<RangeRef> refs = EditorUtils.rangeRefs(editor);
    refs.add(ref);
    return ref;
  }

  /**
   * Get the set of currently tracked range refs of the editor.
   */

  static Set<RangeRef> rangeRefs(Editor editor) {
    Set<RangeRef> refs = RANGE_REFS[editor];

    if (refs == null) {
      refs = Set();
      RANGE_REFS.update(editor, refs);
    }

    return refs;
  }

  /**
   * Remove a custom property from all of the leaf text nodes in the current
   * selection.
   *
   * If the selection is currently collapsed, the removal will be stored on
   * `editor.marks` and applied to the text inserted next.
   */

  static void removeMark(Editor editor, key: string) {
    editor.removeMark(key);
  }

  /**
   * Get the start point of a location.
   */

  static Point start(Editor editor, Location at) {
    return EditorUtils.point(editor, at, edge: Edge.start);
  }

  /**
   * Get the text string content of a location.
   *
   * Note: the text of void nodes is presumed to be an empty string, regardless
   * of what their actual content is.
   */

  String string(Editor editor, Location at) {
    Range range = EditorUtils.range(editor, at);
    const [start, end] = Range.edges(range)
    String text = ''

    for (const [node, path] of Editor.nodes(editor, {
      at: range,
      match: Text.isText,
    })) {
      String t = node.text;

      if (PathUtils.equals(path, end.path)) {
        t = t.slice(0, end.offset)
      }

      if (PathUtils.equals(path, start.path)) {
        t = t.slice(start.offset)
      }

      text += t
    }

    return text;
  }

  /**
   * Transform the editor by an operation.
   */

  transform(Editor editor, Operation op) {
    editor.children = createDraft(editor.children)
    let selection = editor.selection && createDraft(editor.selection)

    switch (op.type) {
      case 'insert_node': {
        const { path, node } = op
        const parent = Node.parent(editor, path)
        const index = path[path.length - 1]
        parent.children.splice(index, 0, node)

        if (selection) {
          for (const [point, key] of Range.points(selection)) {
            selection[key] = Point.transform(point, op)!
          }
        }

        break
      }

      case 'insert_text': {
        const { path, offset, text } = op
        Node node = Node.leaf(editor, path)
        const before = node.text.slice(0, offset)
        const after = node.text.slice(offset)
        node.text = before + text + after

        if (selection) {
          for (const [point, key] of Range.points(selection)) {
            selection[key] = Point.transform(point, op)!
          }
        }

        break
      }

      case 'merge_node': {
        const { path } = op
        Node node = Node.get(editor, path)
        const prevPath = PathUtils.previous(path)
        const prev = Node.get(editor, prevPath)
        const parent = Node.parent(editor, path)
        const index = path[path.length - 1]

        if (Text.isText(node) && Text.isText(prev)) {
          prev.text += node.text
        } else if (!Text.isText(node) && !Text.isText(prev)) {
          prev.children.push(...node.children)
        } else {
          throw new Error(
            `Cannot apply a "merge_node" operation at path [${path}] to nodes of different interaces: ${node} ${prev}`
          )
        }

        parent.children.splice(index, 1)

        if (selection) {
          for (const [point, key] of Range.points(selection)) {
            selection[key] = Point.transform(point, op)!
          }
        }

        break
      }

      case 'move_node': {
        const { path, newPath } = op

        if (PathUtils.isAncestor(path, newPath)) {
          throw new Error(
            `Cannot move a path [${path}] to new path [${newPath}] because the destination is inside itself.`
          )
        }

        Node node = Node.get(editor, path)
        const parent = Node.parent(editor, path)
        const index = path[path.length - 1]

        // This is tricky, but since the `path` and `newPath` both refer to
        // the same snapshot in time, there's a mismatch. After either
        // removing the original position, the second step's path can be out
        // of date. So instead of using the `op.newPath` directly, we
        // transform `op.path` to ascertain what the `newPath` would be after
        // the operation was applied.
        parent.children.splice(index, 1)
        const truePath = PathUtils.transform(path, op)!
        const newParent = Node.get(editor, PathUtils.parent(truePath))
        const newIndex = truePath[truePathUtils.length - 1]

        newParent.children.splice(newIndex, 0, node)

        if (selection) {
          for (const [point, key] of Range.points(selection)) {
            selection[key] = Point.transform(point, op)!
          }
        }

        break
      }

      case 'remove_node': {
        const { path } = op
        const index = path[path.length - 1]
        const parent = Node.parent(editor, path)
        parent.children.splice(index, 1)

        // Transform all of the points in the value, but if the point was in the
        // node that was removed we need to update the range or remove it.
        if (selection) {
          for (const [point, key] of Range.points(selection)) {
            const result = Point.transform(point, op)

            if (selection != null && result != null) {
              selection[key] = result
            } else {
              let prev: NodeEntry<Text> | undefined
              let next: NodeEntry<Text> | undefined

              for (const [n, p] of Node.texts(editor)) {
                if (PathUtils.compare(p, path) == -1) {
                  prev = [n, p]
                } else {
                  next = [n, p]
                  break
                }
              }

              if (prev) {
                point.path = prev[1]
                point.offset = prev[0].text.length
              } else if (next) {
                point.path = next[1]
                point.offset = 0
              } else {
                selection = null
              }
            }
          }
        }

        break
      }

      case 'remove_text': {
        const { path, offset, text } = op
        Node node = Node.leaf(editor, path)
        const before = node.text.slice(0, offset)
        const after = node.text.slice(offset + text.length)
        node.text = before + after

        if (selection) {
          for (const [point, key] of Range.points(selection)) {
            selection[key] = Point.transform(point, op)!
          }
        }

        break
      }

      case 'set_node': {
        const { path, newProperties } = op

        if (path.length == 0) {
          throw new Error(`Cannot set properties on the root node!`)
        }

        Node node = Node.get(editor, path)

        for (const key in newProperties) {
          if (key == 'children' || key == 'text') {
            throw new Error(`Cannot set the "${key}" property of nodes!`)
          }

          const value = newProperties[key]

          if (value == null) {
            delete node[key]
          } else {
            node[key] = value
          }
        }

        break
      }

      case 'set_selection': {
        const { newProperties } = op

        if (newProperties == null) {
          selection = newProperties
        } else if (selection == null) {
          if (!Range.isRange(newProperties)) {
            throw new Error(
              `Cannot apply an incomplete "set_selection" operation properties ${JSON.stringify(
                newProperties
              )} when there is no current selection.`
            )
          }

          selection = newProperties
        } else {
          Object.assign(selection, newProperties)
        }

        break
      }

      case 'split_node': {
        const { path, position, properties } = op

        if (path.length == 0) {
          throw new Error(
            `Cannot apply a "split_node" operation at path [${path}] because the root node cannot be split.`
          )
        }

        Node node = Node.get(editor, path)
        const parent = Node.parent(editor, path)
        const index = path[path.length - 1]
        let newNode: Descendant

        if (Text.isText(node)) {
          const before = node.text.slice(0, position)
          const after = node.text.slice(position)
          node.text = before
          newNode = {
            ...node,
            ...(properties as Partial<Text>),
            text: after,
          }
        } else {
          const before = node.children.slice(0, position)
          const after = node.children.slice(position)
          node.children = before

          newNode = {
            ...node,
            ...(properties as Partial<Element>),
            children: after,
          }
        }

        parent.children.splice(index + 1, 0, newNode)

        if (selection) {
          for (const [point, key] of Range.points(selection)) {
            selection[key] = Point.transform(point, op)!
          }
        }

        break
      }
    }

    editor.children = finishDraft(editor.children) as Node[]

    if (selection) {
      editor.selection = isDraft(selection)
        ? (finishDraft(selection) as Range)
        : selection
    } else {
      editor.selection = null
    }
  }

  /**
   * Convert a range into a non-hanging one.
   */

  Range unhangRange(
    Editor editor,
    Range range,
    {
      bool voids = false
    }
  ) {
    let [start, end] = Range.edges(range)

    // PERF: exit early if we can guarantee that the range isn't hanging.
    if (start.offset != 0 || end.offset != 0 || Range.isCollapsed(range)) {
      return range
    }

    const endBlock = Editor.above(editor, {
      at: end,
      match: n => Editor.isBlock(editor, n),
    })
    const blockPath = endBlock ? endBlock[1] : []
    const first = Editor.start(editor, [])
    const before = { anchor: first, focus: end }
    let skip = true

    for (const [node, path] of Editor.nodes(editor, {
      at: before,
      match: Text.isText,
      reverse: true,
      voids,
    })) {
      if (skip) {
        skip = false
        continue
      }

      if (node.text != '' || PathUtils.isBefore(path, blockPath)) {
        end = { path, offset: node.text.length }
        break
      }
    }

    return { anchor: start, focus: end }
  }

  /**
   * Match a void node in the current branch of the editor.
   */

  static NodeEntry<Element> (
    Editor editor,
    {
      Location at,
      Mode mode,
      bool voids,
    }
  ) {
    return EditorUtils.above(editor, at: at, mode: mode, match: () {
      return EditorUtils.isVoid(editor, n);
    });
  }

  /**
   * Call a function, deferring normalization until after it completes.
   */

  static void withoutNormalizing(Editor editor, void Function() fn) {
    const value = Editor.isNormalizing(editor)
    NORMALIZING.set(editor, false)
    fn()
    NORMALIZING.set(editor, value)
    Editor.normalize(editor)
  }
}

// type NodeMatch<T extends Node> =
//   | ((node: Node) => node is T)
//   | ((node: Node) => bool)

enum Mode {
  highest,
  lowest
}

enum Unit {
  character,
   word,
   line,
   block,
}

enum Edge {
  start
  end
}