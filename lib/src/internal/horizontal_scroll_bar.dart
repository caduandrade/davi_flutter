import 'package:easy_table/src/theme/scroll_theme_data.dart';
import 'package:easy_table/src/theme/theme.dart';
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
    TableScrollThemeData theme = EasyTableTheme.of(context).scroll;
    BoxDecoration? decoration = pinned
        ? theme.pinnedHorizontalDecoration
        : theme.unpinnedHorizontalDecoration;
    return Container(
        child: Theme(
            data: ThemeData(
                scrollbarTheme: ScrollbarThemeData(
                    crossAxisMargin: theme.margin,
                    thumbColor: MaterialStateProperty.all(theme.thumbColor))),
            child: Scrollbar(
                thickness: theme.thickness,
                hoverThickness: theme.thickness,
                radius: theme.radius,
                isAlwaysShown: true,
                child: ScrollConfiguration(
                    behavior: scrollBehavior,
                    child: SingleChildScrollView(
                        child: Container(width: contentWidth),
                        controller: scrollController,
                        scrollDirection: Axis.horizontal)),
                controller: scrollController)),
        decoration: decoration);
  }
}
