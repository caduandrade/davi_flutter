import 'dart:math' as math;

import 'package:easy_table/src/column.dart';
import 'package:easy_table/src/experimental/content_area_id.dart';
import 'package:easy_table/src/model.dart';
import 'package:meta/meta.dart';
import 'package:collection/collection.dart';

@internal
class ColumnsMetricsExp<ROW> {
  factory ColumnsMetricsExp.empty() {
    return const ColumnsMetricsExp._(
        columns: [], widths: [], offsets: [], maxWidth: 0, hashCode: 0);
  }

  factory ColumnsMetricsExp.resizable(
      {required EasyTableModel<ROW> model,
      required double columnDividerThickness,
      required ContentAreaId contentAreaId}) {
    final List<EasyTableColumn<ROW>> columns = [];
    final List<double> widths = [];
    final List<double> offsets = [];

    double offset = 0;
    double maxWidth = 0;
    for (int i = 0; i < model.columnsLength; i++) {
      final EasyTableColumn<ROW> column = model.columnAt(i);
      if ((contentAreaId == ContentAreaId.unpinned && column.pinned == false) ||
          (contentAreaId == ContentAreaId.leftPinned && column.pinned)) {
        columns.add(column);
        widths.add(column.width);
        offsets.add(offset);
        maxWidth = column.width + offset;
        offset += column.width + columnDividerThickness;
      }
    }
    if (maxWidth > 0 && contentAreaId == ContentAreaId.unpinned) {
      maxWidth += columnDividerThickness;
    }

    IterableEquality iterableEquality = const IterableEquality();
    final int hashCode = iterableEquality.hash(columns) ^
        iterableEquality.hash(widths) ^
        iterableEquality.hash(offsets);

    return ColumnsMetricsExp._(
        columns: UnmodifiableListView(columns),
        widths: UnmodifiableListView(widths),
        offsets: UnmodifiableListView(offsets),
        maxWidth: maxWidth,
        hashCode: hashCode);
  }

  factory ColumnsMetricsExp.columnsFit(
      {required EasyTableModel<ROW> model,
      required double containerWidth,
      required double columnDividerThickness}) {
    final List<EasyTableColumn<ROW>> columns = [];
    final List<double> widths = [];
    final List<double> offsets = [];

    double offset = 0;
    int columnsLength = math.max(0, model.columnsLength - 1);
    final double availableWidth =
        math.max(0, containerWidth - (columnDividerThickness * columnsLength));
    final double columnWidthRatio = availableWidth / model.columnsWeight;

    double maxWidth = 0;
    for (int i = 0; i < model.columnsLength; i++) {
      final EasyTableColumn<ROW> column = model.columnAt(i);
      columns.add(column);
      final double width = columnWidthRatio * column.weight;
      widths.add(width);
      offsets.add(offset);
      maxWidth = column.width + offset;
      offset += width + columnDividerThickness;
    }

    IterableEquality iterableEquality = const IterableEquality();
    final int hashCode = iterableEquality.hash(columns) ^
        iterableEquality.hash(widths) ^
        iterableEquality.hash(offsets);
    return ColumnsMetricsExp._(
        columns: UnmodifiableListView(columns),
        widths: UnmodifiableListView(widths),
        offsets: UnmodifiableListView(offsets),
        maxWidth: maxWidth,
        hashCode: hashCode);
  }

  const ColumnsMetricsExp._(
      {required this.columns,
      required this.widths,
      required this.offsets,
      required this.maxWidth,
      required this.hashCode});

  final List<EasyTableColumn<ROW>> columns;
  final List<double> widths;
  final List<double> offsets;
  final double maxWidth;

  @override
  final int hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColumnsMetricsExp &&
          runtimeType == other.runtimeType &&
          hashCode == other.hashCode;
}
