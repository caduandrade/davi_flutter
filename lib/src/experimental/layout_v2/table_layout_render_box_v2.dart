import 'dart:math' as math;
import 'package:easy_table/src/experimental/layout_v2/child_painter_mixin_v2.dart';
import 'package:easy_table/src/experimental/columns_metrics_exp.dart';
import 'package:easy_table/src/experimental/layout_v2/content_area_v2.dart';
import 'package:easy_table/src/experimental/pin_status.dart';
import 'package:easy_table/src/experimental/layout_v2/layout_child_type_v2.dart';
import 'package:easy_table/src/experimental/layout_v2/row_callbacks_v2.dart';
import 'package:easy_table/src/experimental/layout_v2/table_layout_parent_data_v2.dart';
import 'package:easy_table/src/experimental/table_layout_settings.dart';
import 'package:easy_table/src/experimental/table_paint_settings.dart';
import 'package:easy_table/src/row_hover_listener.dart';
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

class TableLayoutRenderBoxV2<ROW> extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, TableLayoutParentDataV2>,
        RenderBoxContainerDefaultsMixin<RenderBox, TableLayoutParentDataV2>,
        ChildPainterMixinV2 {
  TableLayoutRenderBoxV2(
      {required OnRowHoverListener onHoverListener,
      required TableLayoutSettings layoutSettings,
      required TablePaintSettings paintSettings,
      required ColumnsMetricsExp leftPinnedColumnsMetrics,
      required ColumnsMetricsExp unpinnedColumnsMetrics,
      required ColumnsMetricsExp rightPinnedColumnsMetrics,
      required EasyTableThemeData theme,
      required RowCallbacksV2? rowCallbacks})
      : _onHoverListener = onHoverListener,
        _layoutSettings = layoutSettings,
        _paintSettings = paintSettings,
        _leftPinnedContentArea = ContentAreaV2(
            pinStatus: PinStatus.leftPinned,
            bounds: layoutSettings.leftPinnedBounds,
            scrollOffset: layoutSettings.offsets.leftPinnedContentArea,
            columnsMetrics: leftPinnedColumnsMetrics),
        _unpinnedContentArea = ContentAreaV2(
            pinStatus: PinStatus.unpinned,
            bounds: layoutSettings.unpinnedBounds,
            scrollOffset: layoutSettings.offsets.unpinnedContentArea,
            columnsMetrics: unpinnedColumnsMetrics),
        _rightPinnedContentArea = ContentAreaV2(
            pinStatus: PinStatus.rightPinned,
            bounds: layoutSettings.rightPinnedBounds,
            scrollOffset: layoutSettings.offsets.rightPinnedContentArea,
            columnsMetrics: rightPinnedColumnsMetrics),
        _theme = theme,
        _rowCallbacks = rowCallbacks;

  late final TapGestureRecognizer _tapGestureRecognizer;
  late final DoubleTapGestureRecognizer _doubleTapGestureRecognizer;

  final ContentAreaV2 _leftPinnedContentArea;
  final ContentAreaV2 _unpinnedContentArea;
  final ContentAreaV2 _rightPinnedContentArea;

  late final Map<PinStatus, ContentAreaV2> _contentAreaMap = {
    PinStatus.leftPinned: _leftPinnedContentArea,
    PinStatus.unpinned: _unpinnedContentArea,
    PinStatus.rightPinned: _rightPinnedContentArea
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

  RowCallbacksV2? _rowCallbacks;
  set rowCallbacks(RowCallbacksV2? value) {
    _rowCallbacks = value;
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

  int? _lastRowIndex;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _tapGestureRecognizer = TapGestureRecognizer(debugOwner: this);
    _tapGestureRecognizer.onTap = _onRowTap;
    _tapGestureRecognizer.onSecondaryTap = _onRowSecondaryTap;

    _doubleTapGestureRecognizer = DoubleTapGestureRecognizer(debugOwner: this);
    _doubleTapGestureRecognizer.onDoubleTap = _onRowDoubleTap;
  }

  void _onRowTap() {
    if (_lastRowIndex != null) {
      _rowCallbacks?.onRowTap(_lastRowIndex!);
    }
  }

  void _onRowDoubleTap() {
    if (_lastRowIndex != null) {
      _rowCallbacks?.onRowDoubleTap(_lastRowIndex!);
    }
  }

  void _onRowSecondaryTap() {
    if (_lastRowIndex != null) {
      _rowCallbacks?.onRowSecondaryTap(_lastRowIndex!);
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! TableLayoutParentDataV2) {
      child.parentData = TableLayoutParentDataV2();
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
      TableLayoutParentDataV2 parentData = child._parentData();
      if (parentData.type == LayoutChildTypeV2.cell) {
        _contentAreaMap[parentData.pinStatus]!.addCell(renderBox);
      } else if (parentData.type == LayoutChildTypeV2.header) {
        _contentAreaMap[parentData.pinStatus]!.addHeader(renderBox);
      } else if (parentData.type == LayoutChildTypeV2.horizontalScrollbar) {
        _contentAreaMap[parentData.pinStatus]!.scrollbar = renderBox;
      } else if (parentData.type == LayoutChildTypeV2.verticalScrollbar) {
        _verticalScrollbar = renderBox;
      } else if (parentData.type == LayoutChildTypeV2.topCorner) {
        _topCorner = renderBox;
      } else if (parentData.type == LayoutChildTypeV2.bottomCorner) {
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
    return computeMinIntrinsicHeight(width) +
        (_layoutSettings.visibleRowsCount * _layoutSettings.cellHeight) +
        _layoutSettings.scrollbarHeight;
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

    // rows divider
    if (_theme.row.dividerThickness > 0 && _theme.row.dividerColor != null) {
      context.canvas.save();
      context.canvas
          .clipRect(_layoutSettings.cellsBound.translate(offset.dx, offset.dy));
      Paint paint = Paint()
        ..style = PaintingStyle.fill
        ..color = _theme.row.dividerColor!;
      int firstRowIndex =
          (_layoutSettings.offsets.vertical / _layoutSettings.rowHeight)
              .floor();
      double y = _layoutSettings.headerHeight +
          offset.dy +
          _layoutSettings.cellHeight +
          (firstRowIndex * _layoutSettings.rowHeight) -
          _layoutSettings.offsets.vertical;
      while (y < _layoutSettings.height + offset.dy) {
        context.canvas.drawRect(
            Rect.fromLTWH(offset.dx, y, _layoutSettings.cellsBound.width,
                _theme.row.dividerThickness),
            paint);
        y += _layoutSettings.rowHeight;
      }
      context.canvas.restore();
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
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    assert(debugHandleEvent(event, entry));

    if (event is PointerHoverEvent) {
      if (_layoutSettings.cellsBound.contains(event.localPosition)) {
        final double localY = event.localPosition.dy;
        final double y = math.max(0, localY - _layoutSettings.headerHeight) +
            _layoutSettings.offsets.vertical;
        final double rowLocation = y / _layoutSettings.rowHeight;
        final double cellArea =
            _layoutSettings.cellHeight / _layoutSettings.rowHeight;
        int rowIndex = rowLocation.floor();
        if (rowIndex <= _layoutSettings.rowsLength - 1 &&
            rowLocation < rowIndex + cellArea) {
          // ignoring divisor area
          _lastRowIndex = rowIndex;
        } else {
          _lastRowIndex = null;
        }
      } else {
        _lastRowIndex = null;
      }
      _onHoverListener(_lastRowIndex);
    } else if (event is PointerDownEvent) {
      _tapGestureRecognizer.addPointer(event);
      _doubleTapGestureRecognizer.addPointer(event);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void detach() {
    _tapGestureRecognizer.dispose();
    _doubleTapGestureRecognizer.dispose();
    super.detach();
  }
}

typedef _ContentAreaFunction = void Function(ContentAreaV2 area);

/// Utility extension to facilitate obtaining parent data.
extension _TableLayoutParentDataGetter on RenderObject {
  TableLayoutParentDataV2 _parentData() {
    return parentData as TableLayoutParentDataV2;
  }
}
