import 'package:axis_layout/axis_layout.dart';
import 'package:davi/davi.dart';
import 'package:davi/src/column.dart';
import 'package:davi/src/data_source.dart';
import 'package:davi/src/internal/davi_context.dart';
import 'package:davi/src/internal/sort_util.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// [Davi] header cell.
@internal
class DaviHeaderCell<DATA> extends StatefulWidget {
  /// Builds a header cell.
  const DaviHeaderCell(
      {super.key,
      required this.daviContext,
      required this.column,
      required this.resizable,
      required this.columnIndex});

  final DaviContext<DATA> daviContext;
  final DaviColumn<DATA> column;
  final bool resizable;
  final int columnIndex;

  @override
  State<DaviHeaderCell<DATA>> createState() => _DaviHeaderCellState<DATA>();
}

class _DaviHeaderCellState<DATA> extends State<DaviHeaderCell<DATA>> {
  bool _hovered = false;
  double _lastDragPos = 0;
  bool _resizing = false;

  @override
  Widget build(BuildContext context) {
    HeaderCellThemeData theme = DaviTheme.of(context).headerCell;

    final bool interactionEnabled = !_resizing &&
        !widget.daviContext.columnNotifier.resizing &&
        !widget.daviContext.scrolling;
    final bool sortEnabled =
        widget.daviContext.dataSource.sortingMode != SortingMode.disabled &&
            interactionEnabled;
    final bool resizable = widget.resizable &&
        widget.column.resizable &&
        (interactionEnabled || _resizing);

    List<Widget> children = [];

    if (widget.column.leading != null) {
      children.add(Align(
          alignment: widget.column.headerAlignment ?? theme.alignment,
          child: widget.column.leading!));
    }
    Widget content = widget.column.headerBuilder != null
        ? widget.column.headerBuilder!(HeaderCellBuilderParams(
            buildContext: context,
            column: widget.column,
            columnIndex: widget.columnIndex))
        : _textWidget(context);
    if (widget.column.headerTextStyle != null) {
      content = DefaultTextStyle.merge(
          style: widget.column.headerTextStyle, child: content);
    }
    children.add(AxisLayoutChild(
        shrink: theme.expandableName ? 0 : 1,
        expand: theme.expandableName ? 1 : 0,
        child: Align(
            alignment: widget.column.headerAlignment ?? theme.alignment,
            child: content)));

    final DaviSortDirection? sortDirection = widget.column.sortDirection;
    if (sortDirection != null) {
      Widget sortIconWidget =
          theme.sortIconBuilder(sortDirection, theme.sortIconColors);
      children.add(Align(
        alignment: widget.column.headerAlignment ?? theme.alignment,
        child: sortIconWidget,
      ));

      if (widget.daviContext.dataSource.isMultiSorted) {
        if (theme.sortPriorityGap != null) {
          children.add(SizedBox(width: theme.sortPriorityGap));
        }
        children.add(Align(
            alignment: widget.column.headerAlignment ?? theme.alignment,
            child: Text(widget.column.sortPriority.toString(),
                style: TextStyle(
                    color: theme.sortPriorityColor,
                    fontSize: theme.sortPrioritySize))));
      }
    }

    if (sortDirection == null &&
        widget.column.sortable &&
        widget.daviContext.dataSource.sortingMode != SortingMode.disabled &&
        widget.daviContext.columnWidthBehavior ==
            ColumnWidthBehavior.scrollable &&
        DaviColumnHelper.isAutoSizePending(column: widget.column)) {
      // Reserves (invisibly) the room of the sort icon while the auto size
      // is measured, so the name isn't truncated once the column is sorted.
      children.add(Visibility(
          visible: false,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: theme.sortIconBuilder(
              DaviSortDirection.ascending, theme.sortIconColors)));
    }

    Widget header = AxisLayout(
        axis: Axis.horizontal,
        crossAlignment: CrossAlignment.stretch,
        children: children);
    final EdgeInsets? padding = widget.column.headerPadding ?? theme.padding;
    if (padding != null) {
      header = Padding(padding: padding, child: header);
    }

    if (widget.column.sortable) {
      header = MouseRegion(
          cursor: sortEnabled ? SystemMouseCursors.click : MouseCursor.defer,
          child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: sortEnabled ? _onHeaderSortPressed : null,
              child: header));
    }

    if (resizable) {
      // The content is kept as a non-positioned Stack child (instead of
      // Positioned.fill) so RenderStack can derive its height from it when
      // TableLayoutRenderBox measures the header with a loose height
      // constraint. A Stack whose children are all Positioned cannot report
      // a real size on its own and would crash under unbounded height.
      header = Stack(clipBehavior: Clip.none, children: [
        Align(alignment: Alignment.topLeft, child: header),
        Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            child: _resizeWidget(context: context, resizing: _resizing))
      ]);
    }
    return Semantics(
        readOnly: true,
        enabled: true,
        label: 'header ${widget.columnIndex}',
        child: ClipRect(child: header));
  }

  Widget _textWidget(BuildContext context) {
    if (widget.column.name == null) {
      return const SizedBox.shrink();
    }
    // No explicit style: inherits the ambient DefaultTextStyle set up by
    // HeaderWidget (theme) and, when present, by the wrapper above (the
    // column's headerTextStyle override).
    return Text(widget.column.name!, overflow: TextOverflow.ellipsis);
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
            onDoubleTap: _onResizeDoubleTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
                width: theme.headerCell.resizeAreaWidth,
                color: _hovered || resizing
                    ? theme.headerCell.resizeAreaHoverColor
                    : null)));
  }

  void _onResizeDragStart(DragStartDetails details) {
    final Offset pos = details.globalPosition;
    widget.daviContext.hoverNotifier.enabled = false;
    widget.daviContext.columnNotifier.resizing = true;
    setState(() {
      _lastDragPos = pos.dx;
      _resizing = true;
    });
  }

  void _onResizeDragUpdate(DragUpdateDetails details) {
    final Offset pos = details.globalPosition;
    final double diff = pos.dx - _lastDragPos;
    widget.column.width += diff;
    _lastDragPos = pos.dx;
  }

  void _onResizeDoubleTap() {
    DaviColumnHelper.requestAutoSize(column: widget.column);
  }

  void _onResizeDragEnd(DragEndDetails details) {
    widget.daviContext.hoverNotifier.enabled = true;
    widget.daviContext.columnNotifier.resizing = false;
    setState(() {
      _resizing = false;
    });
  }

  void _onHeaderSortPressed() {
    final DaviDataSource<DATA> dataSource = widget.daviContext.dataSource;
    List<DaviSort> sortList = SortUtil.newSortList(
        sortList: dataSource.sortList,
        multiSortEnabled: dataSource.multiSortEnabled,
        alwaysSorted: dataSource.sortingMode == SortingMode.alwaysSorted,
        columnIdToSort: widget.column.id);
    dataSource.sort(sortList);
  }
}
