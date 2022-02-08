import 'package:flutter/widgets.dart';

/// Signature for a function that creates a widget for a given column and row.
///
/// Used by [EasyTable].
typedef EasyTableCellBuilder<ROW_VALUE> = Widget Function(
    BuildContext context, ROW_VALUE rowValue, int rowIndex);

typedef EasyTableHeaderBuilder = Widget Function(
    BuildContext context, EasyTableColumn column, int columnIndex);

class EasyTableColumn<ROW_VALUE> {
  EasyTableColumn(
      {required this.cellBuilder,
      this.initialWidth = 100,
      this.name,
      this.headerBuilder});

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
