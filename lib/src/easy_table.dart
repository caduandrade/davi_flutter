import 'dart:math' as math;
import 'package:easy_table/src/easy_table_column.dart';
import 'package:flutter/widgets.dart';

typedef EasyTableRowColor = Color? Function(int rowIndex);

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
        itemExtent: widget.rowHeight + widget.rowGap,
        itemBuilder: (context, index) {
          return _rowWidget(context: context, rowIndex: index);
        },
        itemCount: widget.rows.length);
  }

  Widget _rowWidget({required BuildContext context, required int rowIndex}) {
    ROW_VALUE row = widget.rows[rowIndex];
    List<Widget> children = [];
    for (EasyTableColumn<ROW_VALUE> column in widget.columns) {
      children.add(column.buildCellWidget(
          context: context,
          rowValue: row,
          rowIndex: rowIndex,
          rowHeight: widget.rowHeight,
          columnWidth: column.initialWidth,
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
