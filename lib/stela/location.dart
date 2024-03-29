import 'package:inday/stela/path.dart';

/// The `Location` interface is a union of the ways to refer to a specific
/// location in a Slate document: paths, points or ranges.
///
/// Methods will often accept a `Location` instead of requiring only a `Path`,
/// `Point` or `Range`. This eliminates the need for developers to manage
/// converting between the different interfaces in their own code base.
class Location {
  Location({this.props});

  /// Custom properties that can extend the `Node` behavior
  Map<String, dynamic> props;
}

/// The `Span` interface is a low-level way to refer to locations in nodes
/// without using `Point` which requires leaf text nodes to be present.
class Span implements Location {
  Span(this.path0, this.path1, {this.props});

  final Path path0;
  final Path path1;

  /// Custom properties that can extend the `Location` behavior
  Map<String, dynamic> props;
}
