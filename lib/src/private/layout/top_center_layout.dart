import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

@internal
class TopCenterLayout extends StatelessWidget {
  const TopCenterLayout({Key? key, required this.top, required this.center})
      : super(key: key);

  final Widget top;
  final Widget center;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
        child: CustomMultiChildLayout(children: [
      LayoutId(id: 1, child: IntrinsicHeight(child: top)),
      LayoutId(id: 2, child: center)
    ], delegate: _TopCenterLayoutDelegate()));
  }
}

class _TopCenterLayoutDelegate extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    BoxConstraints constraints = BoxConstraints(
        minHeight: 0,
        maxHeight: size.height,
        minWidth: size.width,
        maxWidth: size.width);
    Size childSize = layoutChild(1, constraints);
    positionChild(1, Offset.zero);
    constraints = BoxConstraints(
        minHeight: 0,
        maxHeight: math.max(0, size.height - childSize.height),
        minWidth: size.width,
        maxWidth: size.width);
    layoutChild(2, constraints);
    positionChild(2, Offset(0, childSize.height));
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return false;
  }
}
