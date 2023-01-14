import 'package:davi/src/internal/column_metrics.dart';
import 'package:davi/src/internal/columns_layout_parent_data.dart';
import 'package:davi/src/internal/scroll_offsets.dart';
import 'package:davi/src/internal/table_layout_settings.dart';
import 'package:davi/src/pin_status.dart';
import 'package:davi/src/theme/theme_data.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

@internal
class ColumnsLayoutRenderBox<ROW> extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, ColumnsLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, ColumnsLayoutParentData> {
  ColumnsLayoutRenderBox(
      {required TableLayoutSettings layoutSettings,
      required HorizontalScrollOffsets horizontalScrollOffsets,
      required DaviThemeData theme,
      required bool paintDividerColumns})
      : _layoutSettings = layoutSettings,
        _horizontalScrollOffsets = horizontalScrollOffsets,
        _paintDividerColumns = paintDividerColumns,
        _theme = theme;

  bool _paintDividerColumns;

  set paintDividerColumns(bool value) {
    if (_paintDividerColumns != value) {
      _paintDividerColumns = value;
      markNeedsPaint();
    }
  }

  DaviThemeData _theme;

  set theme(DaviThemeData value) {
    if (_theme != value) {
      _theme = value;
      if (_paintDividerColumns) {
        markNeedsPaint();
      }
    }
  }

  HorizontalScrollOffsets _horizontalScrollOffsets;

  set horizontalScrollOffsets(HorizontalScrollOffsets value) {
    if (_horizontalScrollOffsets != value) {
      _horizontalScrollOffsets = value;
      markNeedsLayout();
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
      final double offset = _horizontalScrollOffsets.getOffset(pinStatus);
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
    if (_paintDividerColumns &&
        _theme.columnDividerThickness > 0 &&
        _theme.header.columnDividerColor != null) {
      Paint? headerPaint;
      if (_layoutSettings.themeMetrics.header.visible &&
          _theme.header.columnDividerColor != null) {
        headerPaint = Paint()..color = _theme.header.columnDividerColor!;
      }

      bool needAreaDivisor = false;
      for (int columnIndex = 0;
          columnIndex < _layoutSettings.columnsMetrics.length;
          columnIndex++) {
        final ColumnMetrics columnMetrics =
            _layoutSettings.columnsMetrics[columnIndex];
        final PinStatus pinStatus = columnMetrics.pinStatus;
        final Rect areaBounds = _layoutSettings.getAreaBounds(pinStatus);
        final double scrollOffset =
            _horizontalScrollOffsets.getOffset(pinStatus);
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
                  _layoutSettings.themeMetrics.columnDividerThickness,
                  _layoutSettings.themeMetrics.headerCell.height),
              headerPaint);
        }
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
          if (headerPaint != null) {
            context.canvas.drawRect(
                Rect.fromLTWH(
                    left,
                    offset.dy,
                    _layoutSettings.themeMetrics.columnDividerThickness,
                    _layoutSettings.themeMetrics.headerCell.height),
                headerPaint);
          }
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
}

/// Utility extension to facilitate obtaining parent data.
extension _ParentDataGetter on RenderObject {
  ColumnsLayoutParentData _parentData() {
    return parentData as ColumnsLayoutParentData;
  }
}
