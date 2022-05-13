import 'package:easy_table/src/internal/columns_metrics.dart';
import 'package:easy_table/src/internal/divider_painter_util.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
class DividerPainter extends CustomPainter {
  DividerPainter({required this.columnsMetrics, required this.color});

  final ColumnsMetrics columnsMetrics;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    DividerPainterUtil.paint(
        canvas: canvas,
        offset: Offset.zero,
        color: color,
        columnsMetrics: columnsMetrics,
        height: size.height);
  }

  @override
  bool shouldRepaint(covariant DividerPainter oldDelegate) => false;
}
