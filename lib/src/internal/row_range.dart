import 'package:meta/meta.dart';

@internal
class RowRange {
  static int maxVisibleRowsLength(
      {required double scrollOffset,
      required double height,
      required double rowHeight}) {
    RowRange? rowRange = RowRange.build(
        scrollOffset: scrollOffset, height: height, rowHeight: rowHeight);
    return rowRange != null ? rowRange.length : 0;
  }

  static RowRange? build(
      {required double scrollOffset,
      required double height,
      required double rowHeight}) {
    if (height == 0) {
      return null;
    }
    final int firstIndex = (scrollOffset / rowHeight).floor();
    final double firstRowRemainingHeight =
        rowHeight - (scrollOffset - (firstIndex * rowHeight));
    final double availableHeight = height - firstRowRemainingHeight;
    final int remainingRows = (availableHeight / rowHeight).ceil();
    return RowRange._(
        firstIndex: firstIndex,
        lastIndex: firstIndex + remainingRows,
        length: remainingRows + 1);
  }

  RowRange._(
      {required this.firstIndex,
      required this.lastIndex,
      required this.length});

  final int firstIndex;
  final int lastIndex;
  final int length;
}
