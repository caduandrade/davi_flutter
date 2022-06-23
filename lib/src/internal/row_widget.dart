import 'package:easy_table/src/cell_icon.dart';
import 'package:easy_table/src/cell_style.dart';
import 'package:easy_table/src/column.dart';
import 'package:easy_table/src/internal/columns_layout_child.dart';
import 'package:easy_table/src/internal/columns_layout.dart';
import 'package:easy_table/src/internal/row_callbacks.dart';
import 'package:easy_table/src/internal/column_metrics.dart';
import 'package:easy_table/src/internal/table_layout_settings.dart';
import 'package:easy_table/src/row_color.dart';
import 'package:easy_table/src/row_data.dart';
import 'package:easy_table/src/row_hover_listener.dart';
import 'package:easy_table/src/theme/theme.dart';
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
class RowWidget<ROW> extends StatefulWidget {
  RowWidget(
      {required this.index,
      required this.row,
      required this.onHover,
      required this.layoutSettings,
      required this.scrolling,
      required this.columnResizing,
      required this.color,
      required this.rowCallbacks})
      : super(key: ValueKey<int>(index));

  final ROW row;
  final int index;
  final bool scrolling;
  final bool columnResizing;
  final OnRowHoverListener? onHover;
  final TableLayoutSettings<ROW> layoutSettings;
  final RowCallbacks<ROW> rowCallbacks;
  final EasyTableRowColor<ROW>? color;

  @override
  State<StatefulWidget> createState() => RowWidgetState<ROW>();
}

class RowWidgetState<ROW> extends State<RowWidget<ROW>> {
  late RowData<ROW> _rowData;

  @override
  void initState() {
    super.initState();
    _rowData = RowData(row: widget.row, index: widget.index, hovered: false);
  }

  @override
  void didUpdateWidget(covariant RowWidget<ROW> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _rowData = RowData(
        row: widget.row, index: widget.index, hovered: _rowData.hovered);
  }

  @override
  Widget build(BuildContext context) {
    EasyTableThemeData theme = EasyTableTheme.of(context);

    List<ColumnsLayoutChild<ROW>> children = [];

    for (int columnIndex = 0;
        columnIndex < widget.layoutSettings.columnsMetrics.length;
        columnIndex++) {
      final ColumnMetrics<ROW> columnMetrics =
          widget.layoutSettings.columnsMetrics[columnIndex];
      final EasyTableColumn<ROW> column = columnMetrics.column;
      final Widget cell =
          _buildCellWidget(context: context, column: column, theme: theme);
      children.add(ColumnsLayoutChild<ROW>(index: columnIndex, child: cell));
    }

    Widget layout = ColumnsLayout(
        layoutSettings: widget.layoutSettings, children: children);

    if (widget.rowCallbacks.hasCallback) {
      layout = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _buildOnTap(),
          onDoubleTap: _buildOnDoubleTap(),
          onSecondaryTap: _buildOnSecondaryTap(),
          child: layout);
    }

    Color? color;
    if (widget.color != null) {
      color = widget.color!(_rowData);
    }

    if (!widget.scrolling && !widget.columnResizing) {
      if (widget.rowCallbacks.hasCallback ||
          theme.row.hoverBackground != null ||
          theme.row.hoverForeground != null ||
          widget.onHover != null) {
        if (_rowData.hovered && theme.row.hoverBackground != null) {
          // replace row color
          color = theme.row.hoverBackground!(widget.index);
        }
        _ColorPainter? hoverBackground;
        if (color != null) {
          // row color or hover background
          hoverBackground = _ColorPainter(color);
        }
        _ColorPainter? hoverForeground;
        if (_rowData.hovered && theme.row.hoverForeground != null) {
          Color? color = theme.row.hoverForeground!(widget.index);
          if (color != null) {
            hoverForeground = _ColorPainter(color);
          }
        }
        layout = CustomPaint(
            painter: hoverBackground,
            foregroundPainter: hoverForeground,
            child: layout);
        layout = MouseRegion(
            onEnter: _onEnter,
            cursor: widget.rowCallbacks.hasCallback
                ? SystemMouseCursors.click
                : MouseCursor.defer,
            onExit: _onExit,
            child: layout);
      }
    } else if (color != null) {
      layout = Container(color: color, child: layout);
    }

    return layout;
  }

  Widget _buildCellWidget(
      {required BuildContext context,
      required EasyTableColumn<ROW> column,
      required EasyTableThemeData theme}) {
    // Theme
    EdgeInsets? padding = theme.cell.padding;
    Alignment? alignment = theme.cell.alignment;
    TextStyle? textStyle = theme.cell.textStyle;
    TextOverflow? overflow = theme.cell.overflow;
    // Entire column
    padding = column.cellPadding ?? padding;
    alignment = column.cellAlignment ?? alignment;
    Color? background =
        column.cellBackground != null ? column.cellBackground!(_rowData) : null;
    textStyle = column.cellTextStyle ?? textStyle;
    overflow = column.cellOverflow ?? overflow;
    // Single cell
    if (column.cellStyleBuilder != null) {
      CellStyle? cellStyle = column.cellStyleBuilder!(_rowData);
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
      child = column.cellBuilder!(context, _rowData);
    } else if (column.iconValueMapper != null) {
      CellIcon? cellIcon = column.iconValueMapper!(widget.row);
      if (cellIcon != null) {
        child = Icon(cellIcon.icon, color: cellIcon.color, size: cellIcon.size);
      }
    } else {
      String? value = _stringValue(column: column, row: widget.row);
      if (value != null) {
        child = Text(value,
            overflow: overflow ?? theme.cell.overflow,
            style: textStyle ?? theme.cell.textStyle);
      } else if (theme.cell.nullValueColor != null) {
        background = theme.cell.nullValueColor!(widget.index, _rowData.hovered);
      }
    }
    if (child != null) {
      child = Align(child: child, alignment: alignment);
      if (padding != null) {
        child = Padding(padding: padding, child: child);
      }
    }
    if (background != null) {
      child = Container(child: child, color: background);
    }
    return ClipRect(child: child);
  }

  GestureTapCallback? _buildOnTap() {
    if (widget.rowCallbacks.onRowTap != null) {
      return () => widget.rowCallbacks.onRowTap!(widget.row);
    }
    return null;
  }

  GestureTapCallback? _buildOnDoubleTap() {
    if (widget.rowCallbacks.onRowDoubleTap != null) {
      return () => widget.rowCallbacks.onRowDoubleTap!(widget.row);
    }
    return null;
  }

  GestureTapCallback? _buildOnSecondaryTap() {
    if (widget.rowCallbacks.onRowSecondaryTap != null) {
      return () => widget.rowCallbacks.onRowSecondaryTap!(widget.row);
    }
    return null;
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
    setState(() {
      _rowData = RowData(row: widget.row, index: widget.index, hovered: true);
      if (widget.onHover != null) {
        widget.onHover!(widget.index);
      }
    });
  }

  void _onExit(PointerExitEvent event) {
    setState(() {
      _rowData = RowData(row: widget.row, index: widget.index, hovered: false);
      if (widget.onHover != null) {
        widget.onHover!(null);
      }
    });
  }
}

class _ColorPainter extends CustomPainter {
  _ColorPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _ColorPainter oldDelegate) =>
      color != oldDelegate.color;
}
