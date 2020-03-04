import 'package:inday/stela/editor.dart';
import 'package:inday/stela/location.dart';
import 'package:inday/stela/node.dart';
import 'package:inday/stela/point.dart';
import 'package:inday/stela/range.dart';
import 'package:inday/stela/text.dart';

class Transforms {
  // /// Insert nodes at a specific location in the Editor.
  // void insertNodes(
  //   Editor editor,
  //   List<Node> nodes,
  //   {
  //     Location at,
  //     NodeMatch match,
  //     Mode mode = Mode.lowest,
  //     bool hanging = false,
  //     bool select,
  //     bool voids = false,
  //   }
  // ) {
  //   EditorUtils.withoutNormalizing(editor, () {
  //     const [node] = nodes

  //     // By default, use the selection as the target location. But if there is
  //     // no selection, insert at the end of the document since that is such a
  //     // common use case when inserting from a non-selected state.
  //     if (at == null) {
  //       if (editor.selection) {
  //         at = editor.selection
  //       } else if (editor.children.length > 0) {
  //         at = EditorUtils.end(editor, [])
  //       } else {
  //         at = [0]
  //       }

  //       select = true
  //     }

  //     if (select == null) {
  //       select = false
  //     }

  //     if (at is Range) {
  //       if (!hanging) {
  //         at = EditorUtils.unhangRange(editor, at)
  //       }

  //       if (RangeUtils.isCollapsed(at)) {
  //         at = at.anchor
  //       } else {
  //         const [, end] = RangeUtils.edges(at)
  //         const pointRef = EditorUtils.pointRef(editor, end)
  //         Transforms.delete(editor, { at })
  //         at = pointRef.unref()!
  //       }
  //     }

  //     if (at is Point) {
  //       if (match == null) {
  //         if (node is Text) {
  //           match = (n) { return (n is Text); };
  //         } else if (editor.isInline(node)) {
  //           match = (n) { return (n is Text); } || EditorUtils.isInline(editor, n)
  //         } else {
  //           match = n => EditorUtils.isBlock(editor, n)
  //         }
  //       }

  //       const [entry] = EditorUtils.nodes(editor, {
  //         at: at.path,
  //         match: match,
  //         mode: mode,
  //         voids: voids,
  //       })

  //       if (entry != null) {
  //         const [, matchPath] = entry
  //         const pathRef = EditorUtils.pathRef(editor, matchPath)
  //         const isAtEnd = EditorUtils.isEnd(editor, at, matchPath)
  //         Transforms.splitNodes(editor, { at, match, mode, voids })
  //         const path = pathRef.unref()!
  //         at = isAtEnd ? PathUtils.next(path) : path
  //       } else {
  //         return;
  //       }
  //     }

  //     Path parentPath = PathUtils.parent(at)
  //     let index = at[at.length - 1]

  //     if (!voids && EditorUtils.matchVoid(editor, { at: parentPath })) {
  //       return
  //     }

  //     for (Node node in nodes) {
  //       const path = parentPath.concat(index)
  //       index++
  //       editor.apply({ type: 'insert_node', path, node })
  //     }

  //     if (select) {
  //       const point = EditorUtils.end(editor, at)

  //       if (point) {
  //         Transforms.select(editor, point)
  //       }
  //     }
  //   })
  // }

  // /**
  //  * Lift nodes at a specific location upwards in the document tree, splitting
  //  * their parent in two if necessary.
  //  */

  // liftNodes(
  //   Editor editor,
  //   options: {
  //     Location at,
  //     NodeMatch match,
  //     mode?: 'all' | 'highest' | 'lowest'
  //     bool voids = false
  //   } = {}
  // ) {
  //   EditorUtils.withoutNormalizing(editor, () {
  //     const { at = editor.selection, mode = 'lowest', voids = false } = options
  //     let { match } = options

  //     if (match == null) {
  //       match = Path.isPath(at)
  //         ? matchPath(editor, at)
  //         : n => EditorUtils.isBlock(editor, n)
  //     }

  //     if (at == null) {
  //       return
  //     }

  //     const matches = EditorUtils.nodes(editor, { at, match, mode, voids })
  //     const pathRefs = Array.from(matches, ([, p]) => EditorUtils.pathRef(editor, p))

  //     for (const pathRef of pathRefs) {
  //       const path = pathRef.unref()!

  //       if (path.length < 2) {
  //         throw new Error(
  //           `Cannot lift node at a path [${path}] because it has a depth of less than \`2\`.`
  //         )
  //       }

  //       const [parent, parentPath] = EditorUtils.node(editor, Path.parent(path))
  //       const index = path[path.length - 1]
  //       const { length } = parent.children

  //       if (length == 1) {
  //         const toPath = Path.next(parentPath)
  //         Transforms.moveNodes(editor, { at: path, to: toPath, voids })
  //         Transforms.removeNodes(editor, { at: parentPath, voids })
  //       } else if (index == 0) {
  //         Transforms.moveNodes(editor, { at: path, to: parentPath, voids })
  //       } else if (index == length - 1) {
  //         const toPath = Path.next(parentPath)
  //         Transforms.moveNodes(editor, { at: path, to: toPath, voids })
  //       } else {
  //         const splitPath = Path.next(path)
  //         const toPath = Path.next(parentPath)
  //         Transforms.splitNodes(editor, { at: splitPath, voids })
  //         Transforms.moveNodes(editor, { at: path, to: toPath, voids })
  //       }
  //     }
  //   })
  // },

