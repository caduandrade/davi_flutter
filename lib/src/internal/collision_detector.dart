import 'package:meta/meta.dart';

/// Designed to efficiently track grid cells that are part of a span
/// and determine if each cell has an associated value.
/// This class helps optimize grid operations by providing
/// quick access to information about span usage and value presence.
@internal
class CollisionDetector {
  final Set<_CellSpan> _singleSpans = {};
  final Set<_CellSpan> _multiSpans = {};

  void clear() {
    _singleSpans.clear();
    _multiSpans.clear();
  }

  void add(
      {required int rowIndex,
      required int columnIndex,
      required int rowSpan,
      required int columnSpan}) {
    _CellSpan span = _CellSpan(
        rowIndex: rowIndex,
        columnIndex: columnIndex,
        rowSpan: rowSpan,
        columnSpan: columnSpan);
    if (rowSpan > 1 || columnSpan > 1) {
      _multiSpans.add(span);
    } else {
      _singleSpans.add(span);
    }
  }

  bool intersects(
      {required int rowIndex,
      required int columnIndex,
      required int rowSpan,
      required int columnSpan}) {
    if (rowSpan > 1 || columnSpan > 1) {
      // single will never intersect other single
      for (_CellSpan cellSpan in _singleSpans) {
        if (cellSpan.intersects(
            rowIndex: rowIndex,
            columnIndex: columnIndex,
            rowSpan: rowSpan,
            columnSpan: columnSpan)) {
          return true;
        }
      }
    }
    for (_CellSpan cellSpan in _multiSpans) {
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
    final int thisRowEnd = this.rowIndex + this.rowSpan;
    final int thisColEnd = this.columnIndex + this.columnSpan;
    final int otherRowEnd = rowIndex + rowSpan;
    final int otherColEnd = columnIndex + columnSpan;

    return !(thisRowEnd <= rowIndex || // It's above
        this.rowIndex >= otherRowEnd || // It's below
        thisColEnd <= columnIndex || // It's on the left
        this.columnIndex >= otherColEnd); // It's on the right
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
