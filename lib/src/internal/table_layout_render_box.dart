import 'dart:math' as math;

import 'package:davi/src/internal/layout_child_id.dart';
import 'package:davi/src/internal/layout_utils.dart';
import 'package:davi/src/internal/scroll_offsets.dart';
import 'package:davi/src/internal/table_layout_parent_data.dart';
import 'package:davi/src/internal/table_layout_settings.dart';
import 'package:davi/src/theme/theme_data.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

@internal
class TableLayoutRenderBox<DATA> extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, TableLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, TableLayoutParentData> {
  TableLayoutRenderBox(
      {required TableLayoutSettings layoutSettings,
      required DaviThemeData theme,
      required HorizontalScrollOffsets horizontalScrollOffsets})
      : _layoutSettings = layoutSettings,
        _theme = theme,
        _horizontalScrollOffsets = horizontalScrollOffsets;

  RenderBox? _header;
  RenderBox? _rows;
  RenderBox? _verticalScrollbar;
  RenderBox? _unpinnedHorizontalScrollbar;
  RenderBox? _leftPinnedHorizontalScrollbar;
  RenderBox? _topCorner;
  RenderBox? _bottomCorner;

  HorizontalScrollOffsets _horizontalScrollOffsets;

  set horizontalScrollOffsets(HorizontalScrollOffsets value) {
    if (_horizontalScrollOffsets != value) {
      _horizontalScrollOffsets = value;
      markNeedsPaint();
    }
  }

  DaviThemeData _theme;

  set theme(DaviThemeData value) {
    _theme = value;
  }

  TableLayoutSettings _layoutSettings;

  set layoutSettings(TableLayoutSettings value) {
    if (_layoutSettings != value) {
      _layoutSettings = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! TableLayoutParentData) {
      child.parentData = TableLayoutParentData();
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
      TableLayoutParentData parentData = child._parentData();
      if (parentData.id == LayoutChildId.rows) {
        _rows = renderBox;
      } else if (parentData.id == LayoutChildId.verticalScrollbar) {
        _verticalScrollbar = renderBox;
      } else if (parentData.id == LayoutChildId.unpinnedHorizontalScrollbar) {
        _unpinnedHorizontalScrollbar = renderBox;
      } else if (parentData.id == LayoutChildId.leftPinnedHorizontalScrollbar) {
        _leftPinnedHorizontalScrollbar = renderBox;
      } else if (parentData.id == LayoutChildId.topCorner) {
        _topCorner = renderBox;
      } else if (parentData.id == LayoutChildId.bottomCorner) {
        _bottomCorner = renderBox;
      } else if (parentData.id == LayoutChildId.header) {
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
              width: _layoutSettings.themeMetrics.scrollbar.width,
              height: _layoutSettings.themeMetrics.header.height),
          parentUsesSize: true);
      _topCorner!._parentData().offset = Offset(
          constraints.maxWidth - _layoutSettings.themeMetrics.scrollbar.width,
          0);
    }

    // bottom corner
    if (_bottomCorner != null) {
      _bottomCorner!.layout(
          BoxConstraints.tightFor(
              width: _layoutSettings.themeMetrics.scrollbar.width,
              height: _layoutSettings.themeMetrics.scrollbar.height),
          parentUsesSize: true);
      _bottomCorner!._parentData().offset = Offset(
          constraints.maxWidth - _layoutSettings.themeMetrics.scrollbar.width,
          _layoutSettings.height -
              _layoutSettings.themeMetrics.scrollbar.height);
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
    return _layoutSettings.headerBounds.height;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    final int maxVisibleRowsLength = LayoutUtils.maxVisibleRowsLength(
        scrollOffset: 0,
        visibleAreaHeight: _layoutSettings.cellsBounds.height,
        rowHeight: _layoutSettings.themeMetrics.row.height);
    final int visibleRowsLength =
        math.min(_layoutSettings.rowsLength, maxVisibleRowsLength);
    return computeMinIntrinsicHeight(width) +
        (visibleRowsLength * _layoutSettings.themeMetrics.cell.height) +
        _layoutSettings.themeMetrics.scrollbar.height;
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

    // scrollbar column divider
    if (_layoutSettings.themeMetrics.columnDividerThickness > 0 &&
        _layoutSettings.leftPinnedHorizontalScrollbarBounds.width > 0 &&
        _layoutSettings.leftPinnedHorizontalScrollbarBounds.width <
            _layoutSettings.cellsBounds.width &&
        _theme.scrollbar.columnDividerColor != null) {
      context.canvas.save();
      context.canvas.clipRect(Rect.fromLTWH(offset.dx, offset.dy,
          _layoutSettings.cellsBounds.width, _layoutSettings.height));
      context.canvas.drawRect(
          Rect.fromLTWH(
              offset.dx +
                  _layoutSettings.leftPinnedHorizontalScrollbarBounds.width,
              offset.dy +
                  _layoutSettings.headerBounds.height +
                  _layoutSettings.cellsBounds.height,
              _layoutSettings.themeMetrics.columnDividerThickness,
              _layoutSettings.leftPinnedHorizontalScrollbarBounds.height),
          Paint()..color = _theme.scrollbar.columnDividerColor!);
      context.canvas.restore();
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
      final TableLayoutParentData parentData =
          child.parentData as TableLayoutParentData;
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
  TableLayoutParentData _parentData() {
    return parentData as TableLayoutParentData;
  }
}
