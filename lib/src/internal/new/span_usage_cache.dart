import 'package:meta/meta.dart';

/// Designed to efficiently track grid cells that are part of a span
/// and determine if each cell has an associated value.
/// This class helps optimize grid operations by providing
/// quick access to information about span usage and value presence.
@internal
class SpanUsageCache {
  final Map<int, Set<int>> _rowsAndColumns = {};

  int get count {
    int count = 0;
    for (Set<int> set in _rowsAndColumns.values) {
      count += set.length;
    }
    return count;
  }

  void add(
      {required int rowIndex,
      required int columnIndex,
      required int rowSpan,
      required int columnSpan}) {
    if (rowSpan > 1 || columnSpan > 1) {
      for (int r = rowIndex; r < rowIndex + rowSpan; r++) {
        Set<int>? columns = _rowsAndColumns[r];
        if (columns == null) {
          columns = {};
          _rowsAndColumns[r] = columns;
        }
        for (int c = columnIndex; c < columnIndex + columnSpan; c++) {
          columns.add(c);
        }
      }
    }
  }

  bool intercepts(
      {required int rowIndex,
      required int columnIndex,
      required int rowSpan,
      required int columnSpan}) {
    for (int r = rowIndex; r < rowIndex + rowSpan; r++) {
      Set<int>? columns = _rowsAndColumns[r];
      if (columns != null) {
        for (int c = columnIndex; c < columnIndex + columnSpan; c++) {
          if (columns.contains(c)) {
            return true;
          }
        }
      }
    }
    return false;
  }
}
