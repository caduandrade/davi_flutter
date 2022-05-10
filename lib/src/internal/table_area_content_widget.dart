import 'package:easy_table/src/internal/columns_metrics.dart';
import 'package:easy_table/src/internal/divider_painter.dart';
import 'package:easy_table/src/internal/set_hovered_row_index.dart';
import 'package:easy_table/src/internal/table_row_widget.dart';
import 'package:easy_table/src/model.dart';
import 'package:easy_table/src/row_callbacks.dart';
import 'package:easy_table/src/theme/theme.dart';
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// [EasyTable] area content widget.
@internal
class TableAreaContentWidget<ROW> extends StatelessWidget {
  const TableAreaContentWidget(
      {Key? key,
      required this.model,
      required this.verticalScrollController,
      required this.horizontalScrollController,
      required this.columnsMetrics,
      required this.contentWidth,
      required this.rowHeight,
      required this.columnsFit,
      required this.onRowTap,
      required this.onRowSecondaryTap,
      required this.onRowDoubleTap,
      required this.hoveredRowIndex,
      required this.columnFilter,
      required this.setHoveredRowIndex,
      required this.scrollBehavior})
      : super(key: key);

  final EasyTableModel<ROW> model;
  final ScrollController verticalScrollController;
  final ScrollController horizontalScrollController;
  final ColumnsMetrics columnsMetrics;
  final double contentWidth;
  final double rowHeight;
  final bool columnsFit;
  final RowTapCallback<ROW>? onRowTap;
  final RowTapCallback<ROW>? onRowSecondaryTap;
  final RowDoubleTapCallback<ROW>? onRowDoubleTap;
  final int? hoveredRowIndex;
  final SetHoveredRowIndex setHoveredRowIndex;
  final ColumnFilter columnFilter;
  final ScrollBehavior scrollBehavior;

  @override
  Widget build(BuildContext context) {
    EasyTableThemeData theme = EasyTableTheme.of(context);

    Widget list = ListView.builder(
        controller: verticalScrollController,
        itemExtent: rowHeight,
        itemBuilder: (context, index) {
          return TableRowWidget<ROW>(
              model: model,
              columnsMetrics: columnsMetrics,
              visibleRowIndex: index,
              columnFilter: columnFilter,
              onRowTap: onRowTap,
              onRowSecondaryTap: onRowSecondaryTap,
              onRowDoubleTap: onRowDoubleTap,
              hoveredRowIndex: hoveredRowIndex,
              setHoveredRowIndex: setHoveredRowIndex);
        },
        itemCount: model.visibleRowsLength);

    list = ScrollConfiguration(behavior: scrollBehavior, child: list);

    if (theme.row.columnDividerColor != null) {
      list = CustomPaint(
          child: list,
          foregroundPainter: DividerPainter(
              columnsMetrics: columnsMetrics,
              color: theme.row.columnDividerColor!));
    }

    list =
        MouseRegion(child: list, onExit: (event) => setHoveredRowIndex(null));

    if (columnsFit) {
      return list;
    }

    Widget customScrollView = CustomScrollView(
        scrollDirection: Axis.horizontal,
        controller: horizontalScrollController,
        slivers: [
          SliverToBoxAdapter(
              child: SizedBox(
                  child: ScrollConfiguration(
                      behavior: scrollBehavior, child: list),
                  width: contentWidth))
        ]);

    return ScrollConfiguration(
        behavior: scrollBehavior, child: customScrollView);
  }
}
