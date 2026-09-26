import 'package:davi/src/column_width_behavior.dart';
import 'package:davi/src/controller.dart';
import 'package:davi/src/data_source.dart';
import 'package:davi/src/internal/builder_data_source.dart';
import 'package:davi/src/internal/column_auto_sizer.dart';
import 'package:davi/src/internal/column_notifier.dart';
import 'package:davi/src/internal/davi_context.dart';
import 'package:davi/src/internal/hover_notifier.dart';
import 'package:davi/src/internal/row_extent_manager.dart';
import 'package:davi/src/internal/scroll_controllers.dart';
import 'package:davi/src/internal/table_layout_builder.dart';
import 'package:davi/src/internal/theme_metrics/theme_metrics.dart';
import 'package:davi/src/last_visible_row_listener.dart';
import 'package:davi/src/model.dart';
import 'package:davi/src/row_callback_typedefs.dart';
import 'package:davi/src/row_color.dart';
import 'package:davi/src/row_cursor_builder.dart';
import 'package:davi/src/row_hover_listener.dart';
import 'package:davi/src/sort_callback_typedef.dart';
import 'package:davi/src/theme/theme.dart';
import 'package:davi/src/theme/theme_data.dart';
import 'package:davi/src/trailing_widget_listener.dart';
import 'package:flutter/material.dart';

/// Table view designed for a large number of data.
///
/// The type [DATA] represents the data of each row.
class Davi<DATA> extends StatefulWidget {
//TODO handle negative values
//TODO allow null and use defaults?
  /// Creates a [Davi] in model mode: the table owns its data through
  /// [model], including (unless disabled) its own sorting.
  const Davi(DaviModel<DATA> this.model,
      {super.key,
      this.onHover,
      this.unpinnedHorizontalScrollController,
      this.leftPinnedHorizontalScrollController,
      this.verticalScrollController,
      this.onLastVisibleRow,
      this.onRowTap,
      this.onRowSecondaryTap,
      this.onRowSecondaryTapUp,
      this.onRowDoubleTap,
      this.columnWidthBehavior = ColumnWidthBehavior.scrollable,
      int? visibleRowsCount,
      this.focusable = true,
      this.trailingWidget,
      this.placeholderWidget,
      this.rowColor,
      this.rowCursor,
      this.semanticsEnabled = false,
      this.onTrailingWidget})
      : controller = null,
        rows = null,
        onSort = null,
        visibleRowsCount = visibleRowsCount == null || visibleRowsCount > 0
            ? visibleRowsCount
            : null;

  /// Creates a [Davi] in builder mode: rows are supplied directly (an
  /// external source, e.g. a Bloc/ChangeNotifier, is the source of truth
  /// for both the data and its order), while [controller] only keeps the
  /// state of the columns (order, size, and the *visual* sort state).
  ///
  /// Tapping a sortable header never reorders [rows] by itself: it calls
  /// [onSort] with the requested sort configuration, and it's up to
  /// whoever owns the data to honor it (or not) and rebuild with new
  /// [rows]. If [onSort] is `null`, sorting is treated as disabled since
  /// nothing would apply the requested order.
  const Davi.builder(
      {super.key,
      required DaviController<DATA> this.controller,
      this.rows = const [],
      this.onSort,
      this.onHover,
      this.unpinnedHorizontalScrollController,
      this.leftPinnedHorizontalScrollController,
      this.verticalScrollController,
      this.onLastVisibleRow,
      this.onRowTap,
      this.onRowSecondaryTap,
      this.onRowSecondaryTapUp,
      this.onRowDoubleTap,
      this.columnWidthBehavior = ColumnWidthBehavior.scrollable,
      int? visibleRowsCount,
      this.focusable = true,
      this.trailingWidget,
      this.placeholderWidget,
      this.rowColor,
      this.rowCursor,
      this.semanticsEnabled = false,
      this.onTrailingWidget})
      : model = null,
        visibleRowsCount = visibleRowsCount == null || visibleRowsCount > 0
            ? visibleRowsCount
            : null;

  /// The data model used in model mode (the default constructor).
  /// `null` when using [Davi.builder].
  final DaviModel<DATA>? model;

  /// The controller used in builder mode ([Davi.builder]), holding only the
  /// state of the columns (order, size, visual sort state). `null` when
  /// using the default (model mode) constructor.
  final DaviController<DATA>? controller;

