import 'package:easy_table/src/column.dart';
import 'package:easy_table/src/experimental/layout_v3/layout_child_id_v3.dart';
import 'package:easy_table/src/experimental/layout_v3/table_layout_parent_data_v3.dart';
import 'package:easy_table/src/experimental/metrics/column_metrics_v3.dart';
import 'package:easy_table/src/experimental/metrics/table_layout_settings_v3.dart';
import 'package:easy_table/src/experimental/pin_status.dart';
import 'package:easy_table/src/experimental/table_paint_settings.dart';
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/rendering.dart';

class TableLayoutRenderBoxV3<ROW> extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, TableLayoutParentDataV3>,
        RenderBoxContainerDefaultsMixin<RenderBox, TableLayoutParentDataV3> {
  TableLayoutRenderBoxV3(
      {required TableLayoutSettingsV3<ROW> layoutSettings,
      required TablePaintSettings paintSettings,
      required EasyTableThemeData theme})
      : _layoutSettings = layoutSettings,
        _paintSettings = paintSettings,
        _theme = theme;

  RenderBox? _header;
  RenderBox? _rows;
  RenderBox? _verticalScrollbar;
  RenderBox? _unpinnedHorizontalScrollbar;
  RenderBox? _leftPinnedHorizontalScrollbar;
  RenderBox? _topCorner;
  RenderBox? _bottomCorner;

  EasyTableThemeData _theme;
  set theme(EasyTableThemeData value) {
    _theme = value;
  }

  TableLayoutSettingsV3<ROW> _layoutSettings;

  set layoutSettings(TableLayoutSettingsV3<ROW> value) {
    if (_layoutSettings != value) {
      _layoutSettings = value;
      markNeedsLayout();
    }
  }

  TablePaintSettings _paintSettings;

  set paintSettings(TablePaintSettings value) {
    if (_paintSettings != value) {
      _paintSettings = value;
      markNeedsPaint();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! TableLayoutParentDataV3) {
      child.parentData = TableLayoutParentDataV3();
    }
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return Size(constraints.maxWidth, _layoutSettings.height);
  }

  @override
  void performLayout() {
    _rows = null;
    _header = null;
    _unpinnedHorizontalScrollbar = null;
    _leftPinnedHorizontalScrollbar = null;
    _verticalScrollbar = null;
    _topCorner = null;
    _bottomCorner = null;

    visitChildren((child) {
      RenderBox renderBox = child as RenderBox;
      TableLayoutParentDataV3 parentData = child._parentData();
      if (parentData.id == LayoutChildIdV3.rows) {
        _rows = renderBox;
      } else if (parentData.id == LayoutChildIdV3.verticalScrollbar) {
        _verticalScrollbar = renderBox;
      } else if (parentData.id == LayoutChildIdV3.unpinnedHorizontalScrollbar) {
        _unpinnedHorizontalScrollbar = renderBox;
      } else if (parentData.id ==
          LayoutChildIdV3.leftPinnedHorizontalScrollbar) {
        _leftPinnedHorizontalScrollbar = renderBox;
      } else if (parentData.id == LayoutChildIdV3.topCorner) {
        _topCorner = renderBox;
      } else if (parentData.id == LayoutChildIdV3.bottomCorner) {
        _bottomCorner = renderBox;
      } else if (parentData.id == LayoutChildIdV3.header) {
        _header = renderBox;
      }
    });

    // header
    if (_header != null) {
      _header!.layout(
          BoxConstraints.tightFor(
              width: _layoutSettings.headerBounds.width,
              height: _layoutSettings.headerBounds.height),
          parentUsesSize: true);
      _header!._parentData().offset = Offset.zero;
    }

    // rows
    _layoutChild(child: _rows, bounds: _layoutSettings.cellsBounds);

    // horizontal scrollbars
    _layoutChild(
        child: _leftPinnedHorizontalScrollbar,
        bounds: _layoutSettings.leftPinnedHorizontalScrollbarBounds);
    _layoutChild(
        child: _unpinnedHorizontalScrollbar,
        bounds: _layoutSettings.unpinnedHorizontalScrollbarsBounds);

    // vertical scrollbar
    _layoutChild(
        child: _verticalScrollbar,
        bounds: _layoutSettings.verticalScrollbarBounds);

    // top corner
    if (_topCorner != null) {
      _topCorner!.layout(
          BoxConstraints.tightFor(
              width: _layoutSettings.scrollbarWidth,
              height: _layoutSettings.headerHeight),
          parentUsesSize: true);
      _topCorner!._parentData().offset =
          Offset(constraints.maxWidth - _layoutSettings.scrollbarWidth, 0);
    }

    // bottom corner
    if (_bottomCorner != null) {
      _bottomCorner!.layout(
          BoxConstraints.tightFor(
              width: _layoutSettings.scrollbarWidth,
              height: _layoutSettings.scrollbarHeight),
          parentUsesSize: true);
      _bottomCorner!._parentData().offset = Offset(
          constraints.maxWidth - _layoutSettings.scrollbarWidth,
          _layoutSettings.height - _layoutSettings.scrollbarHeight);
    }

    size = computeDryLayout(constraints);
  }

  void _layoutChild({required RenderBox? child, required Rect bounds}) {
    if (child != null) {
      child.layout(
          BoxConstraints.tightFor(width: bounds.width, height: bounds.height),
          parentUsesSize: true);
      child._parentData().offset = Offset(bounds.left, bounds.top);
    }
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    double height = 0;
    if (_layoutSettings.hasHeader) {
      height += _layoutSettings.headerHeight;
    }
    return height;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return computeMinIntrinsicHeight(width) +
        (_layoutSettings.maxVisibleRowsLength * _layoutSettings.cellHeight) +
        _layoutSettings.scrollbarHeight;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _paintChild(
        context: context,
        offset: offset,
        child: _header,
        clipBounds: _layoutSettings.headerBounds);
    _paintChild(
        context: context, offset: offset, child: _topCorner, clipBounds: null);
    _paintChild(
        context: context,
        offset: offset,
        child: _verticalScrollbar,
        clipBounds: _layoutSettings.verticalScrollbarBounds);
    _paintChild(
        context: context,
        offset: offset,
        child: _leftPinnedHorizontalScrollbar,
        clipBounds: _layoutSettings.horizontalScrollbarsBounds);
    _paintChild(
        context: context,
        offset: offset,
        child: _unpinnedHorizontalScrollbar,
        clipBounds: _layoutSettings.horizontalScrollbarsBounds);
    _paintChild(
        context: context,
        offset: offset,
        child: _bottomCorner,
        clipBounds: null);
    _paintChild(
        context: context,
        offset: offset,
        child: _rows,
        clipBounds: _layoutSettings.cellsBounds);

    // column dividers
    if (_theme.columnDividerThickness > 0 &&
        (_theme.header.columnDividerColor != null ||
            _theme.columnDividerColor != null ||
            _theme.scrollbar.columnDividerColor != null)) {
      Paint? headerPaint;
      if (_theme.header.columnDividerColor != null) {
        headerPaint = Paint()..color = _theme.header.columnDividerColor!;
      }
      Paint? columnPaint;
      if (_theme.columnDividerColor != null) {
        columnPaint = Paint()..color = _theme.columnDividerColor!;
      }

      bool needAreaDivisor = false;
      for (int columnIndex = 0;
          columnIndex < _layoutSettings.columnsMetrics.length;
          columnIndex++) {
        final ColumnMetricsV3<ROW> columnMetrics =
            _layoutSettings.columnsMetrics[columnIndex];
        final EasyTableColumn<ROW> column = columnMetrics.column;
        final PinStatus pinStatus = _layoutSettings.pinStatus(column);
        final Rect areaBounds = _layoutSettings.getAreaBounds(pinStatus);
        final double scrollOffset =
            _layoutSettings.offsets.getHorizontal(pinStatus);
        double left = offset.dx +
            columnMetrics.offset +
            columnMetrics.width -
            scrollOffset;
        context.canvas.save();
        context.canvas.clipRect(areaBounds.translate(offset.dx, offset.dy));
        if (headerPaint != null) {
          context.canvas.drawRect(
              Rect.fromLTWH(
                  left,
                  offset.dy,
                  _layoutSettings.columnDividerThickness,
                  _layoutSettings.headerCellHeight),
              headerPaint);
        }
        if (columnPaint != null) {
          context.canvas.drawRect(
              Rect.fromLTWH(
                  left,
                  offset.dy + _layoutSettings.headerHeight,
                  _layoutSettings.columnDividerThickness,
                  _layoutSettings.cellsBounds.height),
              columnPaint);
        }
        context.canvas.restore();
        if (pinStatus == PinStatus.leftPinned) {
          needAreaDivisor = true;
        } else if (needAreaDivisor && pinStatus == PinStatus.unpinned) {
          needAreaDivisor = false;
          context.canvas.save();
          context.canvas.clipRect(Rect.fromLTWH(offset.dx, offset.dy,
              _layoutSettings.cellsBounds.width, _layoutSettings.height));
          left = offset.dx +
              columnMetrics.offset -
              _layoutSettings.columnDividerThickness;
          if (headerPaint != null) {
            context.canvas.drawRect(
                Rect.fromLTWH(
                    left,
                    offset.dy,
                    _layoutSettings.columnDividerThickness,
                    _layoutSettings.headerCellHeight),
                headerPaint);
          }
          if (columnPaint != null) {
            context.canvas.drawRect(
                Rect.fromLTWH(
                    left,
                    offset.dy + _layoutSettings.headerHeight,
                    _layoutSettings.columnDividerThickness,
                    _layoutSettings.cellsBounds.height),
                columnPaint);
          }
          if (_layoutSettings.hasHorizontalScrollbar &&
              _theme.scrollbar.columnDividerColor != null) {
            context.canvas.drawRect(
                Rect.fromLTWH(
                    left,
                    offset.dy +
                        _layoutSettings.headerHeight +
                        _layoutSettings.cellsBounds.height,
                    _layoutSettings.columnDividerThickness,
                    _layoutSettings.scrollbarHeight),
                Paint()..color = _theme.scrollbar.columnDividerColor!);
          }
          context.canvas.restore();
        }
      }
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  void _paintChild(
      {required PaintingContext context,
      required Offset offset,
      required RenderBox? child,
      required Rect? clipBounds}) {
    if (child != null) {
      final TableLayoutParentDataV3 parentData =
          child.parentData as TableLayoutParentDataV3;
      if (clipBounds != null) {
        context.canvas.save();
        context.canvas.clipRect(clipBounds.translate(offset.dx, offset.dy));
      }
      context.paintChild(child, parentData.offset + offset);
      if (clipBounds != null) {
        context.canvas.restore();
      }
    }
  }
}

/// Utility extension to facilitate obtaining parent data.
extension _TableLayoutParentDataGetter on RenderObject {
  TableLayoutParentDataV3 _parentData() {
    return parentData as TableLayoutParentDataV3;
  }
}
