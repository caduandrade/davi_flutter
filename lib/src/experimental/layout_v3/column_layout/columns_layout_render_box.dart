import 'package:easy_table/src/column.dart';
import 'package:easy_table/src/experimental/layout_v3/column_layout/columns_layout_parent_data.dart';
import 'package:easy_table/src/experimental/metrics/column_metrics.dart';
import 'package:easy_table/src/experimental/metrics/table_layout_settings.dart';
import 'package:easy_table/src/pin_status.dart';
import 'package:flutter/rendering.dart';

class ColumnsLayoutRenderBoxV3<ROW> extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, ColumnsLayoutParentDataV3>,
        RenderBoxContainerDefaultsMixin<RenderBox, ColumnsLayoutParentDataV3> {
  ColumnsLayoutRenderBoxV3({required TableLayoutSettingsV3<ROW> layoutSettings})
      : _layoutSettings = layoutSettings;

  TableLayoutSettingsV3<ROW> _layoutSettings;

  set layoutSettings(TableLayoutSettingsV3<ROW> value) {
    if (_layoutSettings != value) {
      //TODO maybe can check only row height and column widths
      _layoutSettings = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! ColumnsLayoutParentDataV3) {
      child.parentData = ColumnsLayoutParentDataV3();
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
      final ColumnsLayoutParentDataV3 parentData = child._parentData();
      final int columnIndex = parentData.index!;
      final ColumnMetricsV3<ROW> columnMetrics =
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
      final ColumnsLayoutParentDataV3 childParentData = child._parentData();
      final int columnIndex = childParentData.index!;
      final ColumnMetricsV3<ROW> columnMetrics =
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
      final ColumnsLayoutParentDataV3 childParentData = child._parentData();
      final int columnIndex = childParentData.index!;
      final ColumnMetricsV3<ROW> columnMetrics =
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
  ColumnsLayoutParentDataV3 _parentData() {
    return parentData as ColumnsLayoutParentDataV3;
  }
}
