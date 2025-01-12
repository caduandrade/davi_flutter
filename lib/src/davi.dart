import 'package:davi/src/column_width_behavior.dart';
import 'package:davi/src/internal/column_notifier.dart';
import 'package:davi/src/internal/davi_context.dart';
import 'package:davi/src/internal/hover_notifier.dart';
import 'package:davi/src/internal/scroll_controllers.dart';
import 'package:davi/src/internal/table_layout_builder.dart';
import 'package:davi/src/internal/theme_metrics/theme_metrics.dart';
import 'package:davi/src/trailing_widget_listener.dart';
import 'package:davi/src/last_visible_row_listener.dart';
import 'package:davi/src/model.dart';
import 'package:davi/src/row_callback_typedefs.dart';
import 'package:davi/src/row_color.dart';
import 'package:davi/src/row_cursor_builder.dart';
import 'package:davi/src/row_hover_listener.dart';
import 'package:davi/src/theme/theme.dart';
import 'package:davi/src/theme/theme_data.dart';
import 'package:flutter/material.dart';

/// Table view designed for a large number of data.
///
/// The type [DATA] represents the data of each row.
class Davi<DATA> extends StatefulWidget {
//TODO handle negative values
//TODO allow null and use defaults?
  const Davi(this.model,
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
      : visibleRowsCount = visibleRowsCount == null || visibleRowsCount > 0
            ? visibleRowsCount
            : null;

  /// The data model.
  final DaviModel<DATA> model;

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
  final int? visibleRowsCount;
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

  final FocusNode _focusNode = FocusNode(debugLabel: 'Davi');

  @override
  void initState() {
    super.initState();
    _scrollControllers = ScrollControllers(
        unpinnedHorizontal: widget.unpinnedHorizontalScrollController,
        leftPinnedHorizontal: widget.leftPinnedHorizontalScrollController,
        vertical: widget.verticalScrollController);
    _hoverNotifier.addListener(_onHover);
    _buildListenable();
  }

  @override
  void dispose() {
    _hoverNotifier.removeListener(_onHover);
    _hoverNotifier.dispose();
    _columnNotifier.dispose();
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
    if (widget.model != oldWidget.model) {
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
    }
  }

  void _buildListenable() {
    _listenable = Listenable.merge([widget.model, _columnNotifier]);
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

    final DaviContext<DATA> daviContext = DaviContext(
        hoverNotifier: _hoverNotifier,
        hasHoverListener: widget.onHover != null,
        columnNotifier: _columnNotifier,
        semanticsEnabled: widget.semanticsEnabled,
        model: widget.model,
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
        visibleRowsCount: widget.visibleRowsCount,
        columnWidthBehavior: widget.columnWidthBehavior,
        themeMetrics: themeMetrics,
        scrollControllers: _scrollControllers);

    return FocusTraversalGroup(
        policy: _NoTraversalPolicy(),
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (pointer) {
            if (widget.model.isRowsNotEmpty && widget.focusable) {
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
