import 'dart:collection';
import 'dart:math' as math;
import 'package:collection/collection.dart';
import 'package:davi/src/column.dart';
import 'package:davi/src/internal/column_metrics.dart';
import 'package:davi/src/internal/new/divider_paint_manager.dart';
import 'package:davi/src/max_span_behavior.dart';
import 'package:davi/src/model.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

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

  double _verticalOffset=0;
  double get verticalOffset=>_verticalOffset;

  /// rowHeight (cell content height + cell padding + dividerThickness)
  void reset(
      {required double verticalOffset,
      required List<ColumnMetrics> columnsMetrics,
      required double rowHeight,
      required double cellHeight,
      required double maxHeight,
      required double maxWidth,
      required DaviModel<DATA> model,
      required bool hasTrailing,
      required bool rowFillHeight}) {

    final Map<CellMapping, int> oldCellMappings = {
      for (var entry in _cellMappings.entries) entry.value: entry.key,
    };
    List<CellMapping> newCellMappings = [];

    _verticalOffset=verticalOffset;
    _cellMappings.clear();
    rowRegions._clear();

    _lastDataRow = -1;

    _firstDataRow = (verticalOffset / rowHeight).floor();

    // Need to add one extra row because the scroll may be in between rows,
    // causing an additional row to be partially visible.
    _maxVisibleRowCount = ((maxHeight + rowHeight) / rowHeight).ceil();

    // Minus 1 because the index starts at 0.
    // Example: number of visible rows is 2, the last index must be 1.
    _maxDataRowIndex = _firstDataRow + _maxVisibleRowCount - 1;

    // Calculating the index of the first row in the model that
    // can be visible because span. This ensures that, when scrolling,
    // rows above the visible area that have a span extending into
    // the visible viewport remain included.
    // The +1 adjustment accounts for the minimum span of 1 that every
    // cell inherently has. Without this +1, the calculation might
    // result in an index corresponding to a cell whose entire span
    // lies above the visible viewport, making it incorrectly
    // excluded from the visible area.
    _firstRow = math.max(0, _firstDataRow - model.maxRowSpan + 1);

    // - 1 because [maxRowSpan] and [maxColumnSpan]
    // are minimal 1 (already include themselves).
    _maxCellCount = (_maxVisibleRowCount + model.maxRowSpan - 1) *
        (model.columnsLength + model.maxColumnSpan - 1);

    double rowY = (_firstRow * rowHeight) - verticalOffset;

    HashSet<int> indices = HashSet();
    for (int rowIndex = _firstRow; rowIndex <= _maxDataRowIndex; rowIndex++) {
      for (int columnIndex = 0;
      columnIndex < columnsMetrics.length;
      columnIndex++) {
        indices.add(indices.length);
      }
    }
    for (int rowIndex = _firstRow; rowIndex <= _maxDataRowIndex; rowIndex++) {
      _lastRow = rowIndex;

      DATA? data;
      if (rowIndex < model.rowsLength) {
        data = model.rowAt(rowIndex);
      }

      bool trailingRegion = false;
      if (hasTrailing && rowRegions._trailingRegion == null && data == null) {
        trailingRegion = true;
      }

      final Rect rowBounds = Rect.fromLTWH(0, rowY, maxWidth, cellHeight);
      rowRegions._add(RowRegion(
          index: rowIndex,
          bounds: rowBounds,
          hasData: data != null,
          trailing: trailingRegion,
          visible: (rowBounds.top > 0 && rowBounds.top < maxHeight) || (rowBounds.bottom
              > 0 && rowBounds.bottom < maxHeight)));

      if (data != null && rowBounds.top < maxHeight) {
        _lastDataRow = rowIndex;
      }
      rowY += rowHeight;

      for (int columnIndex = 0;
          columnIndex < columnsMetrics.length;
          columnIndex++) {
        if (data != null) {
          final DaviColumn<DATA> column = model.columnAt(columnIndex);

          int rowSpan = math.max(column.rowSpan(data, rowIndex), 1);
          if (rowSpan > model.maxRowSpan) {
            if (model.maxSpanBehavior == MaxSpanBehavior.throwException) {
              throw StateError(
                  'rowSpan exceeds the maximum allowed of ${model.maxRowSpan} rows');
            } else if (model.maxSpanBehavior ==
                MaxSpanBehavior.truncateWithWarning) {
              rowSpan = model.maxRowSpan;
              debugPrint(
                  'Span too large at row $rowIndex: Truncated to $rowSpan rows');
            }
          }

          int columnSpan = math.max(column.columnSpan(data, rowIndex), 1);
          if (columnSpan > model.maxColumnSpan) {
            if (model.maxSpanBehavior == MaxSpanBehavior.throwException) {
              throw StateError(
                  'columnSpan exceeds the maximum allowed of ${model.maxColumnSpan} columns');
            } else if (model.maxSpanBehavior ==
                MaxSpanBehavior.truncateWithWarning) {
              columnSpan = model.maxColumnSpan;
              debugPrint(
                  'Span too large at rowIndex $rowIndex column $columnIndex: Truncated to $columnSpan columns');
            }
          }

          // Check all columns spanned by the columnSpan
          for (int i = columnIndex + 1; i < columnIndex + columnSpan; i++) {
            if (columnsMetrics[i].pinStatus !=
                columnsMetrics[columnIndex].pinStatus) {
              throw StateError(
                "Invalid columnSpan: Columns spanned from index $columnIndex to ${columnIndex + columnSpan - 1} "
                "at rowIndex $rowIndex, have mixed pin status.",
              );
            }
          }

          CellMapping cellMapping = CellMapping(
              rowIndex: rowIndex, columnIndex: columnIndex,
              rowSpan: rowSpan, columnSpan: columnSpan);


          int? oldCellIndex = oldCellMappings.remove(cellMapping);
          if(oldCellIndex!=null) {
            _cellMappings[oldCellIndex] = cellMapping;
            indices.remove(oldCellIndex);
          } else {
            newCellMappings.add(cellMapping);
          }
        }
      }
    }

    for(int cellIndex in indices ){
      if(newCellMappings.isEmpty) {
        break;
      }
      CellMapping cellMapping = newCellMappings.removeAt(0);
      _cellMappings[cellIndex] = cellMapping;
    }
    
    ////////////
    ////////////
    /////////////

    for (int rowIndex = _firstRow; rowIndex <= _maxDataRowIndex; rowIndex++) {

    }



   // if (rowRegions.firstRowIndex != null && rowRegions.lastRowIndex != null) {
      dividerPaintManager.reset(
          //firstRowIndex: rowRegions.firstRowIndex!,
          firstRowIndex: _firstRow,
          //lastRowIndex: rowRegions.lastRowIndex!,
          lastRowIndex: _maxDataRowIndex+model.maxRowSpan-1,
          columnsLength: columnsMetrics.length);
      if (rowRegions.trailingRegion != null &&
          //rowRegions.trailingRegion!.index >= rowRegions.firstRowIndex! &&
          rowRegions.trailingRegion!.index >= _firstDataRow &&
          //rowRegions.trailingRegion!.index <= rowRegions.lastRowIndex!) {
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
     
    //  for(int cellIndex =0; cellIndex<maxCellCount;cellIndex++) {
     //    CellMapping2? cellMapping = getCellMapping(cellIndex: cellIndex);
      //    if(cellMapping!=null) {
      for(CellMapping cellMapping in _cellMappings.values) {
        dividerPaintManager.addStopsForCell(
            rowIndex: cellMapping.rowIndex,
            columnIndex: cellMapping.columnIndex,
            rowSpan: cellMapping.rowSpan,
            columnSpan: cellMapping.columnSpan);
     // }
      //    }
       }
  //  } else {
  //    dividerPaintManager.clear();
  //  }

    // cm -> index
    // 1 > cm 2
    // 2 > cm 3

    // cm 2

    notifyListeners();
  }

  /// Method to get a [CellMapping] based on cell index.
  CellMapping? getCellMapping({required int cellIndex}) {
    return _cellMappings[cellIndex];
  }
}

/// Represents the model indexes. These indexes will be mapped to cell indexes.
@internal
class CellMapping {
  CellMapping({
    required this.rowIndex,
    required this.columnIndex,
    required this.rowSpan,
    required this.columnSpan,
  });

  /// The row index of the model cell to be displayed.
  final int rowIndex;
  
  final int columnIndex;

  /// Number of rows spanned by the model cell in the view.
  final int rowSpan;

  /// Number of columns spanned by the model cell in the view.
  final int columnSpan;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellMapping &&
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
