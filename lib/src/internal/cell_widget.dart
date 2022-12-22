import 'package:easy_table/src/cell_icon.dart';
import 'package:easy_table/src/cell_style.dart';
import 'package:easy_table/src/column.dart';
import 'package:easy_table/src/internal/cell_key.dart';
import 'package:easy_table/src/row_data.dart';
import 'package:easy_table/src/theme/theme.dart';
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
class CellWidget<ROW> extends StatelessWidget {
  final int columnIndex;
  final RowData<ROW> rowData;
  final EasyTableColumn<ROW> column;

  CellWidget(
      {required this.rowData, required this.column, required this.columnIndex})
      : super(
            key: CellKey(
                row: rowData.index,
                column: columnIndex,
                rowSpan: 1,
                columnSpan: 1));

  @override
  Widget build(BuildContext context) {
    EasyTableThemeData theme = EasyTableTheme.of(context);

    // Theme
    EdgeInsets? padding = theme.cell.padding;
    Alignment? alignment = theme.cell.alignment;
    TextStyle? textStyle = theme.cell.textStyle;
    TextOverflow? overflow = theme.cell.overflow;
    // Entire column
    padding = column.cellPadding ?? padding;
    alignment = column.cellAlignment ?? alignment;
    Color? background =
        column.cellBackground != null ? column.cellBackground!(rowData) : null;
    textStyle = column.cellTextStyle ?? textStyle;
    overflow = column.cellOverflow ?? overflow;
    // Single cell
    if (column.cellStyleBuilder != null) {
      CellStyle? cellStyle = column.cellStyleBuilder!(rowData);
      if (cellStyle != null) {
        padding = cellStyle.padding ?? padding;
        alignment = cellStyle.alignment ?? alignment;
        background = cellStyle.background ?? background;
        textStyle = cellStyle.textStyle ?? textStyle;
        overflow = cellStyle.overflow ?? overflow;
      }
    }

    Widget? child;
    if (column.cellBuilder != null) {
      child = column.cellBuilder!(context, rowData);
    } else if (column.iconValueMapper != null) {
      CellIcon? cellIcon = column.iconValueMapper!(rowData.row);
      if (cellIcon != null) {
        child = Icon(cellIcon.icon, color: cellIcon.color, size: cellIcon.size);
      }
    } else {
      String? value = _stringValue(column: column, row: rowData.row);
      if (value != null) {
        child = Text(value,
            overflow: overflow ?? theme.cell.overflow,
            style: textStyle ?? theme.cell.textStyle);
      } else if (theme.cell.nullValueColor != null) {
        background = theme.cell.nullValueColor!(rowData.index, rowData.hovered);
      }
    }
    if (child != null) {
      child = Align(alignment: alignment, child: child);
      if (padding != null) {
        child = Padding(padding: padding, child: child);
      }
    }
    // To avoid the bug that makes a cursor disappear
    // (https://github.com/flutter/flutter/issues/106767),
    // always build a Container with some color.
    background = background ?? Colors.transparent;
    child = Container(color: background, child: child);
    if (column.cellClip) {
      child = ClipRect(child: child);
    }
    return child;
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
}
