import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// Lays out a header's name and accessories at the width of its column.
///
/// The natural width always includes every accessory for column auto size.
/// At narrower widths, the priority, leading widget, and sort icon are hidden
/// in that order, leaving the remaining space for the name.
@internal
class HeaderContentLayout extends MultiChildRenderObjectWidget {
  HeaderContentLayout({
    super.key,
    required Widget content,
    Widget? leading,
    Widget? sortIcon,
    Widget? priorityGap,
    Widget? priority,
    required this.expandableName,
  }) : super(children: [
          leading ?? const SizedBox.shrink(),
          content,
          sortIcon ?? const SizedBox.shrink(),
          priorityGap ?? const SizedBox.shrink(),
          priority ?? const SizedBox.shrink(),
        ]);

  final bool expandableName;

  @override
  RenderHeaderContentLayout createRenderObject(BuildContext context) =>
      RenderHeaderContentLayout(expandableName: expandableName);

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderHeaderContentLayout renderObject) {
    renderObject.expandableName = expandableName;
  }
}

@internal
class RenderHeaderContentLayout extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _HeaderContentParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _HeaderContentParentData> {
  RenderHeaderContentLayout({required bool expandableName})
      : _expandableName = expandableName;

  static const int _leading = 0;
  static const int _content = 1;
  static const int _sortIcon = 2;
  static const int _priorityGap = 3;
  static const int _priority = 4;
  static const int _count = 5;

  bool _expandableName;

  set expandableName(bool value) {
    if (_expandableName != value) {
      _expandableName = value;
      markNeedsLayout();
    }
  }

  // The slots stay mounted, including while hidden, so intrinsic width can
  // still account for their content during auto size.
  final List<bool> _visible = List<bool>.filled(_count, true);

  List<RenderBox> get _children {
    final children = <RenderBox>[];
    for (RenderBox? child = firstChild;
        child != null;
        child = childAfter(child)) {
      children.add(child);
    }
    assert(children.length == _count);
    return children;
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _HeaderContentParentData) {
      child.parentData = _HeaderContentParentData();
    }
  }

  List<double> _naturalWidths(List<RenderBox> children, double height) =>
      [for (final child in children) child.getMaxIntrinsicWidth(height)];

  _HeaderContentSizes _sizes(double availableWidth, List<double> natural) {
    final visible = List<bool>.filled(_count, true);
    double fixed = natural[_leading] +
        natural[_sortIcon] +
        natural[_priorityGap] +
        natural[_priority];

    if (fixed > availableWidth) {
      visible[_priorityGap] = false;
      visible[_priority] = false;
      fixed -= natural[_priorityGap] + natural[_priority];
    }
    if (fixed > availableWidth) {
      visible[_leading] = false;
      fixed -= natural[_leading];
    }
    if (fixed > availableWidth) {
      visible[_sortIcon] = false;
      fixed -= natural[_sortIcon];
    }

    final widths = List<double>.filled(_count, 0);
    for (int i = 0; i < _count; i++) {
      if (i != _content && visible[i]) {
        widths[i] = natural[i];
      }
    }
    final contentLimit = math.max(0.0, availableWidth - fixed);
    widths[_content] = _expandableName
        ? contentLimit
        : math.min(natural[_content], contentLimit);
    // A zero-width name has no visible content and should not inflate the
    // intrinsic height when a custom Text would wrap at zero width.
    visible[_content] = contentLimit > 0;
    return _HeaderContentSizes(widths, visible);
  }

  double _intrinsicHeight(double width, {required bool maximum}) {
    final children = _children;
    final available = width.isFinite ? math.max(0.0, width) : double.infinity;
    final natural = _naturalWidths(children, double.infinity);
    final sizes = _sizes(available, natural);
    double height = 0;
    for (int i = 0; i < _count; i++) {
      if (sizes.visible[i]) {
        final childHeight = maximum
            ? children[i].getMaxIntrinsicHeight(sizes.widths[i])
            : children[i].getMinIntrinsicHeight(sizes.widths[i]);
        height = math.max(height, childHeight);
      }
    }
    return height;
  }

  @override
  double computeMinIntrinsicWidth(double height) => 0;

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _naturalWidths(_children, height).fold(0, (sum, width) => sum + width);

  @override
  double computeMinIntrinsicHeight(double width) =>
      _intrinsicHeight(width, maximum: false);

  @override
  double computeMaxIntrinsicHeight(double width) =>
      _intrinsicHeight(width, maximum: true);

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final natural = _naturalWidths(_children, constraints.maxHeight);
    final naturalTotal = natural.fold<double>(0, (sum, width) => sum + width);
    final width = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : constraints.constrainWidth(naturalTotal);
    return constraints
        .constrain(Size(width, _intrinsicHeight(width, maximum: true)));
  }

  @override
  void performLayout() {
    final children = _children;
    final natural = _naturalWidths(children, constraints.maxHeight);
    final naturalTotal = natural.fold<double>(0, (sum, width) => sum + width);
    final width = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : constraints.constrainWidth(naturalTotal);
    final sizes = _sizes(width, natural);
    final height = constraints.hasBoundedHeight
        ? constraints.maxHeight
        : constraints.constrainHeight(_intrinsicHeight(width, maximum: true));
    size = constraints.constrain(Size(width, height));

    double x = 0;
    bool visibilityChanged = false;
    for (int i = 0; i < _count; i++) {
      final child = children[i];
      final visible = sizes.visible[i];
      if (_visible[i] != visible) {
        _visible[i] = visible;
        visibilityChanged = true;
      }
      final childConstraints = !visible
          ? const BoxConstraints.tightFor(width: 0, height: 0)
          : i == _content && !_expandableName
              ? BoxConstraints(
                  maxWidth: math.max(
                      0.0,
                      size.width -
                          sizes.widths[_leading] -
                          sizes.widths[_sortIcon] -
                          sizes.widths[_priorityGap] -
                          sizes.widths[_priority]),
                  minHeight: size.height,
                  maxHeight: size.height)
              : BoxConstraints.tightFor(
                  width: sizes.widths[i], height: size.height);
      child.layout(childConstraints, parentUsesSize: true);
      (child.parentData! as _HeaderContentParentData).offset = Offset(x, 0);
      if (visible) {
        x += child.size.width;
      }
    }
    if (visibilityChanged) {
      markNeedsSemanticsUpdate();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final children = _children;
    for (int i = 0; i < _count; i++) {
      if (_visible[i]) {
        final child = children[i];
        final data = child.parentData! as _HeaderContentParentData;
        context.paintChild(child, offset + data.offset);
      }
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final children = _children;
    for (int i = _count - 1; i >= 0; i--) {
      if (!_visible[i]) continue;
      final child = children[i];
      final data = child.parentData! as _HeaderContentParentData;
      if (result.addWithPaintOffset(
          offset: data.offset,
          position: position,
          hitTest: (result, transformed) =>
              child.hitTest(result, position: transformed))) {
        return true;
      }
    }
    return false;
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    final children = _children;
    for (int i = 0; i < _count; i++) {
      if (_visible[i]) visitor(children[i]);
    }
  }
}

class _HeaderContentSizes {
  const _HeaderContentSizes(this.widths, this.visible);

  final List<double> widths;
  final List<bool> visible;
}

class _HeaderContentParentData extends ContainerBoxParentData<RenderBox> {}
