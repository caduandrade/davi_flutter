import 'dart:math' as math;
import 'package:easy_table/src/easy_table_column.dart';
import 'package:easy_table/src/easy_table_row_color.dart';
import 'package:flutter/material.dart';

class EasyTable<ROW_VALUE> extends StatefulWidget {
//TODO handle negative values
//TODO allow null and use defaults?
  const EasyTable(
      {Key? key,
      required this.columns,
      this.rows,
      this.cellHeight = 32,
      this.columnGap = 4,
      this.rowGap = 0,
      this.horizontalScrollController,
      this.verticalScrollController,
      this.cellPadding = const EdgeInsets.only(left: 8, right: 8),
      this.headerCellPadding = const EdgeInsets.all(8),
      this.headerDecoration = const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey))),
      this.rowColor})
      : super(key: key);

  final double columnGap;
  final double rowGap;
  final double cellHeight;
  final EdgeInsetsGeometry? cellPadding;
  final EdgeInsetsGeometry? headerCellPadding;
  final List<EasyTableColumn<ROW_VALUE>> columns;
  final List<ROW_VALUE>? rows;
  final ScrollController? horizontalScrollController;
  final ScrollController? verticalScrollController;
  final EasyTableRowColor? rowColor;
  final BoxDecoration? headerDecoration;

  double get rowHeight =>
      cellPadding != null ? cellHeight + cellPadding!.vertical : cellHeight;

  int get length => rows != null ? rows!.length : 0;

  @override
  State<StatefulWidget> createState() => EasyTableState<ROW_VALUE>();
}

class EasyTableState<ROW_VALUE> extends State<EasyTable<ROW_VALUE>> {
  late ScrollController _verticalScrollController;
  late ScrollController _horizontalScrollController;

  final ScrollController _headerHorizontalScrollController = ScrollController();

  final List<double> _columnWidths = [];

  double _requiredWidth = 0;

  @override
  void initState() {
    super.initState();
    for (EasyTableColumn<ROW_VALUE> column in widget.columns) {
      _columnWidths.add(column.initialWidth);
    }
    _calculateRequiredWidth();
    _horizontalScrollController =
        widget.horizontalScrollController ?? ScrollController();
    _verticalScrollController =
        widget.verticalScrollController ?? ScrollController();

    _horizontalScrollController.addListener(_syncHorizontalScroll);
  }

  @override
  void dispose() {
    _horizontalScrollController.removeListener(_syncHorizontalScroll);
    super.dispose();
  }

  void _syncHorizontalScroll() {
    _headerHorizontalScrollController
        .jumpTo(_horizontalScrollController.offset);
  }

  @override
  void didUpdateWidget(covariant EasyTable<ROW_VALUE> oldWidget) {
    super.didUpdateWidget(oldWidget);
    //TODO update values and listeners
  }

  void _calculateRequiredWidth() {
    _requiredWidth = 0;
    for (double width in _columnWidths) {
      _requiredWidth += width;
    }
    _requiredWidth += (widget.columns.length) * widget.columnGap;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double maxWidth = math.max(constraints.maxWidth, _requiredWidth);
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        ScrollConfiguration(
            behavior:
                ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: SingleChildScrollView(
                controller: _headerHorizontalScrollController,
                scrollDirection: Axis.horizontal,
                child: _header(context: context, maxWidth: maxWidth))),
        Expanded(
            child: Scrollbar(
                isAlwaysShown: true,
                controller: _horizontalScrollController,
                child: _rows(context: context, maxWidth: maxWidth)))
      ]);
    });
  }

  Widget _header({required BuildContext context, required double maxWidth}) {
    List<Widget> children = [];
    for (int columnIndex = 0;
        columnIndex < widget.columns.length;
        columnIndex++) {
      EasyTableColumn<ROW_VALUE> column = widget.columns[columnIndex];
      children.add(_headerCell(
          context: context,
          column: column,
          columnIndex: columnIndex,
          columnWidth: _columnWidths[columnIndex],
          columnGap: widget.columnGap));
    }
    return Container(
        child: Row(children: children),
        width: maxWidth,
        decoration: widget.headerDecoration);
  }

  Widget _rows({required BuildContext context, required double maxWidth}) {
    return Scrollbar(
        isAlwaysShown: true,
        controller: _verticalScrollController,
        notificationPredicate: (p) {
          return true;
        },
        child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _horizontalScrollController,
            child: SizedBox(
                child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context)
                        .copyWith(scrollbars: false),
                    child: ListView.builder(
                        controller: _verticalScrollController,
                        itemExtent: widget.rowHeight + widget.rowGap,
                        itemBuilder: (context, index) {
                          return _row(context: context, rowIndex: index);
                        },
                        itemCount: widget.length)),
                width: maxWidth)));
  }

  Widget _row({required BuildContext context, required int rowIndex}) {
    ROW_VALUE row = widget.rows![rowIndex];
    List<Widget> children = [];
    for (int columnIndex = 0;
        columnIndex < widget.columns.length;
        columnIndex++) {
      EasyTableColumn<ROW_VALUE> column = widget.columns[columnIndex];
      children.add(_cell(
          context: context,
          rowValue: row,
          column: column,
          rowIndex: rowIndex,
          rowHeight: widget.rowHeight,
          columnWidth: _columnWidths[columnIndex],
          columnGap: widget.columnGap));
    }
    Widget rowWidget = Row(children: children);

    if (widget.rowColor != null) {
      rowWidget =
          Container(child: rowWidget, color: widget.rowColor!(rowIndex));
    }
    if (widget.rowGap > 0) {
      rowWidget = Padding(
          child: rowWidget, padding: EdgeInsets.only(bottom: widget.rowGap));
    }

    return rowWidget;
  }

  Widget _cell(
      {required BuildContext context,
      required ROW_VALUE rowValue,
      required EasyTableColumn<ROW_VALUE> column,
      required int rowIndex,
      required double rowHeight,
      required double columnWidth,
      required double columnGap}) {
    double width = columnWidth;
    Widget cellWidget = column.cellBuilder(context, rowValue, rowIndex);
    EdgeInsetsGeometry? padding;
    if (columnGap > 0) {
      width += columnGap;
      padding = EdgeInsets.only(right: columnGap);
    }
    if (widget.cellPadding != null) {
      if (padding != null) {
        padding = widget.cellPadding!.add(padding);
      } else {
        padding = widget.cellPadding!;
      }
    }
    if (padding != null) {
      cellWidget = Padding(padding: padding, child: cellWidget);
    }
    return ConstrainedBox(
        constraints: BoxConstraints.tightFor(width: width, height: rowHeight),
        child: cellWidget);
  }

  Widget _headerCell(
      {required BuildContext context,
      required EasyTableColumn column,
      required int columnIndex,
      required double columnWidth,
      required double columnGap}) {
    double width = columnWidth;
    Widget? headerCellWidget;
    if (column.headerCellBuilder != null) {
      headerCellWidget =
          column.headerCellBuilder!(context, column, columnIndex);
    }
    EdgeInsetsGeometry? padding;
    if (columnGap > 0) {
      width += columnGap;
      padding = EdgeInsets.only(right: columnGap);
    }
    if (widget.headerCellPadding != null) {
      if (padding != null) {
        padding = widget.headerCellPadding!.add(padding);
      } else {
        padding = widget.headerCellPadding!;
      }
    }
    if (padding != null) {
      headerCellWidget = Padding(padding: padding, child: headerCellWidget);
    }
    return ConstrainedBox(
        constraints: BoxConstraints.tightFor(width: width),
        child: headerCellWidget);
  }
}
