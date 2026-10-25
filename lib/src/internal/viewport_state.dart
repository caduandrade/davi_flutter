import 'dart:collection';
import 'dart:math' as math;

import 'package:davi/src/data_source.dart';
import 'package:davi/src/internal/column_metrics.dart';
import 'package:davi/src/internal/divider_paint_manager.dart';
import 'package:davi/src/internal/row_extent_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@internal
class RowRegion implements Comparable<RowRegion> {
  RowRegion(
      {required this.index,
      required this.bounds,
      required this.hasData,
      required this.trailing,
      required this.visible});

  final int index;
  final Rect bounds;
  final bool hasData;
  final bool trailing;
  final bool visible;

  @override
  int compareTo(RowRegion other) => index.compareTo(other.index);
}

@internal
class RowRegionCache {
  final List<RowRegion> _list = [];
  final Map<int, RowRegion> _indexMap = {};

  late final Iterable<RowRegion> values = UnmodifiableListView(_list);

  int? _firstRowIndex;
  int? get firstRowIndex => _firstRowIndex;

  int? _lastRowIndex;
  int? get lastRowIndex => _lastRowIndex;

  RowRegion? get lastWithData {
    for (RowRegion rowRegion in _list.reversed) {
      if (rowRegion.hasData) {
        return rowRegion;
      }
    }
    return null;
  }

  RowRegion? _trailingRegion;

  RowRegion? get trailingRegion => _trailingRegion;

  void _add(RowRegion region) {
    if (region.trailing) {
      if (_trailingRegion != null) {
        throw StateError('Already exits trailing region.');
      }
      _trailingRegion = region;
    }
    _firstRowIndex = _firstRowIndex != null
        ? math.min(_firstRowIndex!, region.index)
        : region.index;
    _lastRowIndex = _lastRowIndex != null
        ? math.max(_lastRowIndex!, region.index)
        : region.index;
    _list.add(region);
    _indexMap[region.index] = region;
  }

  RowRegion get(int rowIndex) {
    RowRegion? region = _indexMap[rowIndex];
    if (region == null) {
      throw StateError('Non-existent row region for index $rowIndex');
    }
    return region;
  }

  int? boundsIndex(Offset position) {
    for (RowRegion rowBounds in _list) {
      if (rowBounds.bounds.contains(position)) {
        return rowBounds.index;
      }
    }
    return null;
  }

  void _clear() {
    _list.clear();
    _indexMap.clear();
    _firstRowIndex = null;
    _lastRowIndex = null;
    _trailingRegion = null;
  }
}

@internal
class ViewportState<DATA> extends ChangeNotifier {
  final Map<int, CellMapping> _cellMappings = {};
  final RowRegionCache rowRegions = RowRegionCache();
  final DividerPaintManager dividerPaintManager = DividerPaintManager();

  int _firstDataRow = -1;
  int get firstDataRow => _firstDataRow;

  int _firstRow = -1;
  int get firstRow => _firstRow;

  int _lastRow = -1;
  int get lastRow => _lastRow;

  int _lastDataRow = -1;
  int get lastDataRow => _lastDataRow;

  int _maxDataRowIndex = -1;
  int get maxDataRowIndex => _maxDataRowIndex;

  int _maxVisibleRowCount = 0;
  int get maxVisibleRowCount => _maxVisibleRowCount;

  int get mappedCellCount => _cellMappings.length;

  int _maxCellCount = 0;
  int get maxCellCount => _maxCellCount;

  double _verticalOffset = 0;
  double get verticalOffset => _verticalOffset;

  // Snapshot of the inputs that determine cell topology (mapping, spans,
  // collisions, divider structure) as of the last time that expensive work
  // was actually rebuilt. Used to skip it on scroll deltas that don't change
  // which rows/columns are visible.
  DaviDataSource<DATA>? _lastDataSource;
  int? _lastFirstRow;
  int? _lastMaxDataRowIndex;
  List<ColumnMetrics>? _lastColumnsMetrics;
  bool? _lastHasTrailing;
  bool? _lastRowFillHeight;
  double? _lastMaxWidth;

