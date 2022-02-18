import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// [EasyTable] table layout.
@internal
class TableLayout extends MultiChildRenderObjectWidget {
  factory TableLayout(
      {Key? key,
      Widget? header,
      required Widget body,
      required double rowHeight,
      required double headerHeight,
      required int rowsCount}) {
    List<Widget> children = [body];
    if (header != null) {
      children.insert(0, header);
    }
    return TableLayout._(
        key: key,
        children: children,
        rowHeight: rowHeight,
        rowsCount: rowsCount,
        headerHeight: headerHeight);
  }

  TableLayout._(
      {Key? key,
      required this.rowsCount,
      required this.rowHeight,
      required this.headerHeight,
      required List<Widget> children})
      : super(key: key, children: children);

  final double rowHeight;
  final double headerHeight;
  final int rowsCount;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _TableLayoutRenderBox(
        rowHeight: rowHeight, rowsCount: rowsCount, headerHeight: headerHeight);
  }

  @override
  MultiChildRenderObjectElement createElement() {
    return _TableLayoutElement(this);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _TableLayoutRenderBox renderObject) {
    super.updateRenderObject(context, renderObject);
    renderObject
      ..headerHeight = headerHeight
      ..rowsCount = rowsCount
      ..rowHeight = rowHeight;
  }
}

/// The [TableLayout] element.
class _TableLayoutElement extends MultiChildRenderObjectElement {
  _TableLayoutElement(TableLayout widget) : super(widget);

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    for (var child in children) {
      if (child.renderObject != null) {
        visitor(child);
      }
    }
  }
}

/// Parent data for [_TableLayoutRenderBox] class.
class _TableLayoutParentData extends ContainerBoxParentData<RenderBox> {}

class _TableLayoutRenderBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _TableLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _TableLayoutParentData> {
  _TableLayoutRenderBox(
      {required int rowsCount,
      required double rowHeight,
      required double headerHeight})
      : _rowHeight = rowHeight,
        _headerHeight = headerHeight,
        _rowsCount = rowsCount;

  int _rowsCount;
  set rowsCount(int value) {
    if (_rowsCount != value) {
      _rowsCount = value;
      markNeedsLayout();
    }
  }

  double _rowHeight;
  set rowHeight(double value) {
    if (_rowHeight != value) {
      _rowHeight = value;
      markNeedsLayout();
    }
  }

  double _headerHeight;
  set headerHeight(double value) {
    if (_headerHeight != value) {
      _headerHeight = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _TableLayoutParentData) {
      child.parentData = _TableLayoutParentData();
    }
  }

  @override
  void performLayout() {
    print('constraints: $constraints');

    if (constraints.hasBoundedWidth == false) {
      throw StateError('Unbounded width constraints');
    }

    RenderBox? headerRenderBox = childCount == 2 ? firstChild! : null;
    RenderBox bodyRenderBox = childCount == 1 ? firstChild! : lastChild!;

    if (headerRenderBox != null) {
      headerRenderBox.layout(
          BoxConstraints(
              minWidth: constraints.minWidth,
              maxWidth: constraints.maxWidth,
              minHeight: _headerHeight,
              maxHeight: _headerHeight),
          parentUsesSize: true);
      headerRenderBox.tableLayoutParentData().offset = Offset.zero;
    }

    double bodyHeight = 0;
    if (constraints.maxHeight.isInfinite) {
      bodyHeight = _maxHeight();
    } else {
      bodyHeight = math.max(0, constraints.maxHeight - _headerHeight);
    }

    bodyRenderBox.layout(
        BoxConstraints(
            minWidth: constraints.minWidth,
            maxWidth: constraints.maxWidth,
            minHeight: bodyHeight,
            maxHeight: bodyHeight),
        parentUsesSize: true);
    bodyRenderBox.tableLayoutParentData().offset = Offset(0, _headerHeight);

    if (constraints.hasBoundedHeight) {
      size = constraints.biggest;
    } else {
      size = Size(constraints.maxWidth, bodyHeight);
    }
  }

  double _minHeight() {
    return childCount == 1 ? 0 : _headerHeight;
  }

  double _maxHeight() {
    return _minHeight() * (_rowsCount * _rowHeight);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _minHeight();
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return _maxHeight();
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}

/// Utility extension to facilitate obtaining parent data.
extension _TableLayoutParentDataGetter on RenderObject {
  _TableLayoutParentData tableLayoutParentData() {
    return parentData as _TableLayoutParentData;
  }
}
