import 'package:easy_table/src/cell.dart';
import 'package:easy_table/src/column.dart';
import 'package:easy_table/src/internal/columns_metrics.dart';
import 'package:easy_table/src/internal/horizontal_layout.dart';
import 'package:easy_table/src/internal/set_hovered_row_index.dart';
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
      required this.model,
      required this.columnsMetrics,
      required this.visibleRowIndex,
      required this.columnFilter,
      required this.setHoveredRowIndex,
      required this.hoveredRowIndex,
      required this.onRowTap,
      required this.onRowSecondaryTap,
      required this.onRowDoubleTap})
      : super(key: key);

  final EasyTableModel<ROW> model;
  final ColumnsMetrics columnsMetrics;
  final int visibleRowIndex;
  final ColumnFilter columnFilter;
  final int? hoveredRowIndex;
  final RowTapCallback<ROW>? onRowTap;
  final RowTapCallback<ROW>? onRowSecondaryTap;
  final RowDoubleTapCallback<ROW>? onRowDoubleTap;
  final SetHoveredRowIndex setHoveredRowIndex;

  @override
  Widget build(BuildContext context) {
    EasyTableThemeData theme = EasyTableTheme.of(context);
    ROW row = model.visibleRowAt(visibleRowIndex);
    List<Widget> children = [];
    for (int columnIndex = 0;
        columnIndex < model.columnsLength;
        columnIndex++) {
      EasyTableColumn<ROW> column = model.columnAt(columnIndex);
      if (columnFilter == ColumnFilter.all ||
          (columnFilter == ColumnFilter.unpinnedOnly &&
              column.pinned == false) ||
          (columnFilter == ColumnFilter.pinnedOnly && column.pinned)) {
        children.add(_buildCell(context: context, column: column));
      }
    }

    Widget rowWidget =
        HorizontalLayout(columnsMetrics: columnsMetrics, children: children);

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

  /// Builds a table cell
  Widget _buildCell(
      {required BuildContext context, required EasyTableColumn<ROW> column}) {
    EasyTableThemeData theme = EasyTableTheme.of(context);
    Widget? cell;

    final ROW row = model.visibleRowAt(visibleRowIndex);

    if (column.cellBuilder != null) {
      cell = column.cellBuilder!(context, row);
    } else {
      final TextStyle? textStyle = theme.cell.textStyle;
      bool nullValue = false;
      if (column.stringValueMapper != null) {
        final String? value = column.stringValueMapper!(row);
        if (value != null) {
          cell = EasyTableCell.string(value: value, textStyle: textStyle);
        } else {
          nullValue = true;
        }
      } else if (column.intValueMapper != null) {
        final int? value = column.intValueMapper!(row);
        if (value != null) {
          cell = EasyTableCell.int(value: value, textStyle: textStyle);
        } else {
          nullValue = true;
        }
      } else if (column.doubleValueMapper != null) {
        final double? value = column.doubleValueMapper!(row);
        if (value != null) {
          cell = EasyTableCell.double(
              value: value,
              fractionDigits: column.fractionDigits,
              textStyle: textStyle);
        } else {
          nullValue = true;
        }
      } else if (column.objectValueMapper != null) {
        final Object? value = column.objectValueMapper!(row);
        if (value != null) {
          return EasyTableCell.string(
              value: value.toString(), textStyle: textStyle);
        } else {
          nullValue = true;
        }
      }
      if (nullValue && theme.cell.nullValueColor != null) {
        cell = Container(color: theme.cell.nullValueColor!(visibleRowIndex));
      }
    }
    return ClipRect(child: cell);
  }
}
