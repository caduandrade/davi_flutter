import 'dart:math' as math;
import 'package:easy_table/src/experimental/columns_metrics_exp.dart';
import 'package:easy_table/src/experimental/layout_v3/layout_child_id_v3.dart';
import 'package:easy_table/src/experimental/layout_v3/table_layout_parent_data_v3.dart';
import 'package:easy_table/src/experimental/table_layout_settings.dart';
import 'package:easy_table/src/experimental/table_paint_settings.dart';
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/rendering.dart';

class TableLayoutRenderBoxV3<ROW> extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, TableLayoutParentDataV3>,
        RenderBoxContainerDefaultsMixin<RenderBox, TableLayoutParentDataV3>{
  TableLayoutRenderBoxV3(
      {
      required TableLayoutSettings layoutSettings,
      required TablePaintSettings paintSettings,
      required ColumnsMetricsExp leftPinnedColumnsMetrics,
      required ColumnsMetricsExp unpinnedColumnsMetrics,
      required ColumnsMetricsExp rightPinnedColumnsMetrics,
      required EasyTableThemeData theme})
      :  _layoutSettings = layoutSettings,
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
  
  TableLayoutSettings _layoutSettings;

  set layoutSettings(TableLayoutSettings value) {
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

  set leftPinnedColumnsMetrics(ColumnsMetricsExp value) {

  }

  set unpinnedColumnsMetrics(ColumnsMetricsExp value) {

  }

  set rightPinnedColumnsMetrics(ColumnsMetricsExp value) {

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
    _rows=null;
    _header=null;
    _horizontalScrollbars=null;
    _verticalScrollbar = null;
    _topCorner = null;
    _bottomCorner = null;

    visitChildren((child) {
      RenderBox renderBox = child as RenderBox;
      TableLayoutParentDataV3 parentData = child._parentData();
      if (parentData.id == LayoutChildIdV3.rows) {
        _rows = renderBox;
      }  else if (parentData.id == LayoutChildIdV3.verticalScrollbar) {
        _verticalScrollbar = renderBox;
      } else if (parentData.id == LayoutChildIdV3.horizontalScrollbars) {
        _horizontalScrollbars = renderBox;
      } else if (parentData.id == LayoutChildIdV3.topCorner) {
        _topCorner = renderBox;
      } else if (parentData.id == LayoutChildIdV3.bottomCorner) {
        _bottomCorner = renderBox;
      }
    });

    // header
    if(_header!=null) {
      _header!.layout(
          BoxConstraints.tightFor(
              width: _layoutSettings.headerBounds.width,
              height: _layoutSettings.headerHeight),
          parentUsesSize: true);
      _header!._parentData().offset = Offset.zero;
    }

    //TODO divisors

    // cells
    if(_rows!=null) {
      _rows!.layout(
          BoxConstraints.tightFor(
              width: _layoutSettings.cellsBound.width,
              height: _layoutSettings.cellsBound.height),
          parentUsesSize: true);
      _rows!._parentData().offset = Offset(0, _layoutSettings.headerHeight);
    }

    // horizontal scrollbars
    if(_horizontalScrollbars!=null) {
      _horizontalScrollbars!.layout(
          BoxConstraints.tightFor(
              width: _layoutSettings.cellsBound.width,
              height: _layoutSettings.scrollbarHeight),
          parentUsesSize: true);
      _horizontalScrollbars!._parentData().offset = Offset(0, _layoutSettings.headerHeight + _layoutSettings.cellsBound.height);
    }

    // vertical scrollbar
    _verticalScrollbar!.layout(
        BoxConstraints.tightFor(
            width: _layoutSettings.scrollbarWidth,
            height: math.max(
                0,
                _layoutSettings.height -
                    _layoutSettings.headerHeight -
                    _layoutSettings.scrollbarHeight)),
        parentUsesSize: true);
    _verticalScrollbar!._parentData().offset = Offset(
        constraints.maxWidth - _layoutSettings.scrollbarWidth,
        _layoutSettings.headerHeight);

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
        (_layoutSettings.visibleRowsCount * _layoutSettings.cellHeight) +
        _layoutSettings.scrollbarHeight;
  }

  @override
  void paint(PaintingContext context, Offset offset) {


    paintChild(context: context, offset: offset, child: _verticalScrollbar);
    paintChild(context: context, offset: offset, child: _topCorner);
    paintChild(context: context, offset: offset, child: _bottomCorner);
    paintChild(context: context, offset: offset, child: _header);
    paintChild(context: context, offset: offset, child: _rows);
    paintChild(context: context, offset: offset, child: _horizontalScrollbars);



    // pinned content area divisors
    if (_theme.columnDividerThickness > 0) {
      //TODO check
      if(false) {
      //if (_leftPinnedContentArea.bounds.width > 0) {
        context.canvas.save();
        context.canvas.clipRect(Rect.fromLTWH(offset.dx, offset.dy,
            _layoutSettings.cellsBound.width, _layoutSettings.height));
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
                left: 0,//_leftPinnedContentArea.bounds.width,
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
              left: 0,//_leftPinnedContentArea.bounds.width,
              top: _layoutSettings.headerHeight,
              height: _layoutSettings.cellsBound.height);
        }
        // scrollbar
        if (_theme.scrollbar.columnDividerColor != null) {
          _paintPinnedColumnDividers(
              context: context,
              offset: offset,
              theme: _theme,
              color: _theme.scrollbar.columnDividerColor!,
              //TODO check
              left: 0,//_leftPinnedContentArea.bounds.width,
              top: _layoutSettings.headerHeight +
                  _layoutSettings.cellsBound.height,
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

  void paintChild(
      {required PaintingContext context,
        required Offset offset,
        required RenderBox? child}) {
    if (child != null) {
      final TableLayoutParentDataV3 parentData =
      child.parentData as TableLayoutParentDataV3;
      context.paintChild(child, parentData.offset + offset);
    }
  }
  
}


/// Utility extension to facilitate obtaining parent data.
extension _TableLayoutParentDataGetter on RenderObject {
  TableLayoutParentDataV3 _parentData() {
    return parentData as TableLayoutParentDataV3;
  }
}
