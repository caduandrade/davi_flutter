import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

@internal
class EasyTableScrollController extends ScrollController {

  @override
  ScrollPosition createScrollPosition(ScrollPhysics physics,
      ScrollContext context, ScrollPosition? oldPosition) {
    return EasyTableScrollPosition(
      physics: physics,
      context: context,
      initialPixels: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
      oldPosition: oldPosition,
      debugLabel: debugLabel,
    );
  }
}

class EasyTableScrollPosition extends ScrollPositionWithSingleContext {
  EasyTableScrollPosition({
    required ScrollPhysics physics,
    required ScrollContext context,
    double? initialPixels = 0.0,
    bool keepScrollOffset = true,
    ScrollPosition? oldPosition,
    String? debugLabel,
  }) : super(
            physics: physics,
            context: context,
            initialPixels: initialPixels,
            keepScrollOffset: keepScrollOffset,
            oldPosition: oldPosition);

  @override
  double get pixels => super.pixels.floorToDouble();
}
