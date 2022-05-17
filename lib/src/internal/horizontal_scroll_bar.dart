import 'package:easy_table/src/theme/scrollbar_theme_data.dart';
import 'package:easy_table/src/theme/theme.dart';
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
class HorizontalScrollBar extends StatelessWidget {
  const HorizontalScrollBar(
      {Key? key,
      required this.contentWidth,
      required this.scrollController,
      required this.scrollBehavior,
      required this.pinned})
      : super(key: key);

  final double contentWidth;
  final ScrollController scrollController;
  final ScrollBehavior scrollBehavior;
  final bool pinned;

  @override
  Widget build(BuildContext context) {
    EasyTableThemeData theme = EasyTableTheme.of(context);
    TableScrollbarThemeData scrollTheme = theme.scrollbar;
    double width = contentWidth;
    BoxDecoration? decoration;
    if (pinned) {
      width -= theme.columnDividerThickness;
      decoration = BoxDecoration(
          color: scrollTheme.pinnedHorizontalColor,
          border: Border(
              top: BorderSide(color: scrollTheme.pinnedHorizontalBorderColor),
              right: BorderSide(
                  color: scrollTheme.pinnedHorizontalBorderColor,
                  width: theme.columnDividerThickness)));
    } else {
      decoration = BoxDecoration(
          color: scrollTheme.unpinnedHorizontalColor,
          border: Border(
              top: BorderSide(
                  color: scrollTheme.unpinnedHorizontalBorderColor)));
    }

    return Container(
        decoration: decoration,
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
                    behavior: scrollBehavior,
                    child: SingleChildScrollView(
                        child: Container(width: width),
                        controller: scrollController,
                        scrollDirection: Axis.horizontal)))));
  }
}
