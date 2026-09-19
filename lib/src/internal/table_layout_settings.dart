import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:davi/src/column_width_behavior.dart';
import 'package:davi/src/internal/column_metrics.dart';
import 'package:davi/src/internal/row_extent_manager.dart';
import 'package:davi/src/internal/theme_metrics/theme_metrics.dart';
import 'package:davi/src/model.dart';
import 'package:davi/src/pin_status.dart';
import 'package:davi/src/theme/theme_data.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

@internal
class TableLayoutSettings {
  factory TableLayoutSettings(
      {required DaviModel model,
      required BoxConstraints constraints,
      required ColumnWidthBehavior columnWidthBehavior,
      required TableThemeMetrics themeMetrics,
      required int? visibleRowsCount,
      required bool hasTrailingWidget,
      required RowExtentManager rowExtentManager,
      required DaviThemeData theme}) {
    if (!constraints.hasBoundedWidth) {
      throw FlutterError('Davi was given unbounded width.');
    }
    if (!constraints.hasBoundedHeight && visibleRowsCount == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('Davi was given unbounded height.'),
        ErrorDescription('Davi already is scrollable in the vertical axis.'),
        ErrorHint(
          'Consider using the "visibleRowsCount" property to limit the height'
          ' or use it in another Widget like Expanded or SliverFillRemaining.',
        ),
      ]);
    }

    final int rowsLength = model.rowsLength + (hasTrailingWidget ? 1 : 0);

    // The header no longer has a fixed height metric: TableLayoutRenderBox
    // discovers the real height from the header content at layout time.
    // This is only an estimate used for decisions that must be made before
    // the render tree exists (scrollbar necessity, initial bounds).
    final double estimatedHeaderHeight =
        themeMetrics.headerCell.height + themeMetrics.header.bottomBorderHeight;

    // Let's find out the dynamic metrics given the constraints!!!
    // I'm so excited!!!

    final double height;

    // This will hold all columns metrics (width and offset)
    final List<ColumnMetrics> columnsMetrics;

    double leftPinnedContentWidth = 0;
    double unpinnedContentWidth = 0;

    // It is not possible to identify the need for a vertical and horizontal
    // scrollbar at the same time. Let's try the vertical first considering
    // the possibility that the horizontal might not be visible initially.
    // We will recalculate if the horizontal becomes necessary.
    bool hasHorizontalScrollbar = !theme.scrollbar.horizontalOnlyWhenNeeded;
    bool needVerticalScrollbar = false;
    if (constraints.hasBoundedHeight) {
      final double availableRowsHeight = math.max(
          0,
          constraints.maxHeight -
              (model.hasSummary ? themeMetrics.summary.height : 0) -
              (themeMetrics.header.visible ? estimatedHeaderHeight : 0) -
              (hasHorizontalScrollbar ? themeMetrics.scrollbar.height : 0));
      needVerticalScrollbar =
          rowExtentManager.totalHeight > availableRowsHeight;
    } else {
      needVerticalScrollbar = visibleRowsCount! < rowsLength;
    }
    bool hasVerticalScrollbar =
        !theme.scrollbar.verticalOnlyWhenNeeded || needVerticalScrollbar;

    if (columnWidthBehavior == ColumnWidthBehavior.fit) {
      unpinnedContentWidth = math.max(
          0,
          constraints.maxWidth -
              (hasVerticalScrollbar ? themeMetrics.scrollbar.width : 0));
      columnsMetrics = UnmodifiableListView<ColumnMetrics>(
          ColumnMetrics.columnsFit(
              model: model,
              dividerThickness: themeMetrics.columnDividerThickness,
              maxWidth: unpinnedContentWidth));
      hasHorizontalScrollbar = false;
    } else {
      // resizable columns
      columnsMetrics = UnmodifiableListView<ColumnMetrics>(
          ColumnMetrics.resizable(
              model: model,
              maxWidth: math.max(
                  0,
                  constraints.maxWidth -
                      (hasVerticalScrollbar
                          ? themeMetrics.scrollbar.width
                          : 0)),
              dividerThickness: themeMetrics.columnDividerThickness));

      for (ColumnMetrics columnMetrics in columnsMetrics) {
        if (columnMetrics.pinStatus == PinStatus.none) {
          unpinnedContentWidth = columnMetrics.offset + columnMetrics.width;
        } else if (columnMetrics.pinStatus == PinStatus.left) {
          leftPinnedContentWidth = columnMetrics.offset + columnMetrics.width;
        }
      }
      unpinnedContentWidth = math.max(
          0,
          unpinnedContentWidth -
              leftPinnedContentWidth -
              (leftPinnedContentWidth > 0
                  ? themeMetrics.columnDividerThickness
                  : 0));

      final double maxContentAreaWidth = math.max(
          0,
          constraints.maxWidth -
              (hasVerticalScrollbar ? themeMetrics.scrollbar.width : 0));

      final bool needLeftPinnedHorizontalScrollbar =
          leftPinnedContentWidth > maxContentAreaWidth;

      final bool needUnpinnedHorizontalScrollbar = unpinnedContentWidth >
          maxContentAreaWidth -
              leftPinnedContentWidth -
              (leftPinnedContentWidth > 0
                  ? themeMetrics.columnDividerThickness
                  : 0);

      final bool needHorizontalScrollbar =
          needUnpinnedHorizontalScrollbar || needLeftPinnedHorizontalScrollbar;

      final bool lastHasHorizontalScrollbar = hasHorizontalScrollbar;
      hasHorizontalScrollbar = theme.scrollbar.horizontalOnlyWhenNeeded
          ? needHorizontalScrollbar
          : true;

      if (!lastHasHorizontalScrollbar && hasHorizontalScrollbar) {
        // The horizontal scrollbar became visible.
        // The available height will be smaller.
        // Maybe now it needs to have a vertical scrollbar.
        if (constraints.hasBoundedHeight) {
          final double availableRowsHeight = math.max(
              0,
              constraints.maxHeight -
                  (model.hasSummary ? themeMetrics.summary.height : 0) -
                  (themeMetrics.header.visible ? estimatedHeaderHeight : 0) -
                  themeMetrics.scrollbar.height);
          needVerticalScrollbar =
              rowExtentManager.totalHeight > availableRowsHeight;
        }
        hasVerticalScrollbar =
            !theme.scrollbar.verticalOnlyWhenNeeded || needVerticalScrollbar;
      }
    }

    final double contentHeight = rowExtentManager.totalHeight;

    // Now let's set the screen boundaries!

    final double contentAreaWidth = math.max(
        0,
        constraints.maxWidth -
            (hasVerticalScrollbar ? themeMetrics.scrollbar.width : 0));
    final Rect headerBounds = themeMetrics.header.visible
        ? Rect.fromLTWH(0, 0, contentAreaWidth, estimatedHeaderHeight)
        : Rect.zero;

    final Rect cellsBounds;
    final Rect horizontalScrollbarBounds;
    final Rect unpinnedHorizontalScrollbarsBounds;
    final Rect leftPinnedHorizontalScrollbarBounds;
    final Rect summaryBounds;
    if (constraints.hasBoundedHeight) {
      cellsBounds = Rect.fromLTWH(
          0,
          headerBounds.height,
          contentAreaWidth,
          math.max(
              0,
              constraints.maxHeight -
                  headerBounds.height -
                  (model.hasSummary ? themeMetrics.summary.height : 0) -
                  (hasHorizontalScrollbar
                      ? themeMetrics.scrollbar.height
                      : 0)));
    } else {
      // unbounded height
      cellsBounds = Rect.fromLTWH(
          0,
          headerBounds.height,
          contentAreaWidth,
          rowExtentManager.heightUpTo(visibleRowsCount!));
    }

    if (model.hasSummary) {
      summaryBounds = Rect.fromLTWH(0, cellsBounds.bottom, cellsBounds.width,
          themeMetrics.summary.height);
    } else {
      summaryBounds = Rect.zero;
    }

    if (hasHorizontalScrollbar) {
      final double top = headerBounds.height +
          cellsBounds.height +
          (model.hasSummary ? themeMetrics.summary.height : 0);
      final double leftDivisorWidth =
          leftPinnedContentWidth > 0 ? themeMetrics.columnDividerThickness : 0;
      horizontalScrollbarBounds = Rect.fromLTWH(
          0, top, contentAreaWidth, themeMetrics.scrollbar.height);
      leftPinnedHorizontalScrollbarBounds = Rect.fromLTWH(
          0,
          top,
          math.min(leftPinnedContentWidth, contentAreaWidth),
          themeMetrics.scrollbar.height);
      unpinnedHorizontalScrollbarsBounds = Rect.fromLTWH(
          leftPinnedHorizontalScrollbarBounds.width + leftDivisorWidth,
          top,
          math.max(
              0,
              contentAreaWidth -
                  leftPinnedHorizontalScrollbarBounds.width -
                  leftDivisorWidth),
          themeMetrics.scrollbar.height);
    } else {
      horizontalScrollbarBounds = Rect.zero;
      leftPinnedHorizontalScrollbarBounds = Rect.zero;
      unpinnedHorizontalScrollbarsBounds = Rect.zero;
    }

    height = headerBounds.height +
        cellsBounds.height +
        summaryBounds.height +
        horizontalScrollbarBounds.height;

    final Rect verticalScrollbarBounds = Rect.fromLTWH(
        cellsBounds.width,
        headerBounds.bottom,
        hasVerticalScrollbar ? themeMetrics.scrollbar.width : 0,
        cellsBounds.height);

    final Rect leftPinnedAreaBounds = Rect.fromLTWH(
        0,
        0,
        math.min(leftPinnedContentWidth, cellsBounds.width),
        headerBounds.height + cellsBounds.height);

    final double unpinnedOffset = leftPinnedAreaBounds.width > 0
        ? math.min(
            leftPinnedAreaBounds.width + themeMetrics.columnDividerThickness,
            cellsBounds.width)
        : 0;
    final Rect unpinnedAreaBounds = Rect.fromLTWH(
        unpinnedOffset,
        0,
        math.max(0, cellsBounds.width - unpinnedOffset),
        headerBounds.height + cellsBounds.height);

    // Calculating the hashCode in advance.

    IterableEquality iterableEquality = const IterableEquality();
    final int hashCode = iterableEquality.hash(columnsMetrics) ^
        height.hashCode ^
        rowsLength.hashCode ^
        contentHeight.hashCode ^
        themeMetrics.hashCode ^
        hasTrailingWidget.hashCode ^
        headerBounds.hashCode ^
        cellsBounds.hashCode ^
        summaryBounds.hashCode ^
        horizontalScrollbarBounds.hashCode ^
        unpinnedHorizontalScrollbarsBounds.hashCode ^
        leftPinnedHorizontalScrollbarBounds.hashCode ^
        verticalScrollbarBounds.hashCode ^
        leftPinnedAreaBounds.hashCode ^
        unpinnedContentWidth.hashCode ^
        leftPinnedContentWidth.hashCode ^
        hasVerticalScrollbar.hashCode ^
        hasHorizontalScrollbar.hashCode ^
        unpinnedAreaBounds.hashCode;

    // Mission accomplished!

    return TableLayoutSettings._(
        height: height,
        themeMetrics: themeMetrics,
        rowExtentManager: rowExtentManager,
        contentHeight: contentHeight,
        hasVerticalScrollbar: hasVerticalScrollbar,
        hasHorizontalScrollbar: hasHorizontalScrollbar,
        columnsMetrics: columnsMetrics,
        hasTrailingWidget: hasTrailingWidget,
        rowsLength: rowsLength,
        headerBounds: headerBounds,
        cellsBounds: cellsBounds,
        summaryBounds: summaryBounds,
        horizontalScrollbarsBounds: horizontalScrollbarBounds,
        unpinnedHorizontalScrollbarsBounds: unpinnedHorizontalScrollbarsBounds,
        leftPinnedHorizontalScrollbarBounds:
            leftPinnedHorizontalScrollbarBounds,
        verticalScrollbarBounds: verticalScrollbarBounds,
        leftPinnedAreaBounds: leftPinnedAreaBounds,
        unpinnedContentWidth: unpinnedContentWidth,
        leftPinnedContentWidth: leftPinnedContentWidth,
        unpinnedAreaBounds: unpinnedAreaBounds,
        hashCode: hashCode);
  }

  TableLayoutSettings._(
      {required this.themeMetrics,
      required this.rowExtentManager,
      required this.leftPinnedContentWidth,
      required this.unpinnedContentWidth,
      required this.height,
      required this.hasTrailingWidget,
      required this.rowsLength,
      required this.contentHeight,
      required this.hasVerticalScrollbar,
      required this.hasHorizontalScrollbar,
      required this.columnsMetrics,
      required this.headerBounds,
      required this.summaryBounds,
      required this.cellsBounds,
      required this.horizontalScrollbarsBounds,
      required this.unpinnedHorizontalScrollbarsBounds,
      required this.leftPinnedHorizontalScrollbarBounds,
      required this.verticalScrollbarBounds,
      required this.leftPinnedAreaBounds,
      required this.unpinnedAreaBounds,
      required this.hashCode});

  final TableThemeMetrics themeMetrics;
  final RowExtentManager rowExtentManager;
  final double height;

  /// total height of the content (cells and dividers)
  /// not counting the last widget
  final double contentHeight;
  final double unpinnedContentWidth;
  final double leftPinnedContentWidth;
  final bool hasVerticalScrollbar;
  final bool hasHorizontalScrollbar;
  final bool hasTrailingWidget;
  final int rowsLength;
  final List<ColumnMetrics> columnsMetrics;
  final Rect headerBounds;
  final Rect summaryBounds;
  final Rect cellsBounds;
  final Rect unpinnedHorizontalScrollbarsBounds;
  final Rect leftPinnedHorizontalScrollbarBounds;
  final Rect horizontalScrollbarsBounds;
  final Rect verticalScrollbarBounds;
  final Rect leftPinnedAreaBounds;
  final Rect unpinnedAreaBounds;

  Rect getAreaBounds(PinStatus pinStatus) {
    if (pinStatus == PinStatus.none) {
      return unpinnedAreaBounds;
    } else if (pinStatus == PinStatus.left) {
      return leftPinnedAreaBounds;
    }
    throw ArgumentError('Not recognized $pinStatus');
  }

  // A cache-sizing heuristic only (see TableContentState._updatePainterCacheSize)
  // - real per-row height is looked up from RowExtentManager elsewhere.
  int get maxVisibleRows => (cellsBounds.height /
          (themeMetrics.row.estimatedHeight + themeMetrics.row.dividerThickness))
      .ceil();

  @override
  final int hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TableLayoutSettings &&
          runtimeType == other.runtimeType &&
          hashCode == other.hashCode;
}
