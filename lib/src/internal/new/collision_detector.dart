import 'package:meta/meta.dart';

/// Designed to efficiently track grid cells that are part of a span
/// and determine if each cell has an associated value.
/// This class helps optimize grid operations by providing
/// quick access to information about span usage and value presence.
@internal
class CollisionDetector {
  final Set<_CellSpan> _cache = {};

  void clear(){
    _cache.clear();
  }

  void add(
      {required int rowIndex,
      required int columnIndex,
      required int rowSpan,
      required int columnSpan}) {
    if (rowSpan > 1 || columnSpan > 1) {
      _cache.add(_CellSpan(
          rowIndex: rowIndex,
          columnIndex: columnIndex,
          rowSpan: rowSpan,
          columnSpan: columnSpan));
    }
  }

  bool intersects(
      {required int rowIndex,
      required int columnIndex,
      required int rowSpan,
      required int columnSpan}) {
    for (_CellSpan cellSpan in _cache) {
      if (cellSpan.intersects(
          rowIndex: rowIndex,
          columnIndex: columnIndex,
          rowSpan: rowSpan,
          columnSpan: columnSpan)) {
        return true;
      }
    }
    return false;
  }
}

class _CellSpan {
  _CellSpan({
    required this.rowIndex,
    required this.columnIndex,
    required this.rowSpan,
    required this.columnSpan,
  });

  final int rowIndex;
  final int columnIndex;
  final int rowSpan;
  final int columnSpan;

  bool intersectsFrom(_CellSpan other) {
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
          other is _CellSpan &&
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