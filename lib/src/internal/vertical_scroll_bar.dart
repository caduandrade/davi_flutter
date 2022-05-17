import 'package:easy_table/src/theme/scrollbar_theme_data.dart';
import 'package:easy_table/src/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
class VerticalScrollBar extends StatelessWidget {
  const VerticalScrollBar(
      {Key? key,
      required this.scrollController,
      required this.scrollBehavior,
      required this.rowHeight,
      required this.visibleRowsLength})
      : super(key: key);

  final ScrollController scrollController;
  final ScrollBehavior scrollBehavior;
  final int visibleRowsLength;
  final double rowHeight;

  @override
  Widget build(BuildContext context) {
    TableScrollbarThemeData theme = EasyTableTheme.of(context).scrollbar;
    return Container(
        child: Theme(
            data: ThemeData(
                scrollbarTheme: ScrollbarThemeData(
                    crossAxisMargin: theme.margin,
                    thumbColor: MaterialStateProperty.all(theme.thumbColor))),
            child: Scrollbar(
                thickness: theme.thickness,
                radius: theme.radius,
                thumbVisibility: true,
                child: ScrollConfiguration(
                    behavior: scrollBehavior,
                    child: ListView.builder(
                        controller: scrollController,
                        itemExtent: rowHeight,
                        itemBuilder: (context, index) {
                          return SizedBox(height: rowHeight);
                        },
                        itemCount: visibleRowsLength)),
                controller: scrollController)),
        decoration: BoxDecoration(
            color: theme.verticalColor,
            border:
                Border(left: BorderSide(color: theme.verticalBorderColor))));
  }
}
