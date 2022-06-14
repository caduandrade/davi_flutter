import 'dart:math' as math;
import 'package:easy_table/src/cell_icon.dart';
import 'package:easy_table/src/cell_style.dart';
import 'package:easy_table/src/column.dart';
import 'package:easy_table/src/experimental/columns_metrics_exp.dart';
import 'package:easy_table/src/experimental/pin_status.dart';
import 'package:easy_table/src/experimental/row_callbacks.dart';
import 'package:easy_table/src/experimental/layout_v2/layout_child_v2.dart';
import 'package:easy_table/src/experimental/layout_v2/table_layout_v2.dart';
import 'package:easy_table/src/experimental/table_layout_settings.dart';
import 'package:easy_table/src/experimental/table_paint_settings.dart';
import 'package:easy_table/src/experimental/table_scroll_controllers.dart';
import 'package:easy_table/src/experimental/table_scrollbar.dart';
import 'package:easy_table/src/internal/header_cell.dart';
import 'package:easy_table/src/last_visible_row_listener.dart';
import 'package:easy_table/src/model.dart';
import 'package:easy_table/src/row_hover_listener.dart';
import 'package:easy_table/src/theme/theme.dart';
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/material.dart';

class TableLayoutBuilderV2<ROW> extends StatelessWidget {
  const TableLayoutBuilderV2(
      {Key? key,
      required this.onHoverListener,
      required this.hoveredRowIndex,
      required this.layoutSettingsBuilder,
      required this.scrollControllers,
      required this.multiSortEnabled,
      required this.onLastVisibleRowListener,
      required this.model,
      required this.rowCallbacks})
      : super(key: key);

