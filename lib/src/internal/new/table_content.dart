import 'package:davi/davi.dart';
import 'package:davi/src/internal/cell_widget.dart';
import 'package:davi/src/internal/new/cells_layout.dart';
import 'package:davi/src/internal/new/cells_layout_child.dart';
import 'package:davi/src/internal/new/davi_context.dart';
import 'package:davi/src/internal/new/row_region.dart';
import 'package:davi/src/internal/new/table_events.dart';
import 'package:davi/src/internal/new/value_cache.dart';
import 'package:davi/src/internal/scroll_offsets.dart';
import 'package:davi/src/internal/table_layout_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

@internal
class TableContent<DATA> extends StatelessWidget {
  const TableContent(
      {Key? key,
      required this.layoutSettings,
      required this.daviContext,
      required this.verticalScrollController,
      required this.horizontalScrollOffsets,
      required this.scrolling})
      : super(key: key);

  final TableLayoutSettings layoutSettings;
  final DaviContext<DATA> daviContext;
  final ScrollController verticalScrollController;
  final HorizontalScrollOffsets horizontalScrollOffsets;

  final bool scrolling;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: verticalScrollController,
        builder: (BuildContext context, Widget? child) {
          return LayoutBuilder(builder: _builder);
        });
  }

  Widget _builder(BuildContext context, BoxConstraints constraints) {
    //TODO null hover on resizing
    DaviThemeData theme = DaviTheme.of(context);

    final double verticalOffset = verticalScrollController.hasClients
        ? verticalScrollController.offset
        : 0;

    final int firstRowIndex =
        (verticalOffset / layoutSettings.themeMetrics.row.height).floor();

    List<CellsLayoutChild> children = [];

    final RowRegionCache rowRegionCache = RowRegionCache();

    bool trailingWidgetBuilt = false;
    int? lastVisibleRowIndex;

    // This is used to determine if an extra row might become partially
    // visible during scrolling, allowing preemptive
    // caching to improve performance.
    final maxVisualRows =
        ((constraints.maxHeight + layoutSettings.themeMetrics.cell.height) /
                layoutSettings.themeMetrics.row.height)
            .ceil();

    double rowY = (firstRowIndex * layoutSettings.themeMetrics.row.height) -
        verticalOffset;

    ValueCache<DATA> valueCache = ValueCache();

    int childIndex = 0;

    for (int rowIndex = firstRowIndex;
        rowIndex < firstRowIndex + maxVisualRows;
        rowIndex++) {
      final Rect bounds = Rect.fromLTWH(0, rowY, constraints.maxWidth,
          layoutSettings.themeMetrics.cell.height);

      DATA? data;
      if (rowIndex < daviContext.model.rowsLength) {
        data = daviContext.model.rowAt(rowIndex);
      }

      bool trailingRegion = false;
      if (daviContext.trailingWidget != null &&
          !trailingWidgetBuilt &&
          data == null) {
        trailingWidgetBuilt = true;
        trailingRegion = true;
        children
            .add(CellsLayoutChild.trailing(child: daviContext.trailingWidget!));
      }

      rowRegionCache.add(RowRegion(
          index: rowIndex,
          bounds: bounds,
          hasData: data != null,
          y: rowY,
          trailing: trailingRegion));

      for (int columnIndex = 0;
          columnIndex < layoutSettings.columnsMetrics.length;
          columnIndex++) {
        valueCache.load(
            model: daviContext.model,
            rowIndex: rowIndex,
            columnIndex: columnIndex);

        if (data != null) {
          final DaviColumn<DATA> column =
              daviContext.model.columnAt(columnIndex);
          final CellWidget<DATA> cell = CellWidget(
              column: column,
              columnIndex: columnIndex,
              data: data,
              rowIndex: rowIndex,
              daviContext: daviContext);
          children.add(CellsLayoutChild.cell(
              childIndex: childIndex,
              rowIndex: rowIndex,
              columnIndex: columnIndex,
              child: cell));
          lastVisibleRowIndex = rowIndex;
        } else {
          children.add(CellsLayoutChild.cell(
              childIndex: childIndex,
              rowIndex: rowIndex,
              columnIndex: columnIndex,
              child: const Offstage()));
        }
        childIndex++;
      }
      rowY += layoutSettings.themeMetrics.row.height;
    }

    daviContext.onTrailingWidget(trailingWidgetBuilt);
    daviContext.onLastVisibleRow(lastVisibleRowIndex);

    CellsLayout<DATA> cellsLayout = CellsLayout(
        daviContext: daviContext,
        model: daviContext.model,
        valueCache: valueCache,
        layoutSettings: layoutSettings,
        verticalOffset: verticalOffset,
        horizontalScrollOffsets: horizontalScrollOffsets,
        leftPinnedAreaBounds: layoutSettings.getAreaBounds(PinStatus.left),
        unpinnedAreaBounds: layoutSettings.getAreaBounds(PinStatus.none),
        rowsLength: layoutSettings.rowsLength,
        rowRegionCache: rowRegionCache,
        children: children);

    return ClipRect(
        child: TableEvents(
            daviContext: daviContext,
            rowBoundsCache: rowRegionCache,
            verticalScrollController: verticalScrollController,
            scrolling: scrolling,
            rowTheme: theme.row,
            child: cellsLayout));
  }
}
