import 'dart:math' as math;
import 'package:easy_table/src/internal/columns_metrics.dart';
import 'package:easy_table/src/internal/horizontal_scroll_bar.dart';
import 'package:easy_table/src/internal/table_area_content_widget.dart';
import 'package:easy_table/src/internal/table_area_layout.dart';
import 'package:easy_table/src/internal/table_header_widget.dart';
import 'package:easy_table/src/internal/table_layout.dart';
import 'package:easy_table/src/internal/vertical_scroll_bar.dart';
import 'package:easy_table/src/model.dart';
import 'package:easy_table/src/last_visible_row_listener.dart';
import 'package:easy_table/src/row_callbacks.dart';
import 'package:easy_table/src/row_hover_listener.dart';
import 'package:easy_table/src/internal/table_scrolls.dart';
import 'package:easy_table/src/theme/header_theme_data.dart';
import 'package:easy_table/src/theme/theme.dart';
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Table view designed for a large number of data.
///
/// The type [ROW] represents the data of each row.
/// The [cellContentHeight] is mandatory due to performance.
/// The total height of the cell will be the sum of the [cellContentHeight]
/// value, divider thickness, and cell margin.
class EasyTable<ROW> extends StatefulWidget {
//TODO handle negative values
//TODO allow null and use defaults?
  const EasyTable(this.model,
      {Key? key,
      this.unpinnedHorizontalScrollController,
      this.pinnedHorizontalScrollController,
      this.verticalScrollController,
      this.onHoverListener,
      this.onLastVisibleRowListener,
      this.onRowTap,
      this.onRowSecondaryTap,
      this.onRowDoubleTap,
      this.columnsFit = false,
      int? visibleRowsCount,
      this.cellContentHeight = 32,
      this.scrollbarRadius = Radius.zero,
      this.focusable = true,
      this.multiSortEnabled = false})
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
  final RowTapCallback<ROW>? onRowSecondaryTap;
  final bool columnsFit;
  final int? _visibleRowsCount;
  final Radius? scrollbarRadius;
  final double cellContentHeight;
  final OnLastVisibleRowListener? onLastVisibleRowListener;
  final bool focusable;
  final bool multiSortEnabled;

  int? get visibleRowsCount => _visibleRowsCount;

  @override
  State<StatefulWidget> createState() => _EasyTableState<ROW>();
}

/// The [EasyTable] state.
class _EasyTableState<ROW> extends State<EasyTable<ROW>> {
  late TableScrolls _scrolls;
  int? _hoveredRowIndex;
  int _lastVisibleRow = -1;
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

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
    _focusNode.dispose();
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
      if (widget.model == null) {
        return Container();
      }

      final EasyTableModel<ROW> model = widget.model!;
      EasyTableThemeData theme = EasyTableTheme.of(context);

      final double scrollbarSize =
          theme.scrollbar.margin * 2 + theme.scrollbar.thickness;

      HeaderThemeData headerTheme = theme.header;

      double rowHeight = widget.cellContentHeight;
      if (theme.cell.padding != null) {
        rowHeight += theme.cell.padding!.vertical;
      }
      rowHeight += theme.row.dividerThickness;

      final double headerHeight = headerTheme.bottomBorderHeight + theme.headerCell.height;
      final double scrollbarWidth =
          math.min(scrollbarSize, constraints.maxWidth);
      final double maxWidth =
          math.max(0, constraints.maxWidth - scrollbarWidth);

