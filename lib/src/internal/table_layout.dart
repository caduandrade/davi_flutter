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
      required int rowsCount,
      required int? visibleRowsCount}) {
    List<Widget> children = [body];
    if (header != null) {
      children.insert(0, header);
    }
    return TableLayout._(
        key: key,
        children: children,
        rowHeight: rowHeight,
        rowsCount: rowsCount,
        headerHeight: headerHeight,
        visibleRowsCount: visibleRowsCount);
  }

  TableLayout._(
      {Key? key,
      required this.rowsCount,
      required this.rowHeight,
      required this.headerHeight,
      required this.visibleRowsCount,
      required List<Widget> children})
      : super(key: key, children: children);

  final double rowHeight;
  final double headerHeight;
  final int rowsCount;

  /// Calculates the height based on the number of visible lines.
  /// It can be used within an unbounded height layout.
  final int? visibleRowsCount;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _TableLayoutRenderBox(
        rowHeight: rowHeight,
        rowsCount: rowsCount,
        visibleRowsCount: visibleRowsCount,
        headerHeight: headerHeight);
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
      ..rowHeight = rowHeight
      ..visibleRowsCount = visibleRowsCount;
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
      required double headerHeight,
      required int? visibleRowsCount})
      : _rowHeight = rowHeight,
        _headerHeight = headerHeight,
        _rowsCount = rowsCount,
        _visibleRowsCount = visibleRowsCount;

  int? _visibleRowsCount;
  set visibleRowsCount(int? value) {
    if (_visibleRowsCount != value) {
      _visibleRowsCount = value;
      markNeedsLayout();
    }
  }

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
    if (constraints.hasBoundedWidth == false) {
      throw StateError('Unbounded width constraints');
    }

    RenderBox? headerRenderBox = childCount == 2 ? firstChild! : null;
    RenderBox bodyRenderBox = childCount == 1 ? firstChild! : lastChild!;

    double bodyHeight = 0;

    if (headerRenderBox != null) {
      headerRenderBox.layout(
          BoxConstraints(
              minWidth: constraints.minWidth,
              maxWidth: constraints.maxWidth,
              minHeight: 0,
              maxHeight: math.min(_headerHeight, constraints.maxHeight)),
          parentUsesSize: true);
      headerRenderBox.tableLayoutParentData().offset = Offset.zero;
      bodyHeight += headerRenderBox.size.height;
    }

    bodyRenderBox.layout(
        BoxConstraints(
            minWidth: constraints.minWidth,
            maxWidth: constraints.maxWidth,
            minHeight: 0,
            maxHeight: math.min(_rowHeight * (_visibleRowsCount ?? _rowsCount),
                constraints.maxHeight - bodyHeight)),
        parentUsesSize: true);
    bodyRenderBox.tableLayoutParentData().offset = Offset(0, _headerHeight);
    bodyHeight += bodyRenderBox.size.height;

    if (constraints.hasBoundedHeight) {
      size = Size(
          constraints.maxWidth, math.max(bodyHeight, constraints.maxHeight));
    } else {
      size = Size(constraints.maxWidth, bodyHeight);
    }
  }

  double _maxHeight() {
    return _headerHeight + (_rowsCount * _rowHeight);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _headerHeight;
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
