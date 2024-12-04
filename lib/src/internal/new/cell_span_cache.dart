import 'package:davi/src/internal/new/cell_span.dart';
import 'package:meta/meta.dart';

/// Designed to efficiently track grid cells that are part of a span
/// and determine if each cell has an associated value.
/// This class helps optimize grid operations by providing
/// quick access to information about span usage and value presence.
@internal
class CellSpanCache {
  final Set<CellSpan> _cache = {};

  void add(
      {required int rowIndex,
      required int columnIndex,
      required int rowSpan,
      required int columnSpan}) {
    if (rowSpan > 1 || columnSpan > 1) {
      _cache.add(CellSpan(
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
    for (CellSpan cellSpan in _cache) {
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
