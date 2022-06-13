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
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/gestures.dart';
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
      required EasyTableThemeData theme})
      : _onHoverListener = onHoverListener,
        _layoutSettings = layoutSettings,
        _paintSettings = paintSettings,
        _leftPinnedContentArea = ContentArea(
            id: ContentAreaId.leftPinned,
            bounds: layoutSettings.leftPinnedBounds,
            scrollOffset: layoutSettings.offsets.leftPinnedContentArea,
            columnsMetrics: leftPinnedColumnsMetrics),
        _unpinnedContentArea = ContentArea(
            id: ContentAreaId.unpinned,
            bounds: layoutSettings.unpinnedBounds,
            scrollOffset: layoutSettings.offsets.unpinnedContentArea,
            columnsMetrics: unpinnedColumnsMetrics),
        _rightPinnedContentArea = ContentArea(
            id: ContentAreaId.rightPinned,
            bounds: layoutSettings.rightPinnedBounds,
            scrollOffset: layoutSettings.offsets.rightPinnedContentArea,
            columnsMetrics: rightPinnedColumnsMetrics),
        _theme = theme;

  final ContentArea _leftPinnedContentArea;
  final ContentArea _unpinnedContentArea;
  final ContentArea _rightPinnedContentArea;

  late final Map<ContentAreaId, ContentArea> _contentAreaMap = {
    ContentAreaId.leftPinned: _leftPinnedContentArea,
    ContentAreaId.unpinned: _unpinnedContentArea,
    ContentAreaId.rightPinned: _rightPinnedContentArea
  };

  RenderBox? _verticalScrollbar;
  RenderBox? _topCorner;
  RenderBox? _bottomCorner;

  EasyTableThemeData _theme;
  set theme(EasyTableThemeData value) {
    _theme = value;
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
      _leftPinnedContentArea.scrollOffset = value.offsets.leftPinnedContentArea;
      _unpinnedContentArea.scrollOffset = value.offsets.unpinnedContentArea;
      _rightPinnedContentArea.scrollOffset =
          value.offsets.rightPinnedContentArea;
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
    _topCorner = null;
    _bottomCorner = null;

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
      } else if (parentData.type == LayoutChildType.topCorner) {
        _topCorner = renderBox;
      } else if (parentData.type == LayoutChildType.bottomCorner) {
        _bottomCorner = renderBox;
      }
    });

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

    _forEachContentArea((area) =>
        area.performLayout(layoutSettings: _layoutSettings, theme: _theme));

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
        layoutSettings: _layoutSettings,
        paintSettings: _paintSettings,
        theme: _theme));

    paintChild(context: context, offset: offset, child: _verticalScrollbar);
    paintChild(context: context, offset: offset, child: _topCorner);
    paintChild(context: context, offset: offset, child: _bottomCorner);

    _forEachContentArea((area) => area.paint(
        context: context,
        offset: offset,
        layoutSettings: _layoutSettings,
        paintSettings: _paintSettings,
        theme: _theme));

    // pinned content area divisors
    if (_theme.columnDividerThickness > 0) {
      if (_leftPinnedContentArea.bounds.width > 0) {
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
                left: _leftPinnedContentArea.bounds.width,
                height: _theme.headerCell.height);
          }
          if (_theme.header.bottomBorderHeight > 0 &&
              _theme.header.bottomBorderColor != null) {
            Paint paint = Paint()..color = _theme.header.bottomBorderColor!;
            // header border
            context.canvas.drawRect(
                Rect.fromLTWH(
                    offset.dx + _leftPinnedContentArea.bounds.width,
                    offset.dy + _theme.headerCell.height,
                    _layoutSettings.headerBounds.width,
                    _theme.header.bottomBorderHeight),
                paint);
          }
        }
        // column
        if (_theme.columnDividerColor != null) {
          _paintPinnedColumnDividers(
              context: context,
              offset: offset,
              theme: _theme,
              color: _theme.columnDividerColor!,
              left: _leftPinnedContentArea.bounds.width,
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
              left: _leftPinnedContentArea.bounds.width,
              top: _layoutSettings.headerHeight +
                  _layoutSettings.cellsBound.height,
              height: _layoutSettings.scrollbarHeight);
        }
        context.canvas.restore();
      }
    }

    if (_paintSettings.debugAreas) {
      if (_layoutSettings.hasHeader) {
        _forEachContentArea((area) => area.paintDebugAreas(
            canvas: context.canvas,
            offset: offset,
            layoutSettings: _layoutSettings));
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

  void _paintHover({required Canvas canvas, required Offset offset}) {
    if (_theme.row.hoveredColor != null &&
        _paintSettings.hoveredRowIndex != null) {
      Color? color = _theme.row.hoveredColor!(_paintSettings.hoveredRowIndex!);
      if (color != null) {
        final double y = _layoutSettings.headerHeight +
            (_paintSettings.hoveredRowIndex! * _layoutSettings.rowHeight) -
            _layoutSettings.offsets.vertical;
        canvas.save();
        canvas.clipRect(
            _layoutSettings.cellsBound.translate(offset.dx, offset.dy));
        Paint paint = Paint()
          ..style = PaintingStyle.fill
          ..color = color;
        canvas.drawRect(
            Rect.fromLTWH(offset.dx, offset.dy + y,
                _layoutSettings.cellsBound.width, _layoutSettings.cellHeight),
            paint);
        canvas.restore();
      }
    }
  }

  void _forEachContentArea(_ContentAreaFunction function) {
    function(_leftPinnedContentArea);
    function(_unpinnedContentArea);
    function(_rightPinnedContentArea);
  }

  @override
  bool hitTestSelf(Offset position) => _theme.row.hoveredColor != null;

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (_theme.row.hoveredColor == null) {
      return;
    }
    if (event is PointerHoverEvent) {
      //TODO check null listener?
      if (_layoutSettings.cellsBound.contains(event.localPosition)) {
        final double localY = event.localPosition.dy;
        final double y = math.max(0, localY - _layoutSettings.headerHeight) +
            _layoutSettings.offsets.vertical;
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
