import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

@internal
class DaviScrollController extends ScrollController {
  @override
  ScrollPosition createScrollPosition(ScrollPhysics physics,
      ScrollContext context, ScrollPosition? oldPosition) {
    return DaviScrollPosition(
      physics: physics,
      context: context,
      initialPixels: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
      oldPosition: oldPosition,
      debugLabel: debugLabel,
    );
  }
}

class DaviScrollPosition extends ScrollPositionWithSingleContext {
  DaviScrollPosition({
    required super.physics,
    required super.context,
    super.initialPixels,
    super.keepScrollOffset,
    super.oldPosition,
    String? debugLabel,
  });

  @override
  double get pixels => super.pixels.floorToDouble();
}
