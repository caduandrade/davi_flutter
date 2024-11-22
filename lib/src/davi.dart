import 'package:davi/src/column_width_behavior.dart';
import 'package:davi/src/internal/new/column_notifier.dart';
import 'package:davi/src/internal/new/hover_notifier.dart';
import 'package:davi/src/internal/row_callbacks.dart';
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
      {Key? key,
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
      this.tapToSortEnabled = true,
      this.trailingWidget,
      this.rowColor,
      this.rowCursor,
      this.onTrailingWidget})
      : visibleRowsCount = visibleRowsCount == null || visibleRowsCount > 0
            ? visibleRowsCount
            : null,
        super(key: key);

  final DaviModel<DATA>? model;
  final ScrollController? unpinnedHorizontalScrollController;
  final ScrollController? leftPinnedHorizontalScrollController;
  final ScrollController? verticalScrollController;
  final OnRowHoverListener? onHover;
  final DaviRowColor<DATA>? rowColor;
  final RowCursorBuilder<DATA>? rowCursor;
  final RowDoubleTapCallback<DATA>? onRowDoubleTap;
  final RowTapCallback<DATA>? onRowTap;
  final RowTapCallback<DATA>? onRowSecondaryTap;
  final RowTapUpCallback<DATA>? onRowSecondaryTapUp;
  final ColumnWidthBehavior columnWidthBehavior;
  final int? visibleRowsCount;
  final LastVisibleRowListener? onLastVisibleRow;
  final bool focusable;

  /// An optional widget displayed at the end of the table's content.
  final Widget? trailingWidget;
  final TrailingWidgetListener? onTrailingWidget;

  /// Indicates whether sorting events are enabled on the header.
  final bool tapToSortEnabled;

  @override
  State<StatefulWidget> createState() => _DaviState<DATA>();
}

/// The [Davi] state.
class _DaviState<DATA> extends State<Davi<DATA>> {
  late ScrollControllers _scrollControllers;
  late Listenable _listenable;
  bool _scrolling = false;
  int? _hoveredRowIndex;
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
    _buildListenable();
  }

  @override
  void dispose() {
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
      _buildListenable();
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
    _listenable = Listenable.merge([
      widget.model,
      _columnNotifier,
      _scrollControllers.vertical,
      _scrollControllers.leftPinnedHorizontal,
      _scrollControllers.unpinnedHorizontal
    ]);
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
          decoration: theme.decoration, child: _listenableBuilder());
    }
    return _listenableBuilder();
  }

  Widget _listenableBuilder() {
    return ListenableBuilder(listenable: _listenable, builder: _builder);
  }

  Widget _builder(BuildContext context, Widget? child) {
    final DaviThemeData theme = DaviTheme.of(context);
    final TableThemeMetrics themeMetrics = TableThemeMetrics(theme);
    final RowCallbacks<DATA> rowCallbacks = RowCallbacks(
        onRowTap: widget.onRowTap,
        onRowSecondaryTap: widget.onRowSecondaryTap,
        onRowSecondaryTapUp: widget.onRowSecondaryTapUp,
        onRowDoubleTap: widget.onRowDoubleTap);

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (pointer) {
        if (widget.model != null && widget.focusable) {
          _focusNode.requestFocus();
        }
      },
      child: ClipRect(
          child: TableLayoutBuilder(
              hoverNotifier: _hoverNotifier,
              columnNotifier: _columnNotifier,
              onHover: widget.onHover != null ? _setHoveredRowIndex : null,
              tapToSortEnabled: widget.tapToSortEnabled,
              scrollControllers: _scrollControllers,
              columnWidthBehavior: widget.columnWidthBehavior,
              themeMetrics: themeMetrics,
              visibleRowsLength: widget.visibleRowsCount,
              onTrailingWidget: _onTrailingWidget,
              onLastVisibleRow: _onLastVisibleRowListener,
              model: widget.model,
              scrolling: _scrolling,
              rowColor: widget.rowColor,
              rowCursorBuilder: widget.rowCursor,
              focusable: widget.focusable,
              focusNode: _focusNode,
              trailingWidget: widget.trailingWidget,
              rowCallbacks: rowCallbacks,
              onDragScroll: _onDragScroll)),
    );
  }

  void _setHoveredRowIndex(int? rowIndex) {
    if (widget.model != null && _hoveredRowIndex != rowIndex) {
      _hoveredRowIndex = rowIndex;
      if (widget.onHover != null) {
        widget.onHover!(_hoveredRowIndex);
      }
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
