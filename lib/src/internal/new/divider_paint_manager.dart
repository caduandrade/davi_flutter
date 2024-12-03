import 'package:davi/src/internal/new/cells_layout_parent_data.dart';
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
  final Map<int, _DividerNodes> _horizontalNodes = {};
  final Map<int, _DividerNodes> _verticalNodes = {};

  void setup(
      {required int firstRowIndex,
      required int lastRowIndex,
      required int columnsLength}) {
    List<int> rowIndices = List.generate(
        lastRowIndex - firstRowIndex + 1, (index) => firstRowIndex + index);
    List<int> columnIndices = List.generate(columnsLength, (index) => index);

    _horizontalNodes.clear();
    _verticalNodes.clear();

    for (int row = firstRowIndex; row <= lastRowIndex; row++) {
      _horizontalNodes[row] = _DividerNodes(index: row, indices: columnIndices);
    }
    for (int column = 0; column < columnsLength; column++) {
      _verticalNodes[column] =
          _DividerNodes(index: column, indices: rowIndices);
    }
  }

  Iterable<DividerSegment> verticalSegments({required int column}) sync* {
    _DividerNodes nodes = _verticalNodes[column]!;
    yield* nodes.segments();
  }

  Iterable<DividerSegment> horizontalSegments({required int row}) sync* {
    _DividerNodes? nodes = _horizontalNodes[row];
    if (nodes == null) {
      throw StateError('No horizontal segments for row $row');
    }
    yield* nodes.segments();
  }

  void add(CellsLayoutParentData parentData) {
    final int rowIndex = parentData.rowIndex!;
    final int columnIndex = parentData.columnIndex!;
    final int rowSpan = parentData.rowSpan!;
    final int columnSpan = parentData.columnSpan!;

    if (!parentData.isCell) {
      //TODO add trailing?
      return;
    }

    // horizontal nodes
    for (int ri = rowIndex; ri < rowIndex + rowSpan - 1; ri++) {
      _DividerNodes horizontalNodes = _horizontalNodes[ri]!;
      for (int ci = columnIndex; ci < columnIndex + columnSpan; ci++) {
        if (ci == 0) {
          horizontalNodes.start.lock();
        } else {
          horizontalNodes.middle(ci - 1).lock();
        }
        horizontalNodes.middle(ci).lock();
      }
    }

    // vertical nodes
    for (int ci = columnIndex; ci < columnIndex + columnSpan - 1; ci++) {
      _DividerNodes verticalNodes = _verticalNodes[ci]!;
      for (int ri = rowIndex; ri < rowIndex + rowSpan; ri++) {
        if (ri == 0) {
          verticalNodes.start.lock();
        } else {
          verticalNodes.middle(ri - 1).lock();
        }
        verticalNodes.middle(ri).lock();
      }
    }
  }
}

/// Represents each point between row or column dividers in the grid,
/// including special edge points at the start or end of a line.
class DividerNode {
  DividerNode.edge()
      : edge = true,
        index = -1;
  DividerNode.middle(this.index) : edge = false;

  final bool edge;
  final int index;
  bool _locked = false;
  bool get locked => _locked;
  void lock() {
    _locked = true;
  }

  DividerNode? _next;
  DividerNode? get next => _next;

  @override
  String toString() {
    return 'DividerNode{edge: $edge, index: $index}';
  }
}

class DividerSegment {
  DividerSegment({required this.start, required this.end});

  final DividerNode start;
  final DividerNode end;

  @override
  String toString() {
    return 'DividerSegment{start: $start, end: $end}';
  }
}

class _DividerNodes {
  _DividerNodes({required this.index, required List<int> indices}) {
    start = DividerNode.edge();
    DividerNode current = start;
    for (var index in indices) {
      DividerNode nextNode = DividerNode.middle(index);
      _middles[index] = nextNode;
      current._next = nextNode;
      current = nextNode;
    }
    end = DividerNode.edge();
    current._next = end;
  }

  final int index;

  late final DividerNode start;
  late final DividerNode end;
  final Map<int, DividerNode> _middles = {};

  DividerNode middle(int index) => _middles[index]!;

  Iterable<DividerSegment> segments() sync* {
    DividerNode current = start;

    while (current.next != null) {
      DividerNode next = current.next!;

      if (current.locked && next.locked) {
        current = next;
        continue;
      }

      while (!next.locked && next.next != null) {
        next = next.next!;
      }
      yield DividerSegment(start: current, end: next);

      current = next;
    }
  }
}
