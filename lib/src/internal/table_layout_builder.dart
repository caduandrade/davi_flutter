import 'package:davi/src/column_width_behavior.dart';
import 'package:davi/src/internal/new/davi_context.dart';
import 'package:davi/src/internal/scroll_controllers.dart';
import 'package:davi/src/internal/scroll_offsets.dart';
import 'package:davi/src/internal/table_layout.dart';
import 'package:davi/src/internal/table_layout_child.dart';
import 'package:davi/src/internal/table_layout_settings.dart';
import 'package:davi/src/internal/table_scrollbar.dart';
import 'package:davi/src/internal/theme_metrics/theme_metrics.dart';
import 'package:davi/src/theme/theme.dart';
import 'package:davi/src/theme/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
class TableLayoutBuilder<DATA> extends StatelessWidget {
  const TableLayoutBuilder(
      {Key? key,
      required this.daviContext,
      required this.scrollControllers,
      required this.themeMetrics,
      required this.columnWidthBehavior,
      required this.visibleRowsLength,
      required this.onDragScroll,
      required this.scrolling})
      : super(key: key);

  final DaviContext<DATA> daviContext;
  final ScrollControllers scrollControllers;
  final ColumnWidthBehavior columnWidthBehavior;
  final int? visibleRowsLength;
  final OnDragScroll onDragScroll;
  final bool scrolling;
  final TableThemeMetrics themeMetrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _builder);
  }

  Widget _builder(BuildContext context, BoxConstraints constraints) {
    final DaviThemeData theme = DaviTheme.of(context);

    final HorizontalScrollOffsets horizontalScrollOffsets =
        HorizontalScrollOffsets(scrollControllers);

    TableLayoutSettings layoutSettings = TableLayoutSettings(
        constraints: constraints,
        model: daviContext.model,
        theme: theme,
        columnWidthBehavior: columnWidthBehavior,
        themeMetrics: themeMetrics,
        visibleRowsLength: visibleRowsLength,
        hasTrailingWidget: daviContext.trailingWidget != null);

    final List<TableLayoutChild> children = [];

    if (layoutSettings.hasVerticalScrollbar) {
      children.add(TableLayoutChild.verticalScrollbar(
          child: TableScrollbar(
              axis: Axis.vertical,
              contentSize: layoutSettings.contentHeight,
              scrollController: scrollControllers.vertical,
              color: theme.scrollbar.verticalColor,
              borderColor: theme.scrollbar.verticalBorderColor,
              onDragScroll: onDragScroll)));
    }

    if (themeMetrics.header.visible) {
      children.add(TableLayoutChild.header(
          daviContext: daviContext,
          layoutSettings: layoutSettings,
          resizable: columnWidthBehavior == ColumnWidthBehavior.scrollable,
          horizontalScrollOffsets: horizontalScrollOffsets));
      if (layoutSettings.hasVerticalScrollbar) {
        children.add(TableLayoutChild.topCorner());
      }
    }

    if (layoutSettings.hasHorizontalScrollbar) {
      Widget leftPinnedHorizontalScrollbar = TableScrollbar(
          axis: Axis.horizontal,
          scrollController: scrollControllers.leftPinnedHorizontal,
          color: theme.scrollbar.pinnedHorizontalColor,
          borderColor: theme.scrollbar.pinnedHorizontalBorderColor,
          contentSize: layoutSettings.leftPinnedContentWidth,
          onDragScroll: onDragScroll);
      children.add(TableLayoutChild.leftPinnedHorizontalScrollbar(
          leftPinnedHorizontalScrollbar));
      children.add(TableLayoutChild.unpinnedHorizontalScrollbar(TableScrollbar(
          axis: Axis.horizontal,
          scrollController: scrollControllers.unpinnedHorizontal,
          color: theme.scrollbar.unpinnedHorizontalColor,
          borderColor: theme.scrollbar.unpinnedHorizontalBorderColor,
          contentSize: layoutSettings.unpinnedContentWidth,
          onDragScroll: onDragScroll)));
      if (layoutSettings.hasVerticalScrollbar) {
        children.add(TableLayoutChild.bottomCorner());
      }
    }

    children.add(TableLayoutChild<DATA>.cells(
        daviContext: daviContext,
        layoutSettings: layoutSettings,
        scrolling: scrolling,
        horizontalScrollOffsets: horizontalScrollOffsets,
        verticalScrollController: scrollControllers.vertical));

    return TableLayout<DATA>(
        layoutSettings: layoutSettings,
        theme: theme,
        horizontalScrollOffsets: horizontalScrollOffsets,
        children: children);
  }
}
