import 'dart:math' as math;
import 'package:easy_table/src/experimental/layout_v3/table_layout_builder_v3.dart';
import 'package:easy_table/src/experimental/row_callbacks.dart';
import 'package:easy_table/src/experimental/layout_v2/table_layout_builder_v2.dart';
import 'package:easy_table/src/experimental/table_layout_settings.dart';
import 'package:easy_table/src/experimental/table_scroll_controllers.dart';
import 'package:easy_table/src/model.dart';
import 'package:easy_table/src/last_visible_row_listener.dart';
import 'package:easy_table/src/row_callback_typedefs.dart';
import 'package:easy_table/src/row_hover_listener.dart';
import 'package:easy_table/src/theme/theme.dart';
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/gestures.dart';
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
    if (widget.model != null && _hoveredRowIndex != value) {
      setState(() {
        _hoveredRowIndex = value;
        if (widget.onHoverListener != null) {
          widget.onHoverListener!(_hoveredRowIndex);
        }
      });
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

  void _onLastVisibleRowListener(int lastVisibleRowIndex) {
    if (widget.onLastVisibleRowListener != null) {
      if (_lastVisibleRow != lastVisibleRowIndex) {
        _lastVisibleRow = lastVisibleRowIndex;
        Future.microtask(
            () => widget.onLastVisibleRowListener!(lastVisibleRowIndex));
      }
    }
  }

  void _rebuild() {
    setState(() {
      print('rebuild');
    });
  }

  @override
  Widget build(BuildContext context) {
    final EasyTableThemeData theme = EasyTableTheme.of(context);

    TableLayoutSettingsBuilder layoutSettingsBuilder =
        TableLayoutSettingsBuilder(
            theme: theme,
            visibleRowsCount: widget.visibleRowsCount,
            cellContentHeight: widget.cellContentHeight,
            hasHeader: widget.model != null, // TODO allow hide
            rowsLength: widget.model != null ? widget.model!.rowsLength : 0,
            columnsFit: widget.columnsFit,
            offsets: _scrollControllers.offsets);

    Widget table;
    if (true) {
      table = ClipRect(
          child: TableLayoutBuilderV3(
              onHoverListener: _setHoveredRowIndex,
              hoveredRowIndex: _hoveredRowIndex,
              multiSortEnabled: widget.multiSortEnabled,
              layoutSettingsBuilder: layoutSettingsBuilder,
              scrollControllers: _scrollControllers,
              columnsFit: widget.columnsFit,
              cellContentHeight: widget.cellContentHeight,
              visibleRowsLength: widget.visibleRowsCount,
              onLastVisibleRowListener: widget.onLastVisibleRowListener != null
                  ? _onLastVisibleRowListener
                  : null,
              model: widget.model,
              rowCallbacks: _rowCallbacks()));
    } else {
      table = ClipRect(
          child: TableLayoutBuilderV2(
              onHoverListener: _setHoveredRowIndex,
              hoveredRowIndex: _hoveredRowIndex,
              multiSortEnabled: widget.multiSortEnabled,
              layoutSettingsBuilder: layoutSettingsBuilder,
              scrollControllers: _scrollControllers,
              onLastVisibleRowListener: widget.onLastVisibleRowListener != null
                  ? _onLastVisibleRowListener
                  : null,
              model: widget.model,
              rowCallbacks: _rowCallbacks()));
    }

    if (widget.model != null) {
      if (theme.row.hoveredColor != null) {
        table = MouseRegion(
            onExit: (event) => _setHoveredRowIndex(null), child: table);
      }

      if (widget.focusable) {
        table = Focus(
            focusNode: _focusNode,
            onKey: (node, event) =>
                _handleKeyPress(node, event, layoutSettingsBuilder.rowHeight),
            child: table);
        table = Listener(
          child: table,
          onPointerDown: (pointer) {
            _focusNode.requestFocus();
            _focused = true;
          },
          onPointerSignal: (pointerSignal) {
            if (pointerSignal is PointerScrollEvent) {
              _onPointerScroll(pointerSignal, layoutSettingsBuilder.rowHeight);
            }
          },
        );
      }
    }

    if (theme.decoration != null) {
      table = Container(child: table, decoration: theme.decoration);
    }
    return table;
  }

  void _onPointerScroll(PointerScrollEvent event, double rowHeight) {
    if (event.scrollDelta.dy > 0) {
      if (_scrollControllers.vertical.hasClients) {
        double target = math.min(
            _scrollControllers.vertical.position.pixels + rowHeight,
            _scrollControllers.vertical.position.maxScrollExtent);
        _scrollControllers.vertical.animateTo(target,
            duration: const Duration(milliseconds: 30), curve: Curves.ease);
      }
    } else if (event.scrollDelta.dy < 0) {
      if (_scrollControllers.vertical.hasClients) {
        double target = math.max(
            _scrollControllers.vertical.position.pixels - rowHeight, 0);
        _scrollControllers.vertical.animateTo(target,
            duration: const Duration(milliseconds: 30), curve: Curves.ease);
      }
    }
  }

  KeyEventResult _handleKeyPress(
      FocusNode node, RawKeyEvent event, double rowHeight) {
    if (event is RawKeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.tab) {
        if (_focused) {
          _focused = false;
          node.nextFocus();
        } else {
          _focused = true;
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        if (_scrollControllers.vertical.hasClients) {
          double target = math.min(
              _scrollControllers.vertical.position.pixels + rowHeight,
              _scrollControllers.vertical.position.maxScrollExtent);
          _scrollControllers.vertical.animateTo(target,
              duration: const Duration(milliseconds: 30), curve: Curves.ease);
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        if (_scrollControllers.vertical.hasClients) {
          double target = math.max(
              _scrollControllers.vertical.position.pixels - rowHeight, 0);
          _scrollControllers.vertical.animateTo(target,
              duration: const Duration(milliseconds: 30), curve: Curves.ease);
        }
      } else if (event.logicalKey == LogicalKeyboardKey.pageDown) {
        if (_scrollControllers.vertical.hasClients) {
          double target = math.min(
              _scrollControllers.vertical.position.pixels +
                  _scrollControllers.vertical.position.viewportDimension,
              _scrollControllers.vertical.position.maxScrollExtent);
          _scrollControllers.vertical.animateTo(target,
              duration: const Duration(milliseconds: 30), curve: Curves.ease);
        }
      } else if (event.logicalKey == LogicalKeyboardKey.pageUp) {
        if (_scrollControllers.vertical.hasClients) {
          double target = math.max(
              _scrollControllers.vertical.position.pixels -
                  _scrollControllers.vertical.position.viewportDimension,
              0);
          _scrollControllers.vertical.animateTo(target,
              duration: const Duration(milliseconds: 30), curve: Curves.ease);
        }
      }
    }
    return KeyEventResult.handled;
  }

  RowCallbacks? _rowCallbacks() {
    if (widget.onRowTap != null ||
        widget.onRowDoubleTap != null ||
        widget.onRowSecondaryTap != null) {
      return RowCallbacks(
          onRowDoubleTap: _onRowDoubleTap,
          onRowTap: _onRowTap,
          onRowSecondaryTap: _onRowSecondaryTap);
    }
    return null;
  }

  void _onRowTap(int rowIndex) {
    if (widget.onRowTap != null && widget.model != null) {
      widget.onRowTap!(widget.model!.visibleRowAt(rowIndex));
    }
  }

  void _onRowDoubleTap(int rowIndex) {
    if (widget.onRowDoubleTap != null && widget.model != null) {
      widget.onRowDoubleTap!(widget.model!.visibleRowAt(rowIndex));
    }
  }

  void _onRowSecondaryTap(int rowIndex) {
    if (widget.onRowSecondaryTap != null && widget.model != null) {
      widget.onRowSecondaryTap!(widget.model!.visibleRowAt(rowIndex));
    }
  }
}
