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
      required this.cellPadding,
      required this.cellTextStyle,
      required this.cellAlignment});

  final UnmodifiableListView<EasyTableColumn<ROW>> columns;
  final ColumnsMetrics columnsMetrics;
  final ROW row;
  final double contentHeight;
  final EdgeInsets? cellPadding;
  final Alignment cellAlignment;
  final Color? nullValueColor;
  final TextStyle? cellTextStyle;
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

      Alignment alignment = column.cellAlignment ?? cellAlignment;
      TextStyle? textStyle = column.cellTextStyle ?? cellTextStyle;

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
        String? value = _stringValue(column: column);
        if (value != null) {
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
          }
          textPainter = _defaultTextPainter
            ..text = TextSpan(text: value, style: textStyle);
        }
      }

      if (textPainter != null) {
        if (background != null) {
          _paintBackground(
              left: left,
              right: right,
              top: top,
              bottom: bottom,
              canvas: canvas,
              color: background);
        }
        _paintTextPainter(
            left: left,
            right: right,
            top: top,
            bottom: bottom,
            canvas: canvas,
            size: size,
            layoutWidth: layoutWidth,
            alignment: alignment,
            textPainter: textPainter);
      } else if (nullValueColor != null) {
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
      required Alignment alignment}) {
    double width = layoutWidth.width;
    if (cellPadding != null) {
      left = math.min(left + width, left + cellPadding!.left);
      top = math.min(top + size.height, top + cellPadding!.top);
      right = math.max(left, right - cellPadding!.right);
      bottom = math.max(top, bottom - cellPadding!.bottom);
      width = math.max(0, width - cellPadding!.horizontal);
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
