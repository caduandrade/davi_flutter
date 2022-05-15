import 'dart:collection';

import 'package:easy_table/src/column.dart';
import 'package:easy_table/src/internal/columns_metrics.dart';
import 'package:easy_table/src/internal/set_hovered_row_index.dart';
import 'package:easy_table/src/internal/table_row_layout_delegate.dart';
import 'package:easy_table/src/internal/table_row_painter.dart';
import 'package:easy_table/src/model.dart';
import 'package:easy_table/src/row_callbacks.dart';
import 'package:easy_table/src/theme/theme.dart';
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// [EasyTable] row.
@internal
class TableRowWidget<ROW> extends StatelessWidget {
  const TableRowWidget(
      {Key? key,
      required this.delegate,
      required this.model,
      required this.columnsMetrics,
      required this.visibleRowIndex,
      required this.columns,
      required this.setHoveredRowIndex,
      required this.hoveredRowIndex,
      required this.onRowTap,
      required this.onRowSecondaryTap,
      required this.onRowDoubleTap,
      required this.contentHeight})
      : super(key: key);

  final EasyTableModel<ROW> model;
  final ColumnsMetrics columnsMetrics;
  final int visibleRowIndex;
  final UnmodifiableListView<EasyTableColumn<ROW>> columns;
  final int? hoveredRowIndex;
  final RowTapCallback<ROW>? onRowTap;
  final RowTapCallback<ROW>? onRowSecondaryTap;
  final RowDoubleTapCallback<ROW>? onRowDoubleTap;
  final SetHoveredRowIndex setHoveredRowIndex;
  final TableRowLayoutDelegate delegate;
  final double contentHeight;

  @override
  Widget build(BuildContext context) {
    final EasyTableThemeData theme = EasyTableTheme.of(context);

    final ROW row = model.visibleRowAt(visibleRowIndex);

    Widget? rowWidget;
    List<LayoutId> children = [];
    for (int columnIndex = 0; columnIndex < columns.length; columnIndex++) {
      final EasyTableColumn<ROW> column = columns[columnIndex];
      if (column.cellBuilder != null) {
        Widget cell = ClipRect(child: column.cellBuilder!(context, row));
        children.add(LayoutId(id: columnIndex, child: cell));
      }
    }
    if (children.isNotEmpty) {
      rowWidget =
          CustomMultiChildLayout(delegate: delegate, children: children);
    }
    Color? nullValueColor;
    if (theme.cell.nullValueColor != null) {
      nullValueColor = theme.cell.nullValueColor!(visibleRowIndex);
    }
    rowWidget = CustomPaint(
        child: rowWidget,
        painter: TableRowPainter<ROW>(
            row: row,
            cellPadding: theme.cell.padding,
            cellAlignment: theme.cell.alignment,
            columns: columns,
            columnsMetrics: columnsMetrics,
            contentHeight: contentHeight,
            nullValueColor: nullValueColor));

    if (hoveredRowIndex == visibleRowIndex && theme.row.hoveredColor != null) {
      rowWidget = Container(
          child: rowWidget, color: theme.row.hoveredColor!(visibleRowIndex));
    } else if (theme.row.color != null) {
      rowWidget =
          Container(child: rowWidget, color: theme.row.color!(visibleRowIndex));
    }

    MouseCursor cursor = MouseCursor.defer;

    if (onRowTap != null || onRowDoubleTap != null) {
      cursor = SystemMouseCursors.click;
      rowWidget = GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: rowWidget,
          onDoubleTap:
              onRowDoubleTap != null ? () => onRowDoubleTap!(row) : null,
          onTap: onRowTap != null ? () => onRowTap!(row) : null,
          onSecondaryTap:
              onRowSecondaryTap != null ? () => onRowSecondaryTap!(row) : null);
    }

    rowWidget = MouseRegion(
        cursor: cursor,
        child: rowWidget,
        onEnter: (event) => setHoveredRowIndex(visibleRowIndex));

    if (theme.rowDividerThickness > 0) {
      rowWidget = Padding(
          child: rowWidget,
          padding: EdgeInsets.only(bottom: theme.rowDividerThickness));
    }

    return rowWidget;
  }
}
