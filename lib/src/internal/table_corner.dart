import 'package:davi/src/theme/theme.dart';
import 'package:davi/src/theme/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
class TableCorner extends StatelessWidget {
  const TableCorner({Key? key, required this.top}) : super(key: key);

  final bool top;

  @override
  Widget build(BuildContext context) {
    EasyTableThemeData theme = EasyTableTheme.of(context);

    BoxBorder? border;
    if (theme.scrollbar.borderThickness > 0) {
      if (top) {
        border = Border(
            left: BorderSide(
                color: theme.topCornerBorderColor,
                width: theme.scrollbar.borderThickness),
            bottom: BorderSide(
                color: theme.topCornerBorderColor,
                width: theme.header.bottomBorderHeight));
      } else {
        border = Border(
            left: BorderSide(
                color: theme.bottomCornerBorderColor,
                width: theme.scrollbar.borderThickness),
            top: BorderSide(
                color: theme.bottomCornerBorderColor,
                width: theme.scrollbar.borderThickness));
      }
    }

    return Container(
        decoration: BoxDecoration(
            color: top ? theme.topCornerColor : theme.bottomCornerColor,
            border: border));
  }
}
