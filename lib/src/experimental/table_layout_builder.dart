import 'dart:math' as math;
import 'package:easy_table/src/cell_style.dart';
import 'package:easy_table/src/column.dart';
import 'package:easy_table/src/experimental/columns_metrics_exp.dart';
import 'package:easy_table/src/experimental/content_area_id.dart';
import 'package:easy_table/src/experimental/table_scroll_bar_exp.dart';
import 'package:easy_table/src/experimental/layout_child.dart';
import 'package:easy_table/src/experimental/table_layout_exp.dart';
import 'package:easy_table/src/experimental/table_layout_settings.dart';
import 'package:easy_table/src/experimental/table_paint_settings.dart';
import 'package:easy_table/src/experimental/table_scroll_controllers.dart';
import 'package:easy_table/src/internal/cell.dart';
import 'package:easy_table/src/internal/columns_metrics.dart';
import 'package:easy_table/src/model.dart';
import 'package:easy_table/src/theme/header_theme_data.dart';
import 'package:easy_table/src/theme/theme.dart';
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/material.dart';

class TableLayoutBuilder<ROW> extends StatelessWidget {
  const TableLayoutBuilder(
      {Key? key,
      required this.layoutSettings,
      required this.scrollControllers,
      required this.model})
      : super(key: key);

