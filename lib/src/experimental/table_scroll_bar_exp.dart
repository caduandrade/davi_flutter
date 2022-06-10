import 'package:easy_table/src/theme/scrollbar_theme_data.dart';
import 'package:easy_table/src/theme/theme.dart';
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
class EasyTableScrollBarExp extends StatelessWidget {
  const EasyTableScrollBarExp(
      {Key? key,
      required this.contentSize,
      required this.scrollController,
      required this.axis,
      required this.color})
      : super(key: key);

  final double contentSize;
  final ScrollController scrollController;
  final Axis axis;
  final Color color;

  @override
  Widget build(BuildContext context) {
    EasyTableThemeData theme = EasyTableTheme.of(context);
    TableScrollbarThemeData scrollTheme = theme.scrollbar;
    return Container(
        decoration: BoxDecoration(color: color),
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
  }

  Widget _sizedBox() {
    if (axis == Axis.vertical) {
      return SizedBox(height: contentSize);
    }
    return SizedBox(width: contentSize);
  }
}
