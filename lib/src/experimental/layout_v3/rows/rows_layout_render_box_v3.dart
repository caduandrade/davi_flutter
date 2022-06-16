import 'package:easy_table/src/experimental/layout_v3/layout_util_mixin_v3.dart';
import 'package:easy_table/src/experimental/layout_v3/rows/rows_layout_parent_data_v3.dart';
import 'package:easy_table/src/experimental/layout_v3/rows/rows_layout_settings.dart';
import 'package:easy_table/src/experimental/layout_v3/rows/rows_painting_settings.dart';
import 'package:flutter/rendering.dart';

class RowsLayoutRenderBoxV3<ROW> extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, RowsLayoutParentDataV3>,
        RenderBoxContainerDefaultsMixin<RenderBox, RowsLayoutParentDataV3>,
        LayoutUtilMixinV3 {
  RowsLayoutRenderBoxV3(
      {required RowsLayoutSettings layoutSettings,
      required RowsPaintingSettings paintSettings})
      : _layoutSettings = layoutSettings,
        _paintSettings = paintSettings;

  RowsLayoutSettings _layoutSettings;

  set layoutSettings(RowsLayoutSettings value) {
    if (_layoutSettings != value) {
      _layoutSettings = value;
      markNeedsLayout();
    }
  }

  RowsPaintingSettings _paintSettings;

  set paintSettings(RowsPaintingSettings value) {
    if (_paintSettings != value) {
      _paintSettings = value;
      markNeedsPaint();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! RowsLayoutParentDataV3) {
      child.parentData = RowsLayoutParentDataV3();
    }
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return Size(constraints.maxWidth, constraints.maxHeight);
  }

  @override
  void performLayout() {
    final double rowHeight = _layoutSettings.rowHeight;

    visitChildren((child) {
      final RenderBox renderBox = child as RenderBox;
      final RowsLayoutParentDataV3 parentData = child._parentData();
      final int rowIndex = parentData.index!;

      renderBox.layout(
          BoxConstraints.tightFor(
              width: constraints.maxWidth, height: _layoutSettings.cellHeight),
          parentUsesSize: true);

      final double y = rowY(
          verticalOffset: _layoutSettings.verticalOffset,
          rowIndex: rowIndex,
          rowHeight: rowHeight);

      renderBox._parentData().offset = Offset(0, y);
    });

    size = computeDryLayout(constraints);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);

    if (_layoutSettings.dividerThickness > 0) {
      //TODO paint dividers
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

/// Utility extension to facilitate obtaining parent data.
extension _ParentDataGetter on RenderObject {
  RowsLayoutParentDataV3 _parentData() {
    return parentData as RowsLayoutParentDataV3;
  }
}
