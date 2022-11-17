import 'dart:math' as math;

import 'package:easy_table/src/internal/layout_utils.dart';
import 'package:easy_table/src/internal/row_callbacks.dart';
import 'package:easy_table/src/internal/row_widget.dart';
import 'package:easy_table/src/internal/rows_layout.dart';
import 'package:easy_table/src/internal/rows_layout_child.dart';
import 'package:easy_table/src/internal/rows_painting_settings.dart';
import 'package:easy_table/src/internal/scroll_offsets.dart';
import 'package:easy_table/src/internal/table_layout_settings.dart';
import 'package:easy_table/src/last_row_widget_listener.dart';
import 'package:easy_table/src/last_visible_row_listener.dart';
import 'package:easy_table/src/model.dart';
import 'package:easy_table/src/row_color.dart';
import 'package:easy_table/src/row_hover_listener.dart';
import 'package:easy_table/src/theme/theme.dart';
import 'package:easy_table/src/theme/theme_data.dart';
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
      required this.verticalOffset,
      required this.horizontalScrollOffsets,
      required this.lastRowWidget,
      required this.onLastRowWidget,
      required this.onLastVisibleRow})
      : super(key: key);

  final EasyTableModel<ROW>? model;
  final TableLayoutSettings layoutSettings;
  final bool scrolling;
  final double verticalOffset;
  final HorizontalScrollOffsets horizontalScrollOffsets;
  final OnRowHoverListener? onHover;
  final RowCallbacks<ROW> rowCallbacks;
  final Widget? lastRowWidget;
  final EasyTableRowColor<ROW>? rowColor;
  final OnLastRowWidgetListener onLastRowWidget;
  final OnLastVisibleRowListener onLastVisibleRow;

  @override
  Widget build(BuildContext context) {
    EasyTableThemeData theme = EasyTableTheme.of(context);

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

      final int lastRowIndex = math.min(firstRowIndex + visibleRowsLength, model!.rowsLength-1);
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
            model: model!,
            columnResizing:
                model != null ? model!.columnInResizing != null : false);
        children.add(RowsLayoutChild(index: rowIndex, last: false, child: row));
      }
      onLastVisibleRow(lastRowIndex);
      if (lastRowWidget != null && children.length < visibleRowsLength) {
        children.add(RowsLayoutChild(
            index: model!.rowsLength, last: true, child: lastRowWidget!));
        onLastRowWidget(true);
      } else{
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
