import 'package:davi/davi.dart';
import 'package:davi/src/internal/cell_widget_builder.dart';
import 'package:davi/src/internal/cells_layout.dart';
import 'package:davi/src/internal/cells_layout_child.dart';
import 'package:davi/src/internal/davi_context.dart';
import 'package:davi/src/internal/painter_cache.dart';
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

  /// The vertical offset as of the last time [_onVerticalScrollChange] ran
  /// (whichever path drove it). Used by [_onRowExtentChanged] to detect a
  /// *silent* `ScrollPosition` correction - see there.
  double? _lastKnownVerticalOffset;

  @override
  void initState() {
    super.initState();
    _updatePainterCacheSize();
    _onVerticalScrollChange();
    widget.daviContext.scrollControllers.vertical
        .addListener(_onVerticalScrollChange);
    widget.daviContext.rowExtentManager.addListener(_onRowExtentChanged);
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
    if (oldWidget.daviContext.rowExtentManager !=
        widget.daviContext.rowExtentManager) {
      oldWidget.daviContext.rowExtentManager
          .removeListener(_onRowExtentChanged);
      widget.daviContext.rowExtentManager.addListener(_onRowExtentChanged);
    }
  }

  @override
  void dispose() {
    widget.daviContext.scrollControllers.vertical
        .removeListener(_onVerticalScrollChange);
    widget.daviContext.rowExtentManager.removeListener(_onRowExtentChanged);
    super.dispose();
  }

  /// [RowExtentManager] can shrink the true total content height (a theme
  /// change that resizes rows, or a row's real content finally being
  /// measured) while already scrolled near the end. When that happens,
  /// Flutter's own `ScrollPosition` silently corrects `pixels` during the
  /// `SingleChildScrollView` inside `TableScrollbar`'s layout - but that
  /// correction does NOT call `notifyListeners()` (confirmed: the vertical
  /// `ScrollController`'s own listeners never fire for it, only for a real
  /// user-driven scroll). Since `_onVerticalScrollChange` above only runs
  /// off that listener, nothing re-drives `ViewportState`/row rendering to
  /// pick up the already-corrected offset, leaving a blank gap until the
  /// user scrolls.
  ///
  /// [RowExtentManager] notifies far more often than that rare case though -
  /// once for every row that gets measured for the first time, which
  /// happens continuously during ordinary scrolling. Reacting to every one
  /// of those with a full rebuild previously caused a feedback loop
  /// (rebuild -> relayout -> newly-visible rows get measured -> notify ->
  /// rebuild -> ...), visible as a severe "accordion" jitter. So instead of
  /// reacting unconditionally, this only resyncs when the scroll offset
  /// itself was actually corrected out from under us - comparing the offset
  /// before/after the frame settles, rather than trusting the notification
  /// alone as a signal that something needs fixing.
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
      final ScrollController controller =
          widget.daviContext.scrollControllers.vertical;
      final double currentOffset =
          controller.hasClients ? controller.offset : 0;
      if (_lastKnownVerticalOffset != null &&
          currentOffset != _lastKnownVerticalOffset) {
        // Unlike the plain scroll-position listener (where the cell pool
        // size - maxCellCount - is designed to stay constant across a pure
        // scroll), a content-size change can legitimately change how many
        // rows fit the viewport, so this needs an actual rebuild - not just
        // an internal ViewportState update - to grow/shrink the cell pool.
        setState(_onVerticalScrollChange);
      }
    });
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
    _lastKnownVerticalOffset = verticalOffset;

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
          model: widget.daviContext.model,
          hasTrailing: widget.daviContext.trailingWidget != null,
          rowFillHeight: widget.rowFillHeight);
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
                policy: OrderedTraversalPolicy(), child: cells)));
  }
}