  // /**
  //  * Merge a node at a location with the previous node of the same depth,
  //  * removing any empty containing nodes after the merge if necessary.
  //  */

  // mergeNodes(
  //   Editor editor,
  //   options: {
  //     Location at,
  //     NodeMatch match,
  //     Mode mode = Mode.lowest,
  //     bool hanging = false,
  //     bool voids = false
  //   } = {}
  // ) {
  //   EditorUtils.withoutNormalizing(editor, () {
  //     let { match, at = editor.selection } = options
  //     const { hanging = false, voids = false, mode = 'lowest' } = options

  //     if (at == null) {
  //       return
  //     }

  //     if (match == null) {
  //       if (Path.isPath(at)) {
  //         const [parent] = EditorUtils.parent(editor, at)
  //         match = n => parent.children.includes(n)
  //       } else {
  //         match = n => EditorUtils.isBlock(editor, n)
  //       }
  //     }

  //     if (!hanging && at is Range) {
  //       at = EditorUtils.unhangRange(editor, at)
  //     }

  //     if (at is Range) {
  //       if (RangeUtils.isCollapsed(at)) {
  //         at = at.anchor
  //       } else {
  //         const [, end] = RangeUtils.edges(at)
  //         const pointRef = EditorUtils.pointRef(editor, end)
  //         Transforms.delete(editor, { at })
  //         at = pointRef.unref()!

  //         if (options.at == null) {
  //           Transforms.select(editor, at)
  //         }
  //       }
  //     }

  //     const [current] = EditorUtils.nodes(editor, { at, match, voids, mode })
  //     const prev = EditorUtils.previous(editor, { at, match, voids, mode })

  //     if (!current || !prev) {
  //       return
  //     }

  //     const [node, path] = current
  //     const [prevNode, prevPath] = prev

  //     if (path.length == 0 || prevPath.length == 0) {
  //       return
  //     }

  //     const newPath = Path.next(prevPath)
  //     const commonPath = Path.common(path, prevPath)
  //     const isPreviousSibling = Path.isSibling(path, prevPath)
  //     const levels = Array.from(EditorUtils.levels(editor, { at: path }), ([n]) => n)
  //       .slice(commonPath.length)
  //       .slice(0, -1)

  //     // Determine if the merge will leave an ancestor of the path empty as a
  //     // result, in which case we'll want to remove it after merging.
  //     const emptyAncestor = EditorUtils.above(editor, {
  //       at: path,
  //       mode: 'highest',
  //       match: n =>
  //         levels.includes(n) && Element.isElement(n) && n.children.length == 1,
  //     })

  //     const emptyRef = emptyAncestor && EditorUtils.pathRef(editor, emptyAncestor[1])
  //     let properties
  //     let position

  //     // Ensure that the nodes are equivalent, and figure out what the position
  //     // and extra properties of the merge will be.
  //     if (node is Text && Text.isText(prevNode)) {
  //       const { text, ...rest } = node
  //       position = prevNode.text.length
  //       properties = rest as Partial<Text>
  //     } else if (Element.isElement(node) && Element.isElement(prevNode)) {
  //       const { children, ...rest } = node
  //       position = prevNode.children.length
  //       properties = rest as Partial<Element>
  //     } else {
  //       throw new Error(
  //         `Cannot merge the node at path [${path}] with the previous sibling because it is not the same kind: ${JSON.stringify(
  //           node
  //         )} ${JSON.stringify(prevNode)}`
  //       )
  //     }

  //     // If the node isn't already the next sibling of the previous node, move
  //     // it so that it is before merging.
  //     if (!isPreviousSibling) {
  //       Transforms.moveNodes(editor, { at: path, to: newPath, voids })
  //     }

  //     // If there was going to be an empty ancestor of the node that was merged,
  //     // we remove it from the tree.
  //     if (emptyRef) {
  //       Transforms.removeNodes(editor, { at: emptyRef.current!, voids })
  //     }

  //     // If the target node that we're merging with is empty, remove it instead
  //     // of merging the two. This is a common rich text editor behavior to
  //     // prevent losing formatting when deleting entire nodes when you have a
  //     // hanging selection.
  //     if (
  //       (Element.isElement(prevNode) && EditorUtils.isEmpty(editor, prevNode)) ||
  //       (Text.isText(prevNode) && prevNode.text == '')
  //     ) {
  //       Transforms.removeNodes(editor, { at: prevPath, voids })
  //     } else {
  //       editor.apply({
  //         type: 'merge_node',
  //         path: newPath,
  //         position,
  //         target: null,
  //         properties,
  //       })
  //     }

  //     if (emptyRef) {
  //       emptyRef.unref()
  //     }
  //   })
  // },

  // /**
  //  * Move the nodes at a location to a new location.
  //  */

  // moveNodes(
  //   Editor editor,
  //   options: {
  //     Location at,
  //     NodeMatch match,
  //     mode?: 'all' | 'highest' | 'lowest'
  //     to: Path
  //     bool voids = false
  //   }
  // ) {
  //   EditorUtils.withoutNormalizing(editor, () {
  //     const {
  //       to,
  //       at = editor.selection,
  //       mode = 'lowest',
  //       voids = false,
  //     } = options
  //     let { match } = options

  //     if (at == null) {
  //       return
  //     }

  //     if (match == null) {
  //       match = Path.isPath(at)
  //         ? matchPath(editor, at)
  //         : n => EditorUtils.isBlock(editor, n)
  //     }

