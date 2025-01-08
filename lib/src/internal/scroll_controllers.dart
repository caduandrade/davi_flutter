import 'package:davi/davi.dart';
import 'package:davi/src/internal/scroll_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

@internal
class ScrollControllers {
  ScrollControllers(
      {required ScrollController? unpinnedHorizontal,
      required ScrollController? leftPinnedHorizontal,
      required ScrollController? vertical})
      : _unpinnedHorizontal = unpinnedHorizontal ?? DaviScrollController(),
        _leftPinnedHorizontal = leftPinnedHorizontal ?? DaviScrollController(),
        _vertical = vertical ?? DaviScrollController();

  ScrollController _unpinnedHorizontal;

  ScrollController get unpinnedHorizontal => _unpinnedHorizontal;

  ScrollController _leftPinnedHorizontal;

  ScrollController get leftPinnedHorizontal => _leftPinnedHorizontal;

  ScrollController _vertical;

  ScrollController get vertical => _vertical;

  ScrollController getHorizontalController(PinStatus pinStatus) {
    if (pinStatus == PinStatus.none) {
      return unpinnedHorizontal;
    } else if (pinStatus == PinStatus.left) {
      return leftPinnedHorizontal;
    }
    throw ArgumentError('Unknown pin status: ${pinStatus.name}');
  }

  double getOffset(PinStatus pinStatus) {
    if (pinStatus == PinStatus.none) {
      return unpinnedHorizontal.hasClients ? unpinnedHorizontal.offset : 0;
    } else if (pinStatus == PinStatus.left) {
      return leftPinnedHorizontal.hasClients ? leftPinnedHorizontal.offset : 0;
    }
    throw ArgumentError('Unknown pin status: ${pinStatus.name}');
  }

  bool update(
      {required ScrollController? unpinnedHorizontal,
      required ScrollController? leftPinnedHorizontal,
      required ScrollController? vertical}) {
    bool updated = false;

    if (unpinnedHorizontal != null &&
        _unpinnedHorizontal != unpinnedHorizontal) {
      _unpinnedHorizontal = unpinnedHorizontal;
      updated = true;
    }

    if (leftPinnedHorizontal != null &&
        _leftPinnedHorizontal != leftPinnedHorizontal) {
      _leftPinnedHorizontal = leftPinnedHorizontal;
      updated = true;
    }

    if (vertical != null && _vertical != vertical) {
      _vertical = vertical;
      updated = true;
    }

    return updated;
  }
}
