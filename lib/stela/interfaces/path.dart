/// `Path` arrays are a list of indexes that describe a node's exact position in
/// a Slate node tree. Although they are usually relative to the root `Editor`
/// object, they can be relative to any `Node` object.
class Path {
  Path([this.path]);

  List<int> path = [];

  get length {
    return path.length;
  }

  int at(int index) {
    return path[index];
  }

  void operator []=(int index, int value) {
    path[index] = value;
  }

  int operator [](int index) => path[index];
}
