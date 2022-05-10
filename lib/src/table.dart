import 'dart:math' as math;
import 'package:easy_table/src/internal/columns_metrics.dart';
import 'package:easy_table/src/internal/horizontal_scroll_bar.dart';
import 'package:easy_table/src/internal/table_area_content_widget.dart';
import 'package:easy_table/src/internal/table_area_layout.dart';
import 'package:easy_table/src/internal/table_header_widget.dart';
import 'package:easy_table/src/internal/table_layout.dart';
import 'package:easy_table/src/internal/vertical_scroll_bar.dart';
import 'package:easy_table/src/model.dart';
import 'package:easy_table/src/row_callbacks.dart';
import 'package:easy_table/src/row_hover_listener.dart';
import 'package:easy_table/src/internal/table_scrolls.dart';
import 'package:easy_table/src/theme/header_theme_data.dart';
import 'package:easy_table/src/theme/theme.dart';
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/material.dart';

/// Table view designed for a large number of data.
///
/// The type [ROW] represents the data of each row.
class EasyTable<ROW> extends StatefulWidget {
//TODO handle negative values
//TODO allow null and use defaults?
  const EasyTable(this.model,
      {Key? key,
      this.unpinnedHorizontalScrollController,
      this.pinnedHorizontalScrollController,
      this.verticalScrollController,
      this.onHoverListener,
      this.onRowTap,
      this.onRowDoubleTap,
      this.columnsFit = false,
      int? visibleRowsCount,
      this.scrollbarMargin = 0,
      this.scrollbarThickness = 10,
      this.scrollbarRadius = Radius.zero})
      : _visibleRowsCount = visibleRowsCount == null || visibleRowsCount > 0
            ? visibleRowsCount
            : null,
        super(key: key);

  final EasyTableModel<ROW>? model;
  final ScrollController? unpinnedHorizontalScrollController;
  final ScrollController? pinnedHorizontalScrollController;
  final ScrollController? verticalScrollController;
  final OnRowHoverListener? onHoverListener;
  final RowDoubleTapCallback<ROW>? onRowDoubleTap;
  final RowTapCallback<ROW>? onRowTap;
  final bool columnsFit;
  final int? _visibleRowsCount;
  final double scrollbarMargin;
  final double scrollbarThickness;
  final Radius? scrollbarRadius;

  double get scrollbarSize => scrollbarMargin * 2 + scrollbarThickness;

  int? get visibleRowsCount => _visibleRowsCount;

  @override
  State<StatefulWidget> createState() => _EasyTableState<ROW>();
}

/// The [EasyTable] state.
class _EasyTableState<ROW> extends State<EasyTable<ROW>> {
  late TableScrolls _scrolls;

  int? _hoveredRowIndex;