  final int? hoveredRowIndex;
  final OnLastVisibleRowListener? onLastVisibleRowListener;
  final OnRowHoverListener onHoverListener;
  final TableScrollControllers scrollControllers;
  final TableLayoutSettingsBuilder layoutSettingsBuilder;
  final EasyTableModel<ROW>? model;
  final bool multiSortEnabled;
  final RowCallbacks? rowCallbacks;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _builder);
  }

  Widget _builder(BuildContext context, BoxConstraints constraints) {
    if (!constraints.hasBoundedWidth) {
      throw FlutterError('EasyTable was given unbounded width.');
    }
    if (!constraints.hasBoundedHeight &&
        layoutSettingsBuilder.visibleRowsCount == null) {
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

    TablePaintSettings paintSettings =
        TablePaintSettings(hoveredRowIndex: hoveredRowIndex);

    if (onLastVisibleRowListener != null && model != null) {
      double maxPixels = scrollControllers.verticalOffset +
          scrollControllers.verticalViewportDimension;
      int index = math.max(
          math.min((maxPixels / layoutSettingsBuilder.rowHeight).ceil() - 1,
              model!.rowsLength - 1),
          0);
      onLastVisibleRowListener!(index);
    }

    return _buildTable(
        context: context,
        constraints: constraints,
        model: model,
        paintSettings: paintSettings);
  }

  Widget _buildTable(
      {required BuildContext context,
      required BoxConstraints constraints,
      required EasyTableModel<ROW>? model,
      required TablePaintSettings paintSettings}) {
    final EasyTableThemeData theme = EasyTableTheme.of(context);

    ColumnsMetricsExp<ROW> leftPinnedColumnsMetrics = ColumnsMetricsExp.empty();
    ColumnsMetricsExp<ROW> unpinnedColumnsMetrics = ColumnsMetricsExp.empty();
    ColumnsMetricsExp<ROW> rightPinnedColumnsMetrics =
        ColumnsMetricsExp.empty();

    final List<LayoutChildV2> children = [];

    int visibleRowsCount = layoutSettingsBuilder.visibleRowsCount ?? 0;
    if (constraints.hasBoundedHeight) {
      // Without the data, it is not possible to know if horizontal scrolling
      // will be necessary. The calculation must be done considering
      // that it is not visible.
      final double contentAvailableHeight = math.max(
          0,
          constraints.maxHeight -
              layoutSettingsBuilder.headerHeight -
              theme.scrollbar.borderThickness -
              layoutSettingsBuilder.scrollbarSize);
      visibleRowsCount =
          (contentAvailableHeight / layoutSettingsBuilder.rowHeight).ceil();
    }

    children.add(LayoutChildV2.verticalScrollbar(
        child: TableScrollbar(
            axis: Axis.vertical,
            contentSize: layoutSettingsBuilder.rowsFullHeight,
            scrollController: scrollControllers.vertical,
            color: theme.scrollbar.verticalColor,
            borderColor: theme.scrollbar.verticalBorderColor)));

    if (layoutSettingsBuilder.hasHeader) {
      children.add(LayoutChildV2.topCorner());
    }

    final int firstRowIndex =
        (scrollControllers.verticalOffset / layoutSettingsBuilder.rowHeight)
            .floor();
    final int lastRowIndex = firstRowIndex + visibleRowsCount;

    final double scrollbarWidth =
        layoutSettingsBuilder.scrollbarSize + theme.scrollbar.borderThickness;

    final double maxContentAreaWidth =
        math.max(0, constraints.maxWidth - scrollbarWidth);

    final bool hasHorizontalScrollbar;
    final double pinnedAreaDivisorWidth;
    if (model != null) {
      if (layoutSettingsBuilder.columnsFit) {
        unpinnedColumnsMetrics = ColumnsMetricsExp.columnsFit(
            model: model,
            containerWidth: maxContentAreaWidth,
            columnDividerThickness: theme.columnDividerThickness);
        hasHorizontalScrollbar = false;
        pinnedAreaDivisorWidth = 0;
      } else {
        leftPinnedColumnsMetrics = ColumnsMetricsExp.resizable(
            model: model,
            columnDividerThickness: theme.columnDividerThickness,
            pinStatus: PinStatus.leftPinned);

        unpinnedColumnsMetrics = ColumnsMetricsExp.resizable(
            model: model,
            columnDividerThickness: theme.columnDividerThickness,
            pinStatus: PinStatus.unpinned);

        final double pinnedAreaWidth = leftPinnedColumnsMetrics.maxWidth;
        pinnedAreaDivisorWidth =
            pinnedAreaWidth > 0 ? theme.columnDividerThickness : 0;
        final bool needLeftPinnedHorizontalScrollbar =
            pinnedAreaWidth > maxContentAreaWidth;

        final double unpinnedAreaWidth = unpinnedColumnsMetrics.maxWidth;
        final bool needUnpinnedHorizontalScrollbar = unpinnedAreaWidth >
            maxContentAreaWidth - pinnedAreaWidth - pinnedAreaDivisorWidth;

        final bool needHorizontalScrollbar = needUnpinnedHorizontalScrollbar ||
            needLeftPinnedHorizontalScrollbar;

        hasHorizontalScrollbar = theme.scrollbar.horizontalOnlyWhenNeeded
            ? needHorizontalScrollbar
            : true;

        if (hasHorizontalScrollbar) {
          children.add(LayoutChildV2.horizontalScrollbar(
              pinStatus: PinStatus.leftPinned,
              child: TableScrollbar(
                  axis: Axis.horizontal,
                  scrollController: scrollControllers.leftPinnedContentArea,
                  color: theme.scrollbar.pinnedHorizontalColor,
                  borderColor: theme.scrollbar.pinnedHorizontalBorderColor,
                  contentSize: pinnedAreaWidth)));

          //TODO build EasyTableScrollBarExp in LayoutChild.horizontalScrollbar
          children.add(LayoutChildV2.horizontalScrollbar(
              pinStatus: PinStatus.unpinned,
              child: TableScrollbar(
                  axis: Axis.horizontal,
                  scrollController: scrollControllers.unpinnedContentArea,
                  color: theme.scrollbar.unpinnedHorizontalColor,
                  borderColor: theme.scrollbar.unpinnedHorizontalBorderColor,
                  contentSize: unpinnedAreaWidth)));

          children.add(LayoutChildV2.bottomCorner());
        }
      }
    } else {
      // empty table (no model)
      hasHorizontalScrollbar = false;
      pinnedAreaDivisorWidth = 0;
    }

    Map<PinStatus, ColumnsMetricsExp<ROW>> columnMetricsMap = {
      PinStatus.leftPinned: leftPinnedColumnsMetrics,
      PinStatus.unpinned: unpinnedColumnsMetrics,
      PinStatus.rightPinned: rightPinnedColumnsMetrics
    };

    if (model != null) {
      columnMetricsMap.forEach((pinStatus, columnsMetrics) {
        for (int columnIndex = 0;
            columnIndex < columnsMetrics.columns.length;
            columnIndex++) {
          EasyTableColumn<ROW> column = columnsMetrics.columns[columnIndex];

          children.insert(
              0,
              LayoutChildV2.header(
                  pinStatus: pinStatus,
                  column: columnIndex,
                  child: EasyTableHeaderCell<ROW>(
                      model: model,
                      column: column,
                      resizable: !layoutSettingsBuilder.columnsFit,
                      multiSortEnabled: multiSortEnabled)));

          for (int rowIndex = firstRowIndex;
              rowIndex < model.visibleRowsLength && rowIndex <= lastRowIndex;
              rowIndex++) {
            ROW row = model.visibleRowAt(rowIndex);
            children.insert(
                0,
                LayoutChildV2.cell(
                    pinStatus: pinStatus,
                    row: rowIndex,
                    column: columnIndex,
                    child: _buildCellWidget(
                        context: context,
                        row: row,
                        rowIndex: rowIndex,
                        column: column,
                        theme: theme)));
          }
        }
      });
    }

    final double scrollbarHeight = hasHorizontalScrollbar
        ? layoutSettingsBuilder.scrollbarSize + theme.scrollbar.borderThickness
        : 0;

    final double height;
    final Rect cellsBound;
    if (constraints.hasBoundedHeight) {
      height = constraints.maxHeight;

      cellsBound = Rect.fromLTWH(
          0,
          layoutSettingsBuilder.headerHeight,
          math.max(0, constraints.maxWidth - scrollbarWidth),
          math.max(
              0,
              constraints.maxHeight -
                  layoutSettingsBuilder.headerHeight -
                  (hasHorizontalScrollbar ? scrollbarHeight : 0)));
    } else {
      // unbounded height
      height = layoutSettingsBuilder.headerHeight +
          layoutSettingsBuilder.rowsFullHeight +
          scrollbarHeight;

      cellsBound = Rect.fromLTWH(
          0,
          layoutSettingsBuilder.headerHeight,
          math.max(0, constraints.maxWidth - scrollbarWidth),
          layoutSettingsBuilder.rowsFullHeight);
    }

    TableLayoutSettings layoutSettings = layoutSettingsBuilder.build(
        height: height,
        visibleRowsCount: visibleRowsCount,
        cellsBound: cellsBound,
        hasHorizontalScrollbar: hasHorizontalScrollbar,
        scrollbarWidth: scrollbarWidth,
        scrollbarHeight: scrollbarHeight,
        pinnedAreaDivisorWidth: pinnedAreaDivisorWidth,
        leftPinnedColumnsMetrics: leftPinnedColumnsMetrics,
        unpinnedColumnsMetrics: unpinnedColumnsMetrics,
        rightPinnedColumnsMetrics: rightPinnedColumnsMetrics,
        rowsLength: model != null ? model.visibleRowsLength : 0);

    return TableLayoutV2(
        onHoverListener: onHoverListener,
        layoutSettings: layoutSettings,
        paintSettings: paintSettings,
        leftPinnedColumnsMetrics: leftPinnedColumnsMetrics,
        unpinnedColumnsMetrics: unpinnedColumnsMetrics,
        rightPinnedColumnsMetrics: rightPinnedColumnsMetrics,
        theme: theme,
        rowCallbacks: rowCallbacks,
        children: children);
  }

  Widget _buildCellWidget(
      {required BuildContext context,
      required ROW row,
      required int rowIndex,
      required EasyTableColumn<ROW> column,
      required EasyTableThemeData theme}) {
    EdgeInsets? padding;
    Alignment? alignment;
    Color? background;
    TextStyle? textStyle;
    TextOverflow? overflow;

    if (column.cellStyleBuilder != null) {
      CellStyle? cellStyle = column.cellStyleBuilder!(row);
      if (cellStyle != null) {
        background = cellStyle.background;
        alignment = cellStyle.alignment;
        padding = cellStyle.padding;
        textStyle = cellStyle.textStyle;
        overflow = cellStyle.overflow;
      }
    }

    Widget? child;
    if (column.cellBuilder != null) {
      child = column.cellBuilder!(context, row, rowIndex);
    } else if (column.iconValueMapper != null) {
      CellIcon? cellIcon = column.iconValueMapper!(row);
      if (cellIcon != null) {
        if (cellIcon.alignment != null) {
          //TODO check
          //alignment = cellIcon.alignment!;
        }
        if (cellIcon.background != null) {
          //TODO check
          // background = cellIcon.background;
        }
        child = Icon(cellIcon.icon, color: cellIcon.color, size: cellIcon.size);
      }
    } else {
      String? value = _stringValue(column: column, row: row);
      if (value != null) {
        child = Text(value,
            overflow: overflow ?? theme.cell.overflow,
            style: textStyle ?? theme.cell.textStyle);
      } else if (background == null && theme.cell.nullValueColor != null) {
        background = theme.cell.nullValueColor!(rowIndex);
      }
    }
    if (child != null) {
      child = Align(child: child, alignment: alignment ?? theme.cell.alignment);
      EdgeInsetsGeometry? p = padding ?? theme.cell.padding;
      if (p != null) {
        child = Padding(padding: p, child: child);
      }
    }
    if (background != null) {
      child = Container(child: child, color: background);
    }
    //TODO optional clip?
    return ClipRect(child: child);
  }

  String? _stringValue(
      {required EasyTableColumn<ROW> column, required ROW row}) {
    if (column.stringValueMapper != null) {
      return column.stringValueMapper!(row);
    } else if (column.intValueMapper != null) {
      return column.intValueMapper!(row)?.toString();
    } else if (column.doubleValueMapper != null) {
      final double? doubleValue = column.doubleValueMapper!(row);
      if (doubleValue != null) {
        if (column.fractionDigits != null) {
          return doubleValue.toStringAsFixed(column.fractionDigits!);
        } else {
          return doubleValue.toString();
        }
      }
    } else if (column.objectValueMapper != null) {
      return column.objectValueMapper!(row)?.toString();
    }
    return null;
  }
}