  /// The rows to display in builder mode ([Davi.builder]). Ignored in
  /// model mode, where rows come from [model].
  ///
  /// Like `ListView.builder`'s `itemCount`/`itemBuilder`, pass a new (or
  /// updated) value and rebuild whenever the data changes; don't mutate
  /// the same [List] in place, since parts of the table read from it
  /// between rebuilds (e.g. on a repaint triggered by scrolling,
  /// hovering or resizing a column).
  final Iterable<DATA>? rows;

  /// Called with the requested sort configuration when the user taps a
  /// sortable header, only used in builder mode ([Davi.builder]). If
  /// `null`, sorting is treated as disabled.
  final OnSortCallback<DATA>? onSort;

  /// The horizontal scroll controller for the unpinned area of the table.
  /// It controls the scrolling behavior of the section that is unpinned.
  final ScrollController? unpinnedHorizontalScrollController;

  /// The horizontal scroll controller for the left pinned area of the table.
  /// It controls the scrolling behavior of the section that is pinned to the left.
  final ScrollController? leftPinnedHorizontalScrollController;

  /// The vertical scroll controller for the table, allowing programmatic control of vertical scrolling.
  final ScrollController? verticalScrollController;

  /// A callback that is triggered when a row is hovered over.
  final OnRowHoverListener? onHover;

  /// A callback that defines the row color based on the row data.
  final DaviRowColor<DATA>? rowColor;

  /// A callback to build a custom cursor when hovering over a row.
  final RowCursorBuilder<DATA>? rowCursor;

  /// A callback that is triggered when a row is double-tapped.
  final RowDoubleTapCallback<DATA>? onRowDoubleTap;

  /// A callback that is triggered when a row is tapped.
  final RowTapCallback<DATA>? onRowTap;

  /// A callback that is triggered when a row receives a secondary tap (usually right-click).
  final RowTapCallback<DATA>? onRowSecondaryTap;

  /// A callback that is triggered when a secondary tap (usually right-click) is released over a row.
  final RowTapUpCallback<DATA>? onRowSecondaryTapUp;

  /// Defines column width behavior.
  final ColumnWidthBehavior columnWidthBehavior;

  /// The number of visible rows currently displayed in the table.
  /// It is particularly useful when the table has an unbounded height,
  /// as it helps determine the number of rows currently visible in the view.
  final int? visibleRowsCount;

  /// A callback that is triggered when the last visible row in the table is rendered.
  /// This can be used to perform actions when the table reaches its last visible row.
  final LastVisibleRowListener? onLastVisibleRow;

  /// Defines whether the component is focusable.
  final bool focusable;

  /// An optional widget displayed at the end of the table's content.
  final Widget? trailingWidget;

  /// A callback that is triggered when the trailing widget appears in the table.
  final TrailingWidgetListener? onTrailingWidget;

  /// Activates semantics by adding a Semantics widget internally,
  /// but it may degrade performance.
  final bool semanticsEnabled;

  /// An optional widget that replaces the body of the table
  /// with a temporary visual element. It can be used to display a custom
  /// state or visual indication, such as during
  /// loading or other transitional states.
  final Widget? placeholderWidget;

  @override
  State<StatefulWidget> createState() => _DaviState<DATA>();
}

/// The [Davi] state.
class _DaviState<DATA> extends State<Davi<DATA>> {
  late ScrollControllers _scrollControllers;
  late Listenable _listenable;
  bool _scrolling = false;
  bool _lastRowWidgetVisible = false;
  int? _lastVisibleRow;
  final HoverNotifier _hoverNotifier = HoverNotifier();
  final ColumnNotifier _columnNotifier = ColumnNotifier();
  final RowExtentManager _rowExtentManager = RowExtentManager();
  final ColumnAutoSizer _autoSizer = ColumnAutoSizer();
  double? _lastDividerThickness;
  double? _lastEstimatedHeight;
  Object? _lastDataSourceOwner;
  BuilderDataSource<DATA>? _builderDataSource;

  final FocusNode _focusNode = FocusNode(debugLabel: 'Davi');

  /// The data source consumed by the internal widgets, regardless of mode:
  /// [widget.model] in model mode, or an adapter around
  /// [widget.controller] and [widget.rows] in builder mode.
  DaviDataSource<DATA> get _dataSource => widget.model ?? _builderDataSource!;

