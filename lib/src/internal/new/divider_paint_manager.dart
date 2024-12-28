import 'package:meta/meta.dart';

/// Designed to manage and determine the grid dividers that need to be painted.
///
/// It works by first mapping all possible divider connections within the grid
/// (e.g., between cells like (0,0) to (1,0) or (0,0) to (0,1)).
///
/// As the grid's layout is processed, including spans that merge cells,
/// the manager dynamically updates its internal mapping by removing dividers
/// that are covered by the merged areas.
///
/// Once the layout processing is complete, the [DividerPaintManager] retains
/// only the dividers that should be visually rendered.
/// This ensures the painted dividers accurately represent
/// the grid's structure while accounting for merged cells.
@internal
class DividerPaintManager {
  final Map<int, _DividerVertices> _horizontalVertices = {};
  final Map<int, _DividerVertices> _verticalVertices = {};

  int? _firstRowIndex;

  void clear(){
    _horizontalVertices.clear();
    _verticalVertices.clear();
  }

  void reset(
      {required int firstRowIndex,
      required int lastRowIndex,
      required int columnsLength}) {
    List<int> rowIndices = List.generate(
        lastRowIndex - firstRowIndex + 1, (index) => firstRowIndex + index);
    List<int> columnIndices = List.generate(columnsLength, (index) => index);

    _horizontalVertices.clear();
    _verticalVertices.clear();
    _firstRowIndex = firstRowIndex;


    //for (int ri = rowIndex; ri < rowIndex + rowSpan - 1; ri++) {

    for (int row = firstRowIndex; row <= lastRowIndex; row++) {
      _horizontalVertices[row] =
          _DividerVertices(index: row, indices: columnIndices);
    }
    for (int column = 0; column < columnsLength; column++) {
      _verticalVertices[column] =
          _DividerVertices(index: column, indices: rowIndices);
    }
  }

  List<DividerVertex> allHorizontalVerticesFrom({required int row}) {
    _DividerVertices? dividerVertices = _horizontalVertices[row];
    if (dividerVertices != null) {
      return _collectVertices(dividerVertices.start);
    }
    return [];
  }

  List<DividerVertex> allVerticalVerticesFrom({required int column}) {
    _DividerVertices? dividerVertices = _verticalVertices[column];
    if (dividerVertices != null) {
      return _collectVertices(dividerVertices.start);
    }
    return [];
  }

  List<DividerVertex> _collectVertices(DividerVertex start) {
    List<DividerVertex> vertices = [];
    DividerVertex? current = start;

    while (current != null) {
      vertices.add(current);
      current = current.next;
    }

    return vertices;
  }

  Iterable<DividerSegment> verticalSegments({required int column}) sync* {
    _DividerVertices vertices = _verticalVertices[column]!;
    yield* vertices.segments();
  }

  Iterable<DividerSegment> horizontalSegments({required int row}) sync* {
    _DividerVertices? vertices = _horizontalVertices[row];
    if (vertices == null) {
      throw StateError('No horizontal segments for row $row');
    }
    yield* vertices.segments();
  }

  void addStopsForEntireRow({required int rowIndex, required bool horizontal}) {
    // Updating vertical vertices stop
    for (_DividerVertices verticalVertices in _verticalVertices.values) {
      if (rowIndex == _firstRowIndex) {
        verticalVertices.start._stop = true;
      } else {
        verticalVertices.middle(rowIndex - 1)._stop = true;
      }
    }

    // Updating horizontal vertices stop
    if (horizontal) {
      _DividerVertices horizontalVertices = _horizontalVertices[rowIndex]!;
      horizontalVertices.stopAll();
    }
  }

  void addStopsForCell(
      {required int rowIndex,
      required int columnIndex,
      required int rowSpan,
      required int columnSpan}) {
    // Updating vertical vertices stop
    for (int ci = columnIndex; ci < columnIndex + columnSpan - 1; ci++) {
      _DividerVertices verticalVertices = _verticalVertices[ci]!;
      for (int ri = rowIndex; ri < rowIndex + rowSpan; ri++) {
        if (ri == _firstRowIndex) {
          verticalVertices.start._stop = true;
        } else {
          verticalVertices.middle(ri - 1)._stop = true;
        }
      }
    }

    // Updating horizontal vertices stop
    for (int ri = rowIndex; ri < rowIndex + rowSpan - 1; ri++) {
      _DividerVertices? horizontalVertices = _horizontalVertices[ri];
      if(horizontalVertices==null) {
        throw StateError('No horizontal vertices for rowIndex $ri');
      }
      for (int ci = columnIndex; ci < columnIndex + columnSpan; ci++) {
        if (ci == 0) {
          horizontalVertices.start._stop = true;
        } else {
          horizontalVertices.middle(ci - 1)._stop = true;
        }
      }
    }
  }
}

/// Represents each point between row or column dividers in the grid,
/// including special edge points at the start or end of a line.
class DividerVertex {
  DividerVertex.edge()
      : edge = true,
        index = -1;
  DividerVertex.middle(this.index) : edge = false;

  final bool edge;
  final int index;
  bool _stop = false;
  bool get stop => _stop;

  DividerVertex? _next;
  DividerVertex? get next => _next;

  @override
  String toString() {
    return 'DividerVertex{edge: $edge, index: $index}';
  }
}

@internal
class DividerSegment {
  DividerSegment({required this.start, required this.end});

  final DividerVertex start;
  final DividerVertex end;

  @override
  String toString() {
    return 'DividerSegment{start: $start, end: $end}';
  }
}

class _DividerVertices {
  _DividerVertices({required this.index, required List<int> indices}) {
    DividerVertex current = start;
    for (var index in indices) {
      DividerVertex next = DividerVertex.middle(index);
      _middles[index] = next;
      current._next = next;
      current = next;
    }
    current._next = end;
  }

  final int index;

  final DividerVertex start = DividerVertex.edge();
  final DividerVertex end = DividerVertex.edge();
  final Map<int, DividerVertex> _middles = {};

  void stopAll() {
    start._stop = true;
    end._stop = true;
    for (DividerVertex vertex in _middles.values) {
      vertex._stop = true;
    }
  }

  DividerVertex middle(int index) {
    DividerVertex? vertex = _middles[index];
    if (vertex == null) {
      throw StateError(
          "No middle vertex for index $index. Current indices: ${_middles.keys}");
    }
    return vertex;
  }

  Iterable<DividerSegment> segments() sync* {
    DividerVertex current = start;

    while (current.next != null) {
      DividerVertex next = current.next!;

      if (current.stop) {
        current = next;
        continue;
      }

      while (!next.stop && next.next != null) {
        next = next.next!;
      }
      yield DividerSegment(start: current, end: next);

      current = next;
    }
  }
}
