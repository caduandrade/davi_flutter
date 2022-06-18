import 'package:easy_table/src/internal/rows_layout_parent_data.dart';
import 'package:easy_table/src/internal/rows_painting_settings.dart';
import 'package:easy_table/src/internal/table_layout_settings.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

@internal
class RowsLayoutRenderBox<ROW> extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, RowsLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, RowsLayoutParentData> {
  RowsLayoutRenderBox(
      {required TableLayoutSettings<ROW> layoutSettings,
      required RowsPaintingSettings paintSettings})
      : _layoutSettings = layoutSettings,
        _paintSettings = paintSettings;

  TableLayoutSettings<ROW> _layoutSettings;

  set layoutSettings(TableLayoutSettings<ROW> value) {
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
    if (child.parentData is! RowsLayoutParentData) {
      child.parentData = RowsLayoutParentData();
    }
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return Size(constraints.maxWidth, constraints.maxHeight);
  }

  @override
  void performLayout() {
    final double rowHeight = _layoutSettings.themeMetrics.rowHeight;

    visitChildren((child) {
      final RenderBox renderBox = child as RenderBox;
      final RowsLayoutParentData parentData = child._parentData();
      final int rowIndex = parentData.index!;

      renderBox.layout(
          BoxConstraints.tightFor(
              width: constraints.maxWidth,
              height: _layoutSettings.themeMetrics.cellHeight),
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
    if (_layoutSettings.themeMetrics.columnDividerThickness > 0 &&
        _paintSettings.divisorColor != null) {
      Paint paint = Paint()..color = _paintSettings.divisorColor!;
      final int last =
          _layoutSettings.firstRowIndex + _layoutSettings.maxVisibleRowsLength;
      for (int i = _layoutSettings.firstRowIndex; i < last; i++) {
        double top = (i * _layoutSettings.themeMetrics.rowHeight) -
            _layoutSettings.offsets.vertical +
            _layoutSettings.themeMetrics.cellHeight +
            offset.dy;
        context.canvas.drawRect(
            Rect.fromLTWH(offset.dx, top, _layoutSettings.cellsBounds.width,
                _layoutSettings.themeMetrics.rowDividerThickness),
            paint);
      }
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

/// Utility extension to facilitate obtaining parent data.
extension _ParentDataGetter on RenderObject {
  RowsLayoutParentData _parentData() {
    return parentData as RowsLayoutParentData;
  }
}
