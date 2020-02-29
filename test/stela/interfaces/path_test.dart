import 'package:flutter_test/flutter_test.dart';
import 'package:inday/stela/interfaces/path.dart';

void main() {
  group("ancestors", () {
    test(
        'should return valid list of paths from deepest to shallowest ancestor, excluding itself',
        () {
      Path path = Path([0, 1, 2]);
      List<Path> paths = Path.ancestors(path);

      expect(paths[0].equals(Path([])), true);
      expect(paths[1].equals(Path([0])), true);
      expect(paths[2].equals(Path([0, 1])), true);
    });

    test(
        'should return valid list of paths from shallowest to deepest ancestor when given reverse option, excluding itself',
        () {
      Path path = Path([0, 1, 2]);
      List<Path> paths = Path.ancestors(path, reverse: true);

      expect(paths[0].equals(Path([0, 1])), true);
      expect(paths[1].equals(Path([0])), true);
      expect(paths[2].equals(Path([])), true);
    });
  });

  group("levels", () {
    test(
        'should return valid list of paths from shallowest to deepest, including itself',
        () {
      Path path = Path([0, 1, 2]);
      List<Path> paths = Path.levels(path);

      expect(paths[0].equals(Path([])), true);
      expect(paths[1].equals(Path([0])), true);
      expect(paths[2].equals(Path([0, 1])), true);
      expect(paths[3].equals(Path([0, 1, 2])), true);
    });

    test(
        'should return valid list of paths from deepest to shallowest when given reverse option, including itself',
        () {
      Path path = Path([0, 1, 2]);
      List<Path> paths = Path.levels(path, reverse: true);

      expect(paths[0].equals(Path([0, 1, 2])), true);
      expect(paths[1].equals(Path([0, 1])), true);
      expect(paths[2].equals(Path([0])), true);
      expect(paths[3].equals(Path([])), true);
    });
  });
}
