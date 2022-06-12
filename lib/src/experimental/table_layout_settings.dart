import 'dart:math' as math;
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/rendering.dart';

class TableLayoutSettings {
  factory TableLayoutSettings(
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
    final bool needUnpinnedHorizontalScrollbar =
        !theme.scrollbar.horizontalOnlyWhenNeeded;
    final bool needLeftPinnedHorizontalScrollbar =
        needUnpinnedHorizontalScrollbar;
    final Rect headerBounds = Rect.fromLTWH(0, 0, 0,
        hasHeader ? theme.header.bottomBorderHeight + headerCellHeight : 0);

    final double contentFullHeight = (rowsLength * cellHeight) +
        (math.max(0, rowsLength - 1) * theme.row.dividerThickness);

    return TableLayoutSettings._(
        headerBounds: headerBounds,
        contentBounds: Rect.zero,
        leftPinnedBounds: Rect.zero,
        unpinnedBounds: Rect.zero,
        rightPinnedBounds: Rect.zero,
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
        needUnpinnedHorizontalScrollbar: needUnpinnedHorizontalScrollbar,
        needLeftPinnedHorizontalScrollbar: needLeftPinnedHorizontalScrollbar);
  }

  TableLayoutSettings._(
      {required this.headerBounds,
      required this.contentBounds,
      required this.leftPinnedBounds,
      required this.unpinnedBounds,
      required this.rightPinnedBounds,
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
      required bool needUnpinnedHorizontalScrollbar,
      required bool needLeftPinnedHorizontalScrollbar})
      : _needUnpinnedHorizontalScrollbar = needUnpinnedHorizontalScrollbar,
        _needLeftPinnedHorizontalScrollbar = needLeftPinnedHorizontalScrollbar;

  /// Including cell height and bottom border
  final Rect headerBounds;

  final Rect contentBounds;
  final Rect leftPinnedBounds;
  final Rect unpinnedBounds;
  final Rect rightPinnedBounds;

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

  bool _needUnpinnedHorizontalScrollbar;
  bool get needUnpinnedHorizontalScrollbar => _needUnpinnedHorizontalScrollbar;

  bool _needLeftPinnedHorizontalScrollbar;
  bool get needLeftPinnedHorizontalScrollbar =>
      _needLeftPinnedHorizontalScrollbar;

  void updatesHorizontalScrollbarsNeeds(
      {required bool needLeftPinnedHorizontalScrollbar,
      required bool needUnpinnedHorizontalScrollbar}) {
    _needLeftPinnedHorizontalScrollbar = needLeftPinnedHorizontalScrollbar;
    _needUnpinnedHorizontalScrollbar = needUnpinnedHorizontalScrollbar;
  }

  bool get allowHorizontalScrollbar => !columnsFit;

  bool get hasHorizontalScrollbar =>
      allowHorizontalScrollbar &&
      (needUnpinnedHorizontalScrollbar || needLeftPinnedHorizontalScrollbar);

  double get scrollbarWidth => scrollbarSize;
  double get scrollbarHeight => hasHorizontalScrollbar ? scrollbarSize : 0;
}
