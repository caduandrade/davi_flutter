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
    cellHeight = cellContentHeight +
        ((theme.cell.padding != null) ? theme.cell.padding!.vertical : 0);
    rowHeight = cellHeight + theme.row.dividerThickness;
    scrollbarSize = theme.scrollbar.margin * 2 + theme.scrollbar.thickness;
    headerHeight = hasHeader
        ? theme.header.bottomBorderHeight + theme.headerCell.height
        : 0;
    needHorizontalScrollbar = !theme.scrollbar.horizontalOnlyWhenNeeded;
  }

  final double cellContentHeight;
  final int? visibleRowsCount;
  final bool hasHeader;
  final bool hasVerticalScrollbar;
  final bool columnsFit;
  final double verticalScrollbarOffset;

  /// Cell content and padding.
  late final double cellHeight;

  /// Cell height and divider thickness
  late final double rowHeight;
  late final double scrollbarSize;

  /// Cell height and bottom border
  late final double headerHeight;

  int firstRowIndex = 0;
  double contentHeight = 0;
  late bool needHorizontalScrollbar;

  bool get allowHorizontalScrollbar => !columnsFit;

  bool get hasHorizontalScrollbar =>
      allowHorizontalScrollbar && needHorizontalScrollbar;

  double get scrollbarWidth => scrollbarSize;
  double get scrollbarHeight => hasHorizontalScrollbar ? scrollbarSize : 0;

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
          cellHeight == other.cellHeight &&
          rowHeight == other.rowHeight &&
          scrollbarSize == other.scrollbarSize &&
          headerHeight == other.headerHeight &&
          firstRowIndex == other.firstRowIndex &&
          contentHeight == other.contentHeight &&
          needHorizontalScrollbar == other.needHorizontalScrollbar;

  @override
  int get hashCode =>
      cellContentHeight.hashCode ^
      visibleRowsCount.hashCode ^
      hasHeader.hashCode ^
      hasVerticalScrollbar.hashCode ^
      columnsFit.hashCode ^
      verticalScrollbarOffset.hashCode ^
      cellHeight.hashCode ^
      rowHeight.hashCode ^
      scrollbarSize.hashCode ^
      headerHeight.hashCode ^
      firstRowIndex.hashCode ^
      contentHeight.hashCode ^
      needHorizontalScrollbar.hashCode;
}
