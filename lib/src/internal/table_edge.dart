import 'package:davi/src/theme/edge_theme_data.dart';
import 'package:davi/src/theme/theme.dart';
import 'package:davi/src/theme/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
class TableEdge extends StatelessWidget {
  const TableEdge({super.key, required this.type});

  final CornerType type;

  @override
  Widget build(BuildContext context) {
    final DaviThemeData theme = DaviTheme.of(context);
    final EdgeThemeData edge = theme.edge;
    BoxDecoration? decoration;

    if (type == CornerType.header) {
      decoration = BoxDecoration(
          color: edge.headerColor,
          border: Border(
              left: BorderSide(
                  color: edge.headerLeftBorderColor,
                  width: theme.scrollbar.borderThickness),
              bottom: BorderSide(
                  color: edge.headerBottomBorderColor,
                  width: theme.header.bottomBorderThickness)));
    } else if (type == CornerType.scrollbar) {
      decoration = BoxDecoration(
          color: edge.scrollbarColor,
          border: Border(
              left: BorderSide(
                  color: edge.scrollbarLeftBorderColor,
                  width: theme.scrollbar.borderThickness),
              top: BorderSide(
                  color: edge.scrollbarTopBorderColor,
                  width: theme.scrollbar.borderThickness)));
    } else if (type == CornerType.summary) {
      decoration = BoxDecoration(
          color: edge.summaryColor,
          border: Border(
              left: BorderSide(
                  color: edge.summaryLeftBorderColor,
                  width: theme.scrollbar.borderThickness),
              top: BorderSide(
                  color: edge.summaryTopBorderColor,
                  width: theme.summary.topBorderThickness)));
    }
    return Container(decoration: decoration);
  }
}

enum CornerType { header, summary, scrollbar }
