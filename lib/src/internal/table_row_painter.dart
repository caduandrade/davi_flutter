import 'dart:collection';
import 'dart:math' as math;
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
      required this.cellPadding});

  final UnmodifiableListView<EasyTableColumn<ROW>> columns;
  final ColumnsMetrics columnsMetrics;
  final ROW row;
  final double contentHeight;
  final EdgeInsets? cellPadding;
  final Color? nullValueColor;
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

      final LayoutWidth layoutWidth = columnsMetrics.columns[columnIndex];
      final double left = layoutWidth.x;
      const double top = 0;
      final double right = left + layoutWidth.width;
      final double bottom = top + size.height;

      TextPainter? textPainter;

      if (column.iconValueMapper != null) {
        IconData? icon = column.iconValueMapper!(row);
        if (icon != null) {
          textPainter = TextPainter(
              textDirection: TextDirection.ltr,
              text: TextSpan(
                  text: String.fromCharCode(icon.codePoint),
                  style: TextStyle(fontFamily: icon.fontFamily, fontSize: 26)));
        }
      } else {
        String? value = _stringValue(column: column);
        if (value != null) {
          textPainter = _defaultTextPainter..text = TextSpan(text: value);
        }
      }

      if (textPainter != null) {
        _paintTextPainter(
            left: left,
            right: right,
            top: top,
            bottom: bottom,
            canvas: canvas,
            layoutWidth: layoutWidth,
            textPainter: textPainter);
      } else {
        _paintNull(
            left: left, right: right, top: top, bottom: bottom, canvas: canvas);
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
      required TextPainter textPainter}) {
    double width = layoutWidth.width;
    if (cellPadding != null) {
      left += cellPadding!.left;
      top += cellPadding!.top;
      right -= cellPadding!.right;
      bottom -= cellPadding!.bottom;
      width -= cellPadding!.horizontal;
    }
    textPainter.layout(maxWidth: width);
    top += math.max(0, (contentHeight - textPainter.height) * 0.5);
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(left, top, right, bottom));
    textPainter.paint(canvas, Offset(left, top));
    canvas.restore();
  }

  void _paintNull(
      {required double left,
      required double top,
      required double right,
      required double bottom,
      required Canvas canvas}) {
    if (nullValueColor != null) {
      Paint paint = Paint()..color = nullValueColor!;
      canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), paint);
    }
  }

  @override
  bool shouldRepaint(covariant TableRowPainter oldDelegate) => true;
}