  final TableScrollControllers scrollControllers;
  final TableLayoutSettings layoutSettings;
  final EasyTableModel<ROW>? model;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _builder);
  }

  Widget _builder(BuildContext context, BoxConstraints constraints) {
    if (!constraints.hasBoundedHeight &&
        layoutSettings.visibleRowsCount == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('EasyTable was given unbounded height.'),
        ErrorDescription(
            'EasyTable already is scrollable in the vertical axis.'),
        ErrorHint(
          'Consider using the "visibleRowsCount" property to limit the height'
          ' or use it in another Widget like Expanded or SliverFillRemaining.',
        ),
      ]);
    }
    if (!constraints.hasBoundedWidth) {
      throw FlutterError('EasyTable was given unbounded width.');
    }

    TablePaintSettings paintSettings = TablePaintSettings(debugAreas: true);
    if (model != null) {
      return _buildTable(
          context: context,
          constraints: constraints,
          model: model!,
          paintSettings: paintSettings);
    }
    return _buildEmptyTable(
        context: context,
        constraints: constraints,
        paintSettings: paintSettings);
  }

  Widget _buildTable(
      {required BuildContext context,
      required BoxConstraints constraints,
      required EasyTableModel<ROW> model,
      required TablePaintSettings paintSettings}) {
    final EasyTableThemeData theme = EasyTableTheme.of(context);

    ColumnsMetricsExp<ROW> leftPinnedColumnsMetrics = ColumnsMetricsExp.empty();
    ColumnsMetricsExp<ROW> unpinnedColumnsMetrics = ColumnsMetricsExp.empty();
    ColumnsMetricsExp<ROW> rightPinnedColumnsMetrics =
        ColumnsMetricsExp.empty();

    final List<ROW> rows = [];
    final List<LayoutChild> children = [];

    int visibleRowsCount = layoutSettings.visibleRowsCount ?? 0;
    if (constraints.hasBoundedHeight) {
      //TODO scrollbarSize should have separator
      final double contentAvailableHeight = math.max(
          0,
          constraints.maxHeight -
              layoutSettings.headerHeight -
              layoutSettings.scrollbarSize);
      visibleRowsCount = (contentAvailableHeight /
              (layoutSettings.cellHeight + theme.row.dividerThickness))
          .ceil();
    }
    layoutSettings.contentHeight =
        (model.rowsLength * layoutSettings.cellHeight) +
            (math.max(0, model.rowsLength - 1) * theme.row.dividerThickness);

    children.add(LayoutChild.verticalScrollbar(
        child: EasyTableScrollBarExp(
            axis: Axis.vertical,
            contentSize: layoutSettings.contentHeight,
            scrollController: scrollControllers.vertical,
            color: theme.scrollbar.verticalColor)));

    layoutSettings.firstRowIndex =
        (scrollControllers.verticalOffset / layoutSettings.rowHeight).floor();
    final int lastRowIndex = layoutSettings.firstRowIndex + visibleRowsCount;

    final double maxWidth =
        math.max(0, constraints.maxWidth - layoutSettings.scrollbarSize);
    double unpinnedContentWidth;
    double pinnedWidth = 0;
    double pinnedContentWidth = 0;

    if (layoutSettings.columnsFit) {
      final double availableContentWidth =
          math.max(0, constraints.maxWidth - layoutSettings.scrollbarSize);

      unpinnedContentWidth =
          math.max(availableContentWidth, model.allColumnsWidth);

      unpinnedColumnsMetrics = ColumnsMetricsExp.columnsFit(
          model: model,
          containerWidth: availableContentWidth,
          columnDividerThickness: theme.columnDividerThickness);

      for (int rowIndex = layoutSettings.firstRowIndex;
          rowIndex < model.visibleRowsLength && rowIndex < lastRowIndex;
          rowIndex++) {
        ROW row = model.visibleRowAt(rowIndex);
        rows.add(row);
        for (int columnIndex = 0;
            columnIndex < unpinnedColumnsMetrics.columns.length;
            columnIndex++) {
          EasyTableColumn<ROW> column =
              unpinnedColumnsMetrics.columns[columnIndex];
          if (column.cellBuilder != null) {
            Widget cellChild = column.cellBuilder!(context, row, rowIndex);
            EdgeInsets? padding;
            Alignment? alignment;
            Color? background;
            if (column.cellStyleBuilder != null) {
              CellStyle? cellStyle = column.cellStyleBuilder!(row);
              if (cellStyle != null) {
                background = cellStyle.background;
                alignment = cellStyle.alignment;
                padding = cellStyle.padding;
              }
            }
            Widget cell = ClipRect(
                child: EasyTableCell(
                    child: cellChild,
                    alignment: alignment,
                    padding: padding,
                    background: background));
            children.add(LayoutChild.cell(
                contentAreaId: ContentAreaId.unpinned,
                row: rowIndex,
                column: columnIndex,
                child: cell));
          }
        }
      }
    } else {
      final int unpinnedColumnsLength = model.unpinnedColumnsLength;
      final int pinnedColumnsLength = model.pinnedColumnsLength;
      final bool hasPinned = pinnedColumnsLength > 0;
      pinnedContentWidth = model.pinnedColumnsWidth +
          (pinnedColumnsLength * theme.columnDividerThickness);
      if (hasPinned) {
        bool needPinnedHorizontalScroll = pinnedContentWidth > maxWidth;
        pinnedWidth = math.min(pinnedContentWidth, maxWidth);
        unpinnedContentWidth = model.unpinnedColumnsWidth +
            (unpinnedColumnsLength * theme.columnDividerThickness);
        bool needUnpinnedHorizontalScroll =
            unpinnedContentWidth > maxWidth - pinnedWidth;
        unpinnedContentWidth =
            math.max(maxWidth - pinnedWidth, unpinnedContentWidth);
        if (theme.scrollbar.horizontalOnlyWhenNeeded) {
          layoutSettings.needHorizontalScrollbar =
              needPinnedHorizontalScroll || needUnpinnedHorizontalScroll;
        }
      } else {
        unpinnedContentWidth = model.allColumnsWidth +
            (model.columnsLength * theme.columnDividerThickness);
        if (theme.scrollbar.horizontalOnlyWhenNeeded) {
          layoutSettings.needHorizontalScrollbar =
              unpinnedContentWidth > maxWidth;
        }
        unpinnedContentWidth = math.max(maxWidth, unpinnedContentWidth);
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
    }

    return TableLayoutExp(
        layoutSettings: layoutSettings,
        paintSettings: paintSettings,
        scrollControllers: scrollControllers,
        leftPinnedColumnsMetrics: leftPinnedColumnsMetrics,
        unpinnedColumnsMetrics: unpinnedColumnsMetrics,
        rightPinnedColumnsMetrics: rightPinnedColumnsMetrics,
        rows: rows,
        children: children);
  }

  Widget _buildEmptyTable(
      {required BuildContext context,
      required BoxConstraints constraints,
      required TablePaintSettings paintSettings}) {
    final EasyTableThemeData theme = EasyTableTheme.of(context);

    List<LayoutChild> children = [];
    if (layoutSettings.allowHorizontalScrollbar &&
        !theme.scrollbar.horizontalOnlyWhenNeeded) {
      children.add(LayoutChild.verticalScrollbar(
          child: EasyTableScrollBarExp(
              axis: Axis.vertical,
              contentSize: constraints.maxHeight,
              scrollController: scrollControllers.vertical,
              color: theme.scrollbar.verticalColor)));
      children.add(LayoutChild.horizontalScrollbar(
          contentAreaId: ContentAreaId.unpinned,
          child: EasyTableScrollBarExp(
              axis: Axis.horizontal,
              contentSize: constraints.maxWidth,
              scrollController: scrollControllers.unpinnedContentArea,
              color: theme.scrollbar.unpinnedHorizontalColor)));
    }

    return TableLayoutExp(
        layoutSettings: layoutSettings,
        paintSettings: paintSettings,
        scrollControllers: scrollControllers,
        leftPinnedColumnsMetrics: ColumnsMetricsExp.empty(),
        unpinnedColumnsMetrics: ColumnsMetricsExp.empty(),
        rightPinnedColumnsMetrics: ColumnsMetricsExp.empty(),
        rows: const [],
        children: children);
  }
}
