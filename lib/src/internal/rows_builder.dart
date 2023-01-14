import 'dart:math' as math;

import 'package:davi/src/internal/layout_utils.dart';
import 'package:davi/src/internal/row_callbacks.dart';
import 'package:davi/src/internal/row_widget.dart';
import 'package:davi/src/internal/rows_layout.dart';
import 'package:davi/src/internal/rows_layout_child.dart';
import 'package:davi/src/internal/rows_painting_settings.dart';
import 'package:davi/src/internal/scroll_offsets.dart';
import 'package:davi/src/internal/table_layout_settings.dart';
import 'package:davi/src/last_row_widget_listener.dart';
import 'package:davi/src/last_visible_row_listener.dart';
import 'package:davi/src/model.dart';
import 'package:davi/src/row_color.dart';
import 'package:davi/src/row_cursor.dart';
import 'package:davi/src/row_hover_listener.dart';
import 'package:davi/src/theme/theme.dart';
import 'package:davi/src/theme/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
class RowsBuilder<ROW> extends StatelessWidget {
  const RowsBuilder(
      {Key? key,
      required this.layoutSettings,
      required this.model,
      required this.onHover,
      required this.scrolling,
      required this.rowCallbacks,
      required this.rowColor,
      required this.rowCursor,
      required this.verticalOffset,
      required this.horizontalScrollOffsets,
      required this.lastRowWidget,
      required this.onLastRowWidget,
      required this.onLastVisibleRow})
      : super(key: key);

  final DaviModel<ROW>? model;
  final TableLayoutSettings layoutSettings;
  final bool scrolling;
  final double verticalOffset;
  final HorizontalScrollOffsets horizontalScrollOffsets;
  final OnRowHoverListener? onHover;
  final RowCallbacks<ROW> rowCallbacks;
  final Widget? lastRowWidget;
  final DaviRowColor<ROW>? rowColor;
  final DaviRowCursor<ROW>? rowCursor;
  final OnLastRowWidgetListener onLastRowWidget;
  final OnLastVisibleRowListener onLastVisibleRow;

  @override
  Widget build(BuildContext context) {
    DaviThemeData theme = DaviTheme.of(context);

    List<RowsLayoutChild> children = [];

    if (model != null) {
      final int firstRowIndex =
          (verticalOffset / layoutSettings.themeMetrics.row.height).floor();
      final int maxVisibleRowsLength = LayoutUtils.maxVisibleRowsLength(
          scrollOffset: verticalOffset,
          visibleAreaHeight: layoutSettings.cellsBounds.height,
          rowHeight: layoutSettings.themeMetrics.row.height);
      final int visibleRowsLength =
          math.min(layoutSettings.rowsLength, maxVisibleRowsLength);
      if (model!.rowsLength > 0) {
        final int lastRowIndex =
            math.min(firstRowIndex + visibleRowsLength, model!.rowsLength - 1);
        for (int rowIndex = firstRowIndex;
            rowIndex <= lastRowIndex;
            rowIndex++) {
          RowWidget<ROW> row = RowWidget<ROW>(
              index: rowIndex,
              row: model!.rowAt(rowIndex),
              onHover: onHover,
              layoutSettings: layoutSettings,
              rowCallbacks: rowCallbacks,
              scrolling: scrolling,
              horizontalScrollOffsets: horizontalScrollOffsets,
              color: rowColor,
              cursor: rowCursor,
              model: model!,
              columnResizing:
                  model != null ? model!.columnInResizing != null : false);
          children
              .add(RowsLayoutChild(index: rowIndex, last: false, child: row));
        }
        onLastVisibleRow(lastRowIndex);
      } else {
        onLastVisibleRow(null);
      }
      if (lastRowWidget != null && children.length < visibleRowsLength) {
        children.add(RowsLayoutChild(
            index: model!.rowsLength, last: true, child: lastRowWidget!));
        onLastRowWidget(true);
      } else {
        onLastRowWidget(false);
      }

      RowsPaintingSettings paintSettings = RowsPaintingSettings(
          divisorColor: theme.row.dividerColor,
          fillHeight: theme.row.fillHeight,
          lastRowDividerVisible: theme.row.lastDividerVisible,
          rowColor: theme.row.color,
          visibleRowsLength: visibleRowsLength,
          maxVisibleRowsLength: maxVisibleRowsLength,
          firstRowIndex: firstRowIndex);

      return ClipRect(
          child: RowsLayout<ROW>(
              layoutSettings: layoutSettings,
              paintSettings: paintSettings,
              verticalOffset: verticalOffset,
              horizontalScrollOffsets: horizontalScrollOffsets,
              children: children));
    }
    onLastRowWidget(false);
    onLastVisibleRow(-1);
    return Container();
  }
}
