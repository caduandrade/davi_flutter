import 'package:easy_table/src/experimental/child_painter_mixin.dart';
import 'package:easy_table/src/experimental/columns_metrics_exp.dart';
import 'package:easy_table/src/experimental/content_area_id.dart';
import 'package:easy_table/src/experimental/table_layout_parent_data_exp.dart';
import 'package:easy_table/src/experimental/table_layout_settings.dart';
import 'package:flutter/material.dart';

class ContentArea with ChildPainterMixin {
  ContentArea(
      {required this.id,
      required this.headerAreaDebugColor,
      required this.scrollbarAreaDebugColor,
      required this.columnsMetrics});

  final ContentAreaId id;
  final Color headerAreaDebugColor;
  final Color scrollbarAreaDebugColor;
  ColumnsMetricsExp columnsMetrics;
  final List<RenderBox> _headers = [];
  final List<RenderBox> _cells = [];
  RenderBox? scrollbar;

  Rect bounds = Rect.zero;

  void clear() {
    _headers.clear();
    _cells.clear();
    scrollbar = null;
  }

  void addHeader(RenderBox header) {
    _headers.add(header);
  }

  void addCell(RenderBox cell) {
    _cells.add(cell);
  }

  void performLayout({required TableLayoutSettings layoutSettings}) {
    for (RenderBox renderBox in _headers) {
      final TableLayoutParentDataExp parentData = renderBox._parentData();
      final double y = bounds.top;
      final int columnIndex = parentData.column!;
      final double width = columnsMetrics.widths[columnIndex];
      final double offset = columnsMetrics.offsets[columnIndex];
      renderBox.layout(
          BoxConstraints.tightFor(
              width: width, height: layoutSettings.headerCellHeight),
          parentUsesSize: true);
      parentData.offset = Offset(offset, y);
    }
    for (RenderBox renderBox in _cells) {
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

  void paintDebugAreas(
      {required Canvas canvas,
      required Offset offset,
      required TableLayoutSettings layoutSettings}) {
    if (_cells.isEmpty) {
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

  void paintChildren(
      {required PaintingContext context,
      required Offset offset,
      required Rect contentArea}) {
    for (RenderBox header in _headers) {
      paintChild(context: context, offset: offset, child: header);
    }
    context.canvas.save();
    context.canvas.clipRect(contentArea.translate(offset.dx, offset.dy));
    for (RenderBox cell in _cells) {
      paintChild(context: context, offset: offset, child: cell);
    }
    context.canvas.restore();
    paintChild(context: context, offset: offset, child: scrollbar);
  }
}

/// Utility extension to facilitate obtaining parent data.
extension _TableLayoutParentDataGetter on RenderObject {
  TableLayoutParentDataExp _parentData() {
    return parentData as TableLayoutParentDataExp;
  }
}
