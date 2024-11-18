import 'dart:math' as math;
import 'package:davi/src/internal/row_range.dart';
import 'package:meta/meta.dart';

@internal
class LayoutUtils {

  static int maxVisibleRowsLength(
      {required double scrollOffset,
      required double visibleAreaHeight,
      required double rowHeight}) {
    RowRange? rowRange = RowRange.build(
        scrollOffset: scrollOffset,
        visibleAreaHeight: visibleAreaHeight,
        rowHeight: rowHeight);
    return rowRange != null ? rowRange.length : 0;
  }

  static int maxRowsLength(
      { required double visibleAreaHeight,
        required double rowHeight}) {
    return (visibleAreaHeight/rowHeight).ceil()+1;
  }
}
