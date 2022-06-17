import 'package:easy_table/src/experimental/layout_v3/column_layout/columns_layout_parent_data_v3.dart';
import 'package:easy_table/src/experimental/metrics/column_metrics_v3.dart';
import 'package:easy_table/src/experimental/metrics/table_layout_settings_v3.dart';
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
      //TODO maybe can check only row height and columns
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
      ColumnMetricsV3<ROW> columnMetrics =
          _layoutSettings.columnsMetrics[columnIndex];
      renderBox.layout(
          BoxConstraints.tightFor(
              width: columnMetrics.width, height: constraints.maxHeight),
          parentUsesSize: true);
      renderBox._parentData().offset = Offset(columnMetrics.offset, 0);
    });

    size = computeDryLayout(constraints);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    //TODO clip
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    //TODO clip?
    return defaultHitTestChildren(result, position: position);
  }
}

/// Utility extension to facilitate obtaining parent data.
extension _ParentDataGetter on RenderObject {
  ColumnsLayoutParentDataV3 _parentData() {
    return parentData as ColumnsLayoutParentDataV3;
  }
}
