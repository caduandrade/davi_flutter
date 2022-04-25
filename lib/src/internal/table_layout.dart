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
      Widget? pinnedHeader,
      Widget? pinnedBody,
      required Widget body,
      required double rowHeight,
      required double headerHeight,
      required int rowsCount,
      required int? visibleRowsCount,
      required double pinnedWidth}) {
    List<Widget> children = [body];
    bool hasHeader = false;
    bool pinned = false;
    if (header != null) {
      children.add(header);
      hasHeader = true;
    }
    if (pinnedBody != null) {
      pinned = true;
      children.add(pinnedBody);
    }
    if (pinnedHeader != null) {
      children.add(pinnedHeader);
    }

    return TableLayout._(
        key: key,
        children: children,
        rowHeight: rowHeight,
        rowsCount: rowsCount,
        headerHeight: headerHeight,
        visibleRowsCount: visibleRowsCount,
        hasHeader: hasHeader,
        pinnedWidth: pinnedWidth,
        pinned: pinned);
  }

  TableLayout._(
      {Key? key,
      required this.rowsCount,
      required this.rowHeight,
      required this.headerHeight,
      required this.visibleRowsCount,
      required this.hasHeader,
      required this.pinnedWidth,
      required this.pinned,
      required List<Widget> children})
      : super(key: key, children: children);

  final double rowHeight;
  final double headerHeight;
  final int rowsCount;
  final double pinnedWidth;
  final bool hasHeader;
  final bool pinned;

  /// Calculates the height based on the number of visible lines.
  /// It can be used within an unbounded height layout.
  final int? visibleRowsCount;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _TableLayoutRenderBox(
        rowHeight: rowHeight,
        rowsCount: rowsCount,
        visibleRowsCount: visibleRowsCount,
        headerHeight: headerHeight,
        pinnedWidth: pinnedWidth,
        hasHeader: hasHeader,
        pinned: pinned);
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
      ..visibleRowsCount = visibleRowsCount
      ..hasHeader = hasHeader
      ..pinnedWidth = pinnedWidth
      ..pinned = pinned;
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
      required int? visibleRowsCount,
      required bool hasHeader,
      required double pinnedWidth,
      required bool pinned})
      : _rowHeight = rowHeight,
        _headerHeight = headerHeight,
        _rowsCount = rowsCount,
        _visibleRowsCount = visibleRowsCount,
        _hasHeader = hasHeader,
        _pinned = pinned,
        _pinnedWidth = pinnedWidth;

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

  bool _hasHeader;
  set hasHeader(bool value) {
    if (_hasHeader != value) {
      _hasHeader = value;
      markNeedsLayout();
    }
  }

  double _pinnedWidth;
  set pinnedWidth(double value) {
    if (_pinnedWidth != value) {
      _pinnedWidth = value;
      markNeedsLayout();
    }
  }

  bool _pinned;
  set pinned(bool value) {
    if (_pinned != value) {
      _pinned = value;
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

    RenderBox bodyRenderBox = children.removeAt(0);
    RenderBox? headerRenderBox = _hasHeader ? children.removeAt(0) : null;
    RenderBox? pinnedBodyRenderBox = _pinned ? children.removeAt(0) : null;
    RenderBox? pinnedHeaderRenderBox =
        _pinned && _hasHeader ? children.removeAt(0) : null;

    final double unpinnedWidth =
        math.max(0, constraints.maxWidth - _pinnedWidth);

    if (pinnedHeaderRenderBox != null) {
      pinnedHeaderRenderBox.layout(
          BoxConstraints(
              minWidth: _pinnedWidth,
              maxWidth: _pinnedWidth,
              minHeight: _headerHeight,
              maxHeight: _headerHeight),
          parentUsesSize: true);
      pinnedHeaderRenderBox.tableLayoutParentData().offset = Offset.zero;
    }

    if (headerRenderBox != null) {
      headerRenderBox.layout(
          BoxConstraints(
              minWidth: unpinnedWidth,
              maxWidth: unpinnedWidth,
              minHeight: _headerHeight,
              maxHeight: _headerHeight),
          parentUsesSize: true);
      headerRenderBox.tableLayoutParentData().offset = Offset(_pinnedWidth, 0);
    }

    double minBodyHeight = 0;
    double maxBodyHeight = math.max(constraints.maxHeight - _headerHeight, 0);
    if (constraints.hasBoundedHeight == false && _visibleRowsCount != null) {
      minBodyHeight = math.min(_rowHeight * _visibleRowsCount!,
          constraints.maxHeight - _headerHeight);
      minBodyHeight = math.max(minBodyHeight, 0);
      maxBodyHeight = math.min(minBodyHeight, maxBodyHeight);
    }

    bodyRenderBox.layout(
        BoxConstraints(
            minWidth: unpinnedWidth,
            maxWidth: unpinnedWidth,
            minHeight: minBodyHeight,
            maxHeight: maxBodyHeight),
        parentUsesSize: true);
    bodyRenderBox.tableLayoutParentData().offset =
        Offset(_pinnedWidth, _headerHeight);
    double bodyHeight = bodyRenderBox.size.height;

    if (pinnedBodyRenderBox != null) {
      pinnedBodyRenderBox.layout(
          BoxConstraints(
              minWidth: _pinnedWidth,
              maxWidth: _pinnedWidth,
              minHeight: bodyHeight,
              maxHeight: bodyHeight),
          parentUsesSize: true);
      pinnedBodyRenderBox.tableLayoutParentData().offset =
          Offset(0, _headerHeight);
    }

    if (constraints.hasBoundedHeight) {
      size = Size(constraints.maxWidth,
          math.max(bodyHeight + _headerHeight, constraints.maxHeight));
    } else {
      size = Size(constraints.maxWidth, bodyHeight + _headerHeight);
    }
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _headerHeight;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return _headerHeight + (_visibleRowsCount ?? _rowsCount * _rowHeight);
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
