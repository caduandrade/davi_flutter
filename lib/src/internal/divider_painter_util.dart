import 'package:easy_table/src/internal/columns_metrics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

@internal
class DividerPainterUtil {
  static void paint(
      {required Canvas canvas,
      required Offset offset,
      required Color color,
      required ColumnsMetrics columnsMetrics,
      required double height}) {
    Paint paint = Paint()..color = color;
    for (int i = 0; i < columnsMetrics.dividers.length; i++) {
      LayoutWidth layoutWidth = columnsMetrics.dividers[i];
      canvas.drawRect(
          Rect.fromLTWH(
              layoutWidth.x + offset.dx, offset.dy, layoutWidth.width, height),
          paint);
    }
  }
}