  //     const toRef = EditorUtils.pathRef(editor, to)
  //     const targets = EditorUtils.nodes(editor, { at, match, mode, voids })
  //     const pathRefs = Array.from(targets, ([, p]) => EditorUtils.pathRef(editor, p))

  //     for (const pathRef of pathRefs) {
  //       const path = pathRef.unref()!
  //       const newPath = toRef.current!

  //       if (path.length !== 0) {
  //         editor.apply({ type: 'move_node', path, newPath })
  //       }
  //     }

  //     toRef.unref()
  //   })
  // },

  // /**
  //  * Remove the nodes at a specific location in the document.
  //  */

  // removeNodes(
  //   Editor editor,
  //   options: {
  //     Location at,
  //     NodeMatch match,
  //     Mode mode = Mode.lowest,
  //     bool hanging = false,
  //     bool voids = false
  //   } = {}
  // ) {
  //   EditorUtils.withoutNormalizing(editor, () {
  //     const { hanging = false, voids = false, mode = 'lowest' } = options
  //     let { at = editor.selection, match } = options

  //     if (at == null) {
  //       return
  //     }

  //     if (match == null) {
  //       match = Path.isPath(at)
  //         ? matchPath(editor, at)
  //         : n => EditorUtils.isBlock(editor, n)
  //     }

  //     if (!hanging && at is Range) {
  //       at = EditorUtils.unhangRange(editor, at)
  //     }

  //     const depths = EditorUtils.nodes(editor, { at, match, mode, voids })
  //     const pathRefs = Array.from(depths, ([, p]) => EditorUtils.pathRef(editor, p))

  //     for (const pathRef of pathRefs) {
  //       const path = pathRef.unref()!

  //       if (path) {
  //         const [node] = EditorUtils.node(editor, path)
  //         editor.apply({ type: 'remove_node', path, node })
  //       }
  //     }
  //   })
  // },

  // /**
  //  * Set new properties on the nodes at a location.
  //  */

  // setNodes(
  //   Editor editor,
  //   props: Partial<Node>,
  //   options: {
  //     Location at,
  //     NodeMatch match,
  //     mode?: 'all' | 'highest' | 'lowest'
  //     bool hanging = false,
  //     split?: boolean
  //     bool voids = false
  //   } = {}
  // ) {
  //   EditorUtils.withoutNormalizing(editor, () {
  //     let { match, at = editor.selection } = options
  //     const {
  //       hanging = false,
  //       mode = 'lowest',
  //       split = false,
  //       voids = false,
  //     } = options

  //     if (at == null) {
  //       return
  //     }

  //     if (match == null) {
  //       match = Path.isPath(at)
  //         ? matchPath(editor, at)
  //         : n => EditorUtils.isBlock(editor, n)
  //     }

  //     if (!hanging && at is Range) {
  //       at = EditorUtils.unhangRange(editor, at)
  //     }

  //     if (split && at is Range) {
  //       const rangeRef = EditorUtils.rangeRef(editor, at, { affinity: 'inward' })
  //       const [start, end] = RangeUtils.edges(at)
  //       const splitMode = mode == 'lowest' ? 'lowest' : 'highest'
  //       Transforms.splitNodes(editor, {
  //         at: end,
  //         match,
  //         mode: splitMode,
  //         voids,
  //       })
  //       Transforms.splitNodes(editor, {
  //         at: start,
  //         match,
  //         mode: splitMode,
  //         voids,
  //       })
  //       at = rangeRef.unref()!

  //       if (options.at == null) {
  //         Transforms.select(editor, at)
  //       }
  //     }

  //     for (const [node, path] of EditorUtils.nodes(editor, {
  //       at,
  //       match,
  //       mode,
  //       voids,
  //     })) {
  //       const properties: Partial<Node> = {}
  //       const newProperties: Partial<Node> = {}

  //       // You can't set properties on the editor node.
  //       if (path.length == 0) {
  //         continue
  //       }

  //       for (const k in props) {
  //         if (k == 'children' || k == 'text') {
  //           continue
  //         }

  //         if (props[k] !== node[k]) {
  //           properties[k] = node[k]
  //           newProperties[k] = props[k]
  //         }
  //       }

  //       if (Object.keys(newProperties).length !== 0) {
  //         editor.apply({
  //           type: 'set_node',
  //           path,
  //           properties,
  //           newProperties,
  //         })
  //       }
  //     }
  //   })
  // },

  // /**
  //  * Split the nodes at a specific location.
  //  */

  // splitNodes(
  //   Editor editor,
  //   options: {
  //     Location at,
  //     NodeMatch match,
  //     Mode mode = Mode.lowest,
  //     always?: boolean
  //     height?: number
  //     bool voids = false
  //   } = {}
  // ) {
  //   EditorUtils.withoutNormalizing(editor, () {
  //     const { mode = 'lowest', voids = false } = options
  //     let { match, at = editor.selection, height = 0, always = false } = options

  //     if (match == null) {
  //       match = n => EditorUtils.isBlock(editor, n)
  //     }

  //     if (at is Range) {
  //       at = deleteRange(editor, at)
  //     }

  //     // If the target is a path, the default height-skipping and position
  //     // counters need to account for us potentially splitting at a non-leaf.
  //     if (Path.isPath(at)) {
  //       const path = at
  //       const point = EditorUtils.point(editor, path)
  //       const [parent] = EditorUtils.parent(editor, path)
  //       match = n => n == parent
  //       height = point.path.length - path.length + 1
  //       at = point
  //       always = true
  //     }

