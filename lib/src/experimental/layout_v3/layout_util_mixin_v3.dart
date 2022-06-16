import 'dart:math' as math;
import 'package:easy_table/src/experimental/layout_v3/index_range_v3.dart';

mixin LayoutUtilMixinV3 {
  int visibleRowsLength(
      {required double availableHeight,
      required double rowHeight}) {
    return (availableHeight / rowHeight).ceil();
  }

  double rowY({required double verticalOffset, required int rowIndex, required double rowHeight}){
    return (rowIndex*rowHeight)-verticalOffset;
  }

  int firstRowIndex2(
      {required double verticalOffset,
        required double rowHeight,
        required int visibleRowsLength}) {
    return (verticalOffset / rowHeight).floor();
  }

  IndexRangeV3 indexRange(
      {required double verticalOffset,
      required double rowHeight,
      required int visibleRowsLength}) {
    final first = (verticalOffset / rowHeight).floor();
    return IndexRangeV3(
        first: first, last: first + math.max(0, visibleRowsLength - 1));
  }
}