  // Stored so refreshRowRegions() can redo the (cheap) bounds-only rebuild
  // below without every caller having to re-supply the same viewport shape.
  double _maxWidth = 0;
  double _maxHeight = 0;
  bool _hasTrailing = false;
  DaviDataSource<DATA>? _dataSource;

  void reset(
      {required double verticalOffset,
      required List<ColumnMetrics> columnsMetrics,
      required RowExtentManager rowExtentManager,
      required double maxHeight,
      required double maxWidth,
      required DaviDataSource<DATA> dataSource,
      required bool hasTrailing,
      required bool rowFillHeight}) {
    _verticalOffset = verticalOffset;
    _maxWidth = maxWidth;
    _maxHeight = maxHeight;
    _hasTrailing = hasTrailing;
    _dataSource = dataSource;

    _firstDataRow = rowExtentManager.indexAtOffset(verticalOffset);

    _maxVisibleRowCount = rowExtentManager.viewportRowCount(
        scrollOffset: verticalOffset, availableHeight: maxHeight);

    // Minus 1 because the index starts at 0.
    // Example: number of visible rows is 2, the last index must be 1.
    _maxDataRowIndex = _firstDataRow + _maxVisibleRowCount - 1;

    _firstRow = math.max(0, _firstDataRow);

    _maxCellCount = _maxVisibleRowCount * dataSource.columnsLength;

    _rebuildRowRegions(rowExtentManager);

    // Everything below (cell mapping, divider topology) is O(visible rows x
    // columns) and only depends on which rows/columns are visible, not on
    // the exact scroll pixel offset. Skip it when nothing structural changed
    // since the last call, so a sub-row-height scroll delta (the common case
    // during a drag/fling) doesn't pay this cost on every frame.
    final bool topologyUnchanged = identical(_lastDataSource, dataSource) &&
        _lastFirstRow == _firstRow &&
        _lastMaxDataRowIndex == _maxDataRowIndex &&
        _lastHasTrailing == hasTrailing &&
        _lastRowFillHeight == rowFillHeight &&
        _lastMaxWidth == maxWidth &&
        listEquals(_lastColumnsMetrics, columnsMetrics);
    if (topologyUnchanged) {
      return;
    }
    _lastDataSource = dataSource;
    _lastFirstRow = _firstRow;
    _lastMaxDataRowIndex = _maxDataRowIndex;
    _lastHasTrailing = hasTrailing;
    _lastRowFillHeight = rowFillHeight;
    _lastMaxWidth = maxWidth;
    _lastColumnsMetrics = List.of(columnsMetrics);

    final Map<CellMapping, int> oldCellMappings = {
      for (var entry in _cellMappings.entries) entry.value: entry.key,
    };
    List<CellMapping> newCellMappings = [];

    _cellMappings.clear();

    final HashSet<int> indices = HashSet<int>.from(Iterable<int>.generate(
        (_maxDataRowIndex - _firstRow + 1) * columnsMetrics.length));
    for (int rowIndex = _firstRow; rowIndex <= _maxDataRowIndex; rowIndex++) {
      DATA? data;
      if (rowIndex < dataSource.rowsLength) {
        data = dataSource.rowAt(rowIndex);
      }
      if (data == null) {
        continue;
      }

      for (int columnIndex = 0;
          columnIndex < columnsMetrics.length;
          columnIndex++) {
        CellMapping cellMapping =
            CellMapping(rowIndex: rowIndex, columnIndex: columnIndex);

        int? oldCellIndex = oldCellMappings.remove(cellMapping);
        // A height correction can shrink the pool. Retain a recycled slot
        // only if its widget will still exist after that shrink; otherwise
        // move the cell into one of the new pool's available slots.
        if (oldCellIndex != null && oldCellIndex < _maxCellCount) {
          _cellMappings[oldCellIndex] = cellMapping;
          indices.remove(oldCellIndex);
        } else {
          newCellMappings.add(cellMapping);
        }
      }
    }
    for (int cellIndex in indices) {
      if (newCellMappings.isEmpty) {
        break;
      }
      CellMapping cellMapping = newCellMappings.removeAt(0);
      _cellMappings[cellIndex] = cellMapping;
    }

    dividerPaintManager.reset(
        firstRowIndex: _firstRow,
        lastRowIndex: _maxDataRowIndex,
        columnsLength: columnsMetrics.length);
    if (rowRegions.trailingRegion != null &&
        rowRegions.trailingRegion!.index >= _firstDataRow &&
        rowRegions.trailingRegion!.index <= _maxDataRowIndex) {
      dividerPaintManager.addStopsForEntireRow(
          rowIndex: rowRegions.trailingRegion!.index, horizontal: false);
    }
    if (!rowFillHeight) {
      for (RowRegion rowRegion in rowRegions.values) {
        if (!rowRegion.hasData && !rowRegion.trailing) {
          dividerPaintManager.addStopsForEntireRow(
              rowIndex: rowRegion.index, horizontal: true);
        }
      }
    }

    notifyListeners();
  }

