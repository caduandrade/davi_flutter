import 'package:davi/davi.dart';
import 'package:davi/src/internal/cell_widget_builder.dart';
import 'package:davi/src/internal/cell_focus_traversal.dart';
import 'package:davi/src/internal/cells_layout.dart';
import 'package:davi/src/internal/cells_layout_child.dart';
import 'package:davi/src/internal/davi_context.dart';
import 'package:davi/src/internal/painter_cache.dart';
import 'package:davi/src/internal/row_extent_manager.dart';
import 'package:davi/src/internal/table_events.dart';
import 'package:davi/src/internal/table_layout_settings.dart';
import 'package:davi/src/internal/viewport_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

@internal
class TableContent<DATA> extends StatefulWidget {
  const TableContent(
      {super.key,
      required this.layoutSettings,
      required this.daviContext,
      required this.maxHeight,
      required this.maxWidth,
      required this.rowFillHeight});

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

  bool _postFrameRefreshScheduled = false;
  int _builtCellCount = 0;
  late final CellFocusTraversalPolicy _focusTraversal;

  @override
  void initState() {
    super.initState();
    _focusTraversal = CellFocusTraversalPolicy(
        rowCount: () => widget.daviContext.dataSource.rowsLength,
        columnCount: () => widget.daviContext.dataSource.columnsLength,
        hasWidgets: (column) =>
            widget.daviContext.dataSource.columnAt(column).cellFocusTraversalEnabled,
        reveal: _revealCell);
    widget.daviContext.dataSource.addListener(_focusTraversal.cancel);
    _updatePainterCacheSize();
    _onVerticalScrollChange();
    widget.daviContext.scrollControllers.vertical
        .addListener(_onVerticalScrollChange);
    widget.daviContext.rowExtentManager.addListener(_onRowExtentChanged);
  }

  @override
  void didUpdateWidget(covariant TableContent<DATA> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.daviContext.dataSource != widget.daviContext.dataSource) {
      oldWidget.daviContext.dataSource.removeListener(_focusTraversal.cancel);
      _focusTraversal.cancel();
      widget.daviContext.dataSource.addListener(_focusTraversal.cancel);
    }
    _updatePainterCacheSize();
    _onVerticalScrollChange();
    if (oldWidget.daviContext.scrollControllers.vertical !=
        widget.daviContext.scrollControllers.vertical) {
      oldWidget.daviContext.scrollControllers.vertical
          .removeListener(_onVerticalScrollChange);
      widget.daviContext.scrollControllers.vertical
          .addListener(_onVerticalScrollChange);
    }
    if (oldWidget.daviContext.rowExtentManager !=
        widget.daviContext.rowExtentManager) {
      oldWidget.daviContext.rowExtentManager
          .removeListener(_onRowExtentChanged);
      widget.daviContext.rowExtentManager.addListener(_onRowExtentChanged);
    }
  }

  @override
  void dispose() {
    widget.daviContext.dataSource.removeListener(_focusTraversal.cancel);
    _focusTraversal.dispose();
    widget.daviContext.scrollControllers.vertical
        .removeListener(_onVerticalScrollChange);
    widget.daviContext.rowExtentManager.removeListener(_onRowExtentChanged);
    super.dispose();
  }

  /// Measurements happen after build and can change the required cell pool.
  /// Content shrinkage can also silently clamp ScrollPosition during layout.
  /// Reconcile after that layout, only when the viewport inputs are stale.
  void _onRowExtentChanged() {
    if (_postFrameRefreshScheduled) {
      return;
    }
    _postFrameRefreshScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _postFrameRefreshScheduled = false;
      if (!mounted) {
        return;
      }
      final controller = widget.daviContext.scrollControllers.vertical;
      final double offset = controller.hasClients ? controller.offset : 0;
      final RowExtentManager manager = widget.daviContext.rowExtentManager;
      if (_viewportState.verticalOffset != offset) {
        // A silent correction bypasses the normal paint listeners too.
        setState(_onVerticalScrollChange);
      } else if (_viewportState.firstDataRow != manager.indexAtOffset(offset) ||
          _viewportState.maxVisibleRowCount !=
              manager.viewportRowCount(
                  scrollOffset: offset, availableHeight: widget.maxHeight)) {
        _onVerticalScrollChange();
      }
    });
    // setHeight notifies in a microtask, which may run after the frame has
    // ended. A post-frame callback alone would then wait for unrelated input.
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void _updatePainterCacheSize() {
    _painterCache.size = widget.layoutSettings.maxVisibleRows *
        2 *
        widget.layoutSettings.columnsMetrics.length;
  }

  Future<void> _revealCell(CellMapping cell, bool Function() active) async {
    // First reveal using estimated extents, then correct after the row has
    // been built and measured. Both scrollbars may change during this step.
    for (int pass = 0; pass < 4 && mounted && active(); pass++) {
      if (cell.rowIndex >= widget.daviContext.dataSource.rowsLength ||
          cell.columnIndex >= widget.layoutSettings.columnsMetrics.length) {
        return;
      }
      final manager = widget.daviContext.rowExtentManager;
      final vertical = widget.daviContext.scrollControllers.vertical;
      final top = manager.offsetOf(cell.rowIndex);
      final height = manager.heightOf(cell.rowIndex);
      final column = widget.layoutSettings.columnsMetrics[cell.columnIndex];
      final area = widget.layoutSettings.getAreaBounds(column.pinStatus);
      final horizontal = widget.daviContext.scrollControllers
          .getHorizontalController(column.pinStatus);
      final movedVertically =
          _revealInterval(vertical, top, height, widget.maxHeight);
      final movedHorizontally = _revealInterval(
          horizontal, column.offset - area.left, column.width, area.width);
      if (pass > 0 &&
          !movedVertically &&
          !movedHorizontally &&
          _focusTraversal.cells.containsKey(cell)) {
        return;
      }
      await WidgetsBinding.instance.endOfFrame;
    }
  }

  bool _revealInterval(ScrollController controller, double start, double extent,
      double viewport) {
    if (!controller.hasClients || viewport <= 0) return false;
    final offset = controller.offset;
    double target = offset;
    if (start < offset || extent > viewport) {
      target = start;
    } else if (start + extent > offset + viewport) {
      target = start + extent - viewport;
    }
    target = target.clamp(controller.position.minScrollExtent,
        controller.position.maxScrollExtent);
    if ((target - offset).abs() < 0.01) return false;
    controller.jumpTo(target);
    return true;
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
          rowExtentManager: widget.daviContext.rowExtentManager,
          maxHeight: widget.maxHeight,
          maxWidth: widget.maxWidth,
          dataSource: widget.daviContext.dataSource,
          hasTrailing: widget.daviContext.trailingWidget != null,
          rowFillHeight: widget.rowFillHeight);
      // Scrolling into shorter rows can grow the pool too. Mapping listeners
      // update existing slots, but only this build creates the missing ones.
      if (_builtCellCount != _viewportState.maxCellCount) {
        setState(() {});
      }
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
      _builtCellCount = _viewportState.maxCellCount;

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
                focusTraversal: _focusTraversal,
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
          viewportState: _viewportState,
          children: children);
    }

    return ClipRect(
        child: TableEvents(
            daviContext: widget.daviContext,
            rowRegions: _viewportState.rowRegions,
            rowTheme: theme.row,
            layoutSettings: widget.layoutSettings,
            child: FocusTraversalGroup(
                policy: _focusTraversal,
                child: Focus(
                    focusNode: _focusTraversal.parkingNode,
                    skipTraversal: true,
                    child: cells))));
  }
}
