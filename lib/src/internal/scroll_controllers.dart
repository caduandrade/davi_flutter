import 'package:davi/src/internal/scroll_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

@internal
class ScrollControllers {
  ScrollController unpinnedHorizontal;
  ScrollController leftPinnedHorizontal;
  ScrollController vertical;

  ScrollControllers(
      {required ScrollController? unpinnedHorizontal,
      required ScrollController? leftPinnedHorizontal,
      required ScrollController? vertical})
      : unpinnedHorizontal = unpinnedHorizontal ?? DaviScrollController(),
        leftPinnedHorizontal = leftPinnedHorizontal ?? DaviScrollController(),
        vertical = vertical ?? DaviScrollController();
}