  /// Redoes the (cheap) row region rebuild - not the expensive cell-mapping
  /// one - using the viewport shape from the last [reset] call.
  ///
  /// Called by [CellsLayoutRenderBox] right after it measures real cell
  /// content and corrects [rowExtentManager], so that background/divider
  /// bounds reflect the corrected heights in the very same layout pass,
  /// instead of lagging a frame behind.
  void refreshRowRegions(RowExtentManager rowExtentManager) {
    _rebuildRowRegions(rowExtentManager);
  }

  void _rebuildRowRegions(RowExtentManager rowExtentManager) {
    final DaviDataSource<DATA> dataSource = _dataSource!;

    // Row regions (backgrounds, hover hit-testing, dividers' vertical
    // extent) are cheap - O(visible rows) - so they're rebuilt on every
    // call. This keeps them tracking the live scroll position precisely,
    // even on calls where the expensive topology rebuild is skipped.
    rowRegions._clear();
    _lastDataRow = -1;
    double rowY = rowExtentManager.offsetOf(_firstRow) - _verticalOffset;
    for (int rowIndex = _firstRow; rowIndex <= _maxDataRowIndex; rowIndex++) {
      _lastRow = rowIndex;

      DATA? data;
      if (rowIndex < dataSource.rowsLength) {
        data = dataSource.rowAt(rowIndex);
      }

      bool trailingRegion = false;
      if (_hasTrailing && rowRegions._trailingRegion == null && data == null) {
        trailingRegion = true;
      }

      final double rowContentHeight = rowExtentManager.heightOf(rowIndex);
      final Rect rowBounds =
          Rect.fromLTWH(0, rowY, _maxWidth, rowContentHeight);
      rowRegions._add(RowRegion(
          index: rowIndex,
          bounds: rowBounds,
          hasData: data != null,
          trailing: trailingRegion,
          visible: (rowBounds.top > 0 && rowBounds.top < _maxHeight) ||
              (rowBounds.bottom > 0 && rowBounds.bottom < _maxHeight)));

      if (data != null && rowBounds.top < _maxHeight) {
        _lastDataRow = rowIndex;
      }
      rowY += rowExtentManager.extentOf(rowIndex);
    }
  }

  /// Method to get a [CellMapping] based on cell index.
  CellMapping? getCellMapping({required int cellIndex}) {
    return _cellMappings[cellIndex];
  }
}

/// Represents the data source indexes. These indexes will be mapped to cell indexes.
@internal
class CellMapping {
  CellMapping({required this.rowIndex, required this.columnIndex});

  /// The row index of the data source cell to be displayed.
  final int rowIndex;

  final int columnIndex;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellMapping &&
          runtimeType == other.runtimeType &&
          rowIndex == other.rowIndex &&
          columnIndex == other.columnIndex;

  @override
  int get hashCode => rowIndex.hashCode ^ columnIndex.hashCode;
}
