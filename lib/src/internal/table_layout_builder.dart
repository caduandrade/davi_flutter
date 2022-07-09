import 'dart:math' as math;
import 'package:easy_table/src/internal/table_layout_child.dart';
import 'package:easy_table/src/internal/row_callbacks.dart';
import 'package:easy_table/src/internal/table_layout.dart';
import 'package:easy_table/src/internal/row_range.dart';
import 'package:easy_table/src/internal/table_layout_settings.dart';
import 'package:easy_table/src/internal/table_scroll_controllers.dart';
import 'package:easy_table/src/internal/table_scrollbar.dart';
import 'package:easy_table/src/internal/theme_metrics/theme_metrics.dart';
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
class TableLayoutBuilder<ROW> extends StatelessWidget {
  const TableLayoutBuilder(
      {Key? key,
      required this.onHover,
      required this.scrollControllers,
      required this.multiSort,
      required this.onLastVisibleRow,
      required this.model,
      required this.themeMetrics,
      required this.columnsFit,
      required this.visibleRowsLength,
      required this.rowCallbacks,
      required this.onDragScroll,
      required this.scrolling,
      required this.lastRowWidget,
      required this.onLastRowWidget,
      required this.rowColor})
      : super(key: key);

  final OnLastVisibleRowListener? onLastVisibleRow;
  final OnRowHoverListener? onHover;
  final TableScrollControllers scrollControllers;
  final EasyTableModel<ROW>? model;
  final bool multiSort;
  final bool columnsFit;
  final int? visibleRowsLength;
  final OnDragScroll onDragScroll;
  final bool scrolling;
  final RowCallbacks<ROW> rowCallbacks;
  final TableThemeMetrics themeMetrics;
  final Widget? lastRowWidget;
  final OnLastRowWidgetListener? onLastRowWidget;
  final EasyTableRowColor<ROW>? rowColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _builder);
  }

  Widget _builder(BuildContext context, BoxConstraints constraints) {
    final EasyTableThemeData theme = EasyTableTheme.of(context);

    TableLayoutSettings<ROW> layoutSettings = TableLayoutSettings<ROW>(
        constraints: constraints,
        model: model,
        theme: theme,
        columnsFit: columnsFit,
        offsets: scrollControllers.offsets,
        themeMetrics: themeMetrics,
        visibleRowsLength: visibleRowsLength,
        hasLastRowWidget: lastRowWidget != null);

    final List<TableLayoutChild> children = [];

    if (layoutSettings.hasVerticalScrollbar) {
      children.add(TableLayoutChild.verticalScrollbar(
          child: TableScrollbar(
              axis: Axis.vertical,
              contentSize: layoutSettings.contentHeight,
              scrollController: scrollControllers.vertical,
              color: theme.scrollbar.verticalColor,
              borderColor: theme.scrollbar.verticalBorderColor,
              onDragScroll: onDragScroll)));
    }

    if (themeMetrics.header.visible) {
      children.add(TableLayoutChild.header(
          layoutSettings: layoutSettings,
          model: model,
          resizable: !columnsFit,
          multiSort: multiSort));
      if (layoutSettings.hasVerticalScrollbar) {
        children.add(TableLayoutChild.topCorner());
      }
    }

    if (layoutSettings.hasHorizontalScrollbar) {
      children.add(TableLayoutChild.leftPinnedHorizontalScrollbar(
          TableScrollbar(
              axis: Axis.horizontal,
              scrollController: scrollControllers.leftPinnedContentArea,
              color: theme.scrollbar.pinnedHorizontalColor,
              borderColor: theme.scrollbar.pinnedHorizontalBorderColor,
              contentSize: layoutSettings.leftPinnedContentWidth,
              onDragScroll: onDragScroll)));
      children.add(TableLayoutChild.unpinnedHorizontalScrollbar(TableScrollbar(
          axis: Axis.horizontal,
          scrollController: scrollControllers.unpinnedContentArea,
          color: theme.scrollbar.unpinnedHorizontalColor,
          borderColor: theme.scrollbar.unpinnedHorizontalBorderColor,
          contentSize: layoutSettings.unpinnedContentWidth,
          onDragScroll: onDragScroll)));
      if (layoutSettings.hasVerticalScrollbar) {
        children.add(TableLayoutChild.bottomCorner());
      }
    }

    children.add(TableLayoutChild<ROW>.rows(
        model: model,
        layoutSettings: layoutSettings,
        scrolling: scrolling,
        onHover: onHover,
        rowCallbacks: rowCallbacks,
        rowColor: rowColor,
        lastRowWidget: lastRowWidget));

    Widget layout = TableLayout<ROW>(
        layoutSettings: layoutSettings, theme: theme, children: children);
    final bool hasLastRowListener =
        onLastRowWidget != null && layoutSettings.hasLastRowWidget;
    final bool hasListener = hasLastRowListener || onLastVisibleRow != null;
    if (hasListener && model != null) {
      layout = NotificationListener<ScrollMetricsNotification>(
          child: layout,
          onNotification: (notification) {
            RowRange? rowRange = RowRange.build(
                scrollOffset: scrollControllers.verticalOffset,
                height: layoutSettings.cellsBounds.height,
                rowHeight: themeMetrics.row.height);
            if (rowRange != null) {
              if (hasLastRowListener) {
                onLastRowWidget!(rowRange.lastIndex >= model!.rowsLength);
              }
              if (onLastVisibleRow != null && model!.isRowsNotEmpty) {
                onLastVisibleRow!(
                    math.min(model!.rowsLength - 1, rowRange.lastIndex));
              }
            }
            return false;
          });
    }
    return layout;
  }
}
