import 'dart:math' as math;

import 'package:davi/src/internal/column_metrics.dart';
import 'package:davi/src/internal/columns_layout_parent_data.dart';
import 'package:davi/src/internal/scroll_controllers.dart';
import 'package:davi/src/internal/table_layout_settings.dart';
import 'package:davi/src/pin_status.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

@internal
class ColumnsLayoutRenderBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, ColumnsLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, ColumnsLayoutParentData> {
  ColumnsLayoutRenderBox(
      {required TableLayoutSettings layoutSettings,
      required Color? columnDividerColor,
      required double columnDividerThickness,
      required ScrollControllers scrollControllers})
      : _layoutSettings = layoutSettings,
        _columnDividerThickness = columnDividerThickness,
        _columnDividerColor = columnDividerColor,
        _scrollControllers = scrollControllers {
    _scrollControllers.leftPinnedHorizontal.addListener(markNeedsPaint);
    _scrollControllers.unpinnedHorizontal.addListener(markNeedsPaint);
  }

  double _columnDividerThickness;

  set columnDividerThickness(double value) {
    if (_columnDividerThickness != value) {
      _columnDividerThickness = value;
      markNeedsPaint();
    }
  }

  Color? _columnDividerColor;

  set columnDividerColor(Color? value) {
    if (_columnDividerColor != value) {
      _columnDividerColor = value;
      markNeedsPaint();
    }
  }

  ScrollControllers _scrollControllers;

  set scrollControllers(ScrollControllers value) {
    if (_scrollControllers != value) {
      _scrollControllers.leftPinnedHorizontal.removeListener(markNeedsPaint);
      _scrollControllers.unpinnedHorizontal.removeListener(markNeedsPaint);
      _scrollControllers = value;
      _scrollControllers.leftPinnedHorizontal.addListener(markNeedsPaint);
      _scrollControllers.unpinnedHorizontal.addListener(markNeedsPaint);
    }
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
    if (child.parentData is! ColumnsLayoutParentData) {
      child.parentData = ColumnsLayoutParentData();
    }
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    if (!constraints.hasBoundedHeight) {
      return Size(constraints.maxWidth,
          constraints.constrainHeight(_measureRowHeight(useMax: true)));
    }
    return Size(constraints.maxWidth, constraints.maxHeight);
  }

  /// Measures the natural (content-driven) row height using each child's own
  /// intrinsic height at its column width, instead of a real layout pass.
  ///
  /// A real layout at a loose/unbounded height would go through each cell's
  /// normal layout algorithm, including any internal "flexible child" sizing
  /// that measures at a temporary zero main-axis size (e.g. AxisLayout's
  /// `expand` children) — which produces a wildly wrong height for
  /// width-wrapping content such as unconstrained Text. The dedicated
  /// intrinsic-height query asks each child directly "how tall would you be
  /// at this width", sidestepping that.
  double _measureRowHeight({required bool useMax}) {
    double rowHeight = 0;
    visitChildren((child) {
      final RenderBox renderBox = child as RenderBox;
      final ColumnsLayoutParentData parentData = child._parentData();
      final int columnIndex = parentData.index!;
      final double columnWidth =
          _layoutSettings.columnsMetrics[columnIndex].width;
      final double childHeight = useMax
          ? renderBox.getMaxIntrinsicHeight(columnWidth)
          : renderBox.getMinIntrinsicHeight(columnWidth);
      rowHeight = math.max(rowHeight, childHeight);
    });
    return rowHeight;
  }

  @override
  double computeMinIntrinsicHeight(double width) =>
      _measureRowHeight(useMax: false);

  @override
  double computeMaxIntrinsicHeight(double width) =>
      _measureRowHeight(useMax: true);

