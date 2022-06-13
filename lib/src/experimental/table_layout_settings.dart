import 'dart:math' as math;
import 'package:easy_table/src/experimental/columns_metrics_exp.dart';
import 'package:easy_table/src/experimental/scroll_offsets.dart';
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/rendering.dart';

class TableLayoutSettingsBuilder {
  factory TableLayoutSettingsBuilder(
      {required EasyTableThemeData theme,
      required int? visibleRowsCount,
      required double cellContentHeight,
      required bool hasHeader,
      required bool columnsFit,
      required TableScrollOffsets offsets,
      required int rowsLength}) {
    final double cellHeight = cellContentHeight +
        ((theme.cell.padding != null) ? theme.cell.padding!.vertical : 0);
    final double rowHeight = cellHeight + theme.row.dividerThickness;
    final double scrollbarSize =
        theme.scrollbar.margin * 2 + theme.scrollbar.thickness;
    final double headerHeight = hasHeader
        ? theme.header.bottomBorderHeight + theme.headerCell.height
        : 0;
    final double rowsFullHeight = (rowsLength * cellHeight) +
        (math.max(0, rowsLength - 1) * theme.row.dividerThickness);
    return TableLayoutSettingsBuilder._(
        headerHeight: headerHeight,
        cellContentHeight: cellContentHeight,
        visibleRowsCount: visibleRowsCount,
        hasHeader: hasHeader,
        columnsFit: columnsFit,
        offsets: offsets,
        cellHeight: cellHeight,
        rowHeight: rowHeight,
        scrollbarSize: scrollbarSize,
        rowsFullHeight: rowsFullHeight);
  }

  TableLayoutSettingsBuilder._(
      {required this.headerHeight,
      required this.cellContentHeight,
      required this.visibleRowsCount,
      required this.hasHeader,
      required this.columnsFit,
      required this.offsets,
      required this.cellHeight,
      required this.rowHeight,
      required this.scrollbarSize,
      required this.rowsFullHeight});

  /// Including cell height and bottom border
  final double headerHeight;

  final double cellContentHeight;
  final int? visibleRowsCount;
  final bool hasHeader;
  final bool columnsFit;
  final TableScrollOffsets offsets;

  /// Cell content and padding.
  final double cellHeight;

  /// Cell height and divider thickness
  final double rowHeight;
  final double scrollbarSize;

  /// Height from all rows (including scrollable viewport hidden ones).
  final double rowsFullHeight;

  TableLayoutSettings build(
      {required Rect cellsBound,
      required ColumnsMetricsExp leftPinnedColumnsMetrics,
      required final ColumnsMetricsExp unpinnedColumnsMetrics,
      required final ColumnsMetricsExp rightPinnedColumnsMetrics,
      required double height,
      required double scrollbarHeight,
      required bool hasHorizontalScrollbar}) {
    final Rect headerBounds =
        Rect.fromLTWH(0, 0, cellsBound.width, headerHeight);
    final Rect leftPinnedBounds = Rect.fromLTWH(0, 0,
        math.min(leftPinnedColumnsMetrics.maxWidth, cellsBound.width), height);
    final Rect unpinnedBounds = Rect.fromLTWH(leftPinnedBounds.right, 0,
        math.max(0, cellsBound.width - leftPinnedBounds.width), height);
    //TODO need right width
    final Rect rightPinnedBounds = Rect.fromLTWH(
        unpinnedBounds.right, 0, rightPinnedColumnsMetrics.maxWidth, height);

    return TableLayoutSettings(
        cellsBound: cellsBound,
        headerBounds: headerBounds,
        leftPinnedBounds: leftPinnedBounds,
        unpinnedBounds: unpinnedBounds,
        rightPinnedBounds: rightPinnedBounds,
        height: height,
        headerHeight: headerHeight,
        cellContentHeight: cellContentHeight,
        visibleRowsCount: visibleRowsCount,
        hasHeader: hasHeader,
        offsets: offsets,
        cellHeight: cellHeight,
        rowHeight: rowHeight,
        scrollbarWidth: scrollbarSize,
        scrollbarHeight: scrollbarHeight,
        cellsFullHeight: rowsFullHeight,
        hasHorizontalScrollbar: hasHorizontalScrollbar);
  }
}

class TableLayoutSettings {
  TableLayoutSettings(
      {required this.headerBounds,
      required this.leftPinnedBounds,
      required this.unpinnedBounds,
      required this.rightPinnedBounds,
      required this.cellsBound,
      required this.headerHeight,
      required this.cellContentHeight,
      required this.visibleRowsCount,
      required this.hasHeader,
      required this.height,
      required this.offsets,
      required this.cellHeight,
      required this.rowHeight,
      required this.scrollbarWidth,
      required this.scrollbarHeight,
      required this.cellsFullHeight,
      required this.hasHorizontalScrollbar});

  final Rect headerBounds;

  final Rect cellsBound;

  /// Including cell height and bottom border
  //final Rect headerBounds;

  final Rect leftPinnedBounds;
  final Rect unpinnedBounds;
  final Rect rightPinnedBounds;

  /// Including cell height and bottom border
  final double headerHeight;
  final double cellContentHeight;
  final int? visibleRowsCount;
  final bool hasHeader;
  final TableScrollOffsets offsets;

  /// Cell content and padding.
  final double cellHeight;

  /// Cell height and divider thickness
  final double rowHeight;

  /// Height from all rows, including scrollable viewport hidden ones
  /// (cell + divider).
  final double cellsFullHeight;

  final bool hasHorizontalScrollbar;

  final double scrollbarWidth;
  final double scrollbarHeight;

  final double height;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TableLayoutSettings &&
          runtimeType == other.runtimeType &&
          headerBounds == other.headerBounds &&
          cellsBound == other.cellsBound &&
          leftPinnedBounds == other.leftPinnedBounds &&
          unpinnedBounds == other.unpinnedBounds &&
          rightPinnedBounds == other.rightPinnedBounds &&
          headerHeight == other.headerHeight &&
          cellContentHeight == other.cellContentHeight &&
          visibleRowsCount == other.visibleRowsCount &&
          hasHeader == other.hasHeader &&
          offsets == other.offsets &&
          cellHeight == other.cellHeight &&
          rowHeight == other.rowHeight &&
          cellsFullHeight == other.cellsFullHeight &&
          hasHorizontalScrollbar == other.hasHorizontalScrollbar &&
          scrollbarWidth == other.scrollbarWidth &&
          scrollbarHeight == other.scrollbarHeight &&
          height == other.height;

  @override
  int get hashCode =>
      headerBounds.hashCode ^
      cellsBound.hashCode ^
      leftPinnedBounds.hashCode ^
      unpinnedBounds.hashCode ^
      rightPinnedBounds.hashCode ^
      headerHeight.hashCode ^
      cellContentHeight.hashCode ^
      visibleRowsCount.hashCode ^
      hasHeader.hashCode ^
      offsets.hashCode ^
      cellHeight.hashCode ^
      rowHeight.hashCode ^
      cellsFullHeight.hashCode ^
      hasHorizontalScrollbar.hashCode ^
      scrollbarWidth.hashCode ^
      scrollbarHeight.hashCode ^
      height.hashCode;
}
