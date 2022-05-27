import 'dart:collection';
import 'dart:math' as math;
import 'package:easy_table/src/cell_icon.dart';
import 'package:easy_table/src/cell_style.dart';
import 'package:easy_table/src/column.dart';
import 'package:easy_table/src/internal/columns_metrics.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
class TableRowPainter<ROW> extends CustomPainter {
  TableRowPainter(
      {required this.columnsMetrics,
      required this.row,
      required this.columns,
      required this.contentHeight,
      required this.nullValueColor,
      required this.themePadding,
      required this.themeTextStyle,
      required this.themeAlignment});

  final UnmodifiableListView<EasyTableColumn<ROW>> columns;
  final ColumnsMetrics columnsMetrics;
  final ROW row;
  final double contentHeight;
  final EdgeInsets? themePadding;
  final Alignment themeAlignment;
  final Color? nullValueColor;
  final TextStyle? themeTextStyle;
  final TextPainter _defaultTextPainter =
      TextPainter(textDirection: TextDirection.ltr, ellipsis: '...');

  @override
  void paint(Canvas canvas, Size size) {
    for (int columnIndex = 0; columnIndex < columns.length; columnIndex++) {
      final EasyTableColumn<ROW> column = columns[columnIndex];
      if (column.cellBuilder != null) {
        // Ignore.
        continue;
      }

      Alignment alignment = column.cellAlignment ?? themeAlignment;
      TextStyle? textStyle = column.cellTextStyle ?? themeTextStyle;
      EdgeInsets? padding = column.cellPadding ?? themePadding;

      final LayoutWidth layoutWidth = columnsMetrics.columns[columnIndex];
      final double left = layoutWidth.x;
      const double top = 0;
      final double right = left + layoutWidth.width;
      final double bottom = top + size.height;

      TextPainter? textPainter;
      Color? background;

      if (column.iconValueMapper != null) {
        CellIcon? cellIcon = column.iconValueMapper!(row);
        if (cellIcon != null) {
          if (cellIcon.alignment != null) {
            alignment = cellIcon.alignment!;
          }
          if (cellIcon.background != null) {
            background = cellIcon.background;
          }
          IconData icon = cellIcon.icon;
          textPainter = TextPainter(
              textDirection: TextDirection.ltr,
              text: TextSpan(
                  text: String.fromCharCode(icon.codePoint),
                  style: TextStyle(
                      fontFamily: icon.fontFamily,
                      fontSize: cellIcon.size,
                      color: cellIcon.color)));
        }
      } else {
        CellStyle? cellStyle;
        if (column.cellStyleBuilder != null) {
          cellStyle = column.cellStyleBuilder!(row);
        }
        if (cellStyle != null) {
          if (cellStyle.alignment != null) {
            alignment = cellStyle.alignment!;
          }
          if (cellStyle.textStyle != null) {
            textStyle = cellStyle.textStyle;
          }
          if (cellStyle.background != null) {
            background = cellStyle.background;
          }
          if (cellStyle.padding != null) {
            padding = cellStyle.padding;
          }
        }

        String? value = _stringValue(column: column);
        if (value != null) {
          textPainter = _defaultTextPainter
            ..text = TextSpan(text: value, style: textStyle);
        }
      }

      if (background != null) {
        _paintBackground(
            left: left,
            right: right,
            top: top,
            bottom: bottom,
            canvas: canvas,
            color: background);
      }

      if (textPainter != null) {
        _paintTextPainter(
            left: left,
            right: right,
            top: top,
            bottom: bottom,
            canvas: canvas,
            size: size,
            layoutWidth: layoutWidth,
            alignment: alignment,
            padding: padding,
            textPainter: textPainter);
      } else if (nullValueColor != null && background == null) {
        _paintBackground(
            left: left,
            right: right,
            top: top,
            bottom: bottom,
            canvas: canvas,
            color: nullValueColor!);
      }
    }
  }

  String? _stringValue({required EasyTableColumn<ROW> column}) {
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

  void _paintTextPainter(
      {required double left,
      required double top,
      required double right,
      required double bottom,
      required LayoutWidth layoutWidth,
      required Canvas canvas,
      required Size size,
      required TextPainter textPainter,
      required Alignment alignment,
      required EdgeInsets? padding}) {
    double width = layoutWidth.width;
    if (padding != null) {
      left = math.min(left + width, left + padding.left);
      top = math.min(top + size.height, top + padding.top);
      right = math.max(left, right - padding.right);
      bottom = math.max(top, bottom - padding.bottom);
      width = math.max(0, width - padding.horizontal);
    }
    textPainter.layout(maxWidth: width);
    if (alignment.y == 0) {
      // vertical center
      top += math.max(0, (contentHeight - textPainter.height) * 0.5);
    } else if (alignment.y == 1) {
      // bottom
      top += math.max(0, contentHeight - textPainter.height);
    }
    if (alignment.x == 0) {
      // horizontal center
      left += math.max(0, (width - textPainter.width) * 0.5);
    } else if (alignment.x == 1) {
      // right
      left += math.max(0, width - textPainter.width);
    }
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(left, top, right, bottom));
    textPainter.paint(canvas, Offset(left, top));
    canvas.restore();
  }

  void _paintBackground(
      {required double left,
      required double top,
      required double right,
      required double bottom,
      required Canvas canvas,
      required Color color}) {
    Paint paint = Paint()..color = color;
    canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), paint);
  }

  @override
  bool shouldRepaint(covariant TableRowPainter oldDelegate) => true;
}