  @override
  void performLayout() {
    final double rowHeight = constraints.hasBoundedHeight
        ? constraints.maxHeight
        : constraints.constrainHeight(_measureRowHeight(useMax: true));

    visitChildren((child) {
      final RenderBox renderBox = child as RenderBox;
      final ColumnsLayoutParentData parentData = child._parentData();
      final int columnIndex = parentData.index!;
      final ColumnMetrics columnMetrics =
          _layoutSettings.columnsMetrics[columnIndex];
      renderBox.layout(
          BoxConstraints.tightFor(width: columnMetrics.width, height: rowHeight),
          parentUsesSize: true);
      renderBox._parentData().offset = Offset.zero;
    });

    size = Size(constraints.maxWidth, rowHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    RenderBox? child = firstChild;
    while (child != null) {
      final ColumnsLayoutParentData childParentData = child._parentData();
      final int columnIndex = childParentData.index!;
      final ColumnMetrics columnMetrics =
          _layoutSettings.columnsMetrics[columnIndex];
      final PinStatus pinStatus = columnMetrics.pinStatus;
      final double offsetX = _scrollControllers.getOffset(pinStatus);
      final Rect bounds = _layoutSettings.getAreaBounds(pinStatus);
      context.canvas.save();
      context.canvas.clipRect(bounds.translate(offset.dx, offset.dy));
      context.paintChild(
          child, Offset(columnMetrics.offset - offsetX + offset.dx, offset.dy));
      context.canvas.restore();
      child = childParentData.nextSibling;
    }

    // column dividers
    if (_columnDividerThickness > 0 && _columnDividerColor != null) {
      Paint paint = Paint()..color = _columnDividerColor!;

      bool needAreaDivisor = false;
      for (int columnIndex = 0;
          columnIndex < _layoutSettings.columnsMetrics.length;
          columnIndex++) {
        final ColumnMetrics columnMetrics =
            _layoutSettings.columnsMetrics[columnIndex];
        final PinStatus pinStatus = columnMetrics.pinStatus;
        final Rect areaBounds = _layoutSettings.getAreaBounds(pinStatus);
        final double scrollOffset = _scrollControllers.getOffset(pinStatus);
        double left = offset.dx +
            columnMetrics.offset +
            columnMetrics.width -
            scrollOffset;
        context.canvas.save();
        context.canvas.clipRect(areaBounds.translate(offset.dx, offset.dy));
        context.canvas.drawRect(
            Rect.fromLTWH(
                left,
                offset.dy,
                _layoutSettings.themeMetrics.columnDividerThickness,
                constraints.maxHeight),
            paint);
        context.canvas.restore();
        if (pinStatus == PinStatus.left) {
          needAreaDivisor = true;
        } else if (needAreaDivisor && pinStatus == PinStatus.none) {
          needAreaDivisor = false;
          context.canvas.save();
          context.canvas.clipRect(Rect.fromLTWH(offset.dx, offset.dy,
              _layoutSettings.cellsBounds.width, _layoutSettings.height));
          left = offset.dx +
              columnMetrics.offset -
              _layoutSettings.themeMetrics.columnDividerThickness;
          context.canvas.drawRect(
              Rect.fromLTWH(
                  left,
                  offset.dy,
                  _layoutSettings.themeMetrics.columnDividerThickness,
                  constraints.maxHeight),
              paint);
          context.canvas.restore();
        }
      }
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    RenderBox? child = firstChild;
    while (child != null) {
      final ColumnsLayoutParentData childParentData = child._parentData();
      final int columnIndex = childParentData.index!;
      final ColumnMetrics columnMetrics =
          _layoutSettings.columnsMetrics[columnIndex];
      final PinStatus pinStatus = columnMetrics.pinStatus;
      final Offset renderedPosition = Offset(
          columnMetrics.offset - _scrollControllers.getOffset(pinStatus), 0);
      final bool isHit = result.addWithPaintOffset(
        offset: renderedPosition,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          return child!.hitTest(result, position: transformed);
        },
      );
      if (isHit) {
        return true;
      }
      child = childParentData.nextSibling;
    }
    return false;
  }

  @override
  void dispose() {
    _scrollControllers.leftPinnedHorizontal.removeListener(markNeedsPaint);
    _scrollControllers.unpinnedHorizontal.removeListener(markNeedsPaint);
    super.dispose();
  }
}

/// Utility extension to facilitate obtaining parent data.
extension _ParentDataGetter on RenderObject {
  ColumnsLayoutParentData _parentData() {
    return parentData as ColumnsLayoutParentData;
  }
}
