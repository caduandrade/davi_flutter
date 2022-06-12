import 'dart:math' as math;
import 'package:easy_table/src/experimental/child_painter_mixin.dart';
import 'package:easy_table/src/experimental/columns_metrics_exp.dart';
import 'package:easy_table/src/experimental/content_area.dart';
import 'package:easy_table/src/experimental/content_area_id.dart';
import 'package:easy_table/src/experimental/layout_child_type.dart';
import 'package:easy_table/src/experimental/table_layout_parent_data_exp.dart';
import 'package:easy_table/src/experimental/table_layout_settings.dart';
import 'package:easy_table/src/experimental/table_paint_settings.dart';
import 'package:easy_table/src/row_hover_listener.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class TableLayoutRenderBoxExp<ROW> extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, TableLayoutParentDataExp>,
        RenderBoxContainerDefaultsMixin<RenderBox, TableLayoutParentDataExp>,
        ChildPainterMixin {
  TableLayoutRenderBoxExp(
      {required OnRowHoverListener onHoverListener,
      required TableLayoutSettings layoutSettings,
      required TablePaintSettings paintSettings,
      required ColumnsMetricsExp leftPinnedColumnsMetrics,
      required ColumnsMetricsExp unpinnedColumnsMetrics,
      required ColumnsMetricsExp rightPinnedColumnsMetrics,
      required List<ROW> rows})
      : _onHoverListener = onHoverListener,
        _layoutSettings = layoutSettings,
        _paintSettings = paintSettings,
        //TODO const colors
        _leftPinnedContentArea = ContentArea(
            id: ContentAreaId.leftPinned,
            bounds: layoutSettings.leftPinnedBounds,
            columnsMetrics: leftPinnedColumnsMetrics,
            headerAreaDebugColor: Colors.yellow[300]!.withOpacity(.5),
            scrollbarAreaDebugColor: Colors.yellow[200]!.withOpacity(.5)),
        _unpinnedContentArea = ContentArea(
            id: ContentAreaId.unpinned,
            bounds: layoutSettings.unpinnedBounds,
            columnsMetrics: unpinnedColumnsMetrics,
            headerAreaDebugColor: Colors.lime[300]!.withOpacity(.5),
            scrollbarAreaDebugColor: Colors.lime[200]!.withOpacity(.5)),
        _rightPinnedContentArea = ContentArea(
            id: ContentAreaId.rightPinned,
            bounds: layoutSettings.rightPinnedBounds,
            columnsMetrics: rightPinnedColumnsMetrics,
            headerAreaDebugColor: Colors.orange[300]!.withOpacity(.5),
            scrollbarAreaDebugColor: Colors.orange[200]!.withOpacity(.5)),
        _rows = rows;

  final ContentArea _leftPinnedContentArea;
  final ContentArea _unpinnedContentArea;
  final ContentArea _rightPinnedContentArea;

  late final Map<ContentAreaId, ContentArea> _contentAreaMap = {
    ContentAreaId.leftPinned: _leftPinnedContentArea,
    ContentAreaId.unpinned: _unpinnedContentArea,
    ContentAreaId.rightPinned: _rightPinnedContentArea
  };

  RenderBox? _verticalScrollbar;

  //TODO remove?
  List<ROW> _rows;

  set rows(List<ROW> value) {
    _rows = value;
  }

  OnRowHoverListener _onHoverListener;

  set onHoverListener(OnRowHoverListener value) {
    _onHoverListener = value;
  }

  TableLayoutSettings _layoutSettings;

  set layoutSettings(TableLayoutSettings value) {
    if (_layoutSettings != value) {
      _layoutSettings = value;
      _leftPinnedContentArea.bounds = value.leftPinnedBounds;
      _unpinnedContentArea.bounds = value.unpinnedBounds;
      _rightPinnedContentArea.bounds = value.rightPinnedBounds;
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
    if (_leftPinnedContentArea.columnsMetrics != value) {
      _leftPinnedContentArea.columnsMetrics = value;
      markNeedsLayout();
    }
  }

  set unpinnedColumnsMetrics(ColumnsMetricsExp value) {
    if (_unpinnedContentArea.columnsMetrics != value) {
      _unpinnedContentArea.columnsMetrics = value;
      markNeedsLayout();
    }
  }

  set rightPinnedColumnsMetrics(ColumnsMetricsExp value) {
    if (_rightPinnedContentArea.columnsMetrics != value) {
      _rightPinnedContentArea.columnsMetrics = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! TableLayoutParentDataExp) {
      child.parentData = TableLayoutParentDataExp();
    }
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return Size(constraints.maxWidth, _layoutSettings.height);
  }

  @override
  void performLayout() {
    _forEachContentArea((area) => area.clearChildren());

    _verticalScrollbar = null;

    //TODO list necessary?
    List<RenderBox> children = [];
    visitChildren((child) {
      RenderBox renderBox = child as RenderBox;
      TableLayoutParentDataExp parentData = child._parentData();
      if (parentData.type == LayoutChildType.cell) {
        _contentAreaMap[parentData.contentAreaId]!.addCell(renderBox);
      } else if (parentData.type == LayoutChildType.header) {
        _contentAreaMap[parentData.contentAreaId]!.addHeader(renderBox);
      } else if (parentData.type == LayoutChildType.horizontalScrollbar) {
        _contentAreaMap[parentData.contentAreaId]!.scrollbar = renderBox;
      } else if (parentData.type == LayoutChildType.verticalScrollbar) {
        _verticalScrollbar = renderBox;
      }
      children.add(renderBox);
    });

    // vertical scrollbar
    //TODO scrollbarSize border?
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

    _forEachContentArea(
        (area) => area.performLayout(layoutSettings: _layoutSettings));

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
    double height = computeMinIntrinsicHeight(width);
    if (_layoutSettings.visibleRowsCount != null) {
      height += _layoutSettings.visibleRowsCount! * _layoutSettings.cellHeight;
    }
    return height;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _paintHover(canvas: context.canvas, offset: offset);

    _forEachContentArea((area) => area.paintChildren(
        context: context,
        offset: offset,
        contentBounds: _layoutSettings.contentArea));

    paintChild(context: context, offset: offset, child: _verticalScrollbar);

    if (_paintSettings.debugAreas) {
      if (_layoutSettings.hasHeader) {
        _forEachContentArea((area) => area.paintDebugAreas(
            canvas: context.canvas,
            offset: offset,
            layoutSettings: _layoutSettings));
      }
    }
  }

  void _paintHover({required Canvas canvas, required Offset offset}) {
    //TODO clip contentArea (showing in horizontal scroll area)
    if (_paintSettings.hoveredColor != null &&
        _paintSettings.hoveredRowIndex != null) {
      Color? color =
          _paintSettings.hoveredColor!(_paintSettings.hoveredRowIndex!);
      if (color != null) {
        final double y = _layoutSettings.headerHeight +
            (_paintSettings.hoveredRowIndex! * _layoutSettings.rowHeight) -
            _layoutSettings.verticalScrollbarOffset;
        Paint paint = Paint()
          ..style = PaintingStyle.fill
          ..color = color;
        canvas.drawRect(
            Rect.fromLTWH(offset.dx, offset.dy + y,
                _layoutSettings.contentArea.width, _layoutSettings.cellHeight),
            paint);
      }
    }
  }

  void _forEachContentArea(_ContentAreaFunction function) {
    function(_leftPinnedContentArea);
    function(_unpinnedContentArea);
    function(_rightPinnedContentArea);
  }

  @override
  bool hitTestSelf(Offset position) => _paintSettings.hoveredColor != null;

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (_paintSettings.hoveredColor == null) {
      return;
    }
    if (event is PointerHoverEvent) {
      if (_layoutSettings.contentArea.contains(event.localPosition)) {
        final double localY = event.localPosition.dy;
        final double y = math.max(0, localY - _layoutSettings.headerHeight) +
            _layoutSettings.verticalScrollbarOffset;
        final int rowIndex = (y / _layoutSettings.rowHeight).floor();
        _onHoverListener(rowIndex);
      } else {
        _onHoverListener(null);
      }
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

typedef _ContentAreaFunction = void Function(ContentArea area);

/// Utility extension to facilitate obtaining parent data.
extension _TableLayoutParentDataGetter on RenderObject {
  TableLayoutParentDataExp _parentData() {
    return parentData as TableLayoutParentDataExp;
  }
}
