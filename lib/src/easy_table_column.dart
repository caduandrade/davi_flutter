import 'package:easy_table/src/easy_table_cell_builder.dart';
import 'package:easy_table/src/easy_table_header_builder.dart';
import 'package:flutter/widgets.dart';

class EasyTableColumn<ROW_VALUE> {
  EasyTableColumn(
      {required this.cellBuilder,
      this.initialWidth = 100,
      this.name,
      this.headerBuilder = HeaderBuilders.defaultHeaderBuilder});

  final String? name;
  final double initialWidth;
  final EasyTableCellBuilder<ROW_VALUE> cellBuilder;
  final EasyTableHeaderBuilder? headerBuilder;

  Widget buildCellWidget(
      {required BuildContext context,
      required ROW_VALUE rowValue,
      required int rowIndex,
      required double rowHeight,
      required double columnWidth,
      required double columnGap}) {
    double width = columnWidth;
    Widget widget = cellBuilder(context, rowValue, rowIndex);
    if (columnGap > 0) {
      widget =
          Padding(padding: EdgeInsets.only(right: columnGap), child: widget);
      width += columnGap;
    }
    return ConstrainedBox(
        constraints: BoxConstraints.tightFor(width: width, height: rowHeight),
        child: widget);
  }
}
