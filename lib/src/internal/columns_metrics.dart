import 'dart:math' as math;
import 'dart:collection';

import 'package:easy_table/src/column.dart';
import 'package:easy_table/src/model.dart';
import 'package:meta/meta.dart';

@internal
enum ColumnFilter { all, pinnedOnly, unpinnedOnly }

@internal
class ColumnsMetrics {
  factory ColumnsMetrics.resizable(
      {required EasyTableModel model,
      required double columnDividerThickness,
      required ColumnFilter filter}) {
    List<LayoutWidth> columnsWidth = [];
    List<LayoutWidth> dividersWidth = [];

    double x = 0;

    for (int i = 0; i < model.columnsLength; i++) {
      EasyTableColumn column = model.columnAt(i);
      if (filter == ColumnFilter.all ||
          (filter == ColumnFilter.unpinnedOnly && column.pinned == false) ||
          (filter == ColumnFilter.pinnedOnly && column.pinned)) {
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

  factory ColumnsMetrics.columnsFit(
      {required EasyTableModel model,
      required double containerWidth,
      required double columnDividerThickness}) {
    List<LayoutWidth> columnsWidth = [];
    List<LayoutWidth> dividersWidth = [];

    double x = 0;

    double availableWidth = containerWidth;
    final int count = model.columnsLength;
    availableWidth =
        math.max(0, availableWidth - (columnDividerThickness * count));

    double columnWidthRatio = availableWidth / model.columnsWeight;
    for (int i = 0; i < model.columnsLength; i++) {
      EasyTableColumn column = model.columnAt(i);
      double columnWidth = columnWidthRatio * column.weight;
      LayoutWidth layoutWidth = LayoutWidth(x: x, width: columnWidth);
      columnsWidth.add(layoutWidth);
      x += layoutWidth.width;

      dividersWidth.add(LayoutWidth(width: columnDividerThickness, x: x));
      x += columnDividerThickness;
    }

    return ColumnsMetrics._(
        columns: UnmodifiableListView(columnsWidth),
        dividers: UnmodifiableListView(dividersWidth));
  }

  ColumnsMetrics._({required this.columns, required this.dividers});

  final List<LayoutWidth> columns;
  final List<LayoutWidth> dividers;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColumnsMetrics &&
          runtimeType == other.runtimeType &&
          columns == other.columns &&
          dividers == other.dividers;

  @override
  int get hashCode => columns.hashCode ^ dividers.hashCode;
}

class LayoutWidth {
  LayoutWidth({required this.width, required this.x});

  final double width;
  final double x;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LayoutWidth &&
          runtimeType == other.runtimeType &&
          width == other.width &&
          x == other.x;

  @override
  int get hashCode => width.hashCode ^ x.hashCode;
}
