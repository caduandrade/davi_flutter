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
  _scrollControllers=scrollControllers{
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
    return Size(constraints.maxWidth, constraints.maxHeight);
  }

  @override
  void performLayout() {
    visitChildren((child) {
      final RenderBox renderBox = child as RenderBox;
      final ColumnsLayoutParentData parentData = child._parentData();
      final int columnIndex = parentData.index!;
      final ColumnMetrics columnMetrics =
          _layoutSettings.columnsMetrics[columnIndex];
      final PinStatus pinStatus = columnMetrics.pinStatus;
      final double offset = _scrollControllers.getOffset(pinStatus);
      renderBox.layout(
          BoxConstraints.tightFor(
              width: columnMetrics.width, height: constraints.maxHeight),
          parentUsesSize: true);
      renderBox._parentData().offset = Offset(columnMetrics.offset - offset, 0);
    });

    size = computeDryLayout(constraints);
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
      final Rect bounds = _layoutSettings.getAreaBounds(pinStatus);
      context.canvas.save();
      context.canvas.clipRect(bounds.translate(offset.dx, offset.dy));
      context.paintChild(child, childParentData.offset + offset);
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
        final double scrollOffset =_scrollControllers.getOffset(pinStatus);
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
    RenderBox? child = lastChild;
    while (child != null) {
      final ColumnsLayoutParentData childParentData = child._parentData();
      final int columnIndex = childParentData.index!;
      final ColumnMetrics columnMetrics =
          _layoutSettings.columnsMetrics[columnIndex];
      final PinStatus pinStatus = columnMetrics.pinStatus;
      final Rect bounds = _layoutSettings.getAreaBounds(pinStatus);
      if (bounds.contains(position)) {
        final bool isHit = result.addWithPaintOffset(
          offset: childParentData.offset,
          position: position,
          hitTest: (BoxHitTestResult result, Offset transformed) {
            assert(transformed == position - childParentData.offset);
            return child!.hitTest(result, position: transformed);
          },
        );
        if (isHit) {
          return true;
        }
      }
      child = childParentData.previousSibling;
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
