import 'package:easy_table/src/theme/scrollbar_theme_data.dart';
import 'package:easy_table/src/theme/theme.dart';
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
class HorizontalScrollBarExp extends StatelessWidget {
  const HorizontalScrollBarExp(
      {Key? key, required this.contentWidth, required this.scrollController})
      : super(key: key);

  final double contentWidth;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    EasyTableThemeData theme = EasyTableTheme.of(context);
    TableScrollbarThemeData scrollTheme = theme.scrollbar;

    return Container(
        decoration: BoxDecoration(color: scrollTheme.unpinnedHorizontalColor),
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
                        child: Container(width: contentWidth),
                        controller: scrollController,
                        scrollDirection: Axis.horizontal)))));
  }
}
