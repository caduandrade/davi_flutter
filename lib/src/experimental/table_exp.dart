import 'dart:math' as math;
import 'package:easy_table/src/experimental/table_layout_builder.dart';
import 'package:easy_table/src/experimental/table_layout_settings.dart';
import 'package:easy_table/src/experimental/table_scroll_controllers.dart';
import 'package:easy_table/src/internal/columns_metrics.dart';
import 'package:easy_table/src/internal/horizontal_scroll_bar.dart';
import 'package:easy_table/src/internal/table_area_content_widget.dart';
import 'package:easy_table/src/internal/table_area_layout.dart';
import 'package:easy_table/src/internal/table_header_widget.dart';
import 'package:easy_table/src/internal/table_layout.dart';
import 'package:easy_table/src/internal/vertical_scroll_bar.dart';
import 'package:easy_table/src/model.dart';
import 'package:easy_table/src/last_visible_row_listener.dart';
import 'package:easy_table/src/row_callbacks.dart';
import 'package:easy_table/src/row_hover_listener.dart';
import 'package:easy_table/src/internal/table_scrolls.dart';
import 'package:easy_table/src/theme/header_theme_data.dart';
import 'package:easy_table/src/theme/theme.dart';
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Table view designed for a large number of data.
///
/// The type [ROW] represents the data of each row.
/// The [cellContentHeight] is mandatory due to performance.
/// The total height of the cell will be the sum of the [cellContentHeight]
/// value, divider thickness, and cell margin.
class EasyTableExp<ROW> extends StatefulWidget {
//TODO handle negative values
//TODO allow null and use defaults?
  const EasyTableExp(this.model,
      {Key? key,
      this.onHoverListener,
      this.onLastVisibleRowListener,
      this.onRowTap,
      this.onRowSecondaryTap,
      this.onRowDoubleTap,
      this.columnsFit = false,
      int? visibleRowsCount,
      this.cellContentHeight = 32,
      this.focusable = true,
      this.multiSortEnabled = false})
      : _visibleRowsCount = visibleRowsCount == null || visibleRowsCount > 0
            ? visibleRowsCount
            : null,
        super(key: key);

  final EasyTableModel<ROW>? model;
  final OnRowHoverListener? onHoverListener;
  final RowDoubleTapCallback<ROW>? onRowDoubleTap;
  final RowTapCallback<ROW>? onRowTap;
  final RowTapCallback<ROW>? onRowSecondaryTap;
  final bool columnsFit;
  final int? _visibleRowsCount;
  final double cellContentHeight;
  final OnLastVisibleRowListener? onLastVisibleRowListener;
  final bool focusable;
  final bool multiSortEnabled;

  int? get visibleRowsCount => _visibleRowsCount;

  @override
  State<StatefulWidget> createState() => _EasyTableExpState<ROW>();
}

/// The [EasyTableExp] state.
class _EasyTableExpState<ROW> extends State<EasyTableExp<ROW>> {
  final TableScrollControllers _scrollControllers = TableScrollControllers();

  int? _hoveredRowIndex;

  int _lastVisibleRow = -1;
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  void _setHoveredRowIndex(int? value) {
    if (_hoveredRowIndex != value) {
      setState(() {
        _hoveredRowIndex = value;
      });
      if (widget.onHoverListener != null) {
        widget.onHoverListener!(_hoveredRowIndex);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    widget.model?.addListener(_rebuild);
    _scrollControllers.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.model?.dispose();
    _focusNode.dispose();
    _scrollControllers.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant EasyTableExp<ROW> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model?.removeListener(_rebuild);
      widget.model?.addListener(_rebuild);
    }
  }

  void _rebuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final EasyTableThemeData theme = EasyTableTheme.of(context);

    TableLayoutSettings layoutSettings = TableLayoutSettings(
        theme: theme,
        visibleRowsCount: widget.visibleRowsCount,
        cellContentHeight: widget.cellContentHeight,
        hasHeader: true, // TODO allow hide
        hasVerticalScrollbar: true, // TODO allow hide
        columnsFit: widget.columnsFit,
        verticalScrollbarOffset:_scrollControllers.verticalOffset);

    Widget table = ClipRect(
        child: TableLayoutBuilder(
            layoutSettings: layoutSettings,
            scrollControllers: _scrollControllers,
            model: widget.model));

    if (widget.focusable) {
      table = Focus(
          focusNode: _focusNode,
          onKey: (node, event) => _handleKeyPress(node, event, layoutSettings),
          child: table);
      table = Listener(
          child: table,
          onPointerDown: (pointer) {
            _focusNode.requestFocus();
            _focused = true;
          });
    }

    if (theme.decoration != null) {
      table = Container(child: table, decoration: theme.decoration);
    }
    return table;
  }

  KeyEventResult _handleKeyPress(
      FocusNode node, RawKeyEvent event, TableLayoutSettings layoutSettings) {
    // layoutSettings - dividerThickness + rowHeight
    if (event is RawKeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.tab) {
        if (_focused) {
          _focused = false;
          node.nextFocus();
        } else {
          _focused = true;
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      } else if (event.logicalKey == LogicalKeyboardKey.pageDown) {
      } else if (event.logicalKey == LogicalKeyboardKey.pageUp) {}
    }
    return KeyEventResult.handled;
  }
}
