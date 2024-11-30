import 'package:davi/davi.dart';
import 'package:davi/src/internal/cell_widget.dart';
import 'package:davi/src/internal/new/painter_cache.dart';
import 'package:davi/src/internal/new/cells_layout.dart';
import 'package:davi/src/internal/new/cells_layout_child.dart';
import 'package:davi/src/internal/new/davi_context.dart';
import 'package:davi/src/internal/new/row_region.dart';
import 'package:davi/src/internal/new/table_events.dart';
import 'package:davi/src/internal/scroll_offsets.dart';
import 'package:davi/src/internal/table_layout_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

@internal
class TableContent<DATA> extends StatefulWidget {
  const TableContent(
      {Key? key,
      required this.layoutSettings,
      required this.daviContext,
      required this.verticalScrollController,
      required this.horizontalScrollOffsets})
      : super(key: key);

  final TableLayoutSettings layoutSettings;
  final DaviContext<DATA> daviContext;
  final ScrollController verticalScrollController;
  final HorizontalScrollOffsets horizontalScrollOffsets;

  @override
  State<StatefulWidget> createState() => TableContentState<DATA>();
}

@internal
class TableContentState<DATA> extends State<TableContent<DATA>> {
  final PainterCache<DATA> _painterCache = PainterCache();

  @override
  void initState() {
    super.initState();
    _updatePainterCacheSize();
  }

  @override
  void didUpdateWidget(covariant TableContent<DATA> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updatePainterCacheSize();
  }

  void _updatePainterCacheSize() {
    _painterCache.size = widget.layoutSettings.maxVisibleRows *
        2 *
        widget.layoutSettings.columnsMetrics.length;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: widget.verticalScrollController,
        builder: (BuildContext context, Widget? child) {
          return LayoutBuilder(builder: _builder);
        });
  }

  Widget _builder(BuildContext context, BoxConstraints constraints) {
    //TODO null hover on resizing
    DaviThemeData theme = DaviTheme.of(context);

    final double verticalOffset = widget.verticalScrollController.hasClients
        ? widget.verticalScrollController.offset
        : 0;

    final int firstRowIndex =
        (verticalOffset / widget.layoutSettings.themeMetrics.row.height)
            .floor();

    List<CellsLayoutChild> children = [];

    final RowRegionCache rowRegionCache = RowRegionCache();

    bool trailingWidgetBuilt = false;
    int? lastVisibleRowIndex;

    // This is used to determine if an extra row might become partially
    // visible during scrolling, allowing preemptive
    // caching to improve performance.
    final maxVisualRows = ((constraints.maxHeight +
                widget.layoutSettings.themeMetrics.cell.height) /
            widget.layoutSettings.themeMetrics.row.height)
        .ceil();

    double rowY =
        (firstRowIndex * widget.layoutSettings.themeMetrics.row.height) -
            verticalOffset;

    int childIndex = 0;

    for (int rowIndex = firstRowIndex;
        rowIndex < firstRowIndex + maxVisualRows;
        rowIndex++) {
      final Rect bounds = Rect.fromLTWH(0, rowY, constraints.maxWidth,
          widget.layoutSettings.themeMetrics.cell.height);

      DATA? data;
      if (rowIndex < widget.daviContext.model.rowsLength) {
        data = widget.daviContext.model.rowAt(rowIndex);
      }

      bool trailingRegion = false;
      if (widget.daviContext.trailingWidget != null &&
          !trailingWidgetBuilt &&
          data == null) {
        trailingWidgetBuilt = true;
        trailingRegion = true;
        children.add(CellsLayoutChild.trailing(
            child: widget.daviContext.trailingWidget!));
      }

      rowRegionCache.add(RowRegion(
          index: rowIndex,
          bounds: bounds,
          hasData: data != null,
          y: rowY,
          trailing: trailingRegion));

      for (int columnIndex = 0;
          columnIndex < widget.layoutSettings.columnsMetrics.length;
          columnIndex++) {
        if (data != null) {
          final DaviColumn<DATA> column =
              widget.daviContext.model.columnAt(columnIndex);

          Widget? cellWidget = TableCellWidget<DATA>(
              daviContext: widget.daviContext,
              painterCache: _painterCache,
              data: data,
              column: column,
              rowIndex: rowIndex);
          children.add(CellsLayoutChild.cell(
              childIndex: childIndex,
              rowIndex: rowIndex,
              columnIndex: columnIndex,
              child: cellWidget));
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
      rowY += widget.layoutSettings.themeMetrics.row.height;
    }

    widget.daviContext.onTrailingWidget(trailingWidgetBuilt);
    widget.daviContext.onLastVisibleRow(lastVisibleRowIndex);

    CellsLayout<DATA> cellsLayout = CellsLayout(
        daviContext: widget.daviContext,
        layoutSettings: widget.layoutSettings,
        verticalOffset: verticalOffset,
        horizontalScrollOffsets: widget.horizontalScrollOffsets,
        leftPinnedAreaBounds:
            widget.layoutSettings.getAreaBounds(PinStatus.left),
        unpinnedAreaBounds: widget.layoutSettings.getAreaBounds(PinStatus.none),
        rowsLength: widget.layoutSettings.rowsLength,
        rowRegionCache: rowRegionCache,
        children: children);

    return ClipRect(
        child: TableEvents(
            daviContext: widget.daviContext,
            rowBoundsCache: rowRegionCache,
            verticalScrollController: widget.verticalScrollController,
            rowTheme: theme.row,
            child: cellsLayout));
  }
}
