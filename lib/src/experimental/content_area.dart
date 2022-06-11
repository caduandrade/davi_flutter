import 'package:easy_table/src/experimental/columns_metrics_exp.dart';
import 'package:easy_table/src/experimental/content_area_id.dart';
import 'package:easy_table/src/experimental/table_layout_parent_data_exp.dart';
import 'package:easy_table/src/experimental/table_layout_settings.dart';
import 'package:easy_table/src/experimental/table_paint_settings.dart';
import 'package:flutter/material.dart';

class ContentArea {
  ContentArea(
      {required this.id,
      required this.headerAreaDebugColor,
      required this.scrollbarAreaDebugColor,
      required this.columnsMetrics});

  final ContentAreaId id;
  final Color headerAreaDebugColor;
  final Color scrollbarAreaDebugColor;
  ColumnsMetricsExp columnsMetrics;
  final List<RenderBox> children = [];
  RenderBox? scrollbar;

  Rect bounds = Rect.zero;

  void clear() {
    children.clear();
    scrollbar = null;
  }

  void performLayout({required TableLayoutSettings layoutSettings}) {
    if (children.isEmpty) {
      return;
    }
    for (RenderBox renderBox in children) {
      final TableLayoutParentDataExp parentData = renderBox._parentData();
      final int rowIndex = parentData.row!;
      final double y = layoutSettings.headerHeight +
          (rowIndex * layoutSettings.rowHeight) -
          layoutSettings.verticalScrollbarOffset;
      final int columnIndex = parentData.column!;
      final double width = columnsMetrics.widths[columnIndex];
      final double offset = columnsMetrics.offsets[columnIndex];
      renderBox.layout(
          BoxConstraints.tightFor(
              width: width, height: layoutSettings.cellHeight),
          parentUsesSize: true);
      parentData.offset = Offset(offset, y);
    }
    if (scrollbar != null) {
      scrollbar!.layout(
          BoxConstraints.tightFor(
              width: bounds.width, height: layoutSettings.scrollbarSize),
          parentUsesSize: true);
      scrollbar!._parentData().offset =
          Offset(bounds.left, bounds.bottom - layoutSettings.scrollbarSize);
    }
  }

  void paintHover(
      {required Canvas canvas,
      required Offset offset,
      required TableLayoutSettings layoutSettings,
      required TablePaintSettings paintSettings}) {
    if (paintSettings.hoveredColor != null &&
        paintSettings.hoveredRowIndex != null) {
      Color? color =
          paintSettings.hoveredColor!(paintSettings.hoveredRowIndex!);
      if (color != null) {
        final double y = layoutSettings.headerHeight +
            (paintSettings.hoveredRowIndex! * layoutSettings.rowHeight) -
            layoutSettings.verticalScrollbarOffset;
        Paint paint = Paint()
          ..style = PaintingStyle.fill
          ..color = color;
        canvas.drawRect(
            Rect.fromLTWH(offset.dx, offset.dy + y, bounds.width,
                layoutSettings.cellHeight),
            paint);
      }
    }
  }

  void paintDebugAreas(
      {required Canvas canvas,
      required Offset offset,
      required TableLayoutSettings layoutSettings}) {
    if (children.isEmpty) {
      return;
    }
    if (layoutSettings.hasHeader) {
      Paint paint = Paint()
        ..style = PaintingStyle.fill
        ..color = headerAreaDebugColor;
      canvas.drawRect(
          Rect.fromLTWH(offset.dx + bounds.left, offset.dy + bounds.top,
              bounds.width, layoutSettings.headerHeight),
          paint);
    }

    if (layoutSettings.hasHorizontalScrollbar) {
      Paint paint = Paint()
        ..style = PaintingStyle.fill
        ..color = scrollbarAreaDebugColor;
      canvas.drawRect(
          Rect.fromLTWH(
              offset.dx + bounds.left,
              offset.dy + bounds.bottom - layoutSettings.scrollbarHeight,
              bounds.width,
              layoutSettings.scrollbarHeight),
          paint);
    }
  }

  void paintChildren({required Canvas canvas, required Offset offset}) {}
}

/// Utility extension to facilitate obtaining parent data.
extension _TableLayoutParentDataGetter on RenderObject {
  TableLayoutParentDataExp _parentData() {
    return parentData as TableLayoutParentDataExp;
  }
}
