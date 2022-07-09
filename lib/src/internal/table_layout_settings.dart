import 'dart:math' as math;

import 'package:easy_table/src/column.dart';
import 'package:easy_table/src/internal/column_metrics.dart';
import 'package:easy_table/src/internal/row_range.dart';
import 'package:easy_table/src/internal/theme_metrics/theme_metrics.dart';
import 'package:easy_table/src/pin_status.dart';
import 'package:easy_table/src/internal/scroll_offsets.dart';
import 'package:easy_table/src/model.dart';
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:collection/collection.dart';

@internal
class TableLayoutSettings {
  factory TableLayoutSettings(
      {required EasyTableModel? model,
      required BoxConstraints constraints,
      required bool columnsFit,
      required TableThemeMetrics themeMetrics,
      required int? visibleRowsLength,
      required TableScrollOffsets offsets,
      required bool hasLastRowWidget,
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

    final int rowsLength =
        (model != null ? model.rowsLength : 0) + (hasLastRowWidget ? 1 : 0);

    // Let's find out the dynamic values given the constraints!!!
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
              (themeMetrics.header.visible ? themeMetrics.header.height : 0) -
              (hasHorizontalScrollbar ? themeMetrics.scrollbar.height : 0));
      needVerticalScrollbar = model != null
          ? (rowsLength * themeMetrics.row.height) -
                  themeMetrics.row.dividerThickness >
              availableRowsHeight
          : false;
    } else {
      needVerticalScrollbar =
          model != null ? visibleRowsLength! < rowsLength : false;
    }
    bool hasVerticalScrollbar =
        !theme.scrollbar.verticalOnlyWhenNeeded || needVerticalScrollbar;

    if (model != null) {
      if (columnsFit) {
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

        final bool needHorizontalScrollbar = needUnpinnedHorizontalScrollbar ||
            needLeftPinnedHorizontalScrollbar;

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
                    (themeMetrics.header.visible
                        ? themeMetrics.header.height
                        : 0) -
                    themeMetrics.scrollbar.height);
            needVerticalScrollbar = (rowsLength * themeMetrics.row.height) -
                    themeMetrics.row.dividerThickness >
                availableRowsHeight;
          }
          hasVerticalScrollbar =
              !theme.scrollbar.verticalOnlyWhenNeeded || needVerticalScrollbar;
        }
      }
    } else {
      // null model
      columnsMetrics = UnmodifiableListView<ColumnMetrics>([]);
    }

    final int firstRowIndex =
        (offsets.vertical / themeMetrics.row.height).floor();
    final double contentHeight = model != null
        ? math.max(
            0,
            (rowsLength * themeMetrics.row.height) -
                themeMetrics.row.dividerThickness)
        : 0;

    // Now let's set the screen boundaries!

    final double contentAreaWidth = math.max(
        0,
        constraints.maxWidth -
            (hasVerticalScrollbar ? themeMetrics.scrollbar.width : 0));
    final Rect headerBounds = themeMetrics.header.visible
        ? Rect.fromLTWH(0, 0, contentAreaWidth, themeMetrics.header.height)
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
                  (hasHorizontalScrollbar
                      ? themeMetrics.scrollbar.height
                      : 0)));
    } else {
      // unbounded height
      cellsBounds = Rect.fromLTWH(
          0,
          headerBounds.height,
          contentAreaWidth,
          math.max(
              0,
              (visibleRowsLength! * themeMetrics.row.height) -
                  themeMetrics.row.dividerThickness));
    }
    final int maxVisibleRowsLength = RowRange.maxVisibleRowsLength(
        scrollOffset: offsets.vertical,
        height: cellsBounds.height,
        rowHeight: themeMetrics.row.height);
    final int effectiveVisibleRowsLength =
        model != null ? math.min(rowsLength, maxVisibleRowsLength) : 0;

    if (hasHorizontalScrollbar) {
      final double top = headerBounds.height + cellsBounds.height;
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
        offsets.hashCode ^
        rowsLength.hashCode ^
        columnsFit.hashCode ^
        firstRowIndex.hashCode ^
        contentHeight.hashCode ^
        themeMetrics.hashCode ^
        effectiveVisibleRowsLength.hashCode ^
        maxVisibleRowsLength.hashCode ^
        hasLastRowWidget.hashCode ^
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

    // Mission accomplished!

    return TableLayoutSettings._(
        columnsFit: columnsFit,
        height: height,
        themeMetrics: themeMetrics,
        offsets: offsets,
        firstRowIndex: firstRowIndex,
        contentHeight: contentHeight,
        hasVerticalScrollbar: hasVerticalScrollbar,
        hasHorizontalScrollbar: hasHorizontalScrollbar,
        visibleRowsLength: effectiveVisibleRowsLength,
        maxVisibleRowsLength: maxVisibleRowsLength,
        columnsMetrics: columnsMetrics,
        hasLastRowWidget: hasLastRowWidget,
        rowsLength: rowsLength,
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

  TableLayoutSettings._(
      {required this.themeMetrics,
      required this.columnsFit,
      required this.leftPinnedContentWidth,
      required this.unpinnedContentWidth,
      required this.height,
      required this.offsets,
      required this.hasLastRowWidget,
      required this.rowsLength,
      required this.firstRowIndex,
      required this.contentHeight,
      required this.hasVerticalScrollbar,
      required this.hasHorizontalScrollbar,
      required this.visibleRowsLength,
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
      required this.hashCode});

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
  final bool hasLastRowWidget;
  final int rowsLength;

  /// The number of rows that can be visible at the available height.
  final int maxVisibleRowsLength;
  final int visibleRowsLength;
  final List<ColumnMetrics> columnsMetrics;
  final Rect headerBounds;
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

  PinStatus pinStatus(EasyTableColumn column) {
    if (columnsFit) {
      return PinStatus.none;
    }
    return column.pinStatus;
  }

  @override
  final int hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TableLayoutSettings &&
          runtimeType == other.runtimeType &&
          hashCode == other.hashCode;
}
