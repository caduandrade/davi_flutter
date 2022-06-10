import 'dart:math' as math;
import 'package:easy_table/src/theme/theme_data.dart';

class TableLayoutSettings {
  TableLayoutSettings(
      {required EasyTableThemeData theme,
      required this.cellContentHeight,
      required this.visibleRowsCount,
      required this.hasHeader,
      required this.hasVerticalScrollbar,
      required this.columnsFit,
      required this.verticalScrollbarOffset}) {
    rowHeight = cellContentHeight +
        ((theme.cell.padding != null) ? theme.cell.padding!.vertical : 0);
    scrollbarSize = theme.scrollbar.margin * 2 + theme.scrollbar.thickness;
    headerHeight = theme.header.bottomBorderHeight + theme.headerCell.height;
  }

  final double cellContentHeight;
  final int? visibleRowsCount;
  final bool hasHeader;
  final bool hasVerticalScrollbar;
  final bool columnsFit;
  final double verticalScrollbarOffset;

  /// Cell content and padding.
  late final double rowHeight;
  late final double scrollbarSize;
  late final double headerHeight;

  bool get allowHorizontalScrollbar => !columnsFit;

  double rowsHeight(
      {required int rowsCount, required double rowDividerThickness}) {
    return (rowHeight * rowsCount) +
        (math.max(0, rowsCount - 1) * rowDividerThickness);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TableLayoutSettings &&
          runtimeType == other.runtimeType &&
          cellContentHeight == other.cellContentHeight &&
          visibleRowsCount == other.visibleRowsCount &&
          hasHeader == other.hasHeader &&
          hasVerticalScrollbar == other.hasVerticalScrollbar &&
          columnsFit == other.columnsFit &&
          verticalScrollbarOffset == other.verticalScrollbarOffset &&
          rowHeight == other.rowHeight &&
          scrollbarSize == other.scrollbarSize &&
          headerHeight == other.headerHeight;

  @override
  int get hashCode =>
      cellContentHeight.hashCode ^
      visibleRowsCount.hashCode ^
      hasHeader.hashCode ^
      hasVerticalScrollbar.hashCode ^
      columnsFit.hashCode ^
      verticalScrollbarOffset.hashCode ^
      rowHeight.hashCode ^
      scrollbarSize.hashCode ^
      headerHeight.hashCode;
}
