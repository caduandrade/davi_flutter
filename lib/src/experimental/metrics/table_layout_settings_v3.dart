import 'dart:math' as math;

import 'package:easy_table/src/experimental/metrics/column_metrics_v3.dart';
import 'package:easy_table/src/experimental/pin_status.dart';
import 'package:easy_table/src/model.dart';
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:collection/collection.dart';

@internal
class TableLayoutSettingsV3<ROW> {
  factory TableLayoutSettingsV3(
      {required EasyTableModel<ROW>? model,
      required BoxConstraints constraints,
      required bool columnsFit,
      required double cellContentHeight,
      required int? visibleRowsLength,
      required double verticalOffset,
      required EasyTableThemeData theme}) {
    if (!constraints.hasBoundedWidth) {
      throw FlutterError('EasyTable was given unbounded width.');
    }
    if (!constraints.hasBoundedHeight && visibleRowsLength == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('EasyTable was given unbounded height.'),
        ErrorDescription(
            'EasyTable already is scrollable in the vertical axis.'),
        ErrorHint(
          'Consider using the "visibleRowsCount" property to limit the height'
          ' or use it in another Widget like Expanded or SliverFillRemaining.',
        ),
      ]);
    }

    // Fixed values defined by theme.
    final bool hasHeader = theme.header.visible;
    final double cellHeight = cellContentHeight +
        ((theme.cell.padding != null) ? theme.cell.padding!.vertical : 0);
    final double rowHeight = cellHeight + theme.row.dividerThickness;
    final double headerHeight =
        theme.headerCell.height + theme.header.bottomBorderHeight;
    final double scrollbarWidth =
        theme.scrollbar.borderThickness + theme.scrollbar.thickness;
    final double scrollbarHeight =
        theme.scrollbar.borderThickness + theme.scrollbar.thickness;
    final double columnDividerThickness = theme.columnDividerThickness;
    final double rowDividerThickness = theme.row.dividerThickness;

    // Now let's find out the dynamic values given the constraints!!!
    // I'm so excited!!!

    final double height;

    // This will hold all columns metrics (width and offset)
    final List<ColumnMetricsV3<ROW>> columnsMetrics;

    double leftPinnedContentWidth = 0;
    double unpinnedContentWidth = 0;
    double rightPinnedContentWidth = 0;

    // The maximum number of rows that can be visible at the available height.
    int maxVisibleRowsLength = visibleRowsLength ?? 0;

    // It is not possible to identify the need for a vertical and horizontal
    // scrollbar at the same time. Let's try the vertical first considering
    // the possibility that the horizontal might not be visible initially.
    // Its condition may change if horizontal is required.
    bool hasHorizontalScrollbar = !theme.scrollbar.horizontalOnlyWhenNeeded;
    if (constraints.hasBoundedHeight) {
      final double availableHeight = math.max(
          0,
          constraints.maxHeight -
              (hasHeader ? headerHeight : 0) -
              (hasHorizontalScrollbar ? scrollbarHeight : 0));
      final double start = verticalOffset / rowHeight;
      maxVisibleRowsLength =
          (start + (availableHeight / rowHeight)).ceil() - start.floor();
    }
    bool needVerticalScrollbar =
        model != null ? maxVisibleRowsLength < model.visibleRowsLength : false;
    bool hasVerticalScrollbar =
        !theme.scrollbar.verticalOnlyWhenNeeded || needVerticalScrollbar;

    if (model != null) {
      if (columnsFit) {
        unpinnedContentWidth = math.max(0,
            constraints.maxWidth - (hasVerticalScrollbar ? scrollbarWidth : 0));
        columnsMetrics = UnmodifiableListView<ColumnMetricsV3<ROW>>(
            ColumnMetricsV3.columnsFit<ROW>(
                model: model,
                dividerThickness: columnDividerThickness,
                maxWidth: unpinnedContentWidth));
        hasHorizontalScrollbar = false;
      } else {
        // resizable columns
        columnsMetrics = UnmodifiableListView<ColumnMetricsV3<ROW>>(
            ColumnMetricsV3.resizable<ROW>(
                model: model, dividerThickness: columnDividerThickness));

        for (ColumnMetricsV3<ROW> columnMetrics in columnsMetrics) {
          if (columnMetrics.pinStatus == PinStatus.unpinned) {
            unpinnedContentWidth = columnMetrics.offset + columnMetrics.width;
          } else if (columnMetrics.pinStatus == PinStatus.leftPinned) {
            leftPinnedContentWidth = columnMetrics.offset + columnMetrics.width;
          } else if (columnMetrics.pinStatus == PinStatus.rightPinned) {
            rightPinnedContentWidth =
                columnMetrics.offset + columnMetrics.width;
          }
        }
        unpinnedContentWidth = math.max(
            0,
            unpinnedContentWidth -
                leftPinnedContentWidth -
                (leftPinnedContentWidth > 0 ? columnDividerThickness : 0));

        final double maxContentAreaWidth = math.max(0,
            constraints.maxWidth - (hasVerticalScrollbar ? scrollbarWidth : 0));

        final bool needLeftPinnedHorizontalScrollbar =
            leftPinnedContentWidth > maxContentAreaWidth;

        final bool needUnpinnedHorizontalScrollbar = unpinnedContentWidth >
            maxContentAreaWidth -
                leftPinnedContentWidth -
                (leftPinnedContentWidth > 0 ? columnDividerThickness : 0);

        final bool needHorizontalScrollbar = needUnpinnedHorizontalScrollbar ||
            needLeftPinnedHorizontalScrollbar;

        final bool lastHasHorizontalScrollbar = hasHorizontalScrollbar;
        hasHorizontalScrollbar = theme.scrollbar.horizontalOnlyWhenNeeded
            ? needHorizontalScrollbar
            : true;

        if (!lastHasHorizontalScrollbar && hasHorizontalScrollbar) {
          // The horizontal scrollbar became visible.
          // The available height will be smaller.
          // Maybe now there needs to be a vertical scrollbar.
          if (constraints.hasBoundedHeight) {
            final double availableHeight = math.max(
                0,
                constraints.maxHeight -
                    (hasHeader ? headerHeight : 0) -
                    scrollbarHeight);
            final double start = verticalOffset / rowHeight;
            maxVisibleRowsLength =
                (start + (availableHeight / rowHeight)).ceil() - start.floor();
          }
          needVerticalScrollbar =
              maxVisibleRowsLength < model.visibleRowsLength;
          hasVerticalScrollbar =
              !theme.scrollbar.verticalOnlyWhenNeeded || needVerticalScrollbar;
        }
      }
    } else {
      columnsMetrics = UnmodifiableListView<ColumnMetricsV3<ROW>>([]);
    }

    final int firstRowIndex = (verticalOffset / rowHeight).floor();
    final double contentHeight = model != null
        ? math.max(0, (model.rowsLength * rowHeight) - rowDividerThickness)
        : 0;

    // Now let's set the screen boundaries!

    final double contentAreaWidth = math.max(
        0, constraints.maxWidth - (hasVerticalScrollbar ? scrollbarWidth : 0));
    final Rect headerBounds = hasHeader
        ? Rect.fromLTWH(0, 0, contentAreaWidth, headerHeight)
        : Rect.zero;
    final Rect cellsBounds;
    final Rect horizontalScrollbarBounds;
    if (constraints.hasBoundedHeight) {
      cellsBounds = Rect.fromLTWH(
          0,
          headerBounds.height,
          contentAreaWidth,
          math.max(
              0,
              constraints.maxHeight -
                  headerBounds.height -
                  (hasHorizontalScrollbar ? scrollbarHeight : 0)));
      horizontalScrollbarBounds = hasHorizontalScrollbar
          ? Rect.fromLTWH(0, headerBounds.height + cellsBounds.height,
              contentAreaWidth, scrollbarHeight)
          : Rect.zero;
    } else {
      // unbounded height
      cellsBounds = Rect.fromLTWH(
          0,
          headerBounds.height,
          contentAreaWidth,
          math.max(
              0, (maxVisibleRowsLength * rowHeight) - rowDividerThickness));
      horizontalScrollbarBounds = hasHorizontalScrollbar
          ? Rect.fromLTWH(0, headerBounds.height + cellsBounds.height,
              contentAreaWidth, scrollbarHeight)
          : Rect.zero;
    }

    height = headerBounds.height +
        cellsBounds.height +
        horizontalScrollbarBounds.height;

    final Rect verticalScrollbarBounds = Rect.fromLTWH(
        cellsBounds.width,
        headerBounds.bottom,
        hasVerticalScrollbar ? scrollbarWidth : 0,
        cellsBounds.height);

    final Rect leftPinnedAreaBounds = Rect.fromLTWH(
        0,
        0,
        math.min(leftPinnedContentWidth, cellsBounds.width),
        cellsBounds.height);

    final double unpinnedOffset = leftPinnedAreaBounds.width > 0
        ? math.min(leftPinnedAreaBounds.width + columnDividerThickness,
            cellsBounds.width)
        : 0;
    final Rect unpinnedAreaBounds = Rect.fromLTWH(unpinnedOffset, 0,
        math.max(0, cellsBounds.width - unpinnedOffset), cellsBounds.height);

    // Calculating the hashCode in advance. Will save 1 ms while scrolling ;-)

    IterableEquality iterableEquality = const IterableEquality();
    final int hashCode = iterableEquality.hash(columnsMetrics) ^
        hasHeader.hashCode ^
        rowHeight.hashCode ^
        headerHeight.hashCode ^
        scrollbarWidth.hashCode ^
        scrollbarHeight.hashCode ^
        height.hashCode ^
        verticalOffset.hashCode ^
        firstRowIndex.hashCode ^
        contentHeight.hashCode ^
        cellHeight.hashCode ^
        columnDividerThickness.hashCode ^
        rowDividerThickness.hashCode ^
        maxVisibleRowsLength.hashCode ^
        headerBounds.hashCode ^
        cellsBounds.hashCode ^
        horizontalScrollbarBounds.hashCode ^
        verticalScrollbarBounds.hashCode ^
        leftPinnedAreaBounds.hashCode ^
        unpinnedContentWidth.hashCode ^
        leftPinnedContentWidth.hashCode ^
        hasVerticalScrollbar.hashCode ^
        hasHorizontalScrollbar.hashCode ^
        unpinnedAreaBounds.hashCode;

    return TableLayoutSettingsV3._(
        hasHeader: hasHeader,
        rowHeight: rowHeight,
        headerHeight: headerHeight,
        scrollbarWidth: scrollbarWidth,
        scrollbarHeight: scrollbarHeight,
        height: height,
        cellHeight: cellHeight,
        verticalOffset: verticalOffset,
        firstRowIndex: firstRowIndex,
        contentHeight: contentHeight,
        columnDividerThickness: columnDividerThickness,
        rowDividerThickness: rowDividerThickness,
        hasVerticalScrollbar: hasVerticalScrollbar,
        hasHorizontalScrollbar: hasHorizontalScrollbar,
        maxVisibleRowsLength: maxVisibleRowsLength,
        columnsMetrics: columnsMetrics,
        headerBounds: headerBounds,
        cellsBounds: cellsBounds,
        horizontalScrollbarBounds: horizontalScrollbarBounds,
        verticalScrollbarBounds: verticalScrollbarBounds,
        leftPinnedAreaBounds: leftPinnedAreaBounds,
        unpinnedContentWidth: unpinnedContentWidth,
        leftPinnedContentWidth: leftPinnedContentWidth,
        unpinnedAreaBounds: unpinnedAreaBounds,
        hashCode: hashCode);
  }

  TableLayoutSettingsV3._(
      {required this.hasHeader,
      required this.rowHeight,
      required this.leftPinnedContentWidth,
      required this.unpinnedContentWidth,
      required this.headerHeight,
      required this.scrollbarWidth,
      required this.scrollbarHeight,
      required this.height,
      required this.cellHeight,
      required this.verticalOffset,
      required this.firstRowIndex,
      required this.contentHeight,
      required this.hasVerticalScrollbar,
      required this.hasHorizontalScrollbar,
      required this.columnDividerThickness,
      required this.rowDividerThickness,
      required this.maxVisibleRowsLength,
      required this.columnsMetrics,
      required this.headerBounds,
      required this.cellsBounds,
      required this.horizontalScrollbarBounds,
      required this.verticalScrollbarBounds,
      required this.leftPinnedAreaBounds,
      required this.unpinnedAreaBounds,
      required this.hashCode});

  final bool hasHeader;
  final double rowHeight;
  final double headerHeight;
  final double scrollbarWidth;
  final double scrollbarHeight;
  final double height;
  final double verticalOffset;
  final double cellHeight;
  final int firstRowIndex;
  final double contentHeight;
  final double columnDividerThickness;
  final double rowDividerThickness;
  final double unpinnedContentWidth;
  final double leftPinnedContentWidth;
  final bool hasVerticalScrollbar;
  final bool hasHorizontalScrollbar;
  final int maxVisibleRowsLength;
  final List<ColumnMetricsV3<ROW>> columnsMetrics;
  final Rect headerBounds;
  final Rect cellsBounds;
  final Rect horizontalScrollbarBounds;
  final Rect verticalScrollbarBounds;
  final Rect leftPinnedAreaBounds;
  final Rect unpinnedAreaBounds;

  @override
  final int hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TableLayoutSettingsV3 &&
          runtimeType == other.runtimeType &&
          hashCode == other.hashCode;
}
