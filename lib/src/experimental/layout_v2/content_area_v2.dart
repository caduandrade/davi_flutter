import 'package:easy_table/src/experimental/layout_v2/child_painter_mixin_v2.dart';
import 'package:easy_table/src/experimental/columns_metrics_exp.dart';
import 'package:easy_table/src/experimental/pin_status.dart';
import 'package:easy_table/src/experimental/layout_v2/debug_colors_v2.dart';
import 'package:easy_table/src/experimental/layout_v2/table_layout_parent_data_v2.dart';
import 'package:easy_table/src/experimental/table_layout_settings.dart';
import 'package:easy_table/src/experimental/table_paint_settings.dart';
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/material.dart';

class ContentAreaV2 with ChildPainterMixinV2 {
  ContentAreaV2(
      {required this.pinStatus,
      required this.bounds,
      required this.scrollOffset,
      required this.columnsMetrics});

  final PinStatus pinStatus;
  final List<RenderBox> _headers = [];
  final List<RenderBox> _cells = [];
  ColumnsMetricsExp columnsMetrics;
  Rect bounds;
  double scrollOffset;

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
    // headers
    for (RenderBox renderBox in _headers) {
      final TableLayoutParentDataV2 parentData = renderBox._parentData();
      final double y = bounds.top;
      final int columnIndex = parentData.column!;
      final double width = columnsMetrics.widths[columnIndex];
      final double offset = columnsMetrics.offsets[columnIndex];
      renderBox.layout(
          BoxConstraints.tightFor(
              width: width, height: theme.headerCell.height),
          parentUsesSize: true);
      parentData.offset = Offset(bounds.left + offset - scrollOffset, y);
    }
    // cells
    for (RenderBox renderBox in _cells) {
      final TableLayoutParentDataV2 parentData = renderBox._parentData();
      final int rowIndex = parentData.row!;
      final double y = layoutSettings.headerHeight +
          (rowIndex * layoutSettings.rowHeight) -
          layoutSettings.offsets.vertical;
      final int columnIndex = parentData.column!;
      final double width = columnsMetrics.widths[columnIndex];
      final double offset = columnsMetrics.offsets[columnIndex];
      renderBox.layout(
          BoxConstraints.tightFor(
              width: width, height: layoutSettings.cellHeight),
          parentUsesSize: true);
      parentData.offset = Offset(bounds.left + offset - scrollOffset, y);
    }
    // horizontal scrollbar
    if (scrollbar != null) {
      scrollbar!.layout(
          BoxConstraints.tightFor(
              width: bounds.width, height: layoutSettings.scrollbarHeight),
          parentUsesSize: true);
      scrollbar!._parentData().offset =
          Offset(bounds.left, bounds.bottom - layoutSettings.scrollbarHeight);
    }
  }

  void paintChildren(
      {required PaintingContext context,
      required Offset offset,
      required TableLayoutSettings layoutSettings,
      required TablePaintSettings paintSettings,
      required EasyTableThemeData theme}) {
    // headers
    context.canvas.save();
    context.canvas.clipRect(bounds.translate(offset.dx, offset.dy));
    for (RenderBox header in _headers) {
      paintChild(context: context, offset: offset, child: header);
    }
    context.canvas.restore();

    // cells
    context.canvas.save();
    context.canvas.clipRect(
        bounds.translate(offset.dx, offset.dy + layoutSettings.headerHeight));
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
    context.canvas.save();
    context.canvas.clipRect(bounds.translate(offset.dx, offset.dy));

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

    if (layoutSettings.hasHeader &&
        theme.header.bottomBorderHeight > 0 &&
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

    context.canvas.restore();
  }

  void _paintColumnDividers(
      {required PaintingContext context,
      required Offset offset,
      required EasyTableThemeData theme,
      required double height,
      required Color color,
      required double dy}) {
    Paint paint = Paint()..color = color;
    int less = pinStatus == PinStatus.leftPinned ? 1 : 0;
    for (int i = 0; i < columnsMetrics.widths.length - less; i++) {
      context.canvas.drawRect(
          Rect.fromLTWH(
              bounds.left +
                  columnsMetrics.offsets[i] +
                  columnsMetrics.widths[i] +
                  offset.dx -
                  scrollOffset,
              offset.dy + dy,
              theme.columnDividerThickness,
              height),
          paint);
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
        ..color = DebugColorsV2.headerArea(pinStatus);
      canvas.drawRect(
          Rect.fromLTWH(offset.dx + bounds.left, offset.dy + bounds.top,
              bounds.width, layoutSettings.headerHeight),
          paint);
    }
    if (layoutSettings.hasHorizontalScrollbar) {
      Paint paint = Paint()
        ..style = PaintingStyle.fill
        ..color = DebugColorsV2.horizontalScrollbarArea(pinStatus);
      canvas.drawRect(
          Rect.fromLTWH(
              offset.dx + bounds.left,
              offset.dy + bounds.bottom - layoutSettings.scrollbarHeight,
              bounds.width,
              layoutSettings.scrollbarHeight),
          paint);
    }
  }
}

/// Utility extension to facilitate obtaining parent data.
extension _TableLayoutParentDataGetter on RenderObject {
  TableLayoutParentDataV2 _parentData() {
    return parentData as TableLayoutParentDataV2;
  }
}