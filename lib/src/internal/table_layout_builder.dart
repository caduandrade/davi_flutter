import 'package:davi/src/column_width_behavior.dart';
import 'package:davi/src/internal/header_widget.dart';
import 'package:davi/src/internal/layout_child_id.dart';
import 'package:davi/src/internal/new/davi_context.dart';
import 'package:davi/src/internal/new/summary_widget.dart';
import 'package:davi/src/internal/new/table_content.dart';
import 'package:davi/src/internal/scroll_controllers.dart';
import 'package:davi/src/internal/scroll_offsets.dart';
import 'package:davi/src/internal/table_edge.dart';
import 'package:davi/src/internal/table_layout.dart';
import 'package:davi/src/internal/table_layout_child.dart';
import 'package:davi/src/internal/table_layout_settings.dart';
import 'package:davi/src/internal/table_scrollbar.dart';
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
      required this.onDragScroll})
      : super(key: key);

  final DaviContext<DATA> daviContext;
  final ScrollControllers scrollControllers;
  final OnDragScroll onDragScroll;

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
        columnWidthBehavior: daviContext.columnWidthBehavior,
        themeMetrics: daviContext.themeMetrics,
        visibleRowsCount: daviContext.visibleRowsCount,
        hasTrailingWidget: daviContext.trailingWidget != null);

    final List<TableLayoutChild> children = [];

    if (layoutSettings.hasVerticalScrollbar) {
      children.add(TableLayoutChild(
          id: LayoutChildId.verticalScrollbar,
          child: TableScrollbar(
              axis: Axis.vertical,
              contentSize: layoutSettings.contentHeight,
              scrollController: scrollControllers.vertical,
              color: theme.scrollbar.verticalColor,
              borderColor: theme.scrollbar.verticalBorderColor,
              onDragScroll: onDragScroll)));
    }

    if (daviContext.themeMetrics.header.visible) {
      children.add(TableLayoutChild(
          id: LayoutChildId.header,
          child: HeaderWidget(
              daviContext: daviContext,
              layoutSettings: layoutSettings,
              resizable: daviContext.columnWidthBehavior ==
                  ColumnWidthBehavior.scrollable,
              horizontalScrollOffsets: horizontalScrollOffsets)));
      if (layoutSettings.hasVerticalScrollbar) {
        children.add(TableLayoutChild(
            id: LayoutChildId.topCorner,
            child: const TableEdge(type: CornerType.header)));
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
      children.add(TableLayoutChild(
          id: LayoutChildId.leftPinnedHorizontalScrollbar,
          child: leftPinnedHorizontalScrollbar));
      children.add(TableLayoutChild(
          id: LayoutChildId.unpinnedHorizontalScrollbar,
          child: TableScrollbar(
              axis: Axis.horizontal,
              scrollController: scrollControllers.unpinnedHorizontal,
              color: theme.scrollbar.unpinnedHorizontalColor,
              borderColor: theme.scrollbar.unpinnedHorizontalBorderColor,
              contentSize: layoutSettings.unpinnedContentWidth,
              onDragScroll: onDragScroll)));
      if (layoutSettings.hasVerticalScrollbar) {
        children.add(TableLayoutChild(
            id: LayoutChildId.bottomCorner,
            child: const TableEdge(type: CornerType.scrollbar)));
      }
    }

    children.add(TableLayoutChild(
        id: LayoutChildId.cells,
        child: TableContent(
            daviContext: daviContext,
            layoutSettings: layoutSettings,
            horizontalScrollOffsets: horizontalScrollOffsets,
            verticalScrollController: scrollControllers.vertical)));

    if (daviContext.model.hasSummary) {
      children.add(TableLayoutChild(
          id: LayoutChildId.summary,
          child: SummaryWidget(daviContext: daviContext)));
    }

    return TableLayout<DATA>(
        layoutSettings: layoutSettings,
        theme: theme,
        horizontalScrollOffsets: horizontalScrollOffsets,
        children: children);
  }
}
