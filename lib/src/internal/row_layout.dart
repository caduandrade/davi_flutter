import 'package:easy_table/easy_table.dart';
import 'package:easy_table/src/internal/columns_metrics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

/// [EasyTable] table row layout.
@internal
class RowLayout extends MultiChildRenderObjectWidget {
  RowLayout(
      {Key? key,
      required List<Widget> children,
      required this.columnsMetrics,
      required this.width,
      required this.height})
      : super(key: key, children: children);

  final ColumnsMetrics columnsMetrics;
  final double width;
  final double height;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RowLayoutRenderBox(
        columnsMetrics: columnsMetrics, height: height, width: width);
  }

  @override
  MultiChildRenderObjectElement createElement() {
    return _RowLayoutElement(this);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _RowLayoutRenderBox renderObject) {
    super.updateRenderObject(context, renderObject);
    renderObject
      ..columnsMetrics = columnsMetrics
      ..width = width
      ..height = height;
  }
}

/// The [RowLayout] element.
class _RowLayoutElement extends MultiChildRenderObjectElement {
  _RowLayoutElement(RowLayout widget) : super(widget);

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    for (var child in children) {
      if (child.renderObject != null) {
        visitor(child);
      }
    }
  }
}

/// Parent data for [_RowLayoutRenderBox] class.
class _RowLayoutParentData extends ContainerBoxParentData<RenderBox> {}

class _RowLayoutRenderBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _RowLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _RowLayoutParentData> {
  _RowLayoutRenderBox(
      {required ColumnsMetrics columnsMetrics,
      required double width,
      required double height})
      : _columnsMetrics = columnsMetrics,
        _width = width,
        _height = height;

  ColumnsMetrics _columnsMetrics;
  set columnsMetrics(ColumnsMetrics columnsMetrics) {
    _columnsMetrics = columnsMetrics;
    markNeedsLayout();
  }

  double _width;
  set width(double width) {
    if (_width != width) {
      _width = width;
      markNeedsLayout();
    }
  }

  double _height;
  set height(double height) {
    if (_height != height) {
      _height = height;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _RowLayoutParentData) {
      child.parentData = _RowLayoutParentData();
    }
  }

  @override
  void performLayout() {
    int index = 0;
    visitChildren((child) {
      LayoutWidth layoutWidth = _columnsMetrics.columns[index];
      child.layout(
          BoxConstraints(
              minWidth: layoutWidth.width,
              maxWidth: layoutWidth.width,
              minHeight: _height,
              maxHeight: _height),
          parentUsesSize: true);
      child.rowLayoutParentData().offset = Offset(layoutWidth.x, 0);
      index++;
    });

    size = Size(_width, _height);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _height;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return _height;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
    Canvas canvas = context.canvas;
    Paint paint = Paint()..color = Colors.red;
    for (int i = 0; i < _columnsMetrics.dividers.length; i++) {
      LayoutWidth layoutWidth = _columnsMetrics.dividers[i];
      canvas.drawRect(
          Rect.fromLTWH(
              layoutWidth.x + offset.dx, offset.dy, layoutWidth.width, _height),
          paint);
    }
  }
}

/// Utility extension to facilitate obtaining parent data.
extension _RowLayoutParentDataGetter on RenderObject {
  _RowLayoutParentData rowLayoutParentData() {
    return parentData as _RowLayoutParentData;
  }
}
