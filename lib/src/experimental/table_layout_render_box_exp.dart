import 'package:easy_table/src/experimental/content_area.dart';
import 'package:easy_table/src/experimental/content_area_id.dart';
import 'package:easy_table/src/experimental/layout_child_type.dart';
import 'package:easy_table/src/experimental/table_layout_parent_data_exp.dart';
import 'package:easy_table/src/experimental/table_layout_settings.dart';
import 'package:easy_table/src/experimental/table_paint_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class TableLayoutRenderBoxExp extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, TableLayoutParentDataExp>,
        RenderBoxContainerDefaultsMixin<RenderBox, TableLayoutParentDataExp> {
  TableLayoutRenderBoxExp(
      {required TableLayoutSettings layoutSettings,
      required TablePaintSettings paintSettings})
      : _layoutSettings = layoutSettings,
        _paintSettings = paintSettings;

  final ContentArea _leftPinnedContentArea = ContentArea(
      id: ContentAreaId.leftPinned,
      headerAreaDebugColor: Colors.yellow[300]!,
      scrollbarAreaDebugColor: Colors.yellow[200]!);
  final ContentArea _unpinnedContentArea = ContentArea(
      id: ContentAreaId.unpinned,
      headerAreaDebugColor: Colors.lime[300]!,
      scrollbarAreaDebugColor: Colors.lime[200]!);
  final ContentArea _rightPinnedContentArea = ContentArea(
      id: ContentAreaId.rightPinned,
      headerAreaDebugColor: Colors.orange[300]!,
      scrollbarAreaDebugColor: Colors.orange[200]!);

  TableLayoutSettings _layoutSettings;
  set layoutSettings(TableLayoutSettings value) {
    if (_layoutSettings != value) {
      _layoutSettings = value;
      markNeedsLayout();
    }
  }

  TablePaintSettings _paintSettings;
  set paintSettings(TablePaintSettings value) {
    if (_paintSettings != value) {
      _paintSettings = value;
      markNeedsPaint();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! TableLayoutParentDataExp) {
      child.parentData = TableLayoutParentDataExp();
    }
  }

  @override
  void performLayout() {
    if (!constraints.hasBoundedHeight &&
        _layoutSettings.visibleRowsCount == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('EasyTable was given unbounded height.'),
        ErrorDescription(
            'EasyTable already is scrollable in the vertical axis.'),
        ErrorHint(
          'Consider using the "visibleRowsCount" property to limit the height'
          ' or use it in another Widget like Expanded or SliverFillRemaining.',
        ),
      ]);
    }
    if (!constraints.hasBoundedWidth) {
      throw FlutterError('EasyTable was given unbounded width.');
    }

    RenderBox? unpinnedHorizontalScrollbar;
    List<RenderBox> children = [];
    visitChildren((child) {
      RenderBox renderBox = child as RenderBox;
      TableLayoutParentDataExp parentData = child._parentData();
      if (parentData.type == LayoutChildType.horizontalScrollbar) {
        if (parentData.contentAreaId == ContentAreaId.unpinned) {
          unpinnedHorizontalScrollbar = renderBox;
        } else {
          //TODO error
        }
      }
      children.add(renderBox);
    });

    _leftPinnedContentArea.bounds =
        Rect.fromLTWH(0, 0, 100, constraints.maxHeight);
    _unpinnedContentArea.bounds =
        Rect.fromLTWH(150, 0, 100, constraints.maxHeight);
    _rightPinnedContentArea.bounds =
        Rect.fromLTWH(400, 0, 100, constraints.maxHeight);

    if (constraints.hasBoundedHeight) {
      size = Size(constraints.maxWidth, constraints.maxHeight);
    } else {
      // unbounded height
      size = Size(constraints.maxWidth, constraints.maxHeight);
    }

    _unpinnedContentArea.layout(
        layoutSettings: _layoutSettings,
        scrollbar: unpinnedHorizontalScrollbar);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    double height = 0;
    if (_layoutSettings.hasHeader) {
      height += _layoutSettings.headerHeight;
    }
    return height;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    double height = computeMinIntrinsicHeight(width);
    if (_layoutSettings.visibleRowsCount != null) {
      height += _layoutSettings.visibleRowsCount! * _layoutSettings.rowHeight;
    }
    return height;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_paintSettings.debugAreas) {
      if (_layoutSettings.hasHeader) {
        _forEachContentArea((area) => area.paintDebugAreas(
            canvas: context.canvas,
            offset: offset,
            layoutSettings: _layoutSettings));
      }
    }
    defaultPaint(context, offset);
  }

  void _forEachContentArea(_ContentAreaFunction function) {
    function(_leftPinnedContentArea);
    function(_unpinnedContentArea);
    function(_rightPinnedContentArea);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

typedef _ContentAreaFunction = void Function(ContentArea area);

/// Utility extension to facilitate obtaining parent data.
extension _TableLayoutParentDataGetter on RenderObject {
  TableLayoutParentDataExp _parentData() {
    return parentData as TableLayoutParentDataExp;
  }
}
