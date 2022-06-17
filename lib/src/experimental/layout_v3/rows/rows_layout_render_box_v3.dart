import 'package:easy_table/src/experimental/layout_v3/rows/rows_layout_parent_data_v3.dart';
import 'package:easy_table/src/experimental/layout_v3/rows/rows_painting_settings.dart';
import 'package:easy_table/src/experimental/metrics/table_layout_settings_v3.dart';
import 'package:flutter/rendering.dart';

class RowsLayoutRenderBoxV3<ROW> extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, RowsLayoutParentDataV3>,
        RenderBoxContainerDefaultsMixin<RenderBox, RowsLayoutParentDataV3> {
  RowsLayoutRenderBoxV3(
      {required TableLayoutSettingsV3<ROW> layoutSettings,
      required RowsPaintingSettings paintSettings})
      : _layoutSettings = layoutSettings,
        _paintSettings = paintSettings;

  TableLayoutSettingsV3<ROW> _layoutSettings;

  set layoutSettings(TableLayoutSettingsV3<ROW> value) {
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

      final double y =
          (rowIndex * rowHeight) - _layoutSettings.offsets.vertical;

      renderBox._parentData().offset = Offset(0, y);
    });

    size = computeDryLayout(constraints);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);

    if (_layoutSettings.columnDividerThickness > 0 &&
        _paintSettings.divisorColor != null) {
      Paint paint = Paint()..color = _paintSettings.divisorColor!;
      final int last =
          _layoutSettings.firstRowIndex + _layoutSettings.maxVisibleRowsLength;
      for (int i = _layoutSettings.firstRowIndex; i < last; i++) {
        double top = (i * _layoutSettings.rowHeight) -
            _layoutSettings.offsets.vertical +
            _layoutSettings.cellHeight +
            offset.dy;
        context.canvas.drawRect(
            Rect.fromLTWH(offset.dx, top, _layoutSettings.cellsBounds.width,
                _layoutSettings.rowDividerThickness),
            paint);
      }

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
