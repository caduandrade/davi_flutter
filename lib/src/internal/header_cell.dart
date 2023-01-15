import 'package:axis_layout/axis_layout.dart';
import 'package:davi/davi.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// [Davi] header cell.
@internal
class DaviHeaderCell<ROW> extends StatefulWidget {
  /// Builds a header cell.
  const DaviHeaderCell(
      {Key? key,
      required this.model,
      required this.column,
      required this.resizable,
      required this.multiSort})
      : super(key: key);

  final DaviModel<ROW> model;
  final DaviColumn<ROW> column;
  final bool resizable;
  final bool multiSort;

  @override
  State<StatefulWidget> createState() => _DaviHeaderCellState();
}

class _DaviHeaderCellState extends State<DaviHeaderCell> {
  bool _hovered = false;
  double _lastDragPos = 0;

  @override
  Widget build(BuildContext context) {
    HeaderCellThemeData theme = DaviTheme.of(context).headerCell;

    bool resizing = widget.model.columnInResizing == widget.column;
    bool enabled = resizing == false && widget.model.columnInResizing == null;
    bool sortable = widget.column.sortable;
    bool resizable = widget.resizable &&
        widget.column.resizable &&
        widget.column.grow == null &&
        (enabled || resizing);

    List<Widget> children = [];

    if (widget.column.leading != null) {
      children.add(widget.column.leading!);
    }
    children.add(AxisLayoutChild(
        shrink: theme.expandableName ? 0 : 1,
        expand: theme.expandableName ? 1 : 0,
        child: _textWidget(context)));

    final TableSortOrder? order = widget.column.order;
    if (order != null) {
      IconData? icon;
      if (order == TableSortOrder.ascending) {
        icon = theme.ascendingIcon;
      } else if (order == TableSortOrder.descending) {
        icon = theme.descendingIcon;
      }
      children.add(
          Icon(icon, color: theme.sortIconColor, size: theme.sortIconSize));
      if (widget.model.isMultiSorted) {
        children.add(Align(
            alignment: Alignment.center,
            child: Text(widget.column.priority.toString(),
                style: TextStyle(
                    color: theme.sortIconColor,
                    fontSize: theme.sortOrderSize))));
      }
    }

    Widget header = AxisLayout(
        axis: Axis.horizontal,
        crossAlignment: CrossAlignment.stretch,
        children: children);
    final EdgeInsets? padding = widget.column.headerPadding ?? theme.padding;
    if (padding != null) {
      header = Padding(padding: padding, child: header);
    }

    if (sortable) {
      header = MouseRegion(
          cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
          child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: enabled
                  ? () => _onHeaderPressed(
                      model: widget.model, column: widget.column)
                  : null,
              child: header));
    }

    if (resizable) {
      header = Stack(clipBehavior: Clip.none, children: [
        Positioned.fill(child: header),
        Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            child: _resizeWidget(context: context, resizing: resizing))
      ]);
    }
    return ClipRect(child: header);
  }

  Widget _textWidget(BuildContext context) {
    DaviThemeData theme = DaviTheme.of(context);
    Widget? text;
    if (widget.column.name != null) {
      text = Text(widget.column.name!,
          overflow: TextOverflow.ellipsis,
          style: widget.column.headerTextStyle ?? theme.headerCell.textStyle);
    }
    return Align(
        alignment: widget.column.headerAlignment ?? theme.headerCell.alignment,
        child: text);
  }

  Widget _resizeWidget({required BuildContext context, required resizing}) {
    DaviThemeData theme = DaviTheme.of(context);
    return MouseRegion(
        onEnter: (e) => setState(() {
              _hovered = true;
            }),
        onExit: (e) => setState(() {
              _hovered = false;
            }),
        cursor: SystemMouseCursors.resizeColumn,
        child: GestureDetector(
            onHorizontalDragStart: _onResizeDragStart,
            onHorizontalDragEnd: _onResizeDragEnd,
            onHorizontalDragUpdate: _onResizeDragUpdate,
            behavior: HitTestBehavior.opaque,
            child: Container(
                width: theme.headerCell.resizeAreaWidth,
                color: _hovered || resizing
                    ? theme.headerCell.resizeAreaHoverColor
                    : null)));
  }

  void _onResizeDragStart(DragStartDetails details) {
    final Offset pos = details.globalPosition;
    setState(() {
      _lastDragPos = pos.dx;
    });
    widget.model.columnInResizing = widget.column;
  }

  void _onResizeDragUpdate(DragUpdateDetails details) {
    final Offset pos = details.globalPosition;
    final double diff = pos.dx - _lastDragPos;
    widget.column.width += diff;
    _lastDragPos = pos.dx;
  }

  void _onResizeDragEnd(DragEndDetails details) {
    widget.model.columnInResizing = null;
  }

  void _onHeaderPressed(
      {required DaviModel model, required DaviColumn column}) {
    if (model.isSorted == false) {
      model.sortByColumn(column: column, sortOrder: TableSortOrder.ascending);
    } else if (widget.multiSort) {
      widget.model.multiSortByColumn(widget.column);
    } else {
      final TableSortOrder? order = widget.column.order;
      if (order == null) {
        model.sortByColumn(column: column, sortOrder: TableSortOrder.ascending);
      } else if (order == TableSortOrder.ascending) {
        model.sortByColumn(
            column: column, sortOrder: TableSortOrder.descending);
      } else {
        model.clearSort();
      }
    }
  }
}