  //     if (at == null) {
  //       return
  //     }

  //     const beforeRef = EditorUtils.pointRef(editor, at, {
  //       affinity: 'backward',
  //     })
  //     const [highest] = EditorUtils.nodes(editor, { at, match, mode, voids })

  //     if (!highest) {
  //       return
  //     }

  //     const voidMatch = EditorUtils.matchVoid(editor, { at, mode: 'highest' })
  //     const nudge = 0

  //     if (!voids && voidMatch) {
  //       const [voidNode, voidPath] = voidMatch

  //       if (Element.isElement(voidNode) && editor.isInline(voidNode)) {
  //         let after = EditorUtils.after(editor, voidPath)

  //         if (!after) {
  //           const text = { text: '' }
  //           const afterPath = Path.next(voidPath)
  //           Transforms.insertNodes(editor, text, { at: afterPath, voids })
  //           after = EditorUtils.point(editor, afterPath)!
  //         }

  //         at = after
  //         always = true
  //       }

  //       const siblingHeight = at.path.length - voidPath.length
  //       height = siblingHeight + 1
  //       always = true
  //     }

  //     const afterRef = EditorUtils.pointRef(editor, at)
  //     const depth = at.path.length - height
  //     const [, highestPath] = highest
  //     const lowestPath = at.path.slice(0, depth)
  //     let position = height == 0 ? at.offset : at.path[depth] + nudge
  //     let target: number | null = null

  //     for (const [node, path] of EditorUtils.levels(editor, {
  //       at: lowestPath,
  //       reverse: true,
  //       voids,
  //     })) {
  //       let split = false

  //       if (
  //         path.length < highestPath.length ||
  //         path.length == 0 ||
  //         (!voids && EditorUtils.isVoid(editor, node))
  //       ) {
  //         break
  //       }

  //       const point = beforeRef.current!
  //       const isEnd = EditorUtils.isEnd(editor, point, path)

  //       if (always || !beforeRef || !EditorUtils.isEdge(editor, point, path)) {
  //         split = true
  //         const { text, children, ...properties } = node
  //         editor.apply({
  //           type: 'split_node',
  //           path,
  //           position,
  //           target,
  //           properties,
  //         })
  //       }

  //       target = position
  //       position = path[path.length - 1] + (split || isEnd ? 1 : 0)
  //     }

  //     if (options.at == null) {
  //       const point = afterRef.current || EditorUtils.end(editor, [])
  //       Transforms.select(editor, point)
  //     }

  //     beforeRef.unref()
  //     afterRef.unref()
  //   })
  // },

  // /**
  //  * Unset properties on the nodes at a location.
  //  */

  // unsetNodes(
  //   Editor editor,
  //   props: string | string[],
  //   options: {
  //     Location at,
  //     NodeMatch match,
  //     mode?: 'all' | 'highest' | 'lowest'
  //     split?: boolean
  //     bool voids = false
  //   } = {}
  // ) {
  //   if (!Array.isArray(props)) {
  //     props = [props]
  //   }

  //   const obj = {}

  //   for (const key of props) {
  //     obj[key] = null
  //   }

  //   Transforms.setNodes(editor, obj, options)
  // },

  // /**
  //  * Unwrap the nodes at a location from a parent node, splitting the parent if
  //  * necessary to ensure that only the content in the range is unwrapped.
  //  */

  // unwrapNodes(
  //   Editor editor,
  //   options: {
  //     Location at,
  //     NodeMatch match,
  //     mode?: 'all' | 'highest' | 'lowest'
  //     split?: boolean
  //     bool voids = false
  //   }
  // ) {
  //   EditorUtils.withoutNormalizing(editor, () {
  //     const { mode = 'lowest', split = false, voids = false } = options
  //     let { at = editor.selection, match } = options

  //     if (at == null) {
  //       return
  //     }

  //     if (match == null) {
  //       match = Path.isPath(at)
  //         ? matchPath(editor, at)
  //         : n => EditorUtils.isBlock(editor, n)
  //     }

  //     if (Path.isPath(at)) {
  //       at = EditorUtils.range(editor, at)
  //     }

  //     const rangeRef = at is Range ? EditorUtils.rangeRef(editor, at) : null
  //     const matches = EditorUtils.nodes(editor, { at, match, mode, voids })
  //     const pathRefs = Array.from(matches, ([, p]) => EditorUtils.pathRef(editor, p))

  //     for (const pathRef of pathRefs) {
  //       const path = pathRef.unref()!
  //       const [node] = EditorUtils.node(editor, path)
  //       let range = EditorUtils.range(editor, path)

  //       if (split && rangeRef) {
  //         range = RangeUtils.intersection(rangeRef.current!, range)!
  //       }

  //       Transforms.liftNodes(editor, {
  //         at: range,
  //         match: n => node.children.includes(n),
  //         voids,
  //       })
  //     }

  //     if (rangeRef) {
  //       rangeRef.unref()
  //     }
  //   })
  // },

  // /**
  //  * Wrap the nodes at a location in a new container node, splitting the edges
  //  * of the range first to ensure that only the content in the range is wrapped.
  //  */

  // wrapNodes(
  //   Editor editor,
  //   element: Element,
  //   options: {
  //     Location at,
  //     NodeMatch match,
  //     mode?: 'all' | 'highest' | 'lowest'
  //     split?: boolean
  //     bool voids = false
  //   } = {}
  // ) {
  //   EditorUtils.withoutNormalizing(editor, () {
  //     const { mode = 'lowest', split = false, voids = false } = options
  //     let { match, at = editor.selection } = options

