import 'dart:math' as math;
import 'package:easy_table/src/theme/header_theme_data.dart';
import 'package:easy_table/src/theme/theme.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

const int _headerId = 1;
const int _dividerId = 2;
const int _bodyId = 3;

@internal
class TableLayout extends StatelessWidget {
  const TableLayout({Key? key, required this.header, required this.body})
      : super(key: key);

  final Widget? header;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    HeaderThemeData headerTheme = EasyTableTheme.of(context).header;

    List<Widget> children = [LayoutId(id: _bodyId, child: body)];

    if (header != null) {
      children.add(LayoutId(
          id: _headerId,
          child: SizedBox(height: headerTheme.height, child: header)));

      if (headerTheme.bottomBorderHeight > 0) {
        Widget divider = Container(
            height: headerTheme.bottomBorderHeight,
            color: headerTheme.bottomBorderColor);
        children.add(LayoutId(id: _dividerId, child: divider));
      }
    }
    return ClipRect(
        child: CustomMultiChildLayout(
            children: children, delegate: _TableLayoutDelegate()));
  }
}

class _TableLayoutDelegate extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    double y = 0;

    if (hasChild(_headerId)) {
      Size headerSize = layoutChild(
          _headerId,
          BoxConstraints(
              minHeight: 0,
              maxHeight: size.height,
              minWidth: size.width,
              maxWidth: size.width));
      positionChild(_headerId, Offset.zero);

      y += headerSize.height;

      if (hasChild(_dividerId)) {
        Size dividerSize = layoutChild(
            _dividerId,
            BoxConstraints(
                minHeight: 0,
                maxHeight: math.max(0, size.height - y),
                minWidth: size.width,
                maxWidth: size.width));
        positionChild(_dividerId, Offset(0, y));
        y += dividerSize.height;
      }
    }

    layoutChild(
        _bodyId,
        BoxConstraints(
            minHeight: 0,
            maxHeight: math.max(0, size.height - y),
            minWidth: size.width,
            maxWidth: size.width));
    positionChild(_bodyId, Offset(0, y));
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return false;
  }
}
