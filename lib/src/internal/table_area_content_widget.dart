import 'dart:collection';

import 'package:easy_table/src/column.dart';
import 'package:easy_table/src/internal/columns_metrics.dart';
import 'package:easy_table/src/internal/divider_painter.dart';
import 'package:easy_table/src/internal/set_hovered_row_index.dart';
import 'package:easy_table/src/internal/table_row_layout_delegate.dart';
import 'package:easy_table/src/internal/table_row_widget.dart';
import 'package:easy_table/src/model.dart';
import 'package:easy_table/src/row_callbacks.dart';
import 'package:easy_table/src/theme/theme.dart';
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// [EasyTable] area content widget.
@internal
class TableAreaContentWidget<ROW> extends StatelessWidget {
  factory TableAreaContentWidget(
      {Key? key,
      required EasyTableModel<ROW> model,
      required ScrollController verticalScrollController,
      required ScrollController horizontalScrollController,
      required ColumnsMetrics columnsMetrics,
      required double contentWidth,
      required double rowHeight,
      required bool columnsFit,
      required RowTapCallback<ROW>? onRowTap,
      required RowTapCallback<ROW>? onRowSecondaryTap,
      required RowDoubleTapCallback<ROW>? onRowDoubleTap,
      required int? hoveredRowIndex,
      required SetHoveredRowIndex setHoveredRowIndex,
      required ScrollBehavior scrollBehavior,
      required ColumnFilter columnFilter}) {
    List<EasyTableColumn<ROW>> columns = [];
    for (int columnIndex = 0;
        columnIndex < model.columnsLength;
        columnIndex++) {
      EasyTableColumn<ROW> column = model.columnAt(columnIndex);
      if (columnFilter == ColumnFilter.all ||
          (columnFilter == ColumnFilter.unpinnedOnly &&
              column.pinned == false) ||
          (columnFilter == ColumnFilter.pinnedOnly && column.pinned)) {
        columns.add(column);
      }
    }
    return TableAreaContentWidget._(
        model: model,
        verticalScrollController: verticalScrollController,
        horizontalScrollController: horizontalScrollController,
        columnsMetrics: columnsMetrics,
        contentWidth: contentWidth,
        rowHeight: rowHeight,
        columnsFit: columnsFit,
        onRowTap: onRowTap,
        onRowSecondaryTap: onRowSecondaryTap,
        onRowDoubleTap: onRowDoubleTap,
        hoveredRowIndex: hoveredRowIndex,
        setHoveredRowIndex: setHoveredRowIndex,
        scrollBehavior: scrollBehavior,
        columns: UnmodifiableListView<EasyTableColumn<ROW>>(columns));
  }

  const TableAreaContentWidget._(
      {Key? key,
      required this.model,
      required this.verticalScrollController,
      required this.horizontalScrollController,
      required this.columnsMetrics,
      required this.contentWidth,
      required this.rowHeight,
      required this.columnsFit,
      required this.onRowTap,
      required this.onRowSecondaryTap,
      required this.onRowDoubleTap,
      required this.hoveredRowIndex,
      required this.columns,
      required this.setHoveredRowIndex,
      required this.scrollBehavior})
      : super(key: key);

  final EasyTableModel<ROW> model;
  final ScrollController verticalScrollController;
  final ScrollController horizontalScrollController;
  final ColumnsMetrics columnsMetrics;
  final double contentWidth;
  final double rowHeight;
  final bool columnsFit;
  final RowTapCallback<ROW>? onRowTap;
  final RowTapCallback<ROW>? onRowSecondaryTap;
  final RowDoubleTapCallback<ROW>? onRowDoubleTap;
  final int? hoveredRowIndex;
  final SetHoveredRowIndex setHoveredRowIndex;
  final UnmodifiableListView<EasyTableColumn<ROW>> columns;
  final ScrollBehavior scrollBehavior;

  @override
  Widget build(BuildContext context) {
    EasyTableThemeData theme = EasyTableTheme.of(context);

    TableRowLayoutDelegate delegate =
        TableRowLayoutDelegate(columnsMetrics: columnsMetrics);

    Widget list = ListView.builder(
        controller: verticalScrollController,
        itemExtent: rowHeight,
        itemBuilder: (context, index) {
          return TableRowWidget<ROW>(
              key: ValueKey(index),
              model: model,
              delegate: delegate,
              columnsMetrics: columnsMetrics,
              columns: columns,
              visibleRowIndex: index,
              onRowTap: onRowTap,
              onRowSecondaryTap: onRowSecondaryTap,
              onRowDoubleTap: onRowDoubleTap,
              hoveredRowIndex: hoveredRowIndex,
              setHoveredRowIndex: setHoveredRowIndex);
        },
        itemCount: model.visibleRowsLength);

    list = ScrollConfiguration(behavior: scrollBehavior, child: list);

    if (theme.row.columnDividerColor != null) {
      list = CustomPaint(
          child: list,
          foregroundPainter: DividerPainter(
              columnsMetrics: columnsMetrics,
              color: theme.row.columnDividerColor!));
    }

    list =
        MouseRegion(child: list, onExit: (event) => setHoveredRowIndex(null));

    if (columnsFit) {
      return list;
    }

    Widget customScrollView = CustomScrollView(
        scrollDirection: Axis.horizontal,
        controller: horizontalScrollController,
        slivers: [
          SliverToBoxAdapter(
              child: SizedBox(
                  child: ScrollConfiguration(
                      behavior: scrollBehavior, child: list),
                  width: contentWidth))
        ]);

    return ScrollConfiguration(
        behavior: scrollBehavior, child: customScrollView);
  }
}
