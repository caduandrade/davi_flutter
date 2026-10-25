import 'dart:async';

import 'package:davi/src/internal/viewport_state.dart';
import 'package:flutter/widgets.dart';

/// Traverses logical cells, including rows which have not been built yet.
/// Only mounted cells own focus nodes; searching does not retain offscreen rows.
class CellFocusTraversalPolicy extends OrderedTraversalPolicy {
  CellFocusTraversalPolicy({
    required this.rowCount,
    required this.columnCount,
    required this.hasWidgets,
    required this.reveal,
  });

  final int Function() rowCount;
  final int Function() columnCount;
  final bool Function(int column) hasWidgets;
  final Future<void> Function(CellMapping cell, bool Function() active) reveal;
  final FocusNode parkingNode = FocusNode(debugLabel: 'Davi traversal');
  final Map<CellMapping, FocusNode> cells = {};
  final List<bool> _queue = [];
  final _TraversalState _state = _TraversalState();

  void cancel() {
    _state.generation++;
    _queue.clear();
    if (parkingNode.hasPrimaryFocus) parkingNode.unfocus();
  }

  void dispose() {
    _state.disposed = true;
    cancel();
    parkingNode.dispose();
  }

  CellMapping? _mapping(FocusNode node) {
    for (final entry in cells.entries) {
      if (node.ancestors.contains(entry.value)) {
        return entry.key;
      }
    }
    return null;
  }

  List<FocusNode> _nodes(CellMapping cell) {
    final root = cells[cell];
    if (root == null) return [];
    return super.sortDescendants(root.traversalDescendants, root).toList();
  }

  @override
  Iterable<FocusNode> sortDescendants(
      Iterable<FocusNode> descendants, FocusNode currentNode) {
    final nodes = descendants.toList();
    final hasParkingNode = nodes.remove(parkingNode);
    final sorted = super.sortDescendants(nodes, currentNode).toList();
    // The parking node is normally skipped. When focused at the logical
    // table edge, it lets Flutter continue traversal outside the table.
    if (hasParkingNode) {
      sorted.insert(_state.forward ? sorted.length : 0, parkingNode);
    }
    return sorted;
  }

  @override
  bool next(FocusNode currentNode) => _enqueue(currentNode, true);

  @override
  bool previous(FocusNode currentNode) => _enqueue(currentNode, false);

  bool _enqueue(FocusNode currentNode, bool forward) {
    if (!_state.running && _mapping(currentNode) == null) {
      return forward ? super.next(currentNode) : super.previous(currentNode);
    }
    _queue.add(forward);
    if (!_state.running) unawaited(_drain());
    return true;
  }

  Future<void> _drain() async {
    _state.running = true;
    try {
      while (!_state.disposed && _queue.isNotEmpty) {
        final forward = _queue.removeAt(0);
        final current = FocusManager.instance.primaryFocus;
        final mapping = current == null ? null : _mapping(current);
        if (mapping == null) break;
        await _move(current!, mapping, forward);
      }
    } finally {
      _queue.clear();
      _state.running = false;
    }
  }

  Future<void> _move(
      FocusNode source, CellMapping mapping, bool forward) async {
    final generation = _state.generation;
    final rows = rowCount();
    final columns = columnCount();
    bool active() =>
        !_state.disposed &&
        generation == _state.generation &&
        rowCount() == rows &&
        columnCount() == columns &&
        (FocusManager.instance.primaryFocus == source ||
            parkingNode.hasPrimaryFocus);

    final siblings = _nodes(mapping);
    final siblingIndex = siblings.indexOf(source) + (forward ? 1 : -1);
    _state.forward = forward;
    parkingNode.requestFocus();
    // Apply the parking focus before a scroll recycles the source widget.
    await WidgetsBinding.instance.endOfFrame;
    if (!active()) return;
    if (siblingIndex >= 0 && siblingIndex < siblings.length) {
      await reveal(mapping, active);
      if (!active()) return;
      final updated = _nodes(mapping);
      if (siblingIndex < updated.length) updated[siblingIndex].requestFocus();
      await WidgetsBinding.instance.endOfFrame;
      return;
    }

    for (int index = mapping.rowIndex * columns +
            mapping.columnIndex +
            (forward ? 1 : -1);
        index >= 0 && index < rows * columns && active();
        index += forward ? 1 : -1) {
      final target =
          CellMapping(rowIndex: index ~/ columns, columnIndex: index % columns);
      if (!hasWidgets(target.columnIndex)) continue;
      if (!cells.containsKey(target)) await reveal(target, active);
      if (!active()) return;
      final nodes = _nodes(target);
      if (nodes.isEmpty) continue;
      await reveal(target, active);
      if (!active()) return;
      // Resolve again: scrolling/measurement may have rebuilt the cell.
      final updatedNodes = _nodes(target);
      if (updatedNodes.isEmpty) continue;
      (forward ? updatedNodes.first : updatedNodes.last).requestFocus();
      await WidgetsBinding.instance.endOfFrame;
      return;
    }
    if (active()) {
      if (forward) {
        super.next(parkingNode);
      } else {
        super.previous(parkingNode);
      }
      await WidgetsBinding.instance.endOfFrame;
    }
  }
}

class _TraversalState {
  bool running = false;
  bool disposed = false;
  bool forward = true;
  int generation = 0;
}

class CellFocusRegion extends StatefulWidget {
  const CellFocusRegion(
      {super.key,
      required this.policy,
      required this.mapping,
      required this.child});

  final CellFocusTraversalPolicy policy;
  final CellMapping mapping;
  final Widget child;

  @override
  State<CellFocusRegion> createState() => _CellFocusRegionState();
}

class _CellFocusRegionState extends State<CellFocusRegion> {
  final FocusNode _node =
      FocusNode(skipTraversal: true, canRequestFocus: false);

  @override
  void initState() {
    super.initState();
    widget.policy.cells[widget.mapping] = _node;
  }

  @override
  void dispose() {
    if (widget.policy.cells[widget.mapping] == _node) {
      widget.policy.cells.remove(widget.mapping);
    }
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      Focus(focusNode: _node, child: widget.child);
}
