import 'package:easy_table/src/internal/row_range.dart';
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
}
