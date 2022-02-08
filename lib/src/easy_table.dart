import 'package:easy_table/src/easy_table_column.dart';
import 'package:flutter/material.dart';

typedef EasyTableRowColor = Color? Function(int rowIndex);

class EasyTable<ROW> extends StatefulWidget {
  const EasyTable(
      {Key? key,
      required this.columns,
      required this.rows,
      this.rowHeight = 50,
      this.horizontalScrollController,
      this.verticalScrollController,
      this.easyTableRowColor})
      : super(key: key);

  final double columnGap = 5;
  final double rowGap = 5;
  final double rowHeight;
  final List<EasyTableColumn<ROW>> columns;
  final List<ROW> rows;
  final ScrollController? horizontalScrollController;
  final ScrollController? verticalScrollController;
  final EasyTableRowColor? easyTableRowColor;

  @override
  State<StatefulWidget> createState() => EasyTableState<ROW>();
}

class EasyTableState<ROW> extends State<EasyTable<ROW>> {
  late ScrollController _verticalScrollController;

  @override
  void initState() {
    super.initState();
    _verticalScrollController =
        widget.verticalScrollController ?? ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return _tableContent(context: context);
  }

  Widget _tableContent({required BuildContext context}) {
    return ListView.builder(
        controller: _verticalScrollController,
        itemExtent: widget.rowHeight,
        itemBuilder: (context, index) {
          return _rowWidget(context: context, rowIndex: index);
        },
        itemCount: widget.rows.length);
  }

  Widget _rowWidget({required BuildContext context, required int rowIndex}) {
    Color? rowColor;
    if (widget.easyTableRowColor != null) {
      rowColor = widget.easyTableRowColor!(rowIndex);
    }
    ROW row = widget.rows[rowIndex];
    List<Widget> children = [];
    for (EasyTableColumn<ROW> column in widget.columns) {
      children.add(column.buildCellWidget(
          context: context,
          row: row,
          rowIndex: rowIndex,
          rowHeight: widget.rowHeight,
          columnWidth: column.initialWidth,
          columnGap: widget.columnGap,
          rowGap: widget.rowGap));
    }
    Widget rowWidget = Row(children: children);
    if (rowColor != null) {
      rowWidget = Container(child: rowWidget, color: rowColor);
    }
    return rowWidget;
  }
}
