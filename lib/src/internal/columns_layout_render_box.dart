import 'package:easy_table/src/column.dart';
import 'package:easy_table/src/internal/columns_layout_parent_data.dart';
import 'package:easy_table/src/internal/column_metrics.dart';
import 'package:easy_table/src/internal/table_layout_settings.dart';
import 'package:easy_table/src/pin_status.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

@internal
class ColumnsLayoutRenderBox<ROW> extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, ColumnsLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, ColumnsLayoutParentData> {
  ColumnsLayoutRenderBox({required TableLayoutSettings<ROW> layoutSettings})
      : _layoutSettings = layoutSettings;

  TableLayoutSettings<ROW> _layoutSettings;

  set layoutSettings(TableLayoutSettings<ROW> value) {
    if (_layoutSettings != value) {
      //TODO maybe can check only row height and column widths
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
      final ColumnMetrics<ROW> columnMetrics =
          _layoutSettings.columnsMetrics[columnIndex];
      final EasyTableColumn<ROW> column = columnMetrics.column;
      final PinStatus pinStatus = _layoutSettings.pinStatus(column);
      final double offset = _layoutSettings.offsets.getHorizontal(pinStatus);
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
      final ColumnMetrics<ROW> columnMetrics =
          _layoutSettings.columnsMetrics[columnIndex];
      final EasyTableColumn<ROW> column = columnMetrics.column;
      final PinStatus pinStatus = _layoutSettings.pinStatus(column);
      final Rect bounds = _layoutSettings.getAreaBounds(pinStatus);
      context.canvas.save();
      context.canvas.clipRect(bounds.translate(offset.dx, offset.dy));
      context.paintChild(child, childParentData.offset + offset);
      context.canvas.restore();
      child = childParentData.nextSibling;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    RenderBox? child = lastChild;
    while (child != null) {
      final ColumnsLayoutParentData childParentData = child._parentData();
      final int columnIndex = childParentData.index!;
      final ColumnMetrics<ROW> columnMetrics =
          _layoutSettings.columnsMetrics[columnIndex];
      final EasyTableColumn<ROW> column = columnMetrics.column;
      final PinStatus pinStatus = _layoutSettings.pinStatus(column);
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
