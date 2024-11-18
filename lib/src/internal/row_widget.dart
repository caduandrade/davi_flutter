import 'package:davi/davi.dart';
import 'package:davi/src/internal/cell_widget.dart';
import 'package:davi/src/internal/columns_layout.dart';
import 'package:davi/src/internal/columns_layout_child.dart';
import 'package:davi/src/internal/row_callbacks.dart';
import 'package:davi/src/internal/scroll_offsets.dart';
import 'package:davi/src/internal/table_layout_settings.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
@Deprecated('message')
class RowWidget<DATA> extends StatefulWidget {
  RowWidget(
      {required this.index,
      required this.data,
      required this.onHover,
      required this.layoutSettings,
      required this.scrolling,
      required this.columnResizing,
      required this.color,
      required this.cursor,
      required this.model,
      required this.rowCallbacks,
      required this.horizontalScrollOffsets})
      : super(key: ValueKey<int>(index));

  final DATA data;
  final int index;
  final bool scrolling;
  final bool columnResizing;
  final OnRowHoverListener? onHover;
  final DaviModel<DATA> model;
  final TableLayoutSettings layoutSettings;
  final RowCallbacks<DATA> rowCallbacks;
  final DaviRowColor<DATA>? color;
  final RowCursorBuilder<DATA>? cursor;
  final HorizontalScrollOffsets horizontalScrollOffsets;

  @override
  State<StatefulWidget> createState() => RowWidgetState<DATA>();
}

class RowWidgetState<DATA> extends State<RowWidget<DATA>> {
  late DaviRow<DATA> _row;

  @override
  void initState() {
    super.initState();
    _row = DaviRow(data: widget.data, index: widget.index, hovered: false);
  }

  @override
  void didUpdateWidget(covariant RowWidget<DATA> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _row =
        DaviRow(data: widget.data, index: widget.index, hovered: _row.hovered);
  }

  @override
  Widget build(BuildContext context) {
    DaviThemeData theme = DaviTheme.of(context);

    List<ColumnsLayoutChild<DATA>> children = [];

    for (int columnIndex = 0;
        columnIndex < widget.model.columnsLength;
        columnIndex++) {
      final DaviColumn<DATA> column = widget.model.columnAt(columnIndex);
   //   final CellWidget<DATA> cell =  CellWidget(column: column, columnIndex: columnIndex, row: _row);

    //  children.add(ColumnsLayoutChild<DATA>(index: columnIndex, child: cell));
    }

    Widget layout = ColumnsLayout(
        layoutSettings: widget.layoutSettings,
        horizontalScrollOffsets: widget.horizontalScrollOffsets,
        paintDividerColumns: false,
        children: children);

    if (widget.rowCallbacks.hasCallback) {
      layout = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _buildOnTap(),
          onDoubleTap: _buildOnDoubleTap(),
          onSecondaryTap: _buildOnSecondaryTap(),
          onSecondaryTapUp: _buildOnSecondaryTapUp(),
          child: layout);
    }

    Color? color;
    if (widget.color != null) {
      color = widget.color!(_row);
    }

    if (!widget.scrolling &&
        !widget.columnResizing &&
        (widget.rowCallbacks.hasCallback ||
            theme.row.hoverBackground != null ||
            theme.row.hoverForeground != null ||
            widget.onHover != null ||
            !theme.row.cursorOnTapGesturesOnly)) {
      if (_row.hovered && theme.row.hoverBackground != null) {
        // replace row color
        color = theme.row.hoverBackground!(widget.index);
      }
      _ColorPainter? hoverBackground;
      if (color != null) {
        // row color or hover background
        hoverBackground = _ColorPainter(color);
      }
      _ColorPainter? hoverForeground;
      if (_row.hovered && theme.row.hoverForeground != null) {
        Color? color = theme.row.hoverForeground!(widget.index);
        if (color != null) {
          hoverForeground = _ColorPainter(color);
        }
      }
      layout = CustomPaint(
          painter: hoverBackground,
          foregroundPainter: hoverForeground,
          child: layout);
      layout = MouseRegion(
          onEnter: _onEnter,
          cursor: _cursor(theme),
          onExit: _onExit,
          child: layout);
    } else if (color != null) {
      layout = Container(color: color, child: layout);
    }

    return layout;
  }

  MouseCursor _cursor(DaviThemeData theme) {
    if (!theme.row.cursorOnTapGesturesOnly || widget.rowCallbacks.hasCallback) {
      MouseCursor? cursor;
      if (widget.cursor != null) {
        cursor = widget.cursor!(_row);
      }
      return cursor ?? theme.row.cursor;
    }
    return MouseCursor.defer;
  }

  GestureTapCallback? _buildOnTap() {
    if (widget.rowCallbacks.onRowTap != null) {
      return () => widget.rowCallbacks.onRowTap!(widget.data);
    }
    return null;
  }

  GestureTapCallback? _buildOnDoubleTap() {
    if (widget.rowCallbacks.onRowDoubleTap != null) {
      return () => widget.rowCallbacks.onRowDoubleTap!(widget.data);
    }
    return null;
  }

  GestureTapCallback? _buildOnSecondaryTap() {
    if (widget.rowCallbacks.onRowSecondaryTap != null) {
      return () => widget.rowCallbacks.onRowSecondaryTap!(widget.data);
    }
    return null;
  }

  GestureTapUpCallback? _buildOnSecondaryTapUp() {
    if (widget.rowCallbacks.onRowSecondaryTapUp != null) {
      return (detail) =>
          widget.rowCallbacks.onRowSecondaryTapUp!(widget.data, detail);
    }
    return null;
  }

  void _onEnter(PointerEnterEvent event) {
    setState(() {
      _row = DaviRow(data: widget.data, index: widget.index, hovered: true);
      if (widget.onHover != null) {
        widget.onHover!(widget.index);
      }
    });
  }

  void _onExit(PointerExitEvent event) {
    setState(() {
      _row = DaviRow(data: widget.data, index: widget.index, hovered: false);
      if (widget.onHover != null) {
        widget.onHover!(null);
      }
    });
  }
}

class _ColorPainter extends CustomPainter {
  _ColorPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _ColorPainter oldDelegate) =>
      color != oldDelegate.color;
}
