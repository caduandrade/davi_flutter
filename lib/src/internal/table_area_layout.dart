import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// [EasyTable] table area layout.
@internal
class TableAreaLayout extends MultiChildRenderObjectWidget {
  factory TableAreaLayout(
      {Key? key,
      required Widget? headerWidget,
      required Widget contentWidget,
      required Widget? scrollbarWidget,
      required double rowHeight,
      required double headerHeight,
      required double scrollbarHeight,
      required int? visibleRowsCount,
      required double? width}) {
    List<Widget> children = [];
    if (headerWidget != null) {
      children.add(headerWidget);
    }
    children.add(contentWidget);
    if (scrollbarWidget != null) {
      children.add(scrollbarWidget);
    }
    return TableAreaLayout._(
        key: key,
        children: children,
        rowHeight: rowHeight,
        scrollbarHeight: scrollbarWidget != null ? scrollbarHeight : 0,
        headerHeight: headerHeight,
        visibleRowsCount: visibleRowsCount,
        hasHorizontalScrollbar: scrollbarWidget != null,
        hasHeader: headerWidget != null,
        width: width);
  }

  TableAreaLayout._(
      {Key? key,
      required this.scrollbarHeight,
      required this.rowHeight,
      required this.headerHeight,
      required this.visibleRowsCount,
      required this.hasHeader,
      required this.width,
      required this.hasHorizontalScrollbar,
      required List<Widget> children})
      : super(key: key, children: children);

  final double rowHeight;
  final double headerHeight;
  final double scrollbarHeight;
  final double? width;
  final bool hasHeader;
  final bool hasHorizontalScrollbar;

  /// Calculates the height based on the number of visible lines.
  /// It can be used within an unbounded height layout.
  final int? visibleRowsCount;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _TableLayoutRenderBox(
        rowHeight: rowHeight,
        scrollbarHeight: scrollbarHeight,
        visibleRowsCount: visibleRowsCount,
        headerHeight: headerHeight,
        width: width,
        hasHeader: hasHeader,
        hasHorizontalScrollbar: hasHorizontalScrollbar);
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
      ..scrollbarHeight = scrollbarHeight
      ..rowHeight = rowHeight
      ..visibleRowsCount = visibleRowsCount
      ..hasHeader = hasHeader
      ..hasHorizontalScrollbar = hasHorizontalScrollbar
      ..width = width;
  }
}

/// The [TableAreaLayout] element.
class _TableLayoutElement extends MultiChildRenderObjectElement {
  _TableLayoutElement(TableAreaLayout widget) : super(widget);

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
class _TableAreaLayoutParentData extends ContainerBoxParentData<RenderBox> {}

class _TableLayoutRenderBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _TableAreaLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _TableAreaLayoutParentData> {
  _TableLayoutRenderBox(
      {required double scrollbarHeight,
      required double rowHeight,
      required double headerHeight,
      required int? visibleRowsCount,
      required bool hasHeader,
      required bool hasHorizontalScrollbar,
      required double? width})
      : _rowHeight = rowHeight,
        _headerHeight = headerHeight,
        _scrollbarHeight = scrollbarHeight,
        _visibleRowsCount = visibleRowsCount,
        _hasHeader = hasHeader,
        _hasHorizontalScrollbar = hasHorizontalScrollbar,
        _width = width;

  int? _visibleRowsCount;

  set visibleRowsCount(int? value) {
    if (_visibleRowsCount != value) {
      _visibleRowsCount = value;
      markNeedsLayout();
    }
  }

  double _scrollbarHeight;

  set scrollbarHeight(double value) {
    if (_scrollbarHeight != value) {
      _scrollbarHeight = value;
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

  bool _hasHorizontalScrollbar;

  set hasHorizontalScrollbar(bool value) {
    if (_hasHorizontalScrollbar != value) {
      _hasHorizontalScrollbar = value;
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

  double? _width;

  set width(double? value) {
    if (_width != value) {
      _width = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _TableAreaLayoutParentData) {
      child.parentData = _TableAreaLayoutParentData();
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

    RenderBox? headerRenderBox;
    RenderBox contentRenderBox;
    RenderBox? scrollbarRenderBox;
    if (_hasHeader) {
      headerRenderBox = children.removeAt(0);
    }
    contentRenderBox = children.removeAt(0);
    if (_hasHorizontalScrollbar) {
      scrollbarRenderBox = children.removeAt(0);
    }

    final double width = _width != null
        ? math.min(_width!, constraints.maxWidth)
        : constraints.maxWidth;

    if (constraints.hasBoundedHeight) {
      double y = 0;
      double availableHeight = constraints.maxHeight;

      // header
      if (headerRenderBox != null) {
        final double headerHeight = math.min(_headerHeight, availableHeight);
        headerRenderBox.layout(
            BoxConstraints(
                minWidth: width,
                maxWidth: width,
                minHeight: headerHeight,
                maxHeight: headerHeight),
            parentUsesSize: true);
        headerRenderBox.tableAreaLayoutParentData().offset = Offset.zero;
        y = headerHeight;
        availableHeight -= headerHeight;
      }

      final double scrollbarHeight =
          math.min(_scrollbarHeight, availableHeight);

      final double contentHeight =
          math.max(0, availableHeight - scrollbarHeight);

      contentRenderBox.layout(
          BoxConstraints(
              minWidth: width,
              maxWidth: width,
              minHeight: contentHeight,
              maxHeight: contentHeight),
          parentUsesSize: true);
      contentRenderBox.tableAreaLayoutParentData().offset = Offset(0, y);
      y += contentHeight;
      availableHeight -= contentHeight;

      if (scrollbarRenderBox != null) {
        scrollbarRenderBox.layout(
            BoxConstraints(
                minWidth: width,
                maxWidth: width,
                minHeight: scrollbarHeight,
                maxHeight: scrollbarHeight),
            parentUsesSize: true);
        scrollbarRenderBox.tableAreaLayoutParentData().offset = Offset(0, y);
      }

      size = Size(width, constraints.maxHeight);
    } else {
      // unbounded height
      double y = 0;
      double height = 0;

      // header
      if (headerRenderBox != null) {
        headerRenderBox.layout(
            BoxConstraints(
                minWidth: width,
                maxWidth: width,
                minHeight: _headerHeight,
                maxHeight: _headerHeight),
            parentUsesSize: true);
        headerRenderBox.tableAreaLayoutParentData().offset = Offset.zero;
        y = _headerHeight;
        height += _headerHeight;
      }

      final double contentHeight = _visibleRowsCount! * _rowHeight;
      contentRenderBox.layout(
          BoxConstraints(
              minWidth: width,
              maxWidth: width,
              minHeight: contentHeight,
              maxHeight: contentHeight),
          parentUsesSize: true);
      contentRenderBox.tableAreaLayoutParentData().offset = Offset(0, y);
      y += contentHeight;
      height += contentHeight;

      if (scrollbarRenderBox != null) {
        scrollbarRenderBox.layout(
            BoxConstraints(
                minWidth: width,
                maxWidth: width,
                minHeight: _scrollbarHeight,
                maxHeight: _scrollbarHeight),
            parentUsesSize: true);
        scrollbarRenderBox.tableAreaLayoutParentData().offset = Offset(0, y);
        height += _scrollbarHeight;
      }

      size = Size(width, height);
    }
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    double height = _scrollbarHeight;
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
extension _TableAreaLayoutParentDataGetter on RenderObject {
  _TableAreaLayoutParentData tableAreaLayoutParentData() {
    return parentData as _TableAreaLayoutParentData;
  }
}