      Widget? unpinnedHeader;
      Widget? pinnedHeader;
      Widget unpinnedBody;
      Widget? pinnedBody;
      double pinnedWidth = 0;
      double contentWidth;
      double pinnedContentWidth = 0;
      final bool allowHorizontalScrollbar = !widget.columnsFit;
      bool needHorizontalScrollbar = !theme.scrollbar.horizontalOnlyWhenNeeded;
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
                  allowHorizontalScrollbar && needHorizontalScrollbar
                      ? _scrolls.unpinnedArea.headerHorizontal
                      : null,
              columnsFit: true,
              model: model,
              columnsMetrics: columnsMetrics,
              contentWidth: contentWidth,
              columnFilter: ColumnFilter.all,
              multiSortEnabled: widget.multiSortEnabled);
        }
        unpinnedBody = TableAreaContentWidget(
            columnsFit: widget.columnsFit,
            horizontalScrollController:
                allowHorizontalScrollbar && needHorizontalScrollbar
                    ? _scrolls.unpinnedArea.contentHorizontal
                    : null,
            verticalScrollController: _scrolls.unpinnedArea.contentVertical,
            setHoveredRowIndex: _setHoveredRowIndex,
            hoveredRowIndex: _hoveredRowIndex,
            onRowTap: widget.onRowTap,
            onRowSecondaryTap: widget.onRowSecondaryTap,
            onRowDoubleTap: widget.onRowDoubleTap,
            model: model,
            columnsMetrics: columnsMetrics,
            contentWidth: contentWidth,
            rowHeight: rowHeight,
            cellContentHeight: widget.cellContentHeight,
            columnFilter: ColumnFilter.all,
            scrollBehavior: scrollBehavior);
      } else {
        final int unpinnedColumnsLength = model.unpinnedColumnsLength;
        final int pinnedColumnsLength = model.pinnedColumnsLength;
        final bool hasPinned = pinnedColumnsLength > 0;
        pinnedContentWidth = model.pinnedColumnsWidth +
            (pinnedColumnsLength * theme.columnDividerThickness);
        if (hasPinned) {
          bool needPinnedHorizontalScroll = pinnedContentWidth > maxWidth;
          pinnedWidth = math.min(pinnedContentWidth, maxWidth);
          contentWidth = model.unpinnedColumnsWidth +
              (unpinnedColumnsLength * theme.columnDividerThickness);
          bool needUnpinnedHorizontalScroll =
              contentWidth > maxWidth - pinnedWidth;
          contentWidth = math.max(maxWidth - pinnedWidth, contentWidth);
          if (theme.scrollbar.horizontalOnlyWhenNeeded) {
            needHorizontalScrollbar =
                needPinnedHorizontalScroll || needUnpinnedHorizontalScroll;
          }
        } else {
          contentWidth = model.allColumnsWidth +
              (model.columnsLength * theme.columnDividerThickness);
          if (theme.scrollbar.horizontalOnlyWhenNeeded) {
            needHorizontalScrollbar = contentWidth > maxWidth;
          }
          contentWidth = math.max(maxWidth, contentWidth);
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
                  allowHorizontalScrollbar && needHorizontalScrollbar
                      ? _scrolls.unpinnedArea.headerHorizontal
                      : null,
              columnsFit: false,
              model: model,
              columnsMetrics: unpinnedColumnsMetrics,
              contentWidth: contentWidth,
              columnFilter:
                  hasPinned ? ColumnFilter.unpinnedOnly : ColumnFilter.all,
              multiSortEnabled: widget.multiSortEnabled);
          pinnedHeader = pinnedColumnsMetrics != null
              ? TableHeaderWidget<ROW>(
                  horizontalScrollController:
                      allowHorizontalScrollbar && needHorizontalScrollbar
                          ? _scrolls.pinnedArea.headerHorizontal
                          : null,
                  columnsFit: false,
                  model: model,
                  columnsMetrics: pinnedColumnsMetrics,
                  contentWidth: pinnedContentWidth,
                  columnFilter: ColumnFilter.pinnedOnly,
                  multiSortEnabled: widget.multiSortEnabled)
              : null;
        }

        unpinnedBody = TableAreaContentWidget(
            columnsFit: widget.columnsFit,
            horizontalScrollController:
                allowHorizontalScrollbar && needHorizontalScrollbar
                    ? _scrolls.unpinnedArea.contentHorizontal
                    : null,
            verticalScrollController: _scrolls.unpinnedArea.contentVertical,
            setHoveredRowIndex: _setHoveredRowIndex,
            hoveredRowIndex: _hoveredRowIndex,
            onRowTap: widget.onRowTap,
            onRowSecondaryTap: widget.onRowSecondaryTap,
            onRowDoubleTap: widget.onRowDoubleTap,
            model: model,
            columnsMetrics: unpinnedColumnsMetrics,
            contentWidth: contentWidth,
            rowHeight: rowHeight,
            cellContentHeight: widget.cellContentHeight,
            columnFilter:
                hasPinned ? ColumnFilter.unpinnedOnly : ColumnFilter.all,
            scrollBehavior: scrollBehavior);

        pinnedBody = pinnedColumnsMetrics != null
            ? TableAreaContentWidget(
                columnsFit: false,
                horizontalScrollController:
                    allowHorizontalScrollbar && needHorizontalScrollbar
                        ? _scrolls.pinnedArea.contentHorizontal
                        : null,
                verticalScrollController: _scrolls.pinnedArea.contentVertical,
                setHoveredRowIndex: _setHoveredRowIndex,
                hoveredRowIndex: _hoveredRowIndex,
                onRowTap: widget.onRowTap,
                onRowSecondaryTap: widget.onRowSecondaryTap,
                onRowDoubleTap: widget.onRowDoubleTap,
                model: model,
                columnsMetrics: pinnedColumnsMetrics,
                contentWidth: pinnedContentWidth,
                rowHeight: rowHeight,
                cellContentHeight: widget.cellContentHeight,
                columnFilter: ColumnFilter.pinnedOnly,
                scrollBehavior: scrollBehavior)
            : null;
      }

      Widget? pinnedArea;
      if (pinnedHeader != null && pinnedBody != null) {
        pinnedArea = TableAreaLayout(
            headerWidget: pinnedHeader,
            contentWidget: pinnedBody,
            scrollbarWidget: allowHorizontalScrollbar && needHorizontalScrollbar
                ? HorizontalScrollBar(
                    contentWidth: pinnedContentWidth,
                    scrollController: _scrolls.pinnedArea.horizontal,
                    scrollBehavior: scrollBehavior,
                    pinned: true)
                : null,
            rowHeight: rowHeight,
            scrollbarHeight: scrollbarSize,
            headerHeight: headerHeight,
            visibleRowsCount: widget.visibleRowsCount,
            width: pinnedWidth);
      }

      Widget unpinnedArea = TableAreaLayout(
          headerWidget: unpinnedHeader,
          contentWidget: unpinnedBody,
          scrollbarWidget: allowHorizontalScrollbar && needHorizontalScrollbar
              ? HorizontalScrollBar(
                  contentWidth: contentWidth,
                  scrollController: _scrolls.unpinnedArea.horizontal,
                  scrollBehavior: scrollBehavior,
                  pinned: false)
              : null,
          rowHeight: rowHeight,
          headerHeight: headerHeight,
          visibleRowsCount: widget.visibleRowsCount,
          scrollbarHeight: scrollbarSize,
          width: null);

      Widget verticalScrollArea = TableAreaLayout(
          headerWidget: Container(
              decoration: BoxDecoration(
                  color: theme.topCornerColor,
                  border: Border(
                      left: BorderSide(color: theme.topCornerBorderColor),
                      bottom: BorderSide(color: theme.topCornerBorderColor)))),
          contentWidget: VerticalScrollBar(
              scrollBehavior: scrollBehavior,
              scrollController: _scrolls.vertical,
              rowHeight: rowHeight,
              visibleRowsLength: model.visibleRowsLength),
          scrollbarWidget: allowHorizontalScrollbar && needHorizontalScrollbar
              ? Container(
                  decoration: BoxDecoration(
                      color: theme.bottomCornerColor,
                      border: Border(
                          left:
                              BorderSide(color: theme.bottomCornerBorderColor),
                          top: BorderSide(
                              color: theme.bottomCornerBorderColor))))
              : null,
          rowHeight: rowHeight,
          headerHeight: headerHeight,
          visibleRowsCount: widget.visibleRowsCount,
          scrollbarHeight: scrollbarSize,
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
          pinnedWidth: pinnedWidth,
          scrollbarHeight: allowHorizontalScrollbar && needHorizontalScrollbar
              ? scrollbarSize
              : 0);

      if (widget.onLastVisibleRowListener != null) {
        layout = NotificationListener<ScrollMetricsNotification>(
            child: layout,
            onNotification: (notification) {
              double maxPixels = _scrolls.vertical.offset +
                  _scrolls.vertical.position.viewportDimension;
              int index = math.max(
                  math.min((maxPixels / rowHeight).ceil() - 1,
                      widget.model!.rowsLength - 1),
                  0);
              if (_lastVisibleRow != index) {
                _lastVisibleRow = index;
                widget.onLastVisibleRowListener!(index);
              }
              return false;
            });
      }

      if (widget.focusable) {
        layout = Focus(
            focusNode: _focusNode,
            onKey: (node, event) => _handleKeyPress(node, event, rowHeight),
            child: layout);
        layout = Listener(
            child: layout,
            onPointerDown: (pointer) {
              _focusNode.requestFocus();
              _focused = true;
            });
      }

      return ClipRect(child: layout);
    });
    EasyTableThemeData theme = EasyTableTheme.of(context);
    if (theme.decoration != null) {
      table = Container(child: table, decoration: theme.decoration);
    }
    return table;
  }

  KeyEventResult _handleKeyPress(
      FocusNode node, RawKeyEvent event, double rowHeight) {
    if (event is RawKeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.tab) {
        if (_focused) {
          _focused = false;
          node.nextFocus();
        } else {
          _focused = true;
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        if (_scrolls.vertical.hasClients) {
          double target = math.min(
              _scrolls.vertical.position.pixels + rowHeight,
              _scrolls.vertical.position.maxScrollExtent);
          _scrolls.vertical.animateTo(target,
              duration: const Duration(milliseconds: 30), curve: Curves.ease);
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        if (_scrolls.vertical.hasClients) {
          double target =
              math.max(_scrolls.vertical.position.pixels - rowHeight, 0);
          _scrolls.vertical.animateTo(target,
              duration: const Duration(milliseconds: 30), curve: Curves.ease);
        }
      } else if (event.logicalKey == LogicalKeyboardKey.pageDown) {
        if (_scrolls.vertical.hasClients) {
          double target = math.min(
              _scrolls.vertical.position.pixels +
                  _scrolls.vertical.position.viewportDimension,
              _scrolls.vertical.position.maxScrollExtent);
          _scrolls.vertical.animateTo(target,
              duration: const Duration(milliseconds: 30), curve: Curves.ease);
        }
      } else if (event.logicalKey == LogicalKeyboardKey.pageUp) {
        if (_scrolls.vertical.hasClients) {
          double target = math.max(
              _scrolls.vertical.position.pixels -
                  _scrolls.vertical.position.viewportDimension,
              0);
          _scrolls.vertical.animateTo(target,
              duration: const Duration(milliseconds: 30), curve: Curves.ease);
        }
      }
    }
    return KeyEventResult.handled;
  }
}