  void _setHoveredRowIndex(int? value) {
    if (_hoveredRowIndex != value) {
      setState(() {
        _hoveredRowIndex = value;
      });
      if (widget.onHoverListener != null) {
        widget.onHoverListener!(_hoveredRowIndex);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    widget.model?.addListener(_rebuild);
    _scrolls = TableScrolls(
        unpinnedHorizontal: widget.unpinnedHorizontalScrollController,
        pinnedHorizontal: widget.pinnedHorizontalScrollController,
        vertical: widget.verticalScrollController);
  }

  @override
  void dispose() {
    widget.model?.removeListener(_rebuild);
    _scrolls.removeListeners();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant EasyTable<ROW> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model?.removeListener(_rebuild);
      widget.model?.addListener(_rebuild);
    }
    if (widget.verticalScrollController != null) {
      _scrolls.vertical = widget.verticalScrollController!;
    }
    if (widget.unpinnedHorizontalScrollController != null) {
      _scrolls.unpinnedArea.horizontal =
          widget.unpinnedHorizontalScrollController!;
    }
    if (widget.pinnedHorizontalScrollController != null) {
      _scrolls.pinnedArea.horizontal = widget.pinnedHorizontalScrollController!;
    }
  }

  void _rebuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ScrollBehavior scrollBehavior =
        ScrollConfiguration.of(context).copyWith(scrollbars: false);
    Widget table = LayoutBuilder(builder: (context, constraints) {
      if (widget.model != null) {
        EasyTableModel<ROW> model = widget.model!;
        EasyTableThemeData theme = EasyTableTheme.of(context);
        HeaderThemeData headerTheme = theme.header;

        double rowHeight = theme.cell.contentHeight;
        if (theme.cell.padding != null) {
          rowHeight += theme.cell.padding!.vertical;
        }
        rowHeight += theme.rowDividerThickness;

        final double headerHeight = headerTheme.height;
        final double scrollbarWidth =
            math.min(widget.scrollbarSize, constraints.maxWidth);
        final double maxWidth =
            math.max(0, constraints.maxWidth - scrollbarWidth);

        Widget? unpinnedHeader;
        Widget? pinnedHeader;
        Widget unpinnedBody;
        Widget? pinnedBody;
        double pinnedWidth = 0;
        double contentWidth;
        double pinnedContentWidth = 0;
        if (widget.columnsFit) {
          final double availableWidth =
              math.max(0, constraints.maxWidth - scrollbarWidth);
          contentWidth = math.max(availableWidth, model.allColumnsWidth);
          ColumnsMetrics columnsMetrics = ColumnsMetrics.columnsFit(
              model: model,
              containerWidth: availableWidth,
              columnDividerThickness: theme.columnDividerThickness);

          if (headerHeight > 0) {
            unpinnedHeader = TableHeaderWidget<ROW>(
                horizontalScrollController:
                    _scrolls.unpinnedArea.headerHorizontal,
                columnsFit: true,
                model: model,
                columnsMetrics: columnsMetrics,
                contentWidth: contentWidth,
                columnFilter: ColumnFilter.all);
          }
          unpinnedBody = TableAreaContentWidget(
              columnsFit: widget.columnsFit,
              horizontalScrollController:
                  _scrolls.unpinnedArea.contentHorizontal,
              verticalScrollController: _scrolls.unpinnedArea.contentVertical,
              setHoveredRowIndex: _setHoveredRowIndex,
              hoveredRowIndex: _hoveredRowIndex,
              onRowTap: widget.onRowTap,
              onRowDoubleTap: widget.onRowDoubleTap,
              model: model,
              columnsMetrics: columnsMetrics,
              contentWidth: contentWidth,
              rowHeight: rowHeight,
              columnFilter: ColumnFilter.all,
              scrollBehavior: scrollBehavior);
        } else {
          final int pinnedColumnsLength = model.pinnedColumnsLength;
          final bool hasPinned = pinnedColumnsLength > 0;

          pinnedContentWidth = model.pinnedColumnsWidth +
              (pinnedColumnsLength * theme.columnDividerThickness);
          if (hasPinned) {
            pinnedWidth = math.min(pinnedContentWidth, maxWidth);
            contentWidth = math.max(
                maxWidth - pinnedWidth,
                model.unpinnedColumnsWidth +
                    (model.unpinnedColumnsLength *
                        theme.columnDividerThickness));
          } else {
            contentWidth = math.max(
                maxWidth,
                model.allColumnsWidth +
                    (model.columnsLength * theme.columnDividerThickness));
          }

          ColumnsMetrics unpinnedColumnsMetrics = ColumnsMetrics.resizable(
              model: model,
              columnDividerThickness: theme.columnDividerThickness,
              filter: hasPinned ? ColumnFilter.unpinnedOnly : ColumnFilter.all);

          ColumnsMetrics? pinnedColumnsMetrics = hasPinned
              ? ColumnsMetrics.resizable(
                  model: model,
                  columnDividerThickness: theme.columnDividerThickness,
                  filter: ColumnFilter.pinnedOnly)
              : null;

          if (headerHeight > 0) {
            unpinnedHeader = TableHeaderWidget<ROW>(
                horizontalScrollController:
                    _scrolls.unpinnedArea.headerHorizontal,
                columnsFit: false,
                model: model,
                columnsMetrics: unpinnedColumnsMetrics,
                contentWidth: contentWidth,
                columnFilter:
                    hasPinned ? ColumnFilter.unpinnedOnly : ColumnFilter.all);
            pinnedHeader = pinnedColumnsMetrics != null
                ? TableHeaderWidget<ROW>(
                    horizontalScrollController:
                        _scrolls.pinnedArea.headerHorizontal,
                    columnsFit: false,
                    model: model,
                    columnsMetrics: pinnedColumnsMetrics,
                    contentWidth: pinnedContentWidth,
                    columnFilter: ColumnFilter.pinnedOnly)
                : null;
          }

          unpinnedBody = TableAreaContentWidget(
              columnsFit: widget.columnsFit,
              horizontalScrollController:
                  _scrolls.unpinnedArea.contentHorizontal,
              verticalScrollController: _scrolls.unpinnedArea.contentVertical,
              setHoveredRowIndex: _setHoveredRowIndex,
              hoveredRowIndex: _hoveredRowIndex,
              onRowTap: widget.onRowTap,
              onRowDoubleTap: widget.onRowDoubleTap,
              model: model,
              columnsMetrics: unpinnedColumnsMetrics,
              contentWidth: contentWidth,
              rowHeight: rowHeight,
              columnFilter:
                  hasPinned ? ColumnFilter.unpinnedOnly : ColumnFilter.all,
              scrollBehavior: scrollBehavior);

          pinnedBody = pinnedColumnsMetrics != null
              ? TableAreaContentWidget(
                  columnsFit: false,
                  horizontalScrollController:
                      _scrolls.pinnedArea.contentHorizontal,
                  verticalScrollController: _scrolls.pinnedArea.contentVertical,
                  setHoveredRowIndex: _setHoveredRowIndex,
                  hoveredRowIndex: _hoveredRowIndex,
                  onRowTap: widget.onRowTap,
                  onRowDoubleTap: widget.onRowDoubleTap,
                  model: model,
                  columnsMetrics: pinnedColumnsMetrics,
                  contentWidth: pinnedContentWidth,
                  rowHeight: rowHeight,
                  columnFilter: ColumnFilter.pinnedOnly,
                  scrollBehavior: scrollBehavior)
              : null;
        }

        print('pinnedContentWidth: $pinnedContentWidth');
        Widget? pinnedArea;
        if (pinnedHeader != null && pinnedBody != null) {
          pinnedArea = TableAreaLayout(
              headerWidget: pinnedHeader,
              contentWidget: pinnedBody,
              scrollbarWidget: HorizontalScrollBar(
                  contentWidth: pinnedContentWidth,
                  scrollController: _scrolls.pinnedArea.horizontal,
                  scrollBehavior: scrollBehavior,
                  pinned: true),
              rowHeight: rowHeight,
              scrollbarHeight: widget.scrollbarSize,
              headerHeight: headerHeight,
              visibleRowsCount: widget.visibleRowsCount,
              width: pinnedWidth);
        }
        Widget unpinnedArea = TableAreaLayout(
            headerWidget: unpinnedHeader,
            contentWidget: unpinnedBody,
            scrollbarWidget: HorizontalScrollBar(
                contentWidth: contentWidth,
                scrollController: _scrolls.unpinnedArea.horizontal,
                scrollBehavior: scrollBehavior,
                pinned: false),
            rowHeight: rowHeight,
            headerHeight: headerHeight,
            visibleRowsCount: widget.visibleRowsCount,
            scrollbarHeight: widget.scrollbarSize,
            width: null);

        Widget verticalScrollArea = TableAreaLayout(
            headerWidget: Container(
                decoration: BoxDecoration(
                    color: theme.topCornerColor,
                    border: Border(
                        left: BorderSide(color: theme.topCornerBorderColor),
                        bottom:
                            BorderSide(color: theme.topCornerBorderColor)))),
            contentWidget: VerticalScrollBar(
                scrollBehavior: scrollBehavior,
                scrollController: _scrolls.vertical,
                rowHeight: rowHeight,
                visibleRowsLength: model.visibleRowsLength),
            scrollbarWidget: Container(
                decoration: BoxDecoration(
                    color: theme.bottomCornerColor,
                    border: Border(
                        left: BorderSide(color: theme.bottomCornerBorderColor),
                        top:
                            BorderSide(color: theme.bottomCornerBorderColor)))),
            rowHeight: rowHeight,
            headerHeight: headerHeight,
            visibleRowsCount: widget.visibleRowsCount,
            scrollbarHeight: widget.scrollbarSize,
            width: null);

        Widget layout = TableLayout(
            unpinnedWidget: unpinnedArea,
            pinnedWidget: pinnedArea,
            scrollbarWidget: verticalScrollArea,
            headerHeight: headerHeight,
            visibleRowsCount: widget.visibleRowsCount,
            hasHeader: true,
            scrollbarWidth: scrollbarWidth,
            rowHeight: rowHeight,
            pinnedWidth: pinnedContentWidth);

        return ClipRect(child: layout);
      }
      return Container();
    });
    EasyTableThemeData theme = EasyTableTheme.of(context);
    if (theme.decoration != null) {
      table = Container(child: table, decoration: theme.decoration);
    }
    return table;
  }
}