  //     if (at == null) {
  //       return
  //     }

  //     if (match == null) {
  //       if (Path.isPath(at)) {
  //         match = matchPath(editor, at)
  //       } else if (editor.isInline(element)) {
  //         match = n => EditorUtils.isInline(editor, n) || (n is Text)
  //       } else {
  //         match = n => EditorUtils.isBlock(editor, n)
  //       }
  //     }

  //     if (split && at is Range) {
  //       const [start, end] = RangeUtils.edges(at)
  //       const rangeRef = EditorUtils.rangeRef(editor, at, {
  //         affinity: 'inward',
  //       })
  //       Transforms.splitNodes(editor, { at: end, match, voids })
  //       Transforms.splitNodes(editor, { at: start, match, voids })
  //       at = rangeRef.unref()!

  //       if (options.at == null) {
  //         Transforms.select(editor, at)
  //       }
  //     }

  //     const roots = Array.from(
  //       EditorUtils.nodes(editor, {
  //         at,
  //         match: editor.isInline(element)
  //           ? n => EditorUtils.isBlock(editor, n)
  //           : n => EditorUtils.isEditor(n),
  //         mode: 'highest',
  //         voids,
  //       })
  //     )

  //     for (const [, rootPath] of roots) {
  //       const a = at is Range
  //         ? RangeUtils.intersection(at, EditorUtils.range(editor, rootPath))
  //         : at

  //       if (!a) {
  //         continue
  //       }

  //       const matches = Array.from(
  //         EditorUtils.nodes(editor, { at: a, match, mode, voids })
  //       )

  //       if (matches.length > 0) {
  //         const [first] = matches
  //         const last = matches[matches.length - 1]
  //         const [, firstPath] = first
  //         const [, lastPath] = last
  //         const commonPath = Path.equals(firstPath, lastPath)
  //           ? Path.parent(firstPath)
  //           : Path.common(firstPath, lastPath)

  //         const range = EditorUtils.range(editor, firstPath, lastPath)
  //         const [commonNode] = EditorUtils.node(editor, commonPath)
  //         const depth = commonPath.length + 1
  //         const wrapperPath = Path.next(lastPath.slice(0, depth))
  //         const wrapper = { ...element, children: [] }
  //         Transforms.insertNodes(editor, wrapper, { at: wrapperPath, voids })

  //         Transforms.moveNodes(editor, {
  //           at: range,
  //           match: n => commonNode.children.includes(n),
  //           to: wrapperPath.concat(0),
  //           voids,
  //         })
  //       }
  //     }
  //   })
  // },

  // // Selection transforms

  // /**
  //  * Collapse the selection.
  //  */

  // collapse(
  //   Editor editor,
  //   options: {
  //     edge?: 'anchor' | 'focus' | 'start' | 'end'
  //   } = {}
  // ) {
  //   const { edge = 'anchor' } = options
  //   const { selection } = editor

  //   if (!selection) {
  //     return
  //   } else if (edge == 'anchor') {
  //     Transforms.select(editor, selection.anchor)
  //   } else if (edge == 'focus') {
  //     Transforms.select(editor, selection.focus)
  //   } else if (edge == 'start') {
  //     const [start] = RangeUtils.edges(selection)
  //     Transforms.select(editor, start)
  //   } else if (edge == 'end') {
  //     const [, end] = RangeUtils.edges(selection)
  //     Transforms.select(editor, end)
  //   }
  // },

  // /**
  //  * Unset the selection.
  //  */

  // deselect(Editor editor) {
  //   const { selection } = editor

  //   if (selection) {
  //     editor.apply({
  //       type: 'set_selection',
  //       properties: selection,
  //       newProperties: null,
  //     })
  //   }
  // },

  // /**
  //  * Move the selection's point forward or backward.
  //  */

  // move(
  //   Editor editor,
  //   options: {
  //     distance?: number
  //     unit?: 'offset' | 'character' | 'word' | 'line'
  //     reverse?: boolean
  //     edge?: 'anchor' | 'focus' | 'start' | 'end'
  //   } = {}
  // ) {
  //   const { selection } = editor
  //   const { distance = 1, unit = 'character', reverse = false } = options
  //   let { edge = null } = options

  //   if (!selection) {
  //     return
  //   }

  //   if (edge == 'start') {
  //     edge = RangeUtils.isBackward(selection) ? 'focus' : 'anchor'
  //   }

  //   if (edge == 'end') {
  //     edge = RangeUtils.isBackward(selection) ? 'anchor' : 'focus'
  //   }

  //   const { anchor, focus } = selection
  //   const opts = { distance, unit }
  //   const props: Partial<Range> = {}

  //   if (edge == null || edge == 'anchor') {
  //     const point = reverse
  //       ? EditorUtils.before(editor, anchor, opts)
  //       : EditorUtils.after(editor, anchor, opts)

  //     if (point) {
  //       props.anchor = point
  //     }
  //   }

  //   if (edge == null || edge == 'focus') {
  //     const point = reverse
  //       ? EditorUtils.before(editor, focus, opts)
  //       : EditorUtils.after(editor, focus, opts)

  //     if (point) {
  //       props.focus = point
  //     }
  //   }

  //   Transforms.setSelection(editor, props)
  // },

  // /**
  //  * Set the selection to a new value.
  //  */

  // select(Editor editor, target: Location) {
  //   const { selection } = editor
  //   target = EditorUtils.range(editor, target)

