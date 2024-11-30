import 'dart:math' as math;

import 'package:davi/davi.dart';
import 'package:davi/src/internal/new/davi_context.dart';
import 'package:davi/src/internal/new/row_region.dart';
import 'package:davi/src/internal/theme_metrics/theme_metrics.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

@internal
class TableEvents<DATA> extends StatelessWidget {
  const TableEvents(
      {Key? key,
      required this.daviContext,
      required this.child,
      required this.verticalScrollController,
      required this.rowBoundsCache,
      required this.rowTheme})
      : super(key: key);

  final Widget child;
  final DaviContext<DATA> daviContext;

  final RowRegionCache rowBoundsCache;

  final ScrollController verticalScrollController;

  final RowThemeData rowTheme;

  @override
  Widget build(BuildContext context) {
    final DaviThemeData theme = DaviTheme.of(context);

    Widget widget = child;

    if (daviContext.model.isRowsNotEmpty) {
      if (theme.row.hoverBackground != null ||
          theme.row.hoverForeground != null) {
        widget = MouseRegion(
            onEnter: _onEnter,
            onHover: _onHover,
            onExit: _onExit,
            child: widget);
      }

      if (daviContext.hasCallback) {
        widget = GestureDetector(
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
          child: widget);

      if (daviContext.focusable) {
        final TableThemeMetrics themeMetrics = TableThemeMetrics(theme);

        widget = Focus(
            focusNode: daviContext.focusNode,
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
    if (daviContext.model.isRowsNotEmpty) {
      int? rowIndex;
      if (position != null) {
        rowIndex = rowBoundsCache.boundsIndex(position);
      }
      DATA? data;
      if (rowIndex != null && rowIndex < daviContext.model.rowsLength) {
        data = daviContext.model.rowAt(rowIndex);
      }
      if (data != null) {
        daviContext.hoverNotifier.cursor = _buildCursor(
            data: data,
            index: rowIndex!,
            hovered: daviContext.hoverNotifier.index == rowIndex);
      } else {
        // hover over visual row without value
        rowIndex = null;
      }
      daviContext.hoverNotifier.index = rowIndex;
    }
  }

  MouseCursor _buildCursor(
      {required DATA data, required int index, required bool hovered}) {
    if (!rowTheme.cursorOnTapGesturesOnly || daviContext.hasCallback) {
      MouseCursor? mouseCursor;
      if (daviContext.rowCursorBuilder != null) {
        mouseCursor = daviContext.rowCursorBuilder!(data, index, hovered);
      }
      return mouseCursor ?? rowTheme.cursor;
    }
    return MouseCursor.defer;
  }

  DATA? get _hoverData {
    DATA? data;
    if (daviContext.hoverNotifier.index != null) {
      if (daviContext.hoverNotifier.index! < daviContext.model.rowsLength) {
        data = daviContext.model.rowAt(daviContext.hoverNotifier.index!);
      }
    }
    return data;
  }

  GestureTapCallback? _buildOnTap() {
    if (daviContext.onRowTap != null) {
      return () {
        DATA? data = _hoverData;
        if (data != null) {
          daviContext.onRowTap!(data);
        }
      };
    }
    return null;
  }

  GestureTapCallback? _buildOnDoubleTap() {
    if (daviContext.onRowDoubleTap != null) {
      return () {
        DATA? data = _hoverData;
        if (data != null) {
          daviContext.onRowDoubleTap!(data);
        }
      };
    }
    return null;
  }

  GestureTapCallback? _buildOnSecondaryTap() {
    if (daviContext.onRowSecondaryTap != null) {
      return () {
        DATA? data = _hoverData;
        if (data != null) {
          daviContext.onRowSecondaryTap!(data);
        }
      };
    }
    return null;
  }

  GestureTapUpCallback? _buildOnSecondaryTapUp() {
    if (daviContext.onRowSecondaryTapUp != null) {
      return (detail) {
        DATA? data = _hoverData;
        if (data != null) {
          daviContext.onRowSecondaryTapUp!(data, detail);
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
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          double target =
              math.max(verticalScrollController.position.pixels - rowHeight, 0);
          verticalScrollController.animateTo(target,
              duration: const Duration(milliseconds: 30), curve: Curves.ease);
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.pageDown) {
          double target = math.min(
              verticalScrollController.position.pixels +
                  verticalScrollController.position.viewportDimension,
              verticalScrollController.position.maxScrollExtent);
          verticalScrollController.animateTo(target,
              duration: const Duration(milliseconds: 30), curve: Curves.ease);
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.pageUp) {
          double target = math.max(
              verticalScrollController.position.pixels -
                  verticalScrollController.position.viewportDimension,
              0);
          verticalScrollController.animateTo(target,
              duration: const Duration(milliseconds: 30), curve: Curves.ease);
          return KeyEventResult.handled;
        }
      }
    }
    return KeyEventResult.ignored;
  }
}
