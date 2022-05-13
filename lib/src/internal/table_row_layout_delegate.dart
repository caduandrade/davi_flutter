import 'package:easy_table/src/internal/columns_metrics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

@internal
class TableRowLayoutDelegate extends MultiChildLayoutDelegate {
  TableRowLayoutDelegate({required this.columnsMetrics});

  final ColumnsMetrics columnsMetrics;

  @override
  void performLayout(Size size) {
    for (int columnIndex = 0;
        columnIndex < columnsMetrics.columns.length;
        columnIndex++) {
      if (hasChild(columnIndex)) {
        LayoutWidth layoutWidth = columnsMetrics.columns[columnIndex];
        layoutChild(
            columnIndex,
            BoxConstraints.tightFor(
                width: layoutWidth.width, height: size.height));
        positionChild(columnIndex, Offset(layoutWidth.x, 0));
      }
    }
  }

  @override
  bool shouldRelayout(covariant TableRowLayoutDelegate oldDelegate) => false;
}
