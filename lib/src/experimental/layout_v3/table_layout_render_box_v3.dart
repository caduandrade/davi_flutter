import 'dart:math' as math;
import 'package:easy_table/src/experimental/layout_v3/layout_child_id_v3.dart';
import 'package:easy_table/src/experimental/layout_v3/table_layout_parent_data_v3.dart';
import 'package:easy_table/src/experimental/metrics/table_layout_settings_v3.dart';
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
  RenderBox? _horizontalScrollbars;
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
    _horizontalScrollbars = null;
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
      } else if (parentData.id == LayoutChildIdV3.horizontalScrollbars) {
        _horizontalScrollbars = renderBox;
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

    //TODO divisors

    // rows
    _layoutChild(child: _rows, bounds: _layoutSettings.cellsBounds);

    // horizontal scrollbars
    _layoutChild(
        child: _horizontalScrollbars,
        bounds: _layoutSettings.horizontalScrollbarBounds);

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

    _paintChild(context: context, offset: offset, child: _header, clipBounds: _layoutSettings.headerBounds);
    _paintChild(context: context, offset: offset, child: _topCorner, clipBounds: null);
    _paintChild(context: context, offset: offset, child: _verticalScrollbar, clipBounds: _layoutSettings.verticalScrollbarBounds);
    _paintChild(context: context, offset: offset, child: _horizontalScrollbars, clipBounds: _layoutSettings.horizontalScrollbarBounds);
    _paintChild(context: context, offset: offset, child: _bottomCorner, clipBounds: null);
    _paintChild(context: context, offset: offset, child: _rows, clipBounds: _layoutSettings.cellsBounds);

    // pinned content area divisors
    if (_theme.columnDividerThickness > 0) {
      //TODO check
      if (false) {
        //if (_leftPinnedContentArea.bounds.width > 0) {
        context.canvas.save();
        context.canvas.clipRect(Rect.fromLTWH(offset.dx, offset.dy,
            _layoutSettings.cellsBounds.width, _layoutSettings.height));
        if (_layoutSettings.headerHeight > 0) {
          // header
          if (_theme.header.columnDividerColor != null) {
            _paintPinnedColumnDividers(
                context: context,
                offset: offset,
                theme: _theme,
                color: _theme.header.columnDividerColor!,
                top: 0,
                //TODO check
                left: 0, //_leftPinnedContentArea.bounds.width,
                height: _theme.headerCell.height);
          }
        }
        // column
        if (_theme.columnDividerColor != null) {
          _paintPinnedColumnDividers(
              context: context,
              offset: offset,
              theme: _theme,
              color: _theme.columnDividerColor!,
              //TODO check
              left: 0, //_leftPinnedContentArea.bounds.width,
              top: _layoutSettings.headerHeight,
              height: _layoutSettings.cellsBounds.height);
        }
        // scrollbar
        if (_theme.scrollbar.columnDividerColor != null) {
          _paintPinnedColumnDividers(
              context: context,
              offset: offset,
              theme: _theme,
              color: _theme.scrollbar.columnDividerColor!,
              //TODO check
              left: 0, //_leftPinnedContentArea.bounds.width,
              top: _layoutSettings.headerHeight +
                  _layoutSettings.cellsBounds.height,
              height: _layoutSettings.scrollbarHeight);
        }
        context.canvas.restore();
      }
    }
  }

  void _paintPinnedColumnDividers(
      {required PaintingContext context,
      required Offset offset,
      required EasyTableThemeData theme,
      required double height,
      required Color color,
      required double left,
      required double top}) {
    Paint paint = Paint()..color = color;
    context.canvas.drawRect(
        Rect.fromLTWH(left + offset.dx, offset.dy + top,
            theme.columnDividerThickness, height),
        paint);
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
      if(clipBounds!=null){
        context.canvas.save();
        context.canvas.clipRect(clipBounds.translate(offset.dx, offset.dy));
      }
      context.paintChild(child, parentData.offset + offset);
      if(clipBounds!=null) {
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
