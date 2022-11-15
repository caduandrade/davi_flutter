import 'package:easy_table/src/internal/scroll_controller.dart';
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
      : unpinnedHorizontal = unpinnedHorizontal ?? EasyTableScrollController(),
        leftPinnedHorizontal =
            leftPinnedHorizontal ?? EasyTableScrollController(),
        vertical = vertical ?? EasyTableScrollController();

  void dispose() {
    unpinnedHorizontal.dispose();
    leftPinnedHorizontal.dispose();
    vertical.dispose();
  }
}
