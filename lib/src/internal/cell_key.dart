import 'package:flutter/widgets.dart';

/// Local key for each table cell
class CellKey extends LocalKey {
  final int row;
  final int column;
  final int rowSpan;
  final int columnSpan;

  const CellKey(
      {required this.row,
      required this.column,
      required this.rowSpan,
      required this.columnSpan});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellKey &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          column == other.column &&
          rowSpan == other.rowSpan &&
          columnSpan == other.columnSpan;

  @override
  int get hashCode =>
      row.hashCode ^ column.hashCode ^ rowSpan.hashCode ^ columnSpan.hashCode;
}
