import 'package:easy_table/src/experimental/scroll_offsets.dart';
import 'package:flutter/widgets.dart';

class TableScrollControllers {
  TableScrollControllers(
      {required ScrollController? unpinnedHorizontal,
      required ScrollController? leftPinnedHorizontal,
      required ScrollController? vertical})
      : _leftPinnedContentArea = leftPinnedHorizontal ?? ScrollController(),
        _unpinnedContentArea = unpinnedHorizontal ?? ScrollController(),
        _vertical = vertical ?? ScrollController();

  ScrollController _leftPinnedContentArea;
  ScrollController _unpinnedContentArea;
  ScrollController _vertical;

  void setLeftPinnedScrollController(
      {required ScrollController scrollController,
      required VoidCallback listener}) {
    _leftPinnedContentArea.dispose();
    _leftPinnedContentArea = scrollController;
    _leftPinnedContentArea.addListener(listener);
  }

  void setUnpinnedScrollController(
      {required ScrollController scrollController,
      required VoidCallback listener}) {
    _unpinnedContentArea.dispose();
    _unpinnedContentArea = scrollController;
    _unpinnedContentArea.addListener(listener);
  }

  void setVerticalScrollController(
      {required ScrollController scrollController,
      required VoidCallback listener}) {
    _vertical.dispose();
    _vertical = scrollController;
    _vertical.addListener(listener);
  }

  ScrollController get vertical => _vertical;
  ScrollController get unpinnedContentArea => _unpinnedContentArea;
  ScrollController get leftPinnedContentArea => _leftPinnedContentArea;

  double get leftPinnedContentAreaOffset {
    return _leftPinnedContentArea.hasClients
        ? _leftPinnedContentArea.offset
        : 0;
  }

  double get unpinnedContentAreaOffset {
    return _unpinnedContentArea.hasClients ? _unpinnedContentArea.offset : 0;
  }

  double get verticalOffset {
    return _vertical.hasClients ? _vertical.offset : 0;
  }

  double get verticalViewportDimension {
    return _vertical.hasClients ? _vertical.position.viewportDimension : 0;
  }

  TableScrollOffsets get offsets => TableScrollOffsets(
      leftPinnedContentArea: leftPinnedContentAreaOffset,
      unpinnedContentArea: unpinnedContentAreaOffset,
      rightPinnedContentArea: 0,
      vertical: verticalOffset);

  void addListener(VoidCallback listener) {
    _leftPinnedContentArea.addListener(listener);
    _unpinnedContentArea.addListener(listener);
    _vertical.addListener(listener);
  }

  void dispose() {
    _leftPinnedContentArea.dispose();
    _unpinnedContentArea.dispose();
    _vertical.dispose();
  }
}
