import 'package:easy_table/src/experimental/child_painter_mixin.dart';
import 'package:easy_table/src/experimental/columns_metrics_exp.dart';
import 'package:easy_table/src/experimental/content_area_id.dart';
import 'package:easy_table/src/experimental/debug_colors.dart';
import 'package:easy_table/src/experimental/table_layout_parent_data_exp.dart';
import 'package:easy_table/src/experimental/table_layout_settings.dart';
import 'package:easy_table/src/experimental/table_paint_settings.dart';
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/material.dart';

class ContentArea with ChildPainterMixin {
  ContentArea(
      {required this.id, required this.bounds, required this.columnsMetrics});

  final ContentAreaId id;
  final List<RenderBox> _headers = [];
  final List<RenderBox> _cells = [];
  ColumnsMetricsExp columnsMetrics;
  Rect bounds;

  RenderBox? scrollbar;

  void clearChildren() {
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

  void performLayout(
      {required TableLayoutSettings layoutSettings,
      required EasyTableThemeData theme}) {
    for (RenderBox renderBox in _headers) {
      final TableLayoutParentDataExp parentData = renderBox._parentData();
      final double y = bounds.top;
      final int columnIndex = parentData.column!;
      final double width = columnsMetrics.widths[columnIndex];
      final double offset = columnsMetrics.offsets[columnIndex];
      renderBox.layout(
          BoxConstraints.tightFor(
              width: width, height: theme.headerCell.height),
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
              width: bounds.width, height: layoutSettings.scrollbarHeight),
          parentUsesSize: true);
      scrollbar!._parentData().offset =
          Offset(bounds.left, bounds.bottom - layoutSettings.scrollbarHeight);
    }
  }

  void paintDebugAreas(
      {required Canvas canvas,
      required Offset offset,
      required TableLayoutSettings layoutSettings}) {
    if (bounds.isEmpty) {
      return;
    }
    if (layoutSettings.hasHeader) {
      Paint paint = Paint()
        ..style = PaintingStyle.fill
        ..color = DebugColors.headerArea(id);
      canvas.drawRect(
          Rect.fromLTWH(offset.dx + bounds.left, offset.dy + bounds.top,
              bounds.width, layoutSettings.headerHeight),
          paint);
    }
    if (layoutSettings.hasHorizontalScrollbar) {
      Paint paint = Paint()
        ..style = PaintingStyle.fill
        ..color = DebugColors.horizontalScrollbarArea(id);
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
      required TableLayoutSettings layoutSettings,
      required TablePaintSettings paintSettings,
      required EasyTableThemeData theme}) {
    // headers
    for (RenderBox header in _headers) {
      context.canvas.save();
      context.canvas.clipRect(
          layoutSettings.headerBounds.translate(offset.dx, offset.dy));
      paintChild(context: context, offset: offset, child: header);
      context.canvas.restore();
    }

    // cells
    context.canvas.save();
    context.canvas
        .clipRect(layoutSettings.cellsBound.translate(offset.dx, offset.dy));
    for (RenderBox cell in _cells) {
      paintChild(context: context, offset: offset, child: cell);
    }
    context.canvas.restore();

    // scrollbar
    paintChild(context: context, offset: offset, child: scrollbar);
  }

  void paint(
      {required PaintingContext context,
      required Offset offset,
      required TableLayoutSettings layoutSettings,
      required TablePaintSettings paintSettings,
      required EasyTableThemeData theme}) {
    // column dividers
    if (theme.columnDividerThickness > 0) {
      if (layoutSettings.headerHeight > 0 &&
          theme.header.columnDividerColor != null) {
        _paintColumnDividers(
            context: context,
            offset: offset,
            theme: theme,
            color: theme.header.columnDividerColor!,
            dy: 0,
            height: theme.headerCell.height);
      }
      if (theme.columnDividerColor != null) {
        _paintColumnDividers(
            context: context,
            offset: offset,
            theme: theme,
            color: theme.columnDividerColor!,
            dy: layoutSettings.headerHeight,
            height: layoutSettings.cellsBound.height);
      }
    }

    if (theme.header.bottomBorderHeight > 0 &&
        theme.header.bottomBorderColor != null) {
      Paint paint = Paint()..color = theme.header.bottomBorderColor!;
      context.canvas.drawRect(
          Rect.fromLTWH(
              offset.dx,
              offset.dy + theme.headerCell.height,
              layoutSettings.headerBounds.width,
              theme.header.bottomBorderHeight),
          paint);
    }
  }

  void _paintColumnDividers(
      {required PaintingContext context,
      required Offset offset,
      required EasyTableThemeData theme,
      required double height,
      required Color color,
      required double dy}) {
    Paint paint = Paint()..color = color;
    for (int i = 1; i < columnsMetrics.offsets.length; i++) {
      double x = columnsMetrics.offsets[i] - theme.columnDividerThickness;
      context.canvas.drawRect(
          Rect.fromLTWH(x + offset.dx, offset.dy + dy,
              theme.columnDividerThickness, height),
          paint);
    }
  }
}

/// Utility extension to facilitate obtaining parent data.
extension _TableLayoutParentDataGetter on RenderObject {
  TableLayoutParentDataExp _parentData() {
    return parentData as TableLayoutParentDataExp;
  }
}
