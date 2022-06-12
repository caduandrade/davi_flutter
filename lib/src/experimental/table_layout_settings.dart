import 'dart:math' as math;
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/rendering.dart';

class TableLayoutSettingsBuilder {
  factory TableLayoutSettingsBuilder(
      {required EasyTableThemeData theme,
      required int? visibleRowsCount,
      required double cellContentHeight,
      required bool hasHeader,
      required bool columnsFit,
      required double verticalScrollbarOffset,
      required int rowsLength}) {
    final double cellHeight = cellContentHeight +
        ((theme.cell.padding != null) ? theme.cell.padding!.vertical : 0);
    final double rowHeight = cellHeight + theme.row.dividerThickness;
    final double scrollbarSize =
        theme.scrollbar.margin * 2 + theme.scrollbar.thickness;
    final double headerCellHeight = theme.headerCell.height;
    final bool horizontalOnlyWhenNeeded =
        theme.scrollbar.horizontalOnlyWhenNeeded;
    final double headerHeight =
        hasHeader ? theme.header.bottomBorderHeight + headerCellHeight : 0;
    final double contentFullHeight = (rowsLength * cellHeight) +
        (math.max(0, rowsLength - 1) * theme.row.dividerThickness);
    return TableLayoutSettingsBuilder._(
        headerHeight: headerHeight,
        cellContentHeight: cellContentHeight,
        visibleRowsCount: visibleRowsCount,
        hasHeader: hasHeader,
        columnsFit: columnsFit,
        verticalScrollbarOffset: verticalScrollbarOffset,
        cellHeight: cellHeight,
        rowHeight: rowHeight,
        scrollbarSize: scrollbarSize,
        headerCellHeight: headerCellHeight,
        contentFullHeight: contentFullHeight,
        horizontalOnlyWhenNeeded: horizontalOnlyWhenNeeded);
  }

  TableLayoutSettingsBuilder._(
      {required this.headerHeight,
      required this.cellContentHeight,
      required this.visibleRowsCount,
      required this.hasHeader,
      required this.columnsFit,
      required this.verticalScrollbarOffset,
      required this.cellHeight,
      required this.rowHeight,
      required this.scrollbarSize,
      required this.headerCellHeight,
      required this.contentFullHeight,
      required this.horizontalOnlyWhenNeeded});

  /// Including cell height and bottom border
  final double headerHeight;

  final double cellContentHeight;
  final int? visibleRowsCount;
  final bool hasHeader;
  final bool columnsFit;
  final double verticalScrollbarOffset;

  /// Cell content and padding.
  final double cellHeight;

  /// Cell height and divider thickness
  final double rowHeight;
  final double scrollbarSize;

  final double headerCellHeight;

  /// Height from all rows (including scrollable viewport hidden ones).
  final double contentFullHeight;

  final bool horizontalOnlyWhenNeeded;

  TableLayoutSettings build(
      {
      //required Rect headerBounds,
      required Rect contentBounds,
      //required Rect leftPinnedBounds,
      //required Rect unpinnedBounds,
      //required Rect rightPinnedBounds,
      required double height,
      required double scrollbarHeight,
      required bool hasHorizontalScrollbar}) {
    return TableLayoutSettings(
        contentArea: contentBounds,
        // headerBounds: headerBounds,
        //leftPinnedBounds: leftPinnedBounds,
        //unpinnedBounds: unpinnedBounds,
        //rightPinnedBounds: rightPinnedBounds,
        height: height,
        headerHeight: headerHeight,
        cellContentHeight: cellContentHeight,
        visibleRowsCount: visibleRowsCount,
        hasHeader: hasHeader,
        verticalScrollbarOffset: verticalScrollbarOffset,
        cellHeight: cellHeight,
        rowHeight: rowHeight,
        scrollbarWidth: scrollbarSize,
        scrollbarHeight: scrollbarHeight,
        headerCellHeight: headerCellHeight,
        contentFullHeight: contentFullHeight,
        hasHorizontalScrollbar: hasHorizontalScrollbar);
  }
}

class TableLayoutSettings {
  TableLayoutSettings(
      {
      //required this.headerBounds,
      //required this.leftPinnedBounds,
      //required this.unpinnedBounds,
      //required this.rightPinnedBounds,
      required this.contentArea,
      required this.headerHeight,
      required this.cellContentHeight,
      required this.visibleRowsCount,
      required this.hasHeader,
      required this.height,
      required this.verticalScrollbarOffset,
      required this.cellHeight,
      required this.rowHeight,
      required this.scrollbarWidth,
      required this.scrollbarHeight,
      required this.headerCellHeight,
      required this.contentFullHeight,
      required this.hasHorizontalScrollbar});

  final Rect contentArea;
  /*
  /// Including cell height and bottom border
  final Rect headerBounds;
  final Rect leftPinnedBounds;
  final Rect unpinnedBounds;
  final Rect rightPinnedBounds;
*/
  /// Including cell height and bottom border
  final double headerHeight;
  final double cellContentHeight;
  final int? visibleRowsCount;
  final bool hasHeader;
  final double verticalScrollbarOffset;

  /// Cell content and padding.
  final double cellHeight;

  /// Cell height and divider thickness
  final double rowHeight;

  final double headerCellHeight;

  /// Height from all rows (including scrollable viewport hidden ones).
  final double contentFullHeight;

  final bool hasHorizontalScrollbar;

  final double scrollbarWidth;
  final double scrollbarHeight;

  final double height;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TableLayoutSettings &&
          runtimeType == other.runtimeType &&
          contentArea == other.contentArea &&
          headerHeight == other.headerHeight &&
          cellContentHeight == other.cellContentHeight &&
          visibleRowsCount == other.visibleRowsCount &&
          hasHeader == other.hasHeader &&
          verticalScrollbarOffset == other.verticalScrollbarOffset &&
          cellHeight == other.cellHeight &&
          rowHeight == other.rowHeight &&
          headerCellHeight == other.headerCellHeight &&
          contentFullHeight == other.contentFullHeight &&
          hasHorizontalScrollbar == other.hasHorizontalScrollbar &&
          scrollbarWidth == other.scrollbarWidth &&
          height == other.height &&
          scrollbarHeight == other.scrollbarHeight;

  @override
  int get hashCode =>
      contentArea.hashCode ^
      headerHeight.hashCode ^
      cellContentHeight.hashCode ^
      visibleRowsCount.hashCode ^
      hasHeader.hashCode ^
      verticalScrollbarOffset.hashCode ^
      cellHeight.hashCode ^
      rowHeight.hashCode ^
      height.hashCode ^
      headerCellHeight.hashCode ^
      contentFullHeight.hashCode ^
      hasHorizontalScrollbar.hashCode ^
      scrollbarWidth.hashCode ^
      scrollbarHeight.hashCode;
}
