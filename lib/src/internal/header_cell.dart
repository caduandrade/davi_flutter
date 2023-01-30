import 'package:axis_layout/axis_layout.dart';
import 'package:davi/davi.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// [Davi] header cell.
@internal
class DaviHeaderCell<DATA> extends StatefulWidget {
  /// Builds a header cell.
  const DaviHeaderCell(
      {Key? key,
      required this.model,
      required this.column,
      required this.resizable,
      required this.tapToSortEnabled,
      required this.columnIndex,
      required this.isMultiSorted})
      : super(key: key);

  final DaviModel<DATA> model;
  final DaviColumn<DATA> column;
  final bool resizable;
  final bool tapToSortEnabled;
  final int columnIndex;
  final bool isMultiSorted;

  @override
  State<StatefulWidget> createState() => _DaviHeaderCellState();
}

class _DaviHeaderCellState extends State<DaviHeaderCell> {
  bool _hovered = false;
  double _lastDragPos = 0;

  @override
  Widget build(BuildContext context) {
    HeaderCellThemeData theme = DaviTheme.of(context).headerCell;

    final bool resizing = widget.model.columnInResizing == widget.column;
    final bool sortEnabled = widget.tapToSortEnabled &&
        !resizing &&
        widget.model.columnInResizing == null;
    final bool sortable = widget.column.sortable &&
        (widget.column.sort != null || widget.model.ignoreSortFunctions);
    final bool resizable = widget.resizable &&
        widget.column.resizable &&
        widget.column.grow == null &&
        (sortEnabled || resizing);

    List<Widget> children = [];

    if (widget.column.leading != null) {
      children.add(widget.column.leading!);
    }
    children.add(AxisLayoutChild(
        shrink: theme.expandableName ? 0 : 1,
        expand: theme.expandableName ? 1 : 0,
        child: _textWidget(context)));

    final DaviSortDirection? direction = widget.column.direction;
    if (direction != null) {
      IconData? icon;
      if (direction == DaviSortDirection.ascending) {
        icon = theme.ascendingIcon;
      } else if (direction == DaviSortDirection.descending) {
        icon = theme.descendingIcon;
      }
      children.add(
          Icon(icon, color: theme.sortIconColor, size: theme.sortIconSize));
      if (widget.isMultiSorted) {
        children.add(Align(
            alignment: Alignment.center,
            child: Text(widget.column.sortPriority.toString(),
                style: TextStyle(
                    color: theme.sortIconColor,
                    fontSize: theme.sortPrioritySize))));
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
          cursor: sortEnabled ? SystemMouseCursors.click : MouseCursor.defer,
          child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: sortEnabled
                  ? () => _onHeaderSortPressed(
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
    return Semantics(
        readOnly: true,
        enabled: true,
        label: 'header ${widget.columnIndex}',
        child: ClipRect(child: header));
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

  void _onHeaderSortPressed(
      {required DaviModel model, required DaviColumn column}) {
    List<DaviSort> sortList = HeaderCellUtil.newSortList(model, column);
    model.sort(sortList);
  }
}

class HeaderCellUtil {
  /// Creates a new sort list given the current and new column.
  static List<DaviSort> newSortList(DaviModel model, DaviColumn column) {
    List<DaviSort> newSort = [];
    bool needAddColumn = true;
    List<DaviColumn> sortedColumns = model.sortedColumns;
    for (int index = 0; index < sortedColumns.length; index++) {
      DaviColumn sortedColumn = sortedColumns[index];
      if (sortedColumn == column) {
        needAddColumn = false;
        if (index == sortedColumns.length - 1) {
          if (sortedColumn.direction == DaviSortDirection.ascending) {
            newSort.add(DaviSort(column.id, DaviSortDirection.descending));
          }
        }
        continue;
      }
      if (model.multiSortEnabled && sortedColumn.direction != null) {
        newSort.add(DaviSort(sortedColumn.id, sortedColumn.direction!));
      }
    }
    if (needAddColumn || (model.alwaysSorted && newSort.isEmpty)) {
      newSort.add(DaviSort(column.id, DaviSortDirection.ascending));
    }
    return newSort;
  }
}
