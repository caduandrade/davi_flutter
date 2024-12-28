import 'package:davi/davi.dart';
import 'package:davi/src/internal/new/cell_widget_builder.dart';
import 'package:davi/src/internal/new/painter_cache.dart';
import 'package:davi/src/internal/new/cells_layout.dart';
import 'package:davi/src/internal/new/cells_layout_child.dart';
import 'package:davi/src/internal/new/davi_context.dart';
import 'package:davi/src/internal/new/cell_span_cache.dart';
import 'package:davi/src/internal/new/table_events.dart';
import 'package:davi/src/internal/new/viewport_state.dart';
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
      required this.horizontalScrollOffsets,
      required this.maxHeight,
      required this.maxWidth,
      required this.rowFillHeight})
      : super(key: key);

  final TableLayoutSettings layoutSettings;
  final DaviContext<DATA> daviContext;
  final HorizontalScrollOffsets horizontalScrollOffsets;
  final double maxWidth;
  final double maxHeight;
  final bool rowFillHeight;

  @override
  State<StatefulWidget> createState() => TableContentState<DATA>();
}

@internal
class TableContentState<DATA> extends State<TableContent<DATA>> {
  final PainterCache<DATA> _painterCache = PainterCache();
  final CellSpanCache _cellSpanCache = CellSpanCache();
  final ViewportState<DATA> _viewportState = ViewportState();
  /*
  final ViewportState<DATA> _viewportState = ViewportState();
  final RowRegionCache<DATA> _rowRegionCache = RowRegionCache();
  final DividerPaintManager _dividerPaintManager = DividerPaintManager();
  */

  @override
  void initState() {
    super.initState();
    _updatePainterCacheSize();
    _onVerticalScrollChange();
    widget.daviContext.scrollControllers.vertical.addListener(_onVerticalScrollChange);
  }

  @override
  void didUpdateWidget(covariant TableContent<DATA> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updatePainterCacheSize();
    _onVerticalScrollChange();
    if (oldWidget.daviContext.scrollControllers.vertical != widget.daviContext.scrollControllers.vertical) {
      oldWidget.daviContext.scrollControllers.vertical.removeListener(_onVerticalScrollChange);
      widget.daviContext.scrollControllers.vertical.addListener(_onVerticalScrollChange);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _updatePainterCacheSize() {
    _painterCache.size = widget.layoutSettings.maxVisibleRows *
        2 *
        widget.layoutSettings.columnsMetrics.length;
  }

  void _onVerticalScrollChange(){
    final double verticalOffset = widget.daviContext.scrollControllers.vertical.hasClients
        ? widget.daviContext.scrollControllers.vertical.offset
        : 0;
    _viewportState.reset(verticalOffset: verticalOffset,
        columnsMetrics: widget.layoutSettings.columnsMetrics,
        rowHeight: widget.layoutSettings.themeMetrics.row.height,
        cellHeight: widget.layoutSettings.themeMetrics.cell.height,
        maxHeight: widget.maxHeight,
        maxWidth: widget.maxWidth,
        model: widget.daviContext.model,
        hasTrailing: widget.daviContext.trailingWidget!=null,
        rowFillHeight: widget.rowFillHeight);
    _cellSpanCache.clear();

    //TODO future?
   // widget.daviContext.onTrailingWidget(_rowRegionCache.trailingRegion!=null);
   // widget.daviContext.onLastVisibleRow(_rowRegionCache.lastDataIndex);

  }

  @override
  Widget build(BuildContext context) {   
    //TODO null hover on resizing
    DaviThemeData theme = DaviTheme.of(context);

    final double verticalOffset = widget.daviContext.scrollControllers.vertical.hasClients
        ? widget.daviContext.scrollControllers.vertical.offset
        : 0;

    List<CellsLayoutChild> children = [];

    //TODO se o build nao roda novamente, como vai construir o trailing
    //TODO dinamicamente?
    //TODO terá que adicionar entao sempre esse CellsLayoutChild.trailing
    //TODO e ele tb ficara offstage, quando for notificado pra aparecer,
    //TODO ele internamente tb vai se reconstruir como outras celulas
    if (widget.daviContext.trailingWidget != null ) {
      //TODO keep always built but markneedrepaint when visible
      children.add(CellsLayoutChild.trailing(    child: widget.daviContext.trailingWidget!));
    }
      for (int cellIndex = 0; cellIndex <
          _viewportState.maxCellCount; cellIndex++) {
        children.add(CellsLayoutChild.cell(
            cellIndex: cellIndex,
            child: CellWidgetBuilder(cellIndex: cellIndex,
                daviContext: widget.daviContext,
                viewportState: _viewportState,
                cellSpanCache: _cellSpanCache,
                painterCache: _painterCache,
                layoutSettings: widget.layoutSettings)));
      }
    CellsLayout<DATA> cellsLayout = CellsLayout(
        daviContext: widget.daviContext,
        layoutSettings: widget.layoutSettings,
        verticalOffset: verticalOffset,
        horizontalScrollOffsets: widget.horizontalScrollOffsets,
        leftPinnedAreaBounds:
            widget.layoutSettings.getAreaBounds(PinStatus.left),
        unpinnedAreaBounds: widget.layoutSettings.getAreaBounds(PinStatus.none),
        rowsLength: widget.layoutSettings.rowsLength,
        rowRegionCache: _viewportState.rowRegions,
        dividerPaintManager: _viewportState.dividerPaintManager,
        children: children);

    return ClipRect(
        child: TableEvents(
            daviContext: widget.daviContext,
            rowBoundsCache: _viewportState.rowRegions,
            rowTheme: theme.row,
            child: cellsLayout));
  }
}
