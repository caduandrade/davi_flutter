import 'package:meta/meta.dart';

@internal
class RowRange {
  static RowRange? build(
      {required double scrollOffset,
      required double visibleAreaHeight,
      required double rowHeight}) {
    if (visibleAreaHeight <= 0) {
      return null;
    }

    final int firstIndex = (scrollOffset / rowHeight).floor();
    final double firstRowRemainingHeight =
        rowHeight - (scrollOffset - (firstIndex * rowHeight));
    final double availableHeight = visibleAreaHeight - firstRowRemainingHeight;
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
