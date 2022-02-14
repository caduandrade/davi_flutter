import 'package:easy_table/easy_table.dart';
import 'package:easy_table/src/easy_table_sort_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Default header cell
class EasyTableHeaderCell<ROW> extends StatefulWidget {
  /// Builds a header cell.
  const EasyTableHeaderCell(
      {Key? key,
      required this.model,
      required this.column,
      this.child,
      this.value,
      this.padding,
      this.alignment})
      : super(key: key);

  final Widget? child;
  final String? value;

  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;

  final EasyTableModel<ROW> model;
  final EasyTableColumn<ROW> column;

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<EasyTableHeaderCell> {
  bool _hovered = false;
  double _initialDragPos = 0;
  double _initialColumnWidth = 0;

  @override
  Widget build(BuildContext context) {
    Widget? headerWidget = widget.child;

    EasyTableThemeData theme = EasyTableTheme.of(context);

    TextStyle? textStyle = theme.headerCell.textStyle;

    if (widget.value != null) {
      headerWidget = Text(widget.value!,
          overflow: TextOverflow.ellipsis, style: textStyle);
    }

    headerWidget = headerWidget ?? Container();

    headerWidget = Align(
        child: headerWidget,
        alignment: widget.alignment ?? theme.headerCell.alignment);

    if (widget.column.sortable && widget.model.sortedColumn == widget.column) {
      IconData? icon;
      if (widget.model.sortType == EasyTableSortType.ascending) {
        icon = theme.headerCell.ascendingIcon;
      } else if (widget.model.sortType == EasyTableSortType.descending) {
        icon = theme.headerCell.descendingIcon;
      }
      headerWidget = Row(children: [
        Expanded(child: headerWidget),
        Icon(icon,
            color: theme.headerCell.sortIconColor,
            size: theme.headerCell.sortIconSize)
      ]);
    }

    EdgeInsetsGeometry? p = widget.padding ?? theme.headerCell.padding;
    if (p != null) {
      headerWidget = Padding(padding: p, child: headerWidget);
    }

    bool resizing = widget.model.columnInResizing == widget.column;
    bool enabled = resizing == false && widget.model.columnInResizing == null;

    if (enabled && widget.column.sortable) {
      headerWidget = MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: headerWidget,
              onTap: () => _onHeaderPressed(
                  model: widget.model, column: widget.column)));
    }

    if (widget.column.resizable) {
      headerWidget = _HeaderLayout(children: [
        headerWidget,
        _resizeWidget(context: context, enabled: enabled, resizing: resizing)
      ]);
    }

    return headerWidget;
  }

  Widget _resizeWidget(
      {required BuildContext context, required resizing, required enabled}) {
    EasyTableThemeData theme = EasyTableTheme.of(context);
    Widget child = Container(
        width: theme.headerCell.resizeAreaWidth,
        color: _hovered || resizing
            ? theme.headerCell.resizeAreaHoverColor
            : null);
    if (widget.column.resizable && (enabled || resizing)) {
      return MouseRegion(
          onEnter: (e) => setState(() {
                _hovered = true;
              }),
          onExit: (e) => setState(() {
                _hovered = false;
              }),
          cursor: SystemMouseCursors.resizeColumn,
          child: GestureDetector(
              onHorizontalDragStart: _onDragStart,
              onHorizontalDragEnd: _onDragEnd,
              onHorizontalDragUpdate: _onDragUpdate,
              behavior: HitTestBehavior.opaque,
              child: child));
    }
    return child;
  }

  void _onDragStart(DragStartDetails details) {
    final Offset pos = details.globalPosition;
    setState(() {
      _initialColumnWidth = widget.column.width;
      _initialDragPos = pos.dx;
    });
    widget.model.columnInResizing = widget.column;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final Offset pos = details.globalPosition;
    double diff = pos.dx - _initialDragPos;
    widget.column.width = _initialColumnWidth + diff;
  }

  void _onDragEnd(DragEndDetails details) {
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

class _HeaderLayout extends MultiChildRenderObjectWidget {
  _HeaderLayout({Key? key, required List<Widget> children})
      : super(key: key, children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _HeaderRenderBox();
  }

  @override
  MultiChildRenderObjectElement createElement() {
    return _HeaderElement(this);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _HeaderRenderBox renderObject) {
    super.updateRenderObject(context, renderObject);
  }
}

/// The [_HeaderLayout] element.
class _HeaderElement extends MultiChildRenderObjectElement {
  _HeaderElement(_HeaderLayout widget) : super(widget);

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    for (var child in children) {
      if (child.renderObject != null) {
        visitor(child);
      }
    }
  }
}

/// Parent data for [_HeaderRenderBox] class.
class _HeaderParentData extends ContainerBoxParentData<RenderBox> {}

class _HeaderRenderBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _HeaderParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _HeaderParentData> {
  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _HeaderParentData) {
      child.parentData = _HeaderParentData();
    }
  }

  @override
  void performLayout() {
    RenderBox first = firstChild!;

    first.layout(constraints, parentUsesSize: true);
    first.headerParentData().offset = Offset.zero;

    RenderBox second = first.headerParentData().nextSibling!;
    second.layout(
        BoxConstraints(
            minWidth: 0,
            maxWidth: constraints.maxWidth,
            minHeight: constraints.maxHeight,
            maxHeight: constraints.maxHeight),
        parentUsesSize: true);
    second.headerParentData().offset =
        Offset(constraints.maxWidth - second.size.width, 0);

    size = constraints.biggest;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return computeMinIntrinsicHeight(width);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    RenderBox first = firstChild!;
    return first.getMaxIntrinsicHeight(width);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}

/// Utility extension to facilitate obtaining parent data.
extension _HeaderParentDataGetter on RenderObject {
  _HeaderParentData headerParentData() {
    return parentData as _HeaderParentData;
  }
}
