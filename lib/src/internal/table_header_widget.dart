import 'package:easy_table/src/column.dart';
import 'package:easy_table/src/internal/columns_metrics.dart';
import 'package:easy_table/src/internal/divider_painter.dart';
import 'package:easy_table/src/internal/header_cell.dart';
import 'package:easy_table/src/internal/horizontal_layout.dart';
import 'package:easy_table/src/model.dart';
import 'package:easy_table/src/theme/theme.dart';
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// Table header
@internal
class TableHeaderWidget<ROW> extends StatelessWidget {
  const TableHeaderWidget(
      {Key? key,
      required this.model,
      required this.columnsMetrics,
      required this.columnsFit,
      required this.horizontalScrollController,
      required this.columnFilter,
      required this.contentWidth})
      : super(key: key);

  final EasyTableModel<ROW> model;
  final ColumnsMetrics columnsMetrics;
  final bool columnsFit;
  final double contentWidth;
  final ScrollController? horizontalScrollController;
  final ColumnFilter columnFilter;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (int columnIndex = 0;
        columnIndex < model.columnsLength;
        columnIndex++) {
      EasyTableColumn<ROW> column = model.columnAt(columnIndex);
      if (columnFilter == ColumnFilter.all ||
          (columnFilter == ColumnFilter.unpinnedOnly &&
              column.pinned == false) ||
          (columnFilter == ColumnFilter.pinnedOnly && column.pinned)) {
        children.add(EasyTableHeaderCell<ROW>(
            model: model, column: column, resizable: !columnsFit));
      }
    }

    Widget header =
        HorizontalLayout(columnsMetrics: columnsMetrics, children: children);

    EasyTableThemeData theme = EasyTableTheme.of(context);

    if (theme.header.columnDividerColor != null) {
      header = CustomPaint(
          child: header,
          foregroundPainter: DividerPainter(
              columnsMetrics: columnsMetrics,
              color: theme.header.columnDividerColor!));
    }

    if (theme.header.bottomBorderHeight > 0 &&
        theme.header.bottomBorderColor != null) {
      header = Container(
          child: header,
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      width: theme.header.bottomBorderHeight,
                      color: theme.header.bottomBorderColor!))));
    }

    if (columnsFit || horizontalScrollController == null) {
      return header;
    }

    // scrollable header
    return CustomScrollView(
        controller: horizontalScrollController,
        scrollDirection: Axis.horizontal,
        slivers: [
          SliverToBoxAdapter(
              child: SizedBox(child: header, width: contentWidth))
        ]);
  }
}
