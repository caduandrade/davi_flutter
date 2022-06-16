import 'package:easy_table/src/cell_icon.dart';
import 'package:easy_table/src/cell_style.dart';
import 'package:easy_table/src/column.dart';
import 'package:easy_table/src/experimental/layout_v3/column_layout/columns_layout_child_v3.dart';
import 'package:easy_table/src/experimental/layout_v3/column_layout/columns_layout_v3.dart';
import 'package:easy_table/src/experimental/metrics/column_metrics_v3.dart';
import 'package:easy_table/src/experimental/metrics/table_layout_settings_v3.dart';
import 'package:easy_table/src/theme/theme.dart';
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class RowV3<ROW> extends StatefulWidget {
  RowV3({required this.rowIndex, required this.row, required this.layoutSettings}): super(key: ValueKey<int>(rowIndex));

  final ROW row;
  final int rowIndex;
final  TableLayoutSettingsV3<ROW> layoutSettings;

  @override
  State<StatefulWidget> createState() => RowV3State<ROW>();
}

class RowV3State<ROW> extends State<RowV3<ROW>> {
  bool _enter = false;
  @override
  Widget build(BuildContext context) {
    EasyTableThemeData theme =EasyTableTheme.of(context);

    List<ColumnsLayoutChildV3<ROW>> children = [];

    for (int columnIndex = 0;
    columnIndex < widget.layoutSettings.columnsMetrics.length;
    columnIndex++) {
      final ColumnMetricsV3<ROW> columnMetrics = widget.layoutSettings.columnsMetrics[columnIndex];
      final  EasyTableColumn<ROW> column = columnMetrics.column;
      final Widget cell = _buildCellWidget(
          context: context,
          row: widget.row,
          rowIndex: widget.rowIndex,
          column: column,
          theme: theme);
      children.add(ColumnsLayoutChildV3<ROW>(index: columnIndex, child: cell));
    }

    Color? color = _enter ? Colors.blue[300] : null;
    return MouseRegion(
        onEnter: _onEnter,
        cursor: SystemMouseCursors.click,
        onExit: _onExit,
        child: Container(
            color: color,
            child: ColumnsLayoutV3(
                layoutSettings: widget.layoutSettings, children: children)));
  }

  Widget _buildCellWidget(
      {required BuildContext context,
        required ROW row,
        required int rowIndex,
        required EasyTableColumn<ROW> column,
        required EasyTableThemeData theme}) {
    EdgeInsets? padding;
    Alignment? alignment;
    Color? background;
    TextStyle? textStyle;
    TextOverflow? overflow;
    if (column.cellStyleBuilder != null) {
      CellStyle? cellStyle = column.cellStyleBuilder!(row);
      if (cellStyle != null) {
        background = cellStyle.background;
        alignment = cellStyle.alignment;
        padding = cellStyle.padding;
        textStyle = cellStyle.textStyle;
        overflow = cellStyle.overflow;
      }
    }

    Widget? child;
    if (column.cellBuilder != null) {
      child = column.cellBuilder!(context, row, rowIndex);
    } else if (column.iconValueMapper != null) {
      CellIcon? cellIcon = column.iconValueMapper!(row);
      if (cellIcon != null) {
        if (cellIcon.alignment != null) {
          //TODO check
          //alignment = cellIcon.alignment!;
        }
        if (cellIcon.background != null) {
          //TODO check
          // background = cellIcon.background;
        }
        child = Icon(cellIcon.icon, color: cellIcon.color, size: cellIcon.size);
      }
    } else {
      String? value = _stringValue(column: column, row: row);
      if (value != null) {
        child = Text(value,
            overflow: overflow ?? theme.cell.overflow,
            style: textStyle ?? theme.cell.textStyle);
      } else if (background == null && theme.cell.nullValueColor != null) {
        background = theme.cell.nullValueColor!(rowIndex);
      }
    }
    if (child != null) {
      child = Align(child: child, alignment: alignment ?? theme.cell.alignment);
      EdgeInsetsGeometry? p = padding ?? theme.cell.padding;
      if (p != null) {
        child = Padding(padding: p, child: child);
      }
    }
    if (background != null) {
      child = Container(child: child, color: background);
    }
    //TODO optional clip?
    return ClipRect(child: child);
  }

  String? _stringValue(
      {required EasyTableColumn<ROW> column, required ROW row}) {
    if (column.stringValueMapper != null) {
      return column.stringValueMapper!(row);
    } else if (column.intValueMapper != null) {
      return column.intValueMapper!(row)?.toString();
    } else if (column.doubleValueMapper != null) {
      final double? doubleValue = column.doubleValueMapper!(row);
      if (doubleValue != null) {
        if (column.fractionDigits != null) {
          return doubleValue.toStringAsFixed(column.fractionDigits!);
        } else {
          return doubleValue.toString();
        }
      }
    } else if (column.objectValueMapper != null) {
      return column.objectValueMapper!(row)?.toString();
    }
    return null;
  }

  void _onEnter(PointerEnterEvent event) {
    setState(() => _enter = true);
  }

  void _onExit(PointerExitEvent event) {
    setState(() => _enter = false);
  }
}
