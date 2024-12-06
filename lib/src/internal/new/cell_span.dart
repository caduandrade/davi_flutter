import 'package:meta/meta.dart';

@internal
class CellSpan {
  CellSpan({
    required this.rowIndex,
    required this.columnIndex,
    required this.rowSpan,
    required this.columnSpan,
  });

  final int rowIndex;
  final int columnIndex;
  final int rowSpan;
  final int columnSpan;

  bool intersectsFrom(CellSpan other) {
    return !(columnIndex + columnSpan <= other.columnIndex ||
        columnIndex >= other.columnIndex + other.columnSpan ||
        rowIndex + rowSpan <= other.rowIndex ||
        rowIndex >= other.rowIndex + other.rowSpan);
  }

  bool intersects({
    required int rowIndex,
    required int columnIndex,
    required int rowSpan,
    required int columnSpan,
  }) {
    return !(this.columnIndex + this.columnSpan <= columnIndex ||
        this.columnIndex >= columnIndex + columnSpan ||
        this.rowIndex + this.rowSpan <= rowIndex ||
        this.rowIndex >= rowIndex + rowSpan);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellSpan &&
          runtimeType == other.runtimeType &&
          rowIndex == other.rowIndex &&
          columnIndex == other.columnIndex &&
          rowSpan == other.rowSpan &&
          columnSpan == other.columnSpan;

  @override
  int get hashCode =>
      rowIndex.hashCode ^
      columnIndex.hashCode ^
      rowSpan.hashCode ^
      columnSpan.hashCode;
}
