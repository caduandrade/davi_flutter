import 'dart:math' as math;

import 'package:davi/src/internal/layout_child_id.dart';
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
      required DaviThemeData theme})
      : _layoutSettings = layoutSettings,
        _theme = theme;

  RenderBox? _header;
  RenderBox? _rows;
  RenderBox? _verticalScrollbar;
  RenderBox? _unpinnedHorizontalScrollbar;
  RenderBox? _leftPinnedHorizontalScrollbar;
  RenderBox? _headerEdge;
  RenderBox? _scrollbarEdge;
  RenderBox? _summaryEdge;
  RenderBox? _summary;

  // Bounds recomputed every layout from the header's real (discovered)
  // height. TableLayoutSettings' own bounds only hold a pre-layout estimate;
  // these fields hold the actual geometry used for positioning and painting.
  Rect _headerBounds = Rect.zero;
  Rect _cellsBounds = Rect.zero;
  Rect _summaryBounds = Rect.zero;
  Rect _leftPinnedHorizontalScrollbarBounds = Rect.zero;
  Rect _unpinnedHorizontalScrollbarsBounds = Rect.zero;
  Rect _horizontalScrollbarsBounds = Rect.zero;
  Rect _verticalScrollbarBounds = Rect.zero;
  double _height = 0;

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
    _headerEdge = null;
    _scrollbarEdge = null;
    _summaryEdge = null;
    _summary = null;

    visitChildren((child) {
      RenderBox renderBox = child as RenderBox;
      TableLayoutParentData parentData = child._parentData();
      if (parentData.id == LayoutChildId.cells) {
        _rows = renderBox;
      } else if (parentData.id == LayoutChildId.verticalScrollbar) {
        _verticalScrollbar = renderBox;
      } else if (parentData.id == LayoutChildId.unpinnedHorizontalScrollbar) {
        _unpinnedHorizontalScrollbar = renderBox;
      } else if (parentData.id == LayoutChildId.leftPinnedHorizontalScrollbar) {
        _leftPinnedHorizontalScrollbar = renderBox;
      } else if (parentData.id == LayoutChildId.headerEdge) {
        _headerEdge = renderBox;
      } else if (parentData.id == LayoutChildId.scrollbarEdge) {
        _scrollbarEdge = renderBox;
      } else if (parentData.id == LayoutChildId.header) {
        _header = renderBox;
      } else if (parentData.id == LayoutChildId.summary) {
        _summary = renderBox;
      } else if (parentData.id == LayoutChildId.summaryEdge) {
        _summaryEdge = renderBox;
      }
    });

    // header
    // The header no longer has a theme-fixed height: it is discovered from
    // the header content's own intrinsic height, then everything below it is
    // repositioned to match.
    final double headerHeight = _layoutHeader();
    _headerBounds =
        Rect.fromLTWH(0, 0, _layoutSettings.headerBounds.width, headerHeight);

    // rows
    double cellsHeight = _layoutSettings.cellsBounds.height;
    if (constraints.hasBoundedHeight) {
      // Total table height is fixed by the incoming constraints: the rows
      // area absorbs whatever difference the real header height introduced.
      final double headerHeightDelta =
          headerHeight - _layoutSettings.headerBounds.height;
      cellsHeight = math.max(0, cellsHeight - headerHeightDelta);
    }
    // Otherwise (unbounded height / visibleRowsCount mode) the rows area
    // keeps its size and the table simply grows or shrinks by the delta.
    _cellsBounds = Rect.fromLTWH(
        0, headerHeight, _layoutSettings.cellsBounds.width, cellsHeight);
    _layoutChild(child: _rows, bounds: _cellsBounds);

    // summary
    _summaryBounds = _summary != null
        ? Rect.fromLTWH(
            0,
            _cellsBounds.bottom,
            _layoutSettings.summaryBounds.width,
            _layoutSettings.summaryBounds.height)
        : Rect.zero;
    if (_summary != null) {
      _summary!.layout(
          BoxConstraints.tightFor(
              width: _summaryBounds.width, height: _summaryBounds.height),
          parentUsesSize: true);
      _summary!._parentData().offset = Offset(0, _summaryBounds.top);
    }

    // horizontal scrollbars
    final double horizontalScrollbarsTop =
        _cellsBounds.bottom + _summaryBounds.height;
    _leftPinnedHorizontalScrollbarBounds =
        _layoutSettings.hasHorizontalScrollbar
            ? _translateTop(_layoutSettings.leftPinnedHorizontalScrollbarBounds,
                horizontalScrollbarsTop)
            : Rect.zero;
    _unpinnedHorizontalScrollbarsBounds = _layoutSettings.hasHorizontalScrollbar
        ? _translateTop(_layoutSettings.unpinnedHorizontalScrollbarsBounds,
            horizontalScrollbarsTop)
        : Rect.zero;
    _horizontalScrollbarsBounds = _layoutSettings.hasHorizontalScrollbar
        ? _translateTop(
            _layoutSettings.horizontalScrollbarsBounds, horizontalScrollbarsTop)
        : Rect.zero;
    _layoutChild(
        child: _leftPinnedHorizontalScrollbar,
        bounds: _leftPinnedHorizontalScrollbarBounds);
    _layoutChild(
        child: _unpinnedHorizontalScrollbar,
        bounds: _unpinnedHorizontalScrollbarsBounds);

    // vertical scrollbar
    _verticalScrollbarBounds = Rect.fromLTWH(_cellsBounds.width, headerHeight,
        _layoutSettings.verticalScrollbarBounds.width, _cellsBounds.height);
    _layoutChild(child: _verticalScrollbar, bounds: _verticalScrollbarBounds);

    // total height
    _height = horizontalScrollbarsTop + _horizontalScrollbarsBounds.height;

    // header edge
    if (_headerEdge != null) {
      _headerEdge!.layout(
          BoxConstraints.tightFor(
              width: _layoutSettings.themeMetrics.scrollbar.width,
              height: headerHeight),
          parentUsesSize: true);
      _headerEdge!._parentData().offset = Offset(
          constraints.maxWidth - _layoutSettings.themeMetrics.scrollbar.width,
          0);
    }

    // summary edge
    if (_summaryEdge != null) {
      _summaryEdge!.layout(
          BoxConstraints.tightFor(
              width: _layoutSettings.themeMetrics.scrollbar.width,
              height: _layoutSettings.themeMetrics.summary.height),
          parentUsesSize: true);
      _summaryEdge!._parentData().offset = Offset(
          constraints.maxWidth - _layoutSettings.themeMetrics.scrollbar.width,
          _height -
              (_layoutSettings.hasHorizontalScrollbar
                  ? _layoutSettings.themeMetrics.scrollbar.height
                  : 0) -
              _layoutSettings.themeMetrics.summary.height);
    }

    // scrollbar edge
    if (_scrollbarEdge != null) {
      _scrollbarEdge!.layout(
          BoxConstraints.tightFor(
              width: _layoutSettings.themeMetrics.scrollbar.width,
              height: _layoutSettings.themeMetrics.scrollbar.height),
          parentUsesSize: true);
      _scrollbarEdge!._parentData().offset = Offset(
          constraints.maxWidth - _layoutSettings.themeMetrics.scrollbar.width,
          _height - _layoutSettings.themeMetrics.scrollbar.height);
    }

    size = constraints.constrain(Size(constraints.maxWidth, _height));
  }

  /// Lays out the header and returns its real (discovered) height.
  ///
  /// The height is discovered via the header's intrinsic-height query
  /// (rather than a real layout pass with a loose height constraint), asking
  /// each header cell "how tall would you be at your column's width". A real
  /// loose-height layout would instead go through each cell's normal layout
  /// algorithm, including internal "flexible child" sizing that measures at
  /// a temporary zero main-axis size (e.g. AxisLayout's `expand` children) —
  /// which produces a wildly wrong height for width-wrapping content such as
  /// unconstrained Text.
  ///
  /// The bottom border isn't part of that content (it paints inline, within
  /// whatever height the header is given), so it's added afterwards.
  double _layoutHeader() {
    if (_header == null) {
      return 0;
    }
    final double headerWidth = _layoutSettings.headerBounds.width;
    final double bottomBorderHeight =
        _layoutSettings.themeMetrics.header.bottomBorderHeight;
    final double contentHeight = _header!.getMaxIntrinsicHeight(headerWidth);
    final double headerHeight = contentHeight + bottomBorderHeight;
    _header!.layout(
        BoxConstraints.tightFor(width: headerWidth, height: headerHeight),
        parentUsesSize: true);
    _header!._parentData().offset = Offset.zero;
    return headerHeight;
  }

  static Rect _translateTop(Rect rect, double top) =>
      Rect.fromLTWH(rect.left, top, rect.width, rect.height);

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
    final int maxVisibleRowsLength =
        _layoutSettings.rowExtentManager.visibleRowCount(
            scrollOffset: 0, availableHeight: _layoutSettings.cellsBounds.height);
    final int visibleRowsLength =
        math.min(_layoutSettings.rowsLength, maxVisibleRowsLength);
    return computeMinIntrinsicHeight(width) +
        _layoutSettings.rowExtentManager.heightUpTo(visibleRowsLength) +
        _layoutSettings.themeMetrics.scrollbar.height;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _paintChild(
        context: context,
        offset: offset,
        child: _header,
        clipBounds: _headerBounds);
    _paintChild(
        context: context, offset: offset, child: _headerEdge, clipBounds: null);
    _paintChild(
        context: context,
        offset: offset,
        child: _verticalScrollbar,
        clipBounds: _verticalScrollbarBounds);
    _paintChild(
        context: context,
        offset: offset,
        child: _leftPinnedHorizontalScrollbar,
        clipBounds: _horizontalScrollbarsBounds);
    _paintChild(
        context: context,
        offset: offset,
        child: _unpinnedHorizontalScrollbar,
        clipBounds: _horizontalScrollbarsBounds);
    _paintChild(
        context: context,
        offset: offset,
        child: _scrollbarEdge,
        clipBounds: null);
    _paintChild(
        context: context,
        offset: offset,
        child: _summaryEdge,
        clipBounds: null);
    _paintChild(
        context: context, offset: offset, child: _summary, clipBounds: null);
    _paintChild(
        context: context,
        offset: offset,
        child: _rows,
        clipBounds: _cellsBounds);

    // scrollbar column divider
    if (_layoutSettings.themeMetrics.columnDividerThickness > 0 &&
        _leftPinnedHorizontalScrollbarBounds.width > 0 &&
        _leftPinnedHorizontalScrollbarBounds.width < _cellsBounds.width &&
        _theme.scrollbar.columnDividerColor != null) {
      context.canvas.save();
      context.canvas.clipRect(
          Rect.fromLTWH(offset.dx, offset.dy, _cellsBounds.width, _height));
      context.canvas.drawRect(
          Rect.fromLTWH(
              offset.dx + _leftPinnedHorizontalScrollbarBounds.width,
              offset.dy + _cellsBounds.bottom + _summaryBounds.height,
              _layoutSettings.themeMetrics.columnDividerThickness,
              _leftPinnedHorizontalScrollbarBounds.height),
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
