import 'dart:math' as math;
import 'package:easy_table/src/experimental/content_area_id.dart';
import 'package:easy_table/src/experimental/horizontal_scroll_bar_exp.dart';
import 'package:easy_table/src/experimental/layout_child.dart';
import 'package:easy_table/src/experimental/table_layout_exp.dart';
import 'package:easy_table/src/experimental/table_layout_settings.dart';
import 'package:easy_table/src/experimental/table_paint_settings.dart';
import 'package:easy_table/src/experimental/table_scroll_controllers.dart';
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
    final HeaderThemeData headerTheme = theme.header;

    bool needHorizontalScrollbar = !theme.scrollbar.horizontalOnlyWhenNeeded;

    final double maxWidth =
        math.max(0, constraints.maxWidth - layoutSettings.scrollbarSize);
    double unpinnedContentWidth;
    double pinnedWidth = 0;
    double pinnedContentWidth = 0;
    if (layoutSettings.columnsFit) {
      final double availableWidth =
          math.max(0, constraints.maxWidth - layoutSettings.scrollbarSize);
      unpinnedContentWidth = math.max(availableWidth, model.allColumnsWidth);
      ColumnsMetrics columnsMetrics = ColumnsMetrics.columnsFit(
          model: model,
          containerWidth: availableWidth,
          columnDividerThickness: theme.columnDividerThickness);
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
          needHorizontalScrollbar =
              needPinnedHorizontalScroll || needUnpinnedHorizontalScroll;
        }
      } else {
        unpinnedContentWidth = model.allColumnsWidth +
            (model.columnsLength * theme.columnDividerThickness);
        if (theme.scrollbar.horizontalOnlyWhenNeeded) {
          needHorizontalScrollbar = unpinnedContentWidth > maxWidth;
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
        children: const []);
  }

  Widget _buildEmptyTable(
      {required BuildContext context,
      required BoxConstraints constraints,
      required TablePaintSettings paintSettings}) {
    final EasyTableThemeData theme = EasyTableTheme.of(context);

    List<LayoutChild> children = [];
    if (layoutSettings.allowHorizontalScrollbar &&
        !theme.scrollbar.horizontalOnlyWhenNeeded) {
      children.add(LayoutChild.horizontalScrollbar(
          contentAreaId: ContentAreaId.unpinned,
          child: HorizontalScrollBarExp(
              contentWidth: constraints.maxWidth,
              scrollController: scrollControllers.unpinnedContentArea)));
    }

    return TableLayoutExp(
        layoutSettings: layoutSettings,
        paintSettings: paintSettings,
        scrollControllers: scrollControllers,
        children: children);
  }
}
