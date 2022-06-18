import 'dart:math' as math;

import 'package:easy_table/src/column.dart';
import 'package:easy_table/src/experimental/metrics/column_metrics.dart';
import 'package:easy_table/src/experimental/metrics/row_range.dart';
import 'package:easy_table/src/internal/table_theme_metrics.dart';
import 'package:easy_table/src/pin_status.dart';
import 'package:easy_table/src/experimental/scroll_offsets.dart';
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
      required TableThemeMetrics themeMetrics,
      required int? visibleRowsLength,
      required TableScrollOffsets offsets,
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
              (themeMetrics.hasHeader ? themeMetrics.headerHeight : 0) -
              (hasHorizontalScrollbar ? themeMetrics.scrollbarHeight : 0));
      maxVisibleRowsLength = RowRange.maxVisibleRowsLength(
          scrollOffset: offsets.vertical,
          height: availableHeight,
          rowHeight: themeMetrics.rowHeight);
    }
    bool needVerticalScrollbar =
        model != null ? maxVisibleRowsLength < model.visibleRowsLength : false;
    bool hasVerticalScrollbar =
        !theme.scrollbar.verticalOnlyWhenNeeded || needVerticalScrollbar;

    if (model != null) {
      if (columnsFit) {
        unpinnedContentWidth = math.max(
            0,
            constraints.maxWidth -
                (hasVerticalScrollbar ? themeMetrics.scrollbarWidth : 0));
        columnsMetrics = UnmodifiableListView<ColumnMetricsV3<ROW>>(
            ColumnMetricsV3.columnsFit<ROW>(
                model: model,
                dividerThickness: themeMetrics.columnDividerThickness,
                maxWidth: unpinnedContentWidth));
        hasHorizontalScrollbar = false;
      } else {
        // resizable columns
        columnsMetrics = UnmodifiableListView<ColumnMetricsV3<ROW>>(
            ColumnMetricsV3.resizable<ROW>(
                model: model,
                dividerThickness: themeMetrics.columnDividerThickness));

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
                (leftPinnedContentWidth > 0
                    ? themeMetrics.columnDividerThickness
                    : 0));

        final double maxContentAreaWidth = math.max(
            0,
            constraints.maxWidth -
                (hasVerticalScrollbar ? themeMetrics.scrollbarWidth : 0));

        final bool needLeftPinnedHorizontalScrollbar =
            leftPinnedContentWidth > maxContentAreaWidth;

        final bool needUnpinnedHorizontalScrollbar = unpinnedContentWidth >
            maxContentAreaWidth -
                leftPinnedContentWidth -
                (leftPinnedContentWidth > 0
                    ? themeMetrics.columnDividerThickness
                    : 0);

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
                    (themeMetrics.hasHeader ? themeMetrics.headerHeight : 0) -
                    themeMetrics.scrollbarHeight);
            maxVisibleRowsLength = RowRange.maxVisibleRowsLength(
                scrollOffset: offsets.vertical,
                height: availableHeight,
                rowHeight: themeMetrics.rowHeight);
          }
          needVerticalScrollbar =
              maxVisibleRowsLength < model.visibleRowsLength;
          hasVerticalScrollbar =
              !theme.scrollbar.verticalOnlyWhenNeeded || needVerticalScrollbar;
        }
      }
    } else {
      // null model
      columnsMetrics = UnmodifiableListView<ColumnMetricsV3<ROW>>([]);
    }

    final int firstRowIndex =
        (offsets.vertical / themeMetrics.rowHeight).floor();
    final double contentHeight = model != null
        ? math.max(
            0,
            (model.rowsLength * themeMetrics.rowHeight) -
                themeMetrics.rowDividerThickness)
        : 0;

    // Now let's set the screen boundaries!

    final double contentAreaWidth = math.max(
        0,
        constraints.maxWidth -
            (hasVerticalScrollbar ? themeMetrics.scrollbarWidth : 0));
    final Rect headerBounds = themeMetrics.hasHeader
        ? Rect.fromLTWH(0, 0, contentAreaWidth, themeMetrics.headerHeight)
        : Rect.zero;
    final Rect cellsBounds;
    final Rect horizontalScrollbarBounds;
    final Rect unpinnedHorizontalScrollbarsBounds;
    final Rect leftPinnedHorizontalScrollbarBounds;
    if (constraints.hasBoundedHeight) {
      cellsBounds = Rect.fromLTWH(
          0,
          headerBounds.height,
          contentAreaWidth,
          math.max(
              0,
              constraints.maxHeight -
                  headerBounds.height -
                  (hasHorizontalScrollbar ? themeMetrics.scrollbarHeight : 0)));
    } else {
      // unbounded height
      cellsBounds = Rect.fromLTWH(
          0,
          headerBounds.height,
          contentAreaWidth,
          math.max(
              0,
              (maxVisibleRowsLength * themeMetrics.rowHeight) -
                  themeMetrics.rowDividerThickness));
    }

    if (hasHorizontalScrollbar) {
      final double top = headerBounds.height + cellsBounds.height;
      final double leftDivisorWidth =
          leftPinnedContentWidth > 0 ? themeMetrics.columnDividerThickness : 0;
      horizontalScrollbarBounds =
          Rect.fromLTWH(0, top, contentAreaWidth, themeMetrics.scrollbarHeight);
      leftPinnedHorizontalScrollbarBounds = Rect.fromLTWH(
          0,
          top,
          math.min(leftPinnedContentWidth, contentAreaWidth),
          themeMetrics.scrollbarHeight);
      unpinnedHorizontalScrollbarsBounds = Rect.fromLTWH(
          leftPinnedHorizontalScrollbarBounds.width + leftDivisorWidth,
          top,
          math.max(
              0,
              contentAreaWidth -
                  leftPinnedHorizontalScrollbarBounds.width -
                  leftDivisorWidth),
          themeMetrics.scrollbarHeight);
    } else {
      horizontalScrollbarBounds = Rect.zero;
      leftPinnedHorizontalScrollbarBounds = Rect.zero;
      unpinnedHorizontalScrollbarsBounds = Rect.zero;
    }

    height = headerBounds.height +
        cellsBounds.height +
        horizontalScrollbarBounds.height;

    final Rect verticalScrollbarBounds = Rect.fromLTWH(
        cellsBounds.width,
        headerBounds.bottom,
        hasVerticalScrollbar ? themeMetrics.scrollbarWidth : 0,
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

    // Calculating the hashCode in advance. Will save 1 ms while scrolling ;-)

    IterableEquality iterableEquality = const IterableEquality();
    final int hashCode = iterableEquality.hash(columnsMetrics) ^
        height.hashCode ^
        offsets.hashCode ^
        columnsFit.hashCode ^
        firstRowIndex.hashCode ^
        contentHeight.hashCode ^
        themeMetrics.hashCode ^
        maxVisibleRowsLength.hashCode ^
        headerBounds.hashCode ^
        cellsBounds.hashCode ^
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

    return TableLayoutSettingsV3._(
        columnsFit: columnsFit,
        height: height,
        themeMetrics: themeMetrics,
        offsets: offsets,
        firstRowIndex: firstRowIndex,
        contentHeight: contentHeight,
        hasVerticalScrollbar: hasVerticalScrollbar,
        hasHorizontalScrollbar: hasHorizontalScrollbar,
        maxVisibleRowsLength: maxVisibleRowsLength,
        columnsMetrics: columnsMetrics,
        headerBounds: headerBounds,
        cellsBounds: cellsBounds,
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

  TableLayoutSettingsV3._(
      {required this.themeMetrics,
      required this.columnsFit,
      required this.leftPinnedContentWidth,
      required this.unpinnedContentWidth,
      required this.height,
      required this.offsets,
      required this.firstRowIndex,
      required this.contentHeight,
      required this.hasVerticalScrollbar,
      required this.hasHorizontalScrollbar,
      required this.maxVisibleRowsLength,
      required this.columnsMetrics,
      required this.headerBounds,
      required this.cellsBounds,
      required this.horizontalScrollbarsBounds,
      required this.unpinnedHorizontalScrollbarsBounds,
      required this.leftPinnedHorizontalScrollbarBounds,
      required this.verticalScrollbarBounds,
      required this.leftPinnedAreaBounds,
      required this.unpinnedAreaBounds,
      required this.hashCode}) {
    _areaBounds = {
      PinStatus.leftPinned: leftPinnedAreaBounds,
      PinStatus.unpinned: unpinnedAreaBounds,
      PinStatus.rightPinned: Rect.zero
    };
  }

  final TableThemeMetrics themeMetrics;
  final bool columnsFit;
  final double height;
  final TableScrollOffsets offsets;
  final int firstRowIndex;
  final double contentHeight;
  final double unpinnedContentWidth;
  final double leftPinnedContentWidth;
  final bool hasVerticalScrollbar;
  final bool hasHorizontalScrollbar;
  final int maxVisibleRowsLength;
  final List<ColumnMetricsV3<ROW>> columnsMetrics;
  final Rect headerBounds;
  final Rect cellsBounds;
  final Rect unpinnedHorizontalScrollbarsBounds;
  final Rect leftPinnedHorizontalScrollbarBounds;
  final Rect horizontalScrollbarsBounds;
  final Rect verticalScrollbarBounds;
  final Rect leftPinnedAreaBounds;
  final Rect unpinnedAreaBounds;
  late final Map<PinStatus, Rect> _areaBounds;

  Rect getAreaBounds(PinStatus pinStatus) {
    return _areaBounds[pinStatus]!;
  }

  PinStatus pinStatus(EasyTableColumn<ROW> column) {
    if (columnsFit) {
      return PinStatus.unpinned;
    }
    return column.pinStatus;
  }

  @override
  final int hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TableLayoutSettingsV3 &&
          runtimeType == other.runtimeType &&
          hashCode == other.hashCode;
}
