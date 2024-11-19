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
      this.pinnedHorizontalScrollController,
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
  final ScrollController? pinnedHorizontalScrollController;
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
  bool _scrolling = false;
  int? _hoveredRowIndex;
  bool _lastRowWidgetVisible = false;
  int? _lastVisibleRow;
  final HoverNotifier _hoverNotifier = HoverNotifier();
  final ColumnNotifier _columnNotifier= ColumnNotifier();

  final FocusNode _focusNode = FocusNode(debugLabel: 'Davi');

  void _setHoveredRowIndex(int? rowIndex) {
    if (widget.model != null && _hoveredRowIndex != rowIndex) {
      _hoveredRowIndex = rowIndex;
      if (widget.onHover != null) {
        widget.onHover!(_hoveredRowIndex);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollControllers = ScrollControllers(
        unpinnedHorizontal: widget.unpinnedHorizontalScrollController,
        leftPinnedHorizontal: widget.pinnedHorizontalScrollController,
        vertical: widget.verticalScrollController);
    _scrollControllers.unpinnedHorizontal.addListener(_rebuild);
    _scrollControllers.leftPinnedHorizontal.addListener(_rebuild);
    widget.model?.addListener(_rebuild);
  }

  @override
  void dispose() {
    _scrollControllers.unpinnedHorizontal.removeListener(_rebuild);
    _scrollControllers.leftPinnedHorizontal.removeListener(_rebuild);
    widget.model?.removeListener(_rebuild);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant Davi<DATA> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.verticalScrollController != null &&
        _scrollControllers.vertical != widget.verticalScrollController) {
      _scrollControllers.vertical = widget.verticalScrollController!;
    }
    if (widget.unpinnedHorizontalScrollController != null &&
        _scrollControllers.unpinnedHorizontal !=
            widget.unpinnedHorizontalScrollController) {
      _scrollControllers.unpinnedHorizontal.removeListener(_rebuild);
      _scrollControllers.unpinnedHorizontal =
          widget.unpinnedHorizontalScrollController!;
      _scrollControllers.unpinnedHorizontal.addListener(_rebuild);
    }
    if (widget.pinnedHorizontalScrollController != null &&
        _scrollControllers.leftPinnedHorizontal !=
            widget.pinnedHorizontalScrollController) {
      _scrollControllers.leftPinnedHorizontal.removeListener(_rebuild);
      _scrollControllers.leftPinnedHorizontal =
          widget.pinnedHorizontalScrollController!;
      _scrollControllers.leftPinnedHorizontal.addListener(_rebuild);
    }
    if (widget.model != oldWidget.model) {
      oldWidget.model?.removeListener(_rebuild);
      widget.model?.addListener(_rebuild);
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

  void _rebuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final DaviThemeData theme = DaviTheme.of(context);

    final TableThemeMetrics themeMetrics = TableThemeMetrics(theme);

    //TODO need this cliprect?
    Widget table = ClipRect(
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
            rowCallbacks: RowCallbacks(
                onRowTap: widget.onRowTap,
                onRowSecondaryTap: widget.onRowSecondaryTap,
                onRowSecondaryTapUp: widget.onRowSecondaryTapUp,
                onRowDoubleTap: widget.onRowDoubleTap),
            onDragScroll: _onDragScroll));

    if (widget.model != null) {
            table = Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (pointer) {
          if (widget.focusable) {
            _focusNode.requestFocus();
          }
        },
        child: table,
      );
    }

    if (theme.decoration != null) {
      table = Container(decoration: theme.decoration, child: table);
    }

    if (theme.cell.overrideInputDecoration) {
      table = Theme(
          data: ThemeData(
              inputDecorationTheme: const InputDecorationTheme(
                  isDense: true, border: InputBorder.none)),
          child: table);
    }

    return table;
  }

  void _onDragScroll(bool running) {
    _hoverNotifier.enabled = !running;
    setState(() => _scrolling = running);
  }
}
