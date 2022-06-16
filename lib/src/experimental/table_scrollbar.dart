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
      required this.borderColor})
      : super(key: key);

  final double contentSize;
  final ScrollController scrollController;
  final Axis axis;
  final Color color;
  final Color borderColor;

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
    Widget scrollbar= Container(
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
                        .copyWith(scrollbars: false),
                    child: SingleChildScrollView(
                        child: _sizedBox(),
                        controller: scrollController,
                        scrollDirection: axis)))));

    Widget a=  NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {

          if (scrollNotification is ScrollStartNotification) {
            print('start');
          } else if (scrollNotification is ScrollEndNotification) {
            print('end');
          }
          return false;
        },
        child: scrollbar);

    return Listener(onPointerDown: (a)=>print('down'),
        onPointerUp: (a)=>print('up'), child: a);
  }

  Widget _sizedBox() {
    if (axis == Axis.vertical) {
      return SizedBox(height: contentSize);
    }
    return SizedBox(width: contentSize);
  }
}
