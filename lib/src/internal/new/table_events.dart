import 'dart:math' as math;

import 'package:davi/davi.dart';
import 'package:davi/src/internal/new/hover_notifier.dart';
import 'package:davi/src/internal/new/row_region.dart';
import 'package:davi/src/internal/row_callbacks.dart';
import 'package:davi/src/internal/theme_metrics/theme_metrics.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

@internal
class TableEvents<DATA> extends StatelessWidget {
  const TableEvents(
      {Key? key,
      required this.model,
      required this.onHover,
      required this.rowCallbacks,
      required this.focusable,
      required this.rowCursorBuilder,
      required this.child,
      required this.verticalScrollController,
      required this.scrolling,
      required this.hoverIndex,
      required this.focusNode,
      required this.rowBoundsCache,
      required this.rowTheme})
      : super(key: key);

  final Widget child;
  final DaviModel<DATA>? model;
  final OnRowHoverListener? onHover;
  final RowCursorBuilder<DATA>? rowCursorBuilder;
  final RowCallbacks<DATA> rowCallbacks;

  final bool focusable;
  final RowRegionCache rowBoundsCache;

  final ScrollController verticalScrollController;
  //TODO remove? disable key?
  final bool scrolling;

  final HoverNotifier hoverIndex;
  final FocusNode focusNode;
  
  final RowThemeData rowTheme;

  @override
  Widget build(BuildContext context) {
    final DaviThemeData theme = DaviTheme.of(context);

    Widget widget = child;

    if (model != null) {
      if (theme.row.hoverBackground != null ||
          theme.row.hoverForeground != null) {
        widget = MouseRegion(
            onEnter: _onEnter,
            onHover: _onHover,
            onExit: _onExit,
            child: widget);
      }

      if(rowCallbacks.hasCallback){
        widget=GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _buildOnTap(),
            onDoubleTap: _buildOnDoubleTap(),
            onSecondaryTap: _buildOnSecondaryTap(),
            onSecondaryTapUp: _buildOnSecondaryTapUp(),
            child: widget);
      }

      widget = Listener(
        behavior: HitTestBehavior.translucent,
        onPointerSignal: _onPointerSignal,
        onPointerPanZoomUpdate: _onPointerPanZoomUpdate,
        child: widget
      );

      if (focusable) {
        //TODO from parent?
        final TableThemeMetrics themeMetrics = TableThemeMetrics(theme);

        widget = Focus(
            focusNode: focusNode,
            onKeyEvent: (node, event) =>
                _handleKeyPress(node, event, themeMetrics.row.height),
            child: widget);
      }
    }
    return widget;
  }

  void _onEnter(PointerEnterEvent event) {
    _updateHover(event.localPosition);
  }

  void _onHover(PointerHoverEvent event) {
    _updateHover(event.localPosition);
  }

  void _onExit(PointerExitEvent event) {
    _updateHover(null);
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent &&
        verticalScrollController.hasClients &&
        event.scrollDelta.dy != 0) {
      verticalScrollController.position.pointerScroll(event.scrollDelta.dy);
    }
  }

  void _onPointerPanZoomUpdate(PointerPanZoomUpdateEvent event) {
    // trackpad on macOS
    if (verticalScrollController.hasClients && event.panDelta.dy != 0) {
      verticalScrollController.position.pointerScroll(-event.panDelta.dy);
    }
  }

  void _updateHover(Offset? position) {
    if(model!=null) {
      int? rowIndex;
      if(position!=null) {
        rowIndex = rowBoundsCache.boundsIndex(position);
      }
      DATA? data;
        if(model!=null && rowIndex!=null &&rowIndex< model!.rowsLength) {
          data = model?.rowAt(rowIndex);
        }
      if (data != null) {
        hoverIndex.cursor = _buildCursor(data: data,
                index: rowIndex!,
                hovered: hoverIndex.index == rowIndex);
      } else {
        // hover over visual row without value
        rowIndex=null;
      }
      hoverIndex.index = rowIndex;
      if (onHover != null) {
        onHover!(hoverIndex.index);
      }
    }
  }

  MouseCursor _buildCursor({required DATA data, required int index,required bool hovered}) {
    if (!rowTheme.cursorOnTapGesturesOnly || rowCallbacks.hasCallback) {
      MouseCursor? mouseCursor;
      if (rowCursorBuilder != null) {
        mouseCursor = rowCursorBuilder!(data,index,hovered);
      }
      return mouseCursor ?? rowTheme.cursor;
    }
    return MouseCursor.defer;
  }


  DATA? get _hoverData {
    DATA? data;
    if(hoverIndex.index!=null) {
      if(model!=null &&hoverIndex.index!< model!.rowsLength) {
        data = model?.rowAt(hoverIndex.index!);
      }
    }
    return data;
  }

  GestureTapCallback? _buildOnTap() {
    if (rowCallbacks.onRowTap != null) {
      return () {        
        DATA? data = _hoverData;
        if(data!=null) {
          rowCallbacks.onRowTap!(data);
        }
      };
    }
    return null;
  }

  GestureTapCallback? _buildOnDoubleTap() {
    if (rowCallbacks.onRowDoubleTap != null) {
      return () {
        DATA? data = _hoverData;
        if(data!=null) {
          rowCallbacks.onRowDoubleTap!(data);
        }
      };
    }
    return null;
  }

  GestureTapCallback? _buildOnSecondaryTap() {
    if (rowCallbacks.onRowSecondaryTap != null) {
      return () {
        DATA? data = _hoverData;
        if (data != null) {
          rowCallbacks.onRowSecondaryTap!(data);
        }
      };
    }
    return null;
  }

  GestureTapUpCallback? _buildOnSecondaryTapUp() {
    if (rowCallbacks.onRowSecondaryTapUp != null) {
      return (detail) {
        DATA? data = _hoverData;
        if(data!=null) {
          rowCallbacks.onRowSecondaryTapUp!(data, detail);
        }
      };
    }
    return null;
  }

  KeyEventResult _handleKeyPress(
      FocusNode node, KeyEvent event, double rowHeight) {
    if (event is KeyUpEvent) {
      if (verticalScrollController.hasClients) {
        if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          double target = math.min(
              verticalScrollController.position.pixels + rowHeight,
              verticalScrollController.position.maxScrollExtent);
          verticalScrollController.animateTo(target,
              duration: const Duration(milliseconds: 30), curve: Curves.ease);
        } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          double target = math.max(
              verticalScrollController.position.pixels - rowHeight, 0);
          verticalScrollController.animateTo(target,
              duration: const Duration(milliseconds: 30), curve: Curves.ease);
        } else if (event.logicalKey == LogicalKeyboardKey.pageDown) {
          double target = math.min(
              verticalScrollController.position.pixels +
                  verticalScrollController.position.viewportDimension,
              verticalScrollController.position.maxScrollExtent);
          verticalScrollController.animateTo(target,
              duration: const Duration(milliseconds: 30), curve: Curves.ease);
        } else if (event.logicalKey == LogicalKeyboardKey.pageUp) {
          double target = math.max(
              verticalScrollController.position.pixels -
                  verticalScrollController.position.viewportDimension,
              0);
          verticalScrollController.animateTo(target,
              duration: const Duration(milliseconds: 30), curve: Curves.ease);
        }
      }
    }
    return KeyEventResult.ignored;
  }
}