  //   if (selection) {
  //     Transforms.setSelection(editor, target)
  //     return
  //   }

  //   if (!RangeUtils.isRange(target)) {
  //     throw new Error(
  //       `When setting the selection and the current selection is \`null\` you must provide at least an \`anchor\` and \`focus\`, but you passed: ${JSON.stringify(
  //         target
  //       )}`
  //     )
  //   }

  //   editor.apply({
  //     type: 'set_selection',
  //     properties: selection,
  //     newProperties: target,
  //   })
  // },

  // /**
  //  * Set new properties on one of the selection's points.
  //  */

  // setPoint(
  //   Editor editor,
  //   props: Partial<Point>,
  //   options: {
  //     edge?: 'anchor' | 'focus' | 'start' | 'end'
  //   }
  // ) {
  //   const { selection } = editor
  //   let { edge = 'both' } = options

  //   if (!selection) {
  //     return
  //   }

  //   if (edge == 'start') {
  //     edge = RangeUtils.isBackward(selection) ? 'focus' : 'anchor'
  //   }

  //   if (edge == 'end') {
  //     edge = RangeUtils.isBackward(selection) ? 'anchor' : 'focus'
  //   }

  //   const { anchor, focus } = selection
  //   const point = edge == 'anchor' ? anchor : focus
  //   const newPoint = Object.assign(point, props)

  //   if (edge == 'anchor') {
  //     Transforms.setSelection(editor, { anchor: newPoint })
  //   } else {
  //     Transforms.setSelection(editor, { focus: newPoint })
  //   }
  // },

  // /**
  //  * Set new properties on the selection.
  //  */

  // setSelection(Editor editor, props: Partial<Range>) {
  //   const { selection } = editor
  //   const oldProps: Partial<Range> | null = {}
  //   const newProps: Partial<Range> = {}

  //   if (!selection) {
  //     return
  //   }

  //   for (const k in props) {
  //     if (
  //       (k == 'anchor' &&
  //         props.anchor != null &&
  //         !Point.equals(props.anchor, selection.anchor)) ||
  //       (k == 'focus' &&
  //         props.focus != null &&
  //         !Point.equals(props.focus, selection.focus)) ||
  //       (k !== 'anchor' && k !== 'focus' && props[k] !== selection[k])
  //     ) {
  //       oldProps[k] = selection[k]
  //       newProps[k] = props[k]
  //     }
  //   }

  //   if (Object.keys(oldProps).length > 0) {
  //     editor.apply({
  //       type: 'set_selection',
  //       properties: oldProps,
  //       newProperties: newProps,
  //     })
  //   }
  // },

  // // Text transforms
  // /**
  //  * Delete content in the editor.
  //  */

  // delete(
  //   Editor editor,
  //   options: {
  //     Location at,
  //     distance?: number
  //     unit?: 'character' | 'word' | 'line' | 'block'
  //     reverse?: boolean
  //     bool hanging = false,
  //     bool voids = false
  //   } = {}
  // ) {
  //   EditorUtils.withoutNormalizing(editor, () {
  //     const {
  //       reverse = false,
  //       unit = 'character',
  //       distance = 1,
  //       voids = false,
  //     } = options
  //     let { at = editor.selection, hanging = false } = options

  //     if (at == null) {
  //       return
  //     }

  //     if (at is Range && RangeUtils.isCollapsed(at)) {
  //       at = at.anchor
  //     }

  //     if (at is Point) {
  //       const furthestVoid = EditorUtils.matchVoid(editor, { at, mode: 'highest' })

  //       if (!voids && furthestVoid) {
  //         const [, voidPath] = furthestVoid
  //         at = voidPath
  //       } else {
  //         const opts = { unit, distance }
  //         const target = reverse
  //           ? EditorUtils.before(editor, at, opts) || EditorUtils.start(editor, [])
  //           : EditorUtils.after(editor, at, opts) || EditorUtils.end(editor, [])
  //         at = { anchor: at, focus: target }
  //         hanging = true
  //       }
  //     }

  //     if (Path.isPath(at)) {
  //       Transforms.removeNodes(editor, { at, voids })
  //       return
  //     }

  //     if (RangeUtils.isCollapsed(at)) {
  //       return
  //     }

  //     if (!hanging) {
  //       at = EditorUtils.unhangRange(editor, at, { voids })
  //     }

  //     let [start, end] = RangeUtils.edges(at)
  //     const startBlock = EditorUtils.above(editor, {
  //       match: n => EditorUtils.isBlock(editor, n),
  //       at: start,
  //       voids,
  //     })
  //     const endBlock = EditorUtils.above(editor, {
  //       match: n => EditorUtils.isBlock(editor, n),
  //       at: end,
  //       voids,
  //     })
  //     const isAcrossBlocks =
  //       startBlock && endBlock && !Path.equals(startBlock[1], endBlock[1])
  //     const isSingleText = Path.equals(start.path, end.path)
  //     const startVoid = voids
  //       ? null
  //       : EditorUtils.matchVoid(editor, { at: start, mode: 'highest' })
  //     const endVoid = voids
  //       ? null
  //       : EditorUtils.matchVoid(editor, { at: end, mode: 'highest' })

  //     // If the start or end points are inside an inline void, nudge them out.
  //     if (startVoid) {
  //       const before = EditorUtils.before(editor, start)

  //       if (
  //         before &&
  //         startBlock &&
  //         Path.isAncestor(startBlock[1], before.path)
  //       ) {
  //         start = before
  //       }
  //     }

