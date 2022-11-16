import 'package:easy_table/src/theme/scrollbar_theme_data.dart';
import 'package:easy_table/src/theme/theme.dart';
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
class TableScrollbar extends StatelessWidget {
  const TableScrollbar(
      {Key? key,
      required this.contentSize,
      required this.scrollController,
      required this.axis,
      required this.color,
      required this.borderColor,
      required this.onDragScroll})
      : super(key: key);

  final double contentSize;
  final ScrollController scrollController;
  final Axis axis;
  final Color color;
  final Color borderColor;
  final OnDragScroll onDragScroll;

  @override
  Widget build(BuildContext context) {
    EasyTableThemeData theme = EasyTableTheme.of(context);
    TableScrollbarThemeData scrollTheme = theme.scrollbar;
    BoxBorder? border;
    if (theme.scrollbar.borderThickness > 0) {
      if (axis == Axis.horizontal) {
        border = Border(
            top: BorderSide(
                color: borderColor, width: theme.scrollbar.borderThickness));
      } else if (axis == Axis.vertical) {
        border = Border(
            left: BorderSide(
                color: borderColor, width: theme.scrollbar.borderThickness));
      }
    }
    Widget scrollbar = Container(
        decoration: BoxDecoration(color: color, border: border),
        child: Theme(
            data: ThemeData(
                scrollbarTheme: ScrollbarThemeData(
                    crossAxisMargin: scrollTheme.margin,
                    thumbColor:
                        MaterialStateProperty.all(scrollTheme.thumbColor))),
            child: Scrollbar(
                controller: scrollController,
                thickness: scrollTheme.thickness,
                radius: scrollTheme.radius,
                thumbVisibility: true,
                child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context)
                        .copyWith(scrollbars: false, dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.invertedStylus,
                      PointerDeviceKind.trackpad
                    }),
                    child: SingleChildScrollView(
                        controller: scrollController,
                        scrollDirection: axis,
                        child: _sizedBox())))));

    return Listener(
        onPointerDown: (event) => onDragScroll(true),
        onPointerUp: (event) => onDragScroll(false),
        child: scrollbar);
  }

  Widget _sizedBox() {
    if (axis == Axis.vertical) {
      return SizedBox(height: contentSize);
    }
    return SizedBox(width: contentSize);
  }
}

typedef OnDragScroll = void Function(bool start);
