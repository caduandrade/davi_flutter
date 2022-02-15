import 'dart:math' as math;
import 'package:easy_table/easy_table.dart';
import 'package:easy_table/src/sort_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

/// [EasyTable] header cell.
@internal
class EasyTableHeaderCell<ROW> extends StatefulWidget {
  /// Builds a header cell.
  const EasyTableHeaderCell(
      {Key? key, required this.model, required this.column})
      : super(key: key);

  final EasyTableModel<ROW> model;
  final EasyTableColumn<ROW> column;

  @override
  State<StatefulWidget> createState() => _EasyTableHeaderCellState();
}

class _EasyTableHeaderCellState extends State<EasyTableHeaderCell> {
  bool _hovered = false;
  double _initialDragPos = 0;
  double _initialColumnWidth = 0;

  @override
  Widget build(BuildContext context) {
    EasyTableThemeData theme = EasyTableTheme.of(context);

    bool resizing = widget.model.columnInResizing == widget.column;
    bool enabled = resizing == false && widget.model.columnInResizing == null;
    bool sortable = widget.column.sortable;
    bool resizable = widget.column.resizable && (enabled || resizing);

    List<Widget> children = [_textWidget(context)];

    if (widget.model.sortedColumn == widget.column) {
      IconData? icon;
      if (widget.model.sortType == EasyTableSortType.ascending) {
        icon = theme.headerCell.ascendingIcon;
      } else if (widget.model.sortType == EasyTableSortType.descending) {
        icon = theme.headerCell.descendingIcon;
      }
      children.add(Icon(icon,
          color: theme.headerCell.sortIconColor,
          size: theme.headerCell.sortIconSize));
    }

    if (sortable) {
      children.add(MouseRegion(
          cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
          child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: enabled
                  ? () => _onHeaderPressed(
                      model: widget.model, column: widget.column)
                  : null)));
    }

    if (resizable) {
      children.add(_resizeWidget(
          context: context, resizable: resizable, resizing: resizing));
    }

    final EdgeInsets? padding =
        widget.column.padding ?? theme.headerCell.padding;
    return _HeaderLayout(
        debug: widget.column.name == 'Race',
        children: children,
        resizable: resizable,
        padding: padding,
        sortable: sortable);
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

  Widget _resizeWidget(
      {required BuildContext context, required resizing, required resizable}) {
    EasyTableThemeData theme = EasyTableTheme.of(context);
    Widget child = Container(
        width: theme.headerCell.resizeAreaWidth,
        color: _hovered || resizing
            ? theme.headerCell.resizeAreaHoverColor
            : null);
    if (resizable) {
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
  _HeaderLayout(
      {Key? key,
      required List<Widget> children,
      required this.padding,
      required this.resizable,
      required this.sortable,
      this.debug = false})
      : super(key: key, children: children);

  final bool sortable;
  final EdgeInsets? padding;
  final bool resizable;
  final bool debug;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _HeaderRenderBox(
        debug: debug,
        padding: padding,
        resizable: resizable,
        sortable: sortable);
  }

  @override
  MultiChildRenderObjectElement createElement() {
    return _HeaderElement(this);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _HeaderRenderBox renderObject) {
    super.updateRenderObject(context, renderObject);
    renderObject
      ..padding = padding
      ..resizable = resizable
      ..sortable = sortable;
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
  _HeaderRenderBox(
      {required EdgeInsets? padding,
      required bool sortable,
      required bool resizable,
      required this.debug})
      : _padding = padding,
        _resizable = resizable,
        _sortable = sortable;

  final bool debug;

  double? _intrinsicHeight;

  bool _sortable;
  set sortable(bool sortable) {
    if (_sortable != sortable) {
      _sortable = sortable;
      markNeedsLayout();
    }
  }

  bool _resizable;
  set resizable(bool resizable) {
    if (_resizable != resizable) {
      _resizable = resizable;
      markNeedsLayout();
    }
  }

  EdgeInsets? _padding;
  set padding(EdgeInsets? padding) {
    if (_padding != padding) {
      _padding = padding;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _HeaderParentData) {
      child.parentData = _HeaderParentData();
    }
  }

  @override
  void performLayout() {
    List<RenderBox> children = [];
    visitChildren((child) => children.add(child as RenderBox));

    RenderBox? resizableArea;
    if (_resizable) {
      resizableArea = children.removeLast();
    }

    RenderBox? sortableArea;
    if (_sortable) {
      sortableArea = children.removeLast();
    }

    double availableWidth = constraints.maxWidth;
    if (_padding != null) {
      availableWidth -= _padding!.horizontal;
    }
    double verticalPadding = _padding != null ? _padding!.vertical : 0;
    double height = constraints.maxHeight - verticalPadding;
    for (int i = 1; i < children.length; i++) {
      RenderBox child = children[i];
      child.layout(
          BoxConstraints(
              minWidth: 0,
              maxWidth: double.infinity,
              minHeight: height,
              maxHeight: height),
          parentUsesSize: true);
      availableWidth = math.max(0, availableWidth - child.size.width);
    }
    RenderBox text = children.first;
    text.layout(
        BoxConstraints(
            minWidth: availableWidth,
            maxWidth: availableWidth,
            minHeight: height,
            maxHeight: height),
        parentUsesSize: true);

    double x = 0;
    double y = 0;
    if (_padding != null) {
      x += _padding!.left;
      y += _padding!.top;
    }

    for (RenderBox child in children) {
      child.headerParentData().offset = Offset(x, y);
      x += child.size.width;
    }

    Size resizableAreaSize = Size.zero;
    if (resizableArea != null) {
      resizableArea.layout(
          BoxConstraints(
              minWidth: 0,
              maxWidth: constraints.maxWidth,
              minHeight: constraints.maxHeight,
              maxHeight: constraints.maxHeight),
          parentUsesSize: true);
      resizableArea.headerParentData().offset =
          Offset(constraints.maxWidth - resizableArea.size.width, 0);
      resizableAreaSize = resizableArea.size;
    }

    if (sortableArea != null) {
      sortableArea.layout(
          BoxConstraints(
              minWidth: 0,
              maxWidth:
                  math.max(0, constraints.maxWidth - resizableAreaSize.width),
              minHeight: constraints.maxHeight,
              maxHeight: constraints.maxHeight),
          parentUsesSize: true);
      sortableArea.headerParentData().offset = Offset.zero;
    }

    size = constraints.biggest;
  }

  @override
  void markNeedsLayout() {
    _intrinsicHeight = null;
    super.markNeedsLayout();
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    if (_intrinsicHeight == null) {
      List<RenderBox> children = [];
      visitChildren((child) => children.add(child as RenderBox));

      if (_resizable) {
        children.removeLast();
      }
      if (_sortable) {
        children.removeLast();
      }
      _intrinsicHeight = 0;
      for (RenderBox child in children) {
        _intrinsicHeight = math.max(
            _intrinsicHeight!, child.getMinIntrinsicHeight(double.infinity));
      }
      if (_padding != null) {
        _intrinsicHeight = _intrinsicHeight! + _padding!.vertical;
      }
    }
    return _intrinsicHeight!;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return computeMinIntrinsicHeight(width);
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
