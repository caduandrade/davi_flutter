import 'package:davi/davi.dart';
import 'package:davi/src/internal/new/cell_widget_builder.dart';
import 'package:davi/src/internal/new/painter_cache.dart';
import 'package:davi/src/internal/new/cells_layout.dart';
import 'package:davi/src/internal/new/cells_layout_child.dart';
import 'package:davi/src/internal/new/davi_context.dart';
import 'package:davi/src/internal/new/table_events.dart';
import 'package:davi/src/internal/new/viewport_state.dart';
import 'package:davi/src/internal/table_layout_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

@internal
class TableContent<DATA> extends StatefulWidget {
  const TableContent(
      {Key? key,
      required this.layoutSettings,
      required this.daviContext,
      required this.maxHeight,
      required this.maxWidth,
      required this.rowFillHeight})
      : super(key: key);

  final TableLayoutSettings layoutSettings;
  final DaviContext<DATA> daviContext;
  final double maxWidth;
  final double maxHeight;
  final bool rowFillHeight;

  @override
  State<StatefulWidget> createState() => TableContentState<DATA>();
}

@internal
class TableContentState<DATA> extends State<TableContent<DATA>> {
  final PainterCache<DATA> _painterCache = PainterCache();
  final ViewportState<DATA> _viewportState = ViewportState();
  Object? _error;

  @override
  void initState() {
    super.initState();
    _updatePainterCacheSize();
    _onVerticalScrollChange();
    widget.daviContext.scrollControllers.vertical
        .addListener(_onVerticalScrollChange);
  }

  @override
  void didUpdateWidget(covariant TableContent<DATA> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updatePainterCacheSize();
    _onVerticalScrollChange();
    if (oldWidget.daviContext.scrollControllers.vertical !=
        widget.daviContext.scrollControllers.vertical) {
      oldWidget.daviContext.scrollControllers.vertical
          .removeListener(_onVerticalScrollChange);
      widget.daviContext.scrollControllers.vertical
          .addListener(_onVerticalScrollChange);
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

  void _onVerticalScrollChange() {
    final double verticalOffset =
        widget.daviContext.scrollControllers.vertical.hasClients
            ? widget.daviContext.scrollControllers.vertical.offset
            : 0;

    if (_error != null) {
      setState(() {
        _error = null;
      });
    }
    try {
      _viewportState.reset(
          verticalOffset: verticalOffset,
          columnsMetrics: widget.layoutSettings.columnsMetrics,
          rowHeight: widget.layoutSettings.themeMetrics.row.height,
          cellHeight: widget.layoutSettings.themeMetrics.cell.height,
          maxHeight: widget.maxHeight,
          maxWidth: widget.maxWidth,
          model: widget.daviContext.model,
          hasTrailing: widget.daviContext.trailingWidget != null,
          rowFillHeight: widget.rowFillHeight,
          collisionBehavior: widget.daviContext.model.collisionBehavior);
    } catch (e, stackTrace) {
      setState(() {
        _error = e;
      });
      debugPrint('$e');
      debugPrint('$stackTrace');
    }

    widget.daviContext
        .onTrailingWidget(_viewportState.rowRegions.trailingRegion != null);
    widget.daviContext.onLastVisibleRow(_viewportState.lastDataRow);
  }

  @override
  Widget build(BuildContext context) {
    //TODO null hover on resizing
    DaviThemeData theme = DaviTheme.of(context);

    late Widget cells;

    if (kDebugMode && _error != null) {
      cells = ErrorWidget(_error!);
    } else {
      final double verticalOffset =
          widget.daviContext.scrollControllers.vertical.hasClients
              ? widget.daviContext.scrollControllers.vertical.offset
              : 0;

      List<CellsLayoutChild> children = [];

      if (widget.daviContext.trailingWidget != null) {
        children.add(CellsLayoutChild.trailing(
            child: widget.daviContext.trailingWidget!));
      }
      for (int cellIndex = 0;
          cellIndex < _viewportState.maxCellCount;
          cellIndex++) {
        children.add(CellsLayoutChild.cell(
            cellIndex: cellIndex,
            child: DaviCellWidgetBuilder(
                cellIndex: cellIndex,
                daviContext: widget.daviContext,
                viewportState: _viewportState,
                painterCache: _painterCache,
                layoutSettings: widget.layoutSettings)));
      }
      cells = CellsLayout(
          daviContext: widget.daviContext,
          layoutSettings: widget.layoutSettings,
          verticalOffset: verticalOffset,
          leftPinnedAreaBounds:
              widget.layoutSettings.getAreaBounds(PinStatus.left),
          unpinnedAreaBounds:
              widget.layoutSettings.getAreaBounds(PinStatus.none),
          rowsLength: widget.layoutSettings.rowsLength,
          rowRegionCache: _viewportState.rowRegions,
          dividerPaintManager: _viewportState.dividerPaintManager,
          children: children);
    }

    return ClipRect(
        child: TableEvents(
            daviContext: widget.daviContext,
            rowRegions: _viewportState.rowRegions,
            rowTheme: theme.row,
            child: cells));
  }
}
