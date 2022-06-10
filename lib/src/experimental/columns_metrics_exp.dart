import 'dart:math' as math;

import 'package:easy_table/src/column.dart';
import 'package:easy_table/src/model.dart';
import 'package:meta/meta.dart';
import 'package:collection/collection.dart';

@internal
enum ColumnFilterExp { all, pinnedOnly, unpinnedOnly }

@internal
class ColumnsMetricsExp {
  static const ColumnsMetricsExp empty =
      ColumnsMetricsExp._(columns: [], widths: [], offsets: [], hashCode: 0);

  factory ColumnsMetricsExp.resizable(
      {required EasyTableModel model,
      required double columnDividerThickness,
      required ColumnFilterExp filter}) {
    final List<EasyTableColumn> columns = [];
    final List<double> widths = [];
    final List<double> offsets = [];

    double offset = 0;

    for (int i = 0; i < model.columnsLength; i++) {
      final EasyTableColumn column = model.columnAt(i);
      if (filter == ColumnFilterExp.all ||
          (filter == ColumnFilterExp.unpinnedOnly && column.pinned == false) ||
          (filter == ColumnFilterExp.pinnedOnly && column.pinned)) {
        columns.add(column);
        widths.add(column.width);
        offsets.add(offset);
        offset += column.width + columnDividerThickness;
      }
    }

    IterableEquality iterableEquality = const IterableEquality();
    final int hashCode =
        iterableEquality.hash(columns) ^ iterableEquality.hash(widths);
    return ColumnsMetricsExp._(
        columns: UnmodifiableListView(columns),
        widths: UnmodifiableListView(widths),
        offsets: UnmodifiableListView(offsets),
        hashCode: hashCode);
  }

  factory ColumnsMetricsExp.columnsFit(
      {required EasyTableModel model,
      required double containerWidth,
      required double columnDividerThickness}) {
    final List<EasyTableColumn> columns = [];
    final List<double> widths = [];
    final List<double> offsets = [];

    double offset = 0;

    final int dividersLength = math.max(0, model.columnsLength - 1);
    final double availableWidth =
        math.max(0, containerWidth - (columnDividerThickness * dividersLength));
    final double columnWidthRatio = availableWidth / model.columnsWeight;

    for (int i = 0; i < model.columnsLength; i++) {
      final EasyTableColumn column = model.columnAt(i);
      columns.add(column);
      final double width = columnWidthRatio * column.weight;
      widths.add(width);
      offsets.add(offset);
      offset += width + columnDividerThickness;
    }

    IterableEquality iterableEquality = const IterableEquality();
    final int hashCode =
        iterableEquality.hash(columns) ^ iterableEquality.hash(widths);
    return ColumnsMetricsExp._(
        columns: UnmodifiableListView(columns),
        widths: UnmodifiableListView(widths),
        offsets: UnmodifiableListView(offsets),
        hashCode: hashCode);
  }

  const ColumnsMetricsExp._(
      {required this.columns,
      required this.widths,
      required this.offsets,
      required this.hashCode});

  final List<EasyTableColumn> columns;
  final List<double> widths;
  final List<double> offsets;

  @override
  final int hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColumnsMetricsExp &&
          runtimeType == other.runtimeType &&
          hashCode == other.hashCode;
}
