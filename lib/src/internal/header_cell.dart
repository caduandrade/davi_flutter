import 'package:axis_layout/axis_layout.dart';
import 'package:easy_table/easy_table.dart';
import 'package:easy_table/src/sort_type.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// [EasyTable] header cell.
@internal
class EasyTableHeaderCell<ROW> extends StatefulWidget {
  /// Builds a header cell.
  const EasyTableHeaderCell(
      {Key? key,
      required this.model,
      required this.column,
      required this.resizable})
      : super(key: key);

  final EasyTableModel<ROW> model;
  final EasyTableColumn<ROW> column;
  final bool resizable;

  @override
  State<StatefulWidget> createState() => _EasyTableHeaderCellState();
}

class _EasyTableHeaderCellState extends State<EasyTableHeaderCell> {
  bool _hovered = false;
  double _lastDragPos = 0;

  @override
  Widget build(BuildContext context) {
    HeaderCellThemeData theme = EasyTableTheme.of(context).headerCell;

    bool resizing = widget.model.columnInResizing == widget.column;
    bool enabled = resizing == false && widget.model.columnInResizing == null;
    bool sortable = widget.column.sortable;
    bool resizable =
        widget.resizable && widget.column.resizable && (enabled || resizing);

    List<Widget> children = [];

    if (widget.column.leading != null) {
      children.add(widget.column.leading!);
    }
    children.add(AxisLayoutChild(
        child: _textWidget(context),
        shrink: theme.expandableName ? 0 : 1,
        expand: theme.expandableName ? 1 : 0));

    if (widget.model.sortedColumn == widget.column) {
      IconData? icon;
      if (widget.model.sortType == EasyTableSortType.ascending) {
        icon = theme.ascendingIcon;
      } else if (widget.model.sortType == EasyTableSortType.descending) {
        icon = theme.descendingIcon;
      }
      children.add(
          Icon(icon, color: theme.sortIconColor, size: theme.sortIconSize));
    }

    Widget header = AxisLayout(
        axis: Axis.horizontal,
        children: children,
        crossAlignment: CrossAlignment.stretch);
    final EdgeInsets? padding = widget.column.padding ?? theme.padding;
    if (padding != null) {
      header = Padding(padding: padding, child: header);
    }

    if (sortable) {
      header = MouseRegion(
          cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
          child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: header,
              onTap: enabled
                  ? () => _onHeaderPressed(
                      model: widget.model, column: widget.column)
                  : null));
    }

    if (resizable) {
      header = Stack(clipBehavior: Clip.none, children: [
        Positioned.fill(child: header),
        Positioned(
            child: _resizeWidget(context: context, resizing: resizing),
            top: 0,
            bottom: 0,
            right: 0)
      ]);
    }
    return ClipRect(child: header);
  }

  Widget _textWidget(BuildContext context) {
    EasyTableThemeData theme = EasyTableTheme.of(context);
    Widget? text;
    if (widget.column.name != null) {
      text = Text(widget.column.name!,
          overflow: TextOverflow.ellipsis,
          style: widget.column.textStyle ?? theme.headerCell.textStyle);
    }
    return Align(
        child: text,
        alignment: widget.column.alignment ?? theme.headerCell.alignment);
  }

  Widget _resizeWidget({required BuildContext context, required resizing}) {
    EasyTableThemeData theme = EasyTableTheme.of(context);
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
      {required EasyTableModel model, required EasyTableColumn column}) {
    if (model.sortedColumn == null) {
      model.sortByColumn(column: column, sortType: EasyTableSortType.ascending);
    } else {
      if (model.sortedColumn != column) {
        model.sortByColumn(
            column: column, sortType: EasyTableSortType.ascending);
      } else if (model.sortType == EasyTableSortType.ascending) {
        model.sortByColumn(
            column: column, sortType: EasyTableSortType.descending);
      } else {
        model.removeColumnSort();
      }
    }
  }
}
