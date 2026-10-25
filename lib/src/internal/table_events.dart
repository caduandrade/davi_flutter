import 'dart:math' as math;

import 'package:davi/davi.dart';
import 'package:davi/src/internal/davi_context.dart';
import 'package:davi/src/internal/table_layout_settings.dart';
import 'package:davi/src/internal/viewport_state.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

@internal
class TableEvents<DATA> extends StatefulWidget {
  const TableEvents(
      {super.key,
      required this.daviContext,
      required this.child,
      required this.rowRegions,
      required this.rowTheme,
      required this.layoutSettings});

  final Widget child;
  final DaviContext<DATA> daviContext;

  final RowRegionCache rowRegions;

  final RowThemeData rowTheme;

  final TableLayoutSettings layoutSettings;

  @override
  State<TableEvents<DATA>> createState() => _TableEventsState<DATA>();
}

/// Only mouse and trackpad trigger click-and-drag horizontal scrolling on
/// the table body. Touch devices keep their platform-native gestures
/// (tap, etc.) untouched here.
const Set<PointerDeviceKind> _dragScrollDevices = {
  PointerDeviceKind.mouse,
  PointerDeviceKind.trackpad,
};

class _TableEventsState<DATA> extends State<TableEvents<DATA>> {
  // The horizontal scroll controller targeted by the current click-and-drag
  // gesture, chosen when the drag starts based on whether it began over the
  // left-pinned columns or the unpinned ones.
  ScrollController? _dragScrollController;

  // The mouse's last known local position while it's over the table (null
  // when it isn't). Vertical scrolling moves row content underneath a
  // stationary mouse without generating a new PointerHoverEvent - Flutter
  // only fires those on actual pointer movement - so the hovered row index
  // would otherwise stay pinned to whatever row was under the mouse before
  // the scroll, visibly sliding away from the cursor. Recomputing hover
  // from this cached position whenever the vertical offset changes keeps it
  // under the cursor instead.
  Offset? _lastHoverPosition;

  @override
  void initState() {
    super.initState();
    verticalScroll.addListener(_onVerticalScroll);
  }

  @override
  void didUpdateWidget(covariant TableEvents<DATA> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final ScrollController oldController =
        oldWidget.daviContext.scrollControllers.vertical;
    if (oldController != verticalScroll) {
      oldController.removeListener(_onVerticalScroll);
      verticalScroll.addListener(_onVerticalScroll);
    }
  }

  @override
  void dispose() {
    verticalScroll.removeListener(_onVerticalScroll);
    super.dispose();
  }

  void _onVerticalScroll() {
    if (_lastHoverPosition != null) {
      _updateHover(_lastHoverPosition);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = widget.child;

    if (widget.daviContext.dataSource.isRowsNotEmpty) {
      // Updates logical row status on hover
      content = MouseRegion(
          onEnter: _onEnter,
          onHover: _onHover,
          onExit: _onExit,
          child: content);

      if (widget.daviContext.hasCallback) {
        content = GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _buildOnTap(),
            onDoubleTap: _buildOnDoubleTap(),
            onSecondaryTap: _buildOnSecondaryTap(),
            onSecondaryTapUp: _buildOnSecondaryTapUp(),
            child: content);
      }

      // Click-and-drag horizontal scrolling. Kept as its own GestureDetector,
      // restricted to mouse/trackpad via supportedDevices, so touch taps
      // above are unaffected and the drag/tap gestures are resolved by the
      // normal gesture arena (a real drag past the touch slop wins over a
      // tap, same as any scrollable with tappable children).
      content = GestureDetector(
          behavior: HitTestBehavior.opaque,
          supportedDevices: _dragScrollDevices,
          onHorizontalDragStart: _onHorizontalDragStart,
          onHorizontalDragUpdate: _onHorizontalDragUpdate,
          onHorizontalDragEnd: _onHorizontalDragEnd,
          onHorizontalDragCancel: _onHorizontalDragCancel,
          child: content);

      content = Listener(
          behavior: HitTestBehavior.translucent,
          onPointerSignal: _onPointerSignal,
          onPointerPanZoomUpdate: _onPointerPanZoomUpdate,
          child: content);

      if (widget.daviContext.focusable) {
        content = Focus(
            focusNode: widget.daviContext.focusNode,
            onKeyEvent: _handleKeyPress,
            child: content);
      }
    }
    return content;
  }

  ScrollController get verticalScroll =>
      widget.daviContext.scrollControllers.vertical;

  void _onEnter(PointerEnterEvent event) {
    _lastHoverPosition = event.localPosition;
    _updateHover(event.localPosition);
  }

  void _onHover(PointerHoverEvent event) {
    _lastHoverPosition = event.localPosition;
    _updateHover(event.localPosition);
  }

