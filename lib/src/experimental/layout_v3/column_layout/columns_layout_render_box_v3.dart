import 'package:easy_table/src/experimental/layout_v3/column_layout/columns_layout_parent_data_v3.dart';
import 'package:easy_table/src/experimental/layout_v3/column_layout/columns_layout_settings.dart';
import 'package:flutter/rendering.dart';

class ColumnsLayoutRenderBoxV3<ROW> extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, ColumnsLayoutParentDataV3>,
        RenderBoxContainerDefaultsMixin<RenderBox, ColumnsLayoutParentDataV3> {
  ColumnsLayoutRenderBoxV3({required ColumnsLayoutSettings layoutSettings})
      : _layoutSettings = layoutSettings;

  ColumnsLayoutSettings _layoutSettings;

  set layoutSettings(ColumnsLayoutSettings value) {
    if (_layoutSettings != value) {
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
    double x = 0;
    visitChildren((child) {
      final RenderBox renderBox = child as RenderBox;
      final ColumnsLayoutParentDataV3 parentData = child._parentData();
      final int columnIndex = parentData.index!;

      renderBox.layout(
          BoxConstraints.tightFor(width: 60, height: constraints.maxHeight),
          parentUsesSize: true);
      renderBox._parentData().offset = Offset(x, 0);
      x += 60;
    });

    size = computeDryLayout(constraints);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

/// Utility extension to facilitate obtaining parent data.
extension _ParentDataGetter on RenderObject {
  ColumnsLayoutParentDataV3 _parentData() {
    return parentData as ColumnsLayoutParentDataV3;
  }
}