  //     if (endVoid) {
  //       const after = EditorUtils.after(editor, end)

  //       if (after && endBlock && Path.isAncestor(endBlock[1], after.path)) {
  //         end = after
  //       }
  //     }

  //     // Get the highest nodes that are completely inside the range, as well as
  //     // the start and end nodes.
  //     const matches: NodeEntry[] = []
  //     let lastPath: Path | undefined

  //     for (const entry of EditorUtils.nodes(editor, { at, voids })) {
  //       const [node, path] = entry

  //       if (lastPath && Path.compare(path, lastPath) == 0) {
  //         continue
  //       }

  //       if (
  //         (!voids && EditorUtils.isVoid(editor, node)) ||
  //         (!Path.isCommon(path, start.path) && !Path.isCommon(path, end.path))
  //       ) {
  //         matches.push(entry)
  //         lastPath = path
  //       }
  //     }

  //     const pathRefs = Array.from(matches, ([, p]) => EditorUtils.pathRef(editor, p))
  //     const startRef = EditorUtils.pointRef(editor, start)
  //     const endRef = EditorUtils.pointRef(editor, end)

  //     if (!isSingleText && !startVoid) {
  //       const point = startRef.current!
  //       const [node] = EditorUtils.leaf(editor, point)
  //       const { path } = point
  //       const { offset } = start
  //       const text = node.text.slice(offset)
  //       editor.apply({ type: 'remove_text', path, offset, text })
  //     }

  //     for (const pathRef of pathRefs) {
  //       const path = pathRef.unref()!
  //       Transforms.removeNodes(editor, { at: path, voids })
  //     }

  //     if (!endVoid) {
  //       const point = endRef.current!
  //       const [node] = EditorUtils.leaf(editor, point)
  //       const { path } = point
  //       const offset = isSingleText ? start.offset : 0
  //       const text = node.text.slice(offset, end.offset)
  //       editor.apply({ type: 'remove_text', path, offset, text })
  //     }

  //     if (
  //       !isSingleText &&
  //       isAcrossBlocks &&
  //       endRef.current &&
  //       startRef.current
  //     ) {
  //       Transforms.mergeNodes(editor, {
  //         at: endRef.current,
  //         hanging: true,
  //         voids,
  //       })
  //     }

  //     const point = endRef.unref() || startRef.unref()

  //     if (options.at == null && point) {
  //       Transforms.select(editor, point)
  //     }
  //   })
  // },

  // /**
  //  * Insert a fragment at a specific location in the editor.
  //  */

  // insertFragment(
  //   Editor editor,
  //   fragment: Node[],
  //   options: {
  //     Location at,
  //     bool hanging = false,
  //     bool voids = false
  //   } = {}
  // ) {
  //   EditorUtils.withoutNormalizing(editor, () {
  //     const { hanging = false, voids = false } = options
  //     let { at = editor.selection } = options

  //     if (!fragment.length) {
  //       return
  //     }

  //     if (at == null) {
  //       return
  //     } else if (at is Range) {
  //       if (!hanging) {
  //         at = EditorUtils.unhangRange(editor, at)
  //       }

  //       if (RangeUtils.isCollapsed(at)) {
  //         at = at.anchor
  //       } else {
  //         const [, end] = RangeUtils.edges(at)

  //         if (!voids && EditorUtils.matchVoid(editor, { at: end })) {
  //           return
  //         }

  //         const pointRef = EditorUtils.pointRef(editor, end)
  //         Transforms.delete(editor, { at })
  //         at = pointRef.unref()!
  //       }
  //     } else if (Path.isPath(at)) {
  //       at = EditorUtils.start(editor, at)
  //     }

  //     if (!voids && EditorUtils.matchVoid(editor, { at })) {
  //       return
  //     }

  //     // If the insert point is at the edge of an inline node, move it outside
  //     // instead since it will need to be split otherwise.
  //     const inlineElementMatch = EditorUtils.above(editor, {
  //       at,
  //       match: n => EditorUtils.isInline(editor, n),
  //       mode: 'highest',
  //       voids,
  //     })

  //     if (inlineElementMatch) {
  //       const [, inlinePath] = inlineElementMatch

  //       if (EditorUtils.isEnd(editor, at, inlinePath)) {
  //         const after = EditorUtils.after(editor, inlinePath)!
  //         at = after
  //       } else if (EditorUtils.isStart(editor, at, inlinePath)) {
  //         const before = EditorUtils.before(editor, inlinePath)!
  //         at = before
  //       }
  //     }

  //     const blockMatch = EditorUtils.above(editor, {
  //       match: n => EditorUtils.isBlock(editor, n),
  //       at,
  //       voids,
  //     })!
  //     const [, blockPath] = blockMatch
  //     const isBlockStart = EditorUtils.isStart(editor, at, blockPath)
  //     const isBlockEnd = EditorUtils.isEnd(editor, at, blockPath)
  //     const mergeStart = !isBlockStart || (isBlockStart && isBlockEnd)
  //     const mergeEnd = !isBlockEnd
  //     const [, firstPath] = Node.first({ children: fragment }, [])
  //     const [, lastPath] = Node.last({ children: fragment }, [])

  //     const matches: NodeEntry[] = []
  //     const matcher = ([n, p]: NodeEntry) => {
  //       if (
  //         mergeStart &&
  //         Path.isAncestor(p, firstPath) &&
  //         Element.isElement(n) &&
  //         !editor.isVoid(n) &&
  //         !editor.isInline(n)
  //       ) {
  //         return false
  //       }