  void _onExit(PointerExitEvent event) {
    _lastHoverPosition = null;
    _updateHover(null);
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent &&
        verticalScroll.hasClients &&
        event.scrollDelta.dy != 0) {
      verticalScroll.position.pointerScroll(event.scrollDelta.dy);
    }
  }

  void _onPointerPanZoomUpdate(PointerPanZoomUpdateEvent event) {
    // trackpad on macOS
    if (verticalScroll.hasClients && event.panDelta.dy != 0) {
      verticalScroll.position.pointerScroll(-event.panDelta.dy);
    }
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    final double leftPinnedWidth =
        widget.layoutSettings.leftPinnedAreaBounds.width;
    final PinStatus pinStatus = details.localPosition.dx < leftPinnedWidth
        ? PinStatus.left
        : PinStatus.none;
    final ScrollController controller =
        widget.daviContext.scrollControllers.getHorizontalController(pinStatus);
    if (!controller.hasClients) {
      return;
    }
    _dragScrollController = controller;
    widget.daviContext.onDragScroll(true);
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    final ScrollController? controller = _dragScrollController;
    if (controller == null || !controller.hasClients) {
      return;
    }
    final double target = (controller.offset - details.delta.dx)
        .clamp(0, controller.position.maxScrollExtent);
    controller.jumpTo(target);
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    _endHorizontalDragScroll();
  }

  void _onHorizontalDragCancel() {
    _endHorizontalDragScroll();
  }

  void _endHorizontalDragScroll() {
    if (_dragScrollController != null) {
      _dragScrollController = null;
      widget.daviContext.onDragScroll(false);
    }
  }

  void _updateHover(Offset? position) {
    if (widget.daviContext.dataSource.isRowsNotEmpty) {
      int? rowIndex;
      if (position != null) {
        rowIndex = widget.rowRegions.boundsIndex(position);
      }
      DATA? data;
      if (rowIndex != null && rowIndex < widget.daviContext.dataSource.rowsLength) {
        data = widget.daviContext.dataSource.rowAt(rowIndex);
      }
      if (data != null) {
        widget.daviContext.hoverNotifier.cursor = _buildCursor(
            data: data,
            index: rowIndex!,
            hovered: widget.daviContext.hoverNotifier.index == rowIndex);
      } else {
        // hover over visual row without value
        rowIndex = null;
      }
      widget.daviContext.hoverNotifier.index = rowIndex;
    }
  }

  MouseCursor _buildCursor(
      {required DATA data, required int index, required bool hovered}) {
    MouseCursor? mouseCursor;
    if (widget.daviContext.rowCursorBuilder != null) {
      CursorBuilderParams<DATA> params =
          CursorBuilderParams(data: data, rowIndex: index, hovered: hovered);
      mouseCursor = widget.daviContext.rowCursorBuilder!(params);
    }
    if (mouseCursor == null && widget.daviContext.hasCallback) {
      mouseCursor = widget.rowTheme.callbackCursor;
    }
    return mouseCursor ?? MouseCursor.defer;
  }

  DATA? get _hoverData {
    DATA? data;
    if (widget.daviContext.hoverNotifier.index != null) {
      if (widget.daviContext.hoverNotifier.index! <
          widget.daviContext.dataSource.rowsLength) {
        data = widget.daviContext.dataSource
            .rowAt(widget.daviContext.hoverNotifier.index!);
      }
    }
    return data;
  }

  GestureTapCallback? _buildOnTap() {
    if (widget.daviContext.onRowTap != null && !widget.daviContext.scrolling) {
      return () {
        DATA? data = _hoverData;
        if (data != null) {
          widget.daviContext.onRowTap!(data);
        }
      };
    }
    return null;
  }

  GestureTapCallback? _buildOnDoubleTap() {
    if (widget.daviContext.onRowDoubleTap != null &&
        !widget.daviContext.scrolling) {
      return () {
        DATA? data = _hoverData;
        if (data != null) {
          widget.daviContext.onRowDoubleTap!(data);
        }
      };
    }
    return null;
  }

  GestureTapCallback? _buildOnSecondaryTap() {
    if (widget.daviContext.onRowSecondaryTap != null &&
        !widget.daviContext.scrolling) {
      return () {
        DATA? data = _hoverData;
        if (data != null) {
          widget.daviContext.onRowSecondaryTap!(data);
        }
      };
    }
    return null;
  }

  GestureTapUpCallback? _buildOnSecondaryTapUp() {
    if (widget.daviContext.onRowSecondaryTapUp != null &&
        !widget.daviContext.scrolling) {
      return (detail) {
        DATA? data = _hoverData;
        if (data != null) {
          widget.daviContext.onRowSecondaryTapUp!(data, detail);
        }
      };
    }
    return null;
  }

  KeyEventResult _handleKeyPress(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) {
      if (verticalScroll.hasClients) {
        if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          final double rowHeight = widget.layoutSettings.rowExtentManager
              .extentOf(widget.layoutSettings.rowExtentManager
                  .indexAtOffset(verticalScroll.position.pixels));
          double target = math.min(verticalScroll.position.pixels + rowHeight,
              verticalScroll.position.maxScrollExtent);
          verticalScroll.animateTo(target,
              duration: const Duration(milliseconds: 30), curve: Curves.ease);
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          final double rowHeight = widget.layoutSettings.rowExtentManager
              .extentOf(widget.layoutSettings.rowExtentManager
                  .indexAtOffset(verticalScroll.position.pixels));
          double target =
              math.max(verticalScroll.position.pixels - rowHeight, 0);
          verticalScroll.animateTo(target,
              duration: const Duration(milliseconds: 30), curve: Curves.ease);
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.pageDown) {
          double target = math.min(
              verticalScroll.position.pixels +
                  verticalScroll.position.viewportDimension,
              verticalScroll.position.maxScrollExtent);
          verticalScroll.animateTo(target,
              duration: const Duration(milliseconds: 30), curve: Curves.ease);
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.pageUp) {
          double target = math.max(
              verticalScroll.position.pixels -
                  verticalScroll.position.viewportDimension,
              0);
          verticalScroll.animateTo(target,
              duration: const Duration(milliseconds: 30), curve: Curves.ease);
          return KeyEventResult.handled;
        }
      }
    }
    return KeyEventResult.ignored;
  }
}
