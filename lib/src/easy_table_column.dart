import 'package:flutter/widgets.dart';

/// Signature for a function that creates a widget for a given column and row.
///
/// Used by [EasyTable].
typedef EasyTableCellWidgetBuilder<ROW> = Widget Function(
    BuildContext context, ROW row, int rowIndex);

class EasyTableColumn<ROW> {
  EasyTableColumn({required this.cellBuilder, this.initialWidth = 100});

  final double initialWidth;
  final EasyTableCellWidgetBuilder<ROW> cellBuilder;

  Widget buildCellWidget(
      {required BuildContext context,
      required ROW row,
      required int rowIndex,
      required double rowHeight,
      required double columnWidth,
      required double columnGap,
      required double rowGap}) {
    double width = columnWidth;
    double height = rowHeight;
    Widget widget = cellBuilder(context, row, rowIndex);
    if (columnGap > 0 || rowGap > 0) {
      widget = Padding(
          padding: EdgeInsets.only(right: columnGap, bottom: rowGap),
          child: widget);
      width += columnGap;
      height += rowGap;
    }
    return ConstrainedBox(
        constraints: BoxConstraints.tightFor(width: width, height: height),
        child: widget);
  }
}