  //       if (
  //         mergeEnd &&
  //         Path.isAncestor(p, lastPath) &&
  //         Element.isElement(n) &&
  //         !editor.isVoid(n) &&
  //         !editor.isInline(n)
  //       ) {
  //         return false
  //       }

  //       return true
  //     }

  //     for (const entry of Node.nodes(
  //       { children: fragment },
  //       { pass: matcher }
  //     )) {
  //       if (entry[1].length > 0 && matcher(entry)) {
  //         matches.push(entry)
  //       }
  //     }

  //     const starts = []
  //     const middles = []
  //     const ends = []
  //     let starting = true
  //     let hasBlocks = false

  //     for (const [node] of matches) {
  //       if (Element.isElement(node) && !editor.isInline(node)) {
  //         starting = false
  //         hasBlocks = true
  //         middles.push(node)
  //       } else if (starting) {
  //         starts.push(node)
  //       } else {
  //         ends.push(node)
  //       }
  //     }

  //     const [inlineMatch] = EditorUtils.nodes(editor, {
  //       at,
  //       match: (n) { return (n is Text); } || EditorUtils.isInline(editor, n),
  //       mode: 'highest',
  //       voids,
  //     })!

  //     const [, inlinePath] = inlineMatch
  //     const isInlineStart = EditorUtils.isStart(editor, at, inlinePath)
  //     const isInlineEnd = EditorUtils.isEnd(editor, at, inlinePath)

  //     const middleRef = EditorUtils.pathRef(
  //       editor,
  //       isBlockEnd ? Path.next(blockPath) : blockPath
  //     )

  //     const endRef = EditorUtils.pathRef(
  //       editor,
  //       isInlineEnd ? Path.next(inlinePath) : inlinePath
  //     )

  //     Transforms.splitNodes(editor, {
  //       at,
  //       match: n =>
  //         hasBlocks
  //           ? EditorUtils.isBlock(editor, n)
  //           : (n is Text) || EditorUtils.isInline(editor, n),
  //       mode: hasBlocks ? 'lowest' : 'highest',
  //       voids,
  //     })

  //     const startRef = EditorUtils.pathRef(
  //       editor,
  //       !isInlineStart || (isInlineStart && isInlineEnd)
  //         ? Path.next(inlinePath)
  //         : inlinePath
  //     )

  //     Transforms.insertNodes(editor, starts, {
  //       at: startRef.current!,
  //       match: (n) { return (n is Text); } || EditorUtils.isInline(editor, n),
  //       mode: 'highest',
  //       voids,
  //     })

  //     Transforms.insertNodes(editor, middles, {
  //       at: middleRef.current!,
  //       match: n => EditorUtils.isBlock(editor, n),
  //       mode: 'lowest',
  //       voids,
  //     })

  //     Transforms.insertNodes(editor, ends, {
  //       at: endRef.current!,
  //       match: (n) { return (n is Text); } || EditorUtils.isInline(editor, n),
  //       mode: 'highest',
  //       voids,
  //     })

  //     if (!options.at) {
  //       let path

  //       if (ends.length > 0) {
  //         path = Path.previous(endRef.current!)
  //       } else if (middles.length > 0) {
  //         path = Path.previous(middleRef.current!)
  //       } else {
  //         path = Path.previous(startRef.current!)
  //       }

  //       const end = EditorUtils.end(editor, path)
  //       Transforms.select(editor, end)
  //     }

  //     startRef.unref()
  //     middleRef.unref()
  //     endRef.unref()
  //   })
  // },

  // /**
  //  * Insert a string of text in the Editor.
  //  */

  // insertText(
  //   Editor editor,
  //   text: string,
  //   options: {
  //     Location at,
  //     bool voids = false
  //   } = {}
  // ) {
  //   EditorUtils.withoutNormalizing(editor, () {
  //     const { voids = false } = options
  //     let { at = editor.selection } = options

  //     if (at == null) {
  //       return
  //     }

  //     if (Path.isPath(at)) {
  //       at = EditorUtils.range(editor, at)
  //     }

  //     if (at is Range) {
  //       if (RangeUtils.isCollapsed(at)) {
  //         at = at.anchor
  //       } else {
  //         const end = RangeUtils.end(at)

  //         if (!voids && EditorUtils.matchVoid(editor, { at: end })) {
  //           return
  //         }

  //         const pointRef = EditorUtils.pointRef(editor, end)
  //         Transforms.delete(editor, { at, voids })
  //         at = pointRef.unref()!
  //         Transforms.setSelection(editor, { anchor: at, focus: at })
  //       }
  //     }

  //     if (!voids && EditorUtils.matchVoid(editor, { at })) {
  //       return
  //     }

  //     const { path, offset } = at
  //     editor.apply({ type: 'insert_text', path, offset, text })
  //   })
  // },
}

// /// Convert a range into a point by deleting it's content.
// Point Function(Editor editor, Range range) deleteRange = (Editor editor, Range range)  {
//   if (RangeUtils.isCollapsed(range)) {
//     return range.anchor;
//   } else {
//     const [, end] = RangeUtils.edges(range)
//     const pointRef = EditorUtils.pointRef(editor, end)
//     Transforms.delete(editor, { at: range })
//     return pointRef.unref();
//   }
// }

// (bool Function(Node node)) Function(Editor editor, Path path) matchPath = (Editor editor, Path path) {
//   const [node] = EditorUtils.node(editor, path)
//   return n => n == node
// }
