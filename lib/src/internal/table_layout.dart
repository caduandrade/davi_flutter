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
      Widget? pinnedWidget,
      required Widget unpinnedWidget,
      required Widget scrollbarWidget,
      required double rowHeight,
      required double headerHeight,
      required double scrollbarWidth,
      required int? visibleRowsCount,
      required double? pinnedWidth,
      required bool hasHeader}) {
    List<Widget> children = [unpinnedWidget, scrollbarWidget];
    if (pinnedWidget != null) {
      children.insert(0, pinnedWidget);
    }
    return TableLayout._(
        key: key,
        children: children,
        rowHeight: rowHeight,
        scrollbarWidth: scrollbarWidth,
        headerHeight: headerHeight,
        visibleRowsCount: visibleRowsCount,
        hasHeader: hasHeader,
        pinnedWidth: pinnedWidth);
  }

  TableLayout._(
      {Key? key,
      required this.scrollbarWidth,
      required this.rowHeight,
      required this.headerHeight,
      required this.visibleRowsCount,
      required this.hasHeader,
      required this.pinnedWidth,
      required List<Widget> children})
      : super(key: key, children: children);

  final double rowHeight;
  final double headerHeight;
  final double scrollbarWidth;
  final double? pinnedWidth;
  final bool hasHeader;

  /// Calculates the height based on the number of visible lines.
  /// It can be used within an unbounded height layout.
  final int? visibleRowsCount;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _TableLayoutRenderBox(
        rowHeight: rowHeight,
        scrollbarWidth: scrollbarWidth,
        visibleRowsCount: visibleRowsCount,
        headerHeight: headerHeight,
        pinnedWidth: pinnedWidth,
        hasHeader: hasHeader);
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
      ..scrollbarWidth = scrollbarWidth
      ..rowHeight = rowHeight
      ..visibleRowsCount = visibleRowsCount
      ..hasHeader = hasHeader
      ..pinnedWidth = pinnedWidth;
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
      {required double scrollbarWidth,
      required double rowHeight,
      required double headerHeight,
      required int? visibleRowsCount,
      required bool hasHeader,
      required double? pinnedWidth})
      : _rowHeight = rowHeight,
        _headerHeight = headerHeight,
        _scrollbarWidth = scrollbarWidth,
        _visibleRowsCount = visibleRowsCount,
        _hasHeader = hasHeader,
        _pinnedWidth = pinnedWidth;

  int? _visibleRowsCount;

  set visibleRowsCount(int? value) {
    if (_visibleRowsCount != value) {
      _visibleRowsCount = value;
      markNeedsLayout();
    }
  }

  double _scrollbarWidth;

  set scrollbarWidth(double value) {
    if (_scrollbarWidth != value) {
      _scrollbarWidth = value;
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

  bool _hasHeader;

  set hasHeader(bool value) {
    if (_hasHeader != value) {
      _hasHeader = value;
      markNeedsLayout();
    }
  }

  double? _pinnedWidth;

  set pinnedWidth(double? value) {
    if (_pinnedWidth != value) {
      _pinnedWidth = value;
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
    if (!constraints.hasBoundedHeight && _visibleRowsCount == null) {
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

    List<RenderBox> children = [];
    visitChildren((child) => children.add(child as RenderBox));

    final RenderBox? pinnedRenderBox;
    final RenderBox unpinnedRenderBox;
    final RenderBox scrollbarRenderBox;
    if (children.length == 3) {
      pinnedRenderBox = children[0];
      unpinnedRenderBox = children[1];
      scrollbarRenderBox = children[2];
    } else {
      pinnedRenderBox = null;
      unpinnedRenderBox = children[0];
      scrollbarRenderBox = children[1];
    }

    final double scrollbarWidth =
        math.min(_scrollbarWidth, constraints.maxWidth);
    final double pinnedWidth = _pinnedWidth != null
        ? math.min(_pinnedWidth!, constraints.maxWidth - scrollbarWidth)
        : 0;
    final double unpinnedWidth =
        math.max(0, constraints.maxWidth - pinnedWidth - scrollbarWidth);

    if (constraints.hasBoundedHeight) {
      double x = 0;

      // pinned
      if (pinnedRenderBox != null) {
        pinnedRenderBox.layout(
            BoxConstraints(
                minWidth: pinnedWidth,
                maxWidth: pinnedWidth,
                minHeight: constraints.maxHeight,
                maxHeight: constraints.maxHeight),
            parentUsesSize: true);
        pinnedRenderBox.tableAreaLayoutParentData().offset = Offset.zero;
        x = pinnedWidth;
      }

      unpinnedRenderBox.layout(
          BoxConstraints(
              minWidth: unpinnedWidth,
              maxWidth: unpinnedWidth,
              minHeight: constraints.maxHeight,
              maxHeight: constraints.maxHeight),
          parentUsesSize: true);
      unpinnedRenderBox.tableAreaLayoutParentData().offset = Offset(x, 0);
      x += unpinnedWidth;

      scrollbarRenderBox.layout(
          BoxConstraints(
              minWidth: scrollbarWidth,
              maxWidth: scrollbarWidth,
              minHeight: constraints.maxHeight,
              maxHeight: constraints.maxHeight),
          parentUsesSize: true);
      scrollbarRenderBox.tableAreaLayoutParentData().offset = Offset(x, 0);

      size = Size(constraints.maxWidth, constraints.maxHeight);
    } else {
      // unbounded height
      double x = 0;
      final double contentHeight = _visibleRowsCount! * _rowHeight;
      final double height = (_hasHeader ? _headerHeight : 0) + contentHeight;

      // pinned
      if (pinnedRenderBox != null) {
        pinnedRenderBox.layout(
            BoxConstraints(
                minWidth: pinnedWidth,
                maxWidth: pinnedWidth,
                minHeight: height,
                maxHeight: height),
            parentUsesSize: true);
        pinnedRenderBox.tableAreaLayoutParentData().offset = Offset.zero;
        x = pinnedWidth;
      }

      unpinnedRenderBox.layout(
          BoxConstraints(
              minWidth: unpinnedWidth,
              maxWidth: unpinnedWidth,
              minHeight: height,
              maxHeight: height),
          parentUsesSize: true);
      unpinnedRenderBox.tableAreaLayoutParentData().offset = Offset(x, 0);
      x += unpinnedWidth;

      scrollbarRenderBox.layout(
          BoxConstraints(
              minWidth: scrollbarWidth,
              maxWidth: scrollbarWidth,
              minHeight: height,
              maxHeight: height),
          parentUsesSize: true);
      scrollbarRenderBox.tableAreaLayoutParentData().offset = Offset(x, 0);

      size = Size(constraints.maxWidth, height);
    }
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    double height = _scrollbarWidth;
    if (_hasHeader) {
      height += _headerHeight;
    }
    return height;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    double height = computeMinIntrinsicHeight(width);
    if (_visibleRowsCount != null) {
      height += _visibleRowsCount! * _rowHeight;
    }
    return height;
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
  _TableLayoutParentData tableAreaLayoutParentData() {
    return parentData as _TableLayoutParentData;
  }
}
