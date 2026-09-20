import 'package:davi/davi.dart';
import 'package:davi/src/column.dart';
import 'package:davi/src/internal/column_metrics.dart';
import 'package:davi/src/internal/header_widget.dart';
import 'package:davi/src/internal/layout_child_id.dart';
import 'package:davi/src/internal/davi_context.dart';
import 'package:davi/src/internal/summary_widget.dart';
import 'package:davi/src/internal/table_content.dart';
import 'package:davi/src/internal/table_edge.dart';
import 'package:davi/src/internal/table_layout.dart';
import 'package:davi/src/internal/table_layout_child.dart';
import 'package:davi/src/internal/table_layout_settings.dart';
import 'package:davi/src/internal/table_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
class TableLayoutBuilder<DATA> extends StatefulWidget {
  const TableLayoutBuilder(
      {super.key, required this.daviContext, required this.onDragScroll});

  final DaviContext<DATA> daviContext;
  final OnDragScroll onDragScroll;

  @override
  State<TableLayoutBuilder<DATA>> createState() =>
      _TableLayoutBuilderState<DATA>();
}

class _TableLayoutBuilderState<DATA> extends State<TableLayoutBuilder<DATA>> {
  DaviContext<DATA> get daviContext => widget.daviContext;
  OnDragScroll get onDragScroll => widget.onDragScroll;

  BoxConstraints? _lastConstraints;
  DaviThemeData? _lastTheme;
  TableLayoutSettings? _lastLayoutSettings;
  bool _refreshScheduled = false;

  @override
  void initState() {
    super.initState();
    daviContext.rowExtentManager.addListener(_onRowExtentChanged);
  }

  @override
  void didUpdateWidget(covariant TableLayoutBuilder<DATA> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.daviContext.rowExtentManager !=
        daviContext.rowExtentManager) {
      oldWidget.daviContext.rowExtentManager
          .removeListener(_onRowExtentChanged);
      daviContext.rowExtentManager.addListener(_onRowExtentChanged);
    }
  }

  @override
  void dispose() {
    daviContext.rowExtentManager.removeListener(_onRowExtentChanged);
    super.dispose();
  }

  void _onRowExtentChanged() {
    if (_refreshScheduled) {
      return;
    }
    _refreshScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshScheduled = false;
      if (!mounted || _lastLayoutSettings == null) {
        return;
      }
      final next = _settings(_lastConstraints!, _lastTheme!);
      final previous = _lastLayoutSettings!;
      // Measurements update scroll extents directly. Rebuild the outer
      // table only when scrollbar visibility or its own height changes.
      if (next.hasVerticalScrollbar != previous.hasVerticalScrollbar ||
          next.hasHorizontalScrollbar != previous.hasHorizontalScrollbar ||
          next.height != previous.height) {
        setState(() {});
      }
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _builder);
  }

  Widget _builder(BuildContext context, BoxConstraints constraints) {
    final DaviThemeData theme = DaviTheme.of(context);
    final TableLayoutSettings layoutSettings = _settings(constraints, theme);
    _lastConstraints = constraints;
    _lastTheme = theme;
    _lastLayoutSettings = layoutSettings;

    if (daviContext.columnWidthBehavior == ColumnWidthBehavior.scrollable) {
      for (int columnIndex = 0;
          columnIndex < daviContext.model.columnsLength;
          columnIndex++) {
        DaviColumn column = daviContext.model.columnAt(columnIndex);
        if (!DaviColumnHelper.isLayoutPerformed(column: column)) {
          ColumnMetrics columnMetrics =
              layoutSettings.columnsMetrics[columnIndex];
          DaviColumnHelper.performLayout(
              column: column, layoutWidth: columnMetrics.width);
        }
      }
    }

    final List<TableLayoutChild> children = [];

    if (layoutSettings.hasVerticalScrollbar) {
      children.add(TableLayoutChild(
          id: LayoutChildId.verticalScrollbar,
          child: TableScrollbar(
              axis: Axis.vertical,
              contentSize: layoutSettings.contentHeight,
              rowExtentManager: daviContext.rowExtentManager,
              scrollController: daviContext.scrollControllers.vertical,
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
                  ColumnWidthBehavior.scrollable)));
      if (layoutSettings.hasVerticalScrollbar) {
        children.add(TableLayoutChild(
            id: LayoutChildId.headerEdge,
            child: const TableEdge(type: CornerType.header)));
      }
    }

    if (layoutSettings.hasHorizontalScrollbar) {
      Widget leftPinnedHorizontalScrollbar = TableScrollbar(
          axis: Axis.horizontal,
          scrollController: daviContext.scrollControllers.leftPinnedHorizontal,
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
              scrollController:
                  daviContext.scrollControllers.unpinnedHorizontal,
              color: theme.scrollbar.unpinnedHorizontalColor,
              borderColor: theme.scrollbar.unpinnedHorizontalBorderColor,
              contentSize: layoutSettings.unpinnedContentWidth,
              onDragScroll: onDragScroll)));
      if (layoutSettings.hasVerticalScrollbar) {
        children.add(TableLayoutChild(
            id: LayoutChildId.scrollbarEdge,
            child: const TableEdge(type: CornerType.scrollbar)));
      }
    }

    children.add(TableLayoutChild(
        id: LayoutChildId.cells,
        child: LayoutBuilder(builder: (context, constraints) {
          DaviThemeData theme = DaviTheme.of(context);
          return TableContent(
              daviContext: daviContext,
              layoutSettings: layoutSettings,
              rowFillHeight: theme.row.fillHeight,
              maxWidth: constraints.maxWidth,
              maxHeight: constraints.maxHeight);
        })));

    if (daviContext.model.hasSummary) {
      children.add(TableLayoutChild(
          id: LayoutChildId.summary,
          child: SummaryWidget(
              daviContext: daviContext, layoutSettings: layoutSettings)));
      if (layoutSettings.hasVerticalScrollbar) {
        children.add(TableLayoutChild(
            id: LayoutChildId.summaryEdge,
            child: const TableEdge(type: CornerType.summary)));
      }
    }

    return TableLayout<DATA>(
        layoutSettings: layoutSettings, theme: theme, children: children);
  }

  TableLayoutSettings _settings(
          BoxConstraints constraints, DaviThemeData theme) =>
      TableLayoutSettings(
          constraints: constraints,
          model: daviContext.model,
          theme: theme,
          columnWidthBehavior: daviContext.columnWidthBehavior,
          themeMetrics: daviContext.themeMetrics,
          visibleRowsCount: daviContext.visibleRowsCount,
          rowExtentManager: daviContext.rowExtentManager,
          hasTrailingWidget: daviContext.trailingWidget != null);
}
