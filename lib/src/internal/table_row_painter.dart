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
  final TextPainter _textPainter =
      TextPainter(textDirection: TextDirection.ltr, ellipsis: '...');

  @override
  void paint(Canvas canvas, Size size) {
    for (int columnIndex = 0; columnIndex < columns.length; columnIndex++) {
      final EasyTableColumn<ROW> column = columns[columnIndex];
      if (column.cellBuilder == null) {
        String? value;
        if (column.stringValueMapper != null) {
          value = column.stringValueMapper!(row);
        } else if (column.intValueMapper != null) {
          value = column.intValueMapper!(row)?.toString();
        } else if (column.doubleValueMapper != null) {
          final double? doubleValue = column.doubleValueMapper!(row);
          if (doubleValue != null) {
            if (column.fractionDigits != null) {
              value = doubleValue.toStringAsFixed(column.fractionDigits!);
            } else {
              value = doubleValue.toString();
            }
          }
        } else if (column.objectValueMapper != null) {
          value = column.objectValueMapper!(row)?.toString();
        }
        LayoutWidth layoutWidth = columnsMetrics.columns[columnIndex];
        _paint(
            layoutWidth: layoutWidth, value: value, size: size, canvas: canvas);
      }
    }
  }

  void _paint(
      {required LayoutWidth layoutWidth,
      required String? value,
      required Size size,
      required Canvas canvas}) {
    double left = layoutWidth.x;
    double top = 0;
    double right = left + layoutWidth.width;
    double bottom = top + size.height;

    if (value != null) {
      _textPainter.text = TextSpan(text: value);
      double width = layoutWidth.width;
      if (cellPadding != null) {
        left += cellPadding!.left;
        top += cellPadding!.top;
        right -= cellPadding!.right;
        bottom -= cellPadding!.bottom;
        width -= cellPadding!.horizontal;
      }
      _textPainter.layout(maxWidth: width);
      top += math.max(0, (contentHeight - _textPainter.height) * 0.5);
      canvas.save();
      canvas.clipRect(Rect.fromLTRB(left, top, right, bottom));
      _textPainter.paint(canvas, Offset(left, top));
      canvas.restore();
    } else if (nullValueColor != null) {
      Paint paint = Paint()..color = nullValueColor!;
      canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), paint);
    }
  }

  @override
  bool shouldRepaint(covariant TableRowPainter oldDelegate) => true;
}
