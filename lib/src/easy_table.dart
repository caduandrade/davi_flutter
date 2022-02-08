import 'dart:math' as math;
import 'package:easy_table/src/easy_table_column.dart';
import 'package:easy_table/src/easy_table_row_color.dart';
import 'package:flutter/widgets.dart';

class EasyTable<ROW_VALUE> extends StatefulWidget {
//TODO handle negative values
//TODO allow null and use defaults?
  const EasyTable(
      {Key? key,
      required this.columns,
      required this.rows,
      this.rowHeight = 28,
      this.columnGap = 4,
      this.rowGap = 0,
      this.horizontalScrollController,
      this.verticalScrollController,
      this.rowColor})
      : super(key: key);

  final double columnGap;
  final double rowGap;
  final double rowHeight;
  final List<EasyTableColumn<ROW_VALUE>> columns;
  final List<ROW_VALUE> rows;
  final ScrollController? horizontalScrollController;
  final ScrollController? verticalScrollController;
  final EasyTableRowColor? rowColor;

  @override
  State<StatefulWidget> createState() => EasyTableState<ROW_VALUE>();
}

class EasyTableState<ROW_VALUE> extends State<EasyTable<ROW_VALUE>> {
  late ScrollController _verticalScrollController;

  final List<double> _columnWidths = [];

  @override
  void initState() {
    super.initState();
    for (EasyTableColumn<ROW_VALUE> column in widget.columns) {
      _columnWidths.add(column.initialWidth);
    }
    _verticalScrollController =
        widget.verticalScrollController ?? ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _header(context: context),
      Expanded(child: _content(context: context))
    ]);
  }

  Widget _header({required BuildContext context}) {
    List<Widget> children = [];
    for (int columnIndex = 0;
        columnIndex < widget.columns.length;
        columnIndex++) {
      EasyTableColumn<ROW_VALUE> column = widget.columns[columnIndex];
      double width = _columnWidths[columnIndex];
      Widget? header;
      if (column.headerBuilder != null) {
        header = column.headerBuilder!(context, column, columnIndex);
      }
      children.add(ConstrainedBox(
          constraints: BoxConstraints.tightFor(width: width), child: header));
    }
    return Row(children: children);
  }

  Widget _content({required BuildContext context}) {
    return ListView.builder(
        controller: _verticalScrollController,
        itemExtent: widget.rowHeight + widget.rowGap,
        itemBuilder: (context, index) {
          return _rowWidget(context: context, rowIndex: index);
        },
        itemCount: widget.rows.length);
  }

  Widget _rowWidget({required BuildContext context, required int rowIndex}) {
    ROW_VALUE row = widget.rows[rowIndex];
    List<Widget> children = [];
    for (int columnIndex = 0;
        columnIndex < widget.columns.length;
        columnIndex++) {
      EasyTableColumn<ROW_VALUE> column = widget.columns[columnIndex];
      children.add(column.buildCellWidget(
          context: context,
          rowValue: row,
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
}