  @override
  void initState() {
    super.initState();
    _scrollControllers = ScrollControllers(
        unpinnedHorizontal: widget.unpinnedHorizontalScrollController,
        leftPinnedHorizontal: widget.leftPinnedHorizontalScrollController,
        vertical: widget.verticalScrollController);
    _hoverNotifier.addListener(_onHover);
    _initBuilderDataSource();
    _buildListenable();
  }

  @override
  void dispose() {
    _hoverNotifier.removeListener(_onHover);
    _hoverNotifier.dispose();
    _columnNotifier.dispose();
    _rowExtentManager.dispose();
    _autoSizer.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant Davi<DATA> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_scrollControllers.update(
        unpinnedHorizontal: widget.unpinnedHorizontalScrollController,
        leftPinnedHorizontal: widget.leftPinnedHorizontalScrollController,
        vertical: widget.verticalScrollController)) {
      setState(() {
        // rebuild subtree with the new scroll controllers.
      });
    }
    final bool dataSourceOwnerChanged = widget.model != oldWidget.model ||
        widget.controller != oldWidget.controller;
    if (dataSourceOwnerChanged) {
      // A genuinely different table (different model/controller instance):
      // rebuild the data source and reset scroll, same as a model swap.
      _initBuilderDataSource();
      _buildListenable();
      if (_scrollControllers.vertical.hasClients) {
        _scrollControllers.vertical.jumpTo(0);
      }
      if (_scrollControllers.leftPinnedHorizontal.hasClients) {
        _scrollControllers.leftPinnedHorizontal.jumpTo(0);
      }
      if (_scrollControllers.unpinnedHorizontal.hasClients) {
        _scrollControllers.unpinnedHorizontal.jumpTo(0);
      }
    } else if (widget.controller != null) {
      // Builder mode, same controller: only the rows (and/or onSort) may
      // have changed, which is the normal case on every external rebuild.
      // Keep the adapter's identity so listener registrations made against
      // it by internal widgets stay valid.
      _builderDataSource!.updateRows(widget.rows ?? const []);
      _builderDataSource!.onSort = widget.onSort;
    }
  }

  void _initBuilderDataSource() {
    final DaviController<DATA>? controller = widget.controller;
    _builderDataSource = controller != null
        ? BuilderDataSource<DATA>(
            controller: controller,
            rows: widget.rows ?? const [],
            onSort: widget.onSort)
        : null;
  }

  void _buildListenable() {
    final Listenable owner = widget.model ?? widget.controller!;
    _listenable = Listenable.merge([owner, _columnNotifier]);
  }

  @override
  Widget build(BuildContext context) {
    final DaviThemeData theme = DaviTheme.of(context);
    if (theme.cell.overrideInputDecoration) {
      return Theme(
          data: ThemeData(
              inputDecorationTheme: const InputDecorationTheme(
                  isDense: true, border: InputBorder.none)),
          child: _decoratedContainer(context));
    }
    return _decoratedContainer(context);
  }

  Widget _decoratedContainer(BuildContext context) {
    final DaviThemeData theme = DaviTheme.of(context);
    if (theme.decoration != null) {
      return Container(
          decoration: theme.decoration, child: _placeholder(context));
    }
    return _placeholder(context);
  }

  Widget _placeholder(BuildContext context) {
    if (widget.placeholderWidget != null) {
      return widget.placeholderWidget!;
    }
    return _cursorBugWorkaround(context);
  }

  Widget _cursorBugWorkaround(BuildContext context) {
    final DaviThemeData theme = DaviTheme.of(context);
    if (theme.decoration?.color != null) {
      return _listenableBuilder();
    }
    // To avoid the bug that makes a cursor disappear
    // (https://github.com/flutter/flutter/issues/106767),
    // always build a Container with some color.
    return Container(color: Colors.transparent, child: _listenableBuilder());
  }

  Widget _listenableBuilder() {
    return ListenableBuilder(listenable: _listenable, builder: _builder);
  }

  Widget _builder(BuildContext context, Widget? child) {
    final DaviThemeData theme = DaviTheme.of(context);
    final TableThemeMetrics themeMetrics = TableThemeMetrics(theme);
    final DaviDataSource<DATA> dataSource = _dataSource;
    final Object dataSourceOwner = widget.model ?? widget.controller!;

    final int rowsLength =
        dataSource.rowsLength + (widget.trailingWidget != null ? 1 : 0);
    if (_rowExtentManager.rowsLength != rowsLength ||
        !identical(_lastDataSourceOwner, dataSourceOwner)) {
      // Structural change (row count, or a different model/controller
      // instance entirely): the data underneath every index may now be
      // different, so every measurement is discarded and re-measured as
      // rows scroll back into view.
      _rowExtentManager.resize(
          rowsLength: rowsLength,
          estimatedHeight: theme.row.estimatedHeight,
          dividerThickness: theme.row.dividerThickness);
      _lastDataSourceOwner = dataSourceOwner;
      _lastDividerThickness = theme.row.dividerThickness;
      _lastEstimatedHeight = theme.row.estimatedHeight;
    } else if (_lastDividerThickness != theme.row.dividerThickness ||
        _lastEstimatedHeight != theme.row.estimatedHeight) {
      // Only the geometry changed - the same rows are still showing the
      // same data, so real measurements stay valid; only rows that were
      // never actually measured get reseeded to the new estimate.
      _rowExtentManager.updateGeometry(
          estimatedHeight: theme.row.estimatedHeight,
          dividerThickness: theme.row.dividerThickness);
      _lastDividerThickness = theme.row.dividerThickness;
      _lastEstimatedHeight = theme.row.estimatedHeight;
    }

    _autoSizer.update(
        dataSource: dataSource,
        enabled: widget.columnWidthBehavior == ColumnWidthBehavior.scrollable);

    final DaviContext<DATA> daviContext = DaviContext(
        hoverNotifier: _hoverNotifier,
        hasHoverListener: widget.onHover != null,
        columnNotifier: _columnNotifier,
        semanticsEnabled: widget.semanticsEnabled,
        dataSource: dataSource,
        onLastVisibleRow: _onLastVisibleRowListener,
        onTrailingWidget: _onTrailingWidget,
        rowColor: widget.rowColor,
        focusable: widget.focusable,
        focusNode: _focusNode,
        rowCursorBuilder: widget.rowCursor,
        trailingWidget: widget.trailingWidget,
        onRowTap: widget.onRowTap,
        onRowSecondaryTap: widget.onRowSecondaryTap,
        onRowSecondaryTapUp: widget.onRowSecondaryTapUp,
        onRowDoubleTap: widget.onRowDoubleTap,
        scrolling: _scrolling,
        onDragScroll: _onDragScroll,
        visibleRowsCount: widget.visibleRowsCount,
        columnWidthBehavior: widget.columnWidthBehavior,
        themeMetrics: themeMetrics,
        rowExtentManager: _rowExtentManager,
        autoSizer: _autoSizer,
        scrollControllers: _scrollControllers);

    return FocusTraversalGroup(
        policy: _NoTraversalPolicy(),
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (pointer) {
            if (dataSource.isRowsNotEmpty && widget.focusable) {
              _focusNode.requestFocus();
            }
          },
          child: ClipRect(
              child: TableLayoutBuilder(
                  daviContext: daviContext, onDragScroll: _onDragScroll)),
        ));
  }

  void _onHover() {
    if (widget.onHover != null) {
      widget.onHover!(_hoverNotifier.index);
    }
  }

  void _onTrailingWidget(bool visible) {
    if (widget.onTrailingWidget != null) {
      if (_lastRowWidgetVisible != visible) {
        _lastRowWidgetVisible = visible;
        Future.microtask(() => widget.onTrailingWidget!(_lastRowWidgetVisible));
      }
    }
  }

  void _onLastVisibleRowListener(int? lastVisibleRowIndex) {
    if (widget.onLastVisibleRow != null) {
      if (_lastVisibleRow != lastVisibleRowIndex) {
        _lastVisibleRow = lastVisibleRowIndex;
        Future.microtask(() => widget.onLastVisibleRow!(lastVisibleRowIndex));
      }
    }
  }

  void _onDragScroll(bool running) {
    _hoverNotifier.enabled = !running;
    setState(() => _scrolling = running);
  }
}

class _NoTraversalPolicy extends FocusTraversalPolicy {
  @override
  FocusNode? findFirstFocusInDirection(
          FocusNode currentNode, TraversalDirection direction) =>
      null;

  @override
  bool inDirection(FocusNode currentNode, TraversalDirection direction) =>
      false;

  @override
  Iterable<FocusNode> sortDescendants(
          Iterable<FocusNode> descendants, FocusNode currentNode) =>
      descendants;
}
