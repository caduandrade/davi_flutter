import 'dart:math' as math;
import 'dart:collection';

import 'package:easy_table/src/column.dart';
import 'package:easy_table/src/model.dart';
import 'package:meta/meta.dart';

@internal
class ColumnsMetrics {
  factory ColumnsMetrics(
      {required EasyTableModel model,
      required bool columnsFit,
      required double containerWidth,
      required double columnDividerThickness}) {
    List<LayoutWidth> columnsWidth = [];
    List<LayoutWidth> dividersWidth = [];

    double x = 0;

    if (columnsFit) {
      double availableWidth = containerWidth;
      availableWidth = math.max(
          0, availableWidth - (columnDividerThickness * model.columnsLength));

      double columnWidth = availableWidth / model.columnsLength;
      for (int i = 0; i < model.columnsLength; i++) {
        LayoutWidth layoutWidth = LayoutWidth(x: x, width: columnWidth);
        columnsWidth.add(layoutWidth);
        x += layoutWidth.width;

        dividersWidth.add(LayoutWidth(width: columnDividerThickness, x: x));
        x += columnDividerThickness;
      }
    } else {
      for (int i = 0; i < model.columnsLength; i++) {
        EasyTableColumn column = model.columnAt(i);
        LayoutWidth layoutWidth = LayoutWidth(x: x, width: column.width);
        columnsWidth.add(layoutWidth);
        x += layoutWidth.width;
        dividersWidth.add(LayoutWidth(width: columnDividerThickness, x: x));
        x += columnDividerThickness;
      }
    }

    return ColumnsMetrics._(
        columns: UnmodifiableListView(columnsWidth),
        dividers: UnmodifiableListView(dividersWidth));
  }

  ColumnsMetrics._({required this.columns, required this.dividers});

  final List<LayoutWidth> columns;
  final List<LayoutWidth> dividers;
}

class LayoutWidth {
  LayoutWidth({required this.width, required this.x});

  final double width;
  final double x;
}
