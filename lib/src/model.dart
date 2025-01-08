import 'dart:collection';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:davi/src/column.dart';
import 'package:davi/src/max_span_behavior.dart';
import 'package:davi/src/row_span_overflow_behavior.dart';
import 'package:davi/src/sort.dart';
import 'package:davi/src/sort_callback_typedef.dart';
import 'package:davi/src/sort_direction.dart';
import 'package:flutter/widgets.dart';

/// The [Davi] model.
///
/// The type [DATA] represents the data of each row.
class DaviModel<DATA> extends ChangeNotifier {
  DaviModel(
      {List<DATA> rows = const [],
      List<DaviColumn<DATA>> columns = const [],
      this.ignoreDataComparators = false,
      this.alwaysSorted = false,
      this.multiSortEnabled = false,
      this.onSort,
      int maxColumnSpan = 10,
      int maxRowSpan = 15,
      this.rowSpanOverflowBehavior = RowSpanOverflowBehavior.cap,
      this.maxSpanBehavior = MaxSpanBehavior.throwException})
      : maxRowSpan = math.max(maxRowSpan, 1),
        maxColumnSpan = math.max(maxColumnSpan, 1) {
    _originalRows = List.from(rows);
    _addColumns(columns, false);
    _updateRows(notify: false);
  }

  final List<DaviColumn<DATA>> _columns = [];

  late final List<DATA> _originalRows;
  late List<DATA> _sortableRows;
  late UnmodifiableListView<DATA> _rowsView;
  UnmodifiableListView<DATA> get rows => _rowsView;

  /// The event that will be triggered at each sorting.
  OnSortCallback<DATA>? onSort;

  final bool multiSortEnabled;

  bool _hasSummary = false;

  bool get hasSummary => _hasSummary;

  /// Gets the sorted columns.
  List<DaviColumn<DATA>> get sortedColumns {
    List<DaviColumn<DATA>> list =
        _columns.where((column) => column.sortDirection != null).toList();
    list.sort((a, b) => a.sortPriority.compareTo(b.sortPriority));
    return list;
  }

  /// The list of sorts. The list is sorted by priority.
  List<DaviSort> get sortList {
    List<DaviSort> list = [];
    for (DaviColumn<DATA> column in sortedColumns) {
      final DaviSortDirection? direction = column.sortDirection;
      if (direction == null) {
        throw StateError('Column sort should not be null.');
      }
      list.add(DaviSort(column.id, direction));
    }
    return list;
  }

  /// Ignore column [dataComparator] to maintain the natural order of the data.
  final bool ignoreDataComparators;

  /// Defines if there will always be some sorted column.
  ///
  /// The column must be sortable.
  final bool alwaysSorted;

  bool get _isRowsModifiable => _sortableRows is! UnmodifiableListView;

  int get originalRowsLength => _originalRows.length;

  bool get isOriginalRowsEmpty => _originalRows.isEmpty;

  bool get isOriginalRowsNotEmpty => _originalRows.isNotEmpty;

  int get rowsLength => _sortableRows.length;

  bool get isRowsEmpty => _sortableRows.isEmpty;

  bool get isRowsNotEmpty => _sortableRows.isNotEmpty;

  int get columnsLength => _columns.length;

  bool get isColumnsEmpty => _columns.isEmpty;

  bool get isColumnsNotEmpty => _columns.isNotEmpty;

  /// The maximum number of rows a single cell can span.
  ///
  /// If a cell's `rowSpan` exceeds this value, the behavior will depend on
  /// [maxSpanBehavior]. See [MaxSpanBehavior] for available options and details.
  ///
  /// Adjust this value to control the performance and usability of the grid.
  final int maxRowSpan;

  /// The maximum number of columns a single cell can span.
  ///
  /// If a cell's `columnSpan` exceeds this value, the behavior will depend on
  /// [maxSpanBehavior]. See [MaxSpanBehavior] for available options and details.
  ///
  /// Adjust this value to accommodate wider spans when necessary.
  final int maxColumnSpan;

  /// Determines how to handle spans that exceed [maxRowSpan] or [maxColumnSpan].
  ///
  /// Refer to [MaxSpanBehavior] for details on the available policies.
  final MaxSpanBehavior maxSpanBehavior;

  /// Defines the behavior when a cell's rowSpan exceeds the available number of rows in the table.
  final RowSpanOverflowBehavior rowSpanOverflowBehavior;

  /// Indicates whether the model is sorted.
  ///
  /// The model will be sorted if it has at least one sorted column.
  bool get isSorted =>
      _columns.firstWhereOrNull((column) => column.sortDirection != null) !=
              null
          ? true
          : false;

  /// Indicates whether the model is sorted by multiple columns.
  bool get isMultiSorted {
    int count = 0;
    for (DaviColumn column in _columns) {
      if (column.sortDirection != null) {
        count++;
      }
      if (count > 1) {
        return true;
      }
    }
    return false;
  }

  DATA rowAt(int index) => _sortableRows[index];

  void addRow(DATA row) {
    _originalRows.add(row);
    _updateRows(notify: true);
  }

  void addRows(Iterable<DATA> rows) {
    _originalRows.addAll(rows);
    _updateRows(notify: true);
  }

  /// Remove all rows.
  void removeRows() {
    _originalRows.clear();
    _updateRows(notify: true);
  }

  void replaceRows(Iterable<DATA> rows) {
    _originalRows.clear();
    _originalRows.addAll(rows);
    _updateRows(notify: true);
  }

  void removeRowAt(int index) {
    if (_isRowsModifiable) {
      DATA row = _sortableRows.removeAt(index);
      _originalRows.remove(row);
    } else {
      _originalRows.removeAt(index);
    }
    notifyListeners();
  }

  void removeRow(DATA row) {
    _originalRows.remove(row);
    if (_isRowsModifiable) {
      _sortableRows.remove(row);
    }
    notifyListeners();
  }

  DaviColumn<DATA> columnAt(int index) => _columns[index];

  /// Gets a column given an [id]. If [id] is [NULL], no columns are returned.
  DaviColumn<DATA>? getColumn(dynamic id) {
    if (id != null) {
      for (DaviColumn<DATA> column in _columns) {
        if (column.id == id) {
          return column;
        }
      }
    }
    return null;
  }

  void addColumn(DaviColumn<DATA> column) {
    if (isSorted && !multiSortEnabled) {
      DaviColumnHelper.clearSort(column: column);
    }
    _columns.add(column);
    _checkColumnIdCollision();
    if (column.sortDirection != null) {
      _fixSortPriorities();
    }
    _checkSummary();
    column.addListener(notifyListeners);
    _ensureSort();
    notifyListeners();
  }

  void _addColumns(Iterable<DaviColumn<DATA>> columns, bool notify) {
    final bool sorted = isSorted;
    for (DaviColumn<DATA> column in columns) {
      if (sorted && !multiSortEnabled) {
        DaviColumnHelper.clearSort(column: column);
      }
      _columns.add(column);
      column.addListener(notifyListeners);
    }
    _checkColumnIdCollision();
    _fixSortPriorities();
    _checkSummary();
    _ensureSort();
    if (notify) {
      notifyListeners();
    }
  }

  void addColumns(Iterable<DaviColumn<DATA>> columns) {
    _addColumns(columns, true);
  }

  void _fixSortPriorities() {
    List<DaviColumn<DATA>> sortedColumns = this.sortedColumns;
    int sortPriority = 1;
    for (DaviColumn<DATA> column in sortedColumns) {
      DaviColumnHelper.setSortPriority(
          column: column, priority: sortPriority++);
    }
  }

  void _checkColumnIdCollision() {
    HashSet<dynamic> uniqueIds = HashSet<dynamic>();
    for (DaviColumn column in _columns) {
      if (!uniqueIds.add(column.id)) {
        throw ArgumentError('Multiple columns with the same id.');
      }
    }
  }

  /// Remove all columns.
  void removeColumns() {
    _columns.clear();
    _hasSummary = false;
    _updateRows(notify: true);
  }

  void removeColumnAt(int index) {
    DaviColumn<DATA> column = _columns[index];
    removeColumn(column);
  }

  void removeColumn(DaviColumn<DATA> column) {
    if (_columns.remove(column)) {
      column.removeListener(notifyListeners);
      if (column.sortDirection != null) {
        DaviColumnHelper.clearSort(column: column);
        _fixSortPriorities();
        _updateRows(notify: false);
      }
      _checkSummary();
      notifyListeners();
    }
  }

  void _checkSummary() {
    _hasSummary = _columns.any((column) => column.summary != null);
  }

  void _notifyOnSort() {
    if (onSort != null) {
      onSort!(sortedColumns);
    }
  }

  /// Revert to original sort order
  void clearSort() {
    _clearColumnsSortData();
    _ensureSort();
    _updateRows(notify: true);
    _notifyOnSort();
  }

  void _clearColumnsSortData() {
    for (DaviColumn<DATA> column in _columns) {
      DaviColumnHelper.clearSort(column: column);
    }
  }

  /// Defines the columns that will be used in sorting.
  ///
  /// If multi sorting is disabled, only the first one in the list will be used.
  /// Not sortable columns will be ignored.
  void sort(List<DaviSort> newSortList) {
    if (const ListEquality().equals(sortList, newSortList)) {
      // same sort
      return;
    }

    _clearColumnsSortData();
    HashSet<dynamic> uniqueColumnIds = HashSet<dynamic>();
    int priority = 1;
    for (DaviSort sort in newSortList) {
      if (!uniqueColumnIds.add(sort.columnId)) {
        throw ArgumentError(
            'List has multiple configurations with the same columnId.');
      }
      DaviColumn<DATA>? column = getColumn(sort.columnId);
      if (column != null && column.sortable) {
        DaviColumnHelper.setSort(
            column: column, direction: sort.direction, priority: priority++);
        if (!multiSortEnabled) {
          // only the first one
          break;
        }
      }
    }
    _ensureSort();
    _updateRows(notify: true);
    _notifyOnSort();
  }

  void _ensureSort() {
    if (alwaysSorted) {
      DaviColumn? firstNonSortedColumn;
      for (DaviColumn column in _columns) {
        if (column.sortable) {
          if (column.sortDirection != null) {
            // It's already sorted.
            return;
          }
          firstNonSortedColumn ??= column;
        }
      }
      // No sorted columns. Let's order the first one available.
      if (firstNonSortedColumn != null) {
        DaviColumnHelper.setSort(
            column: firstNonSortedColumn,
            direction: DaviSortDirection.ascending,
            priority: 1);
      }
    }
  }

  /// Notifies any data update by calling all the registered listeners.
  void notifyUpdate() {
    notifyListeners();
  }

  /// Updates the visible rows given the sorts and filters.
  void _updateRows({required bool notify}) {
    if (isSorted && !ignoreDataComparators) {
      List<DATA> list = List.from(_originalRows);

      // Create a list of pairs (index, value),
      // where each element is a MapEntry
      // The key of MapEntry is the index,
      // and the value is the corresponding element
      List<MapEntry<int, DATA>> indexedList = List.generate(
        list.length,
        (index) => MapEntry(index, list[index]),
      );

      indexedList.sort((a, b) => _compoundSort(a.value, a.key, b.value, b.key));

      // Convert the sorted indexedList back into a normal list of values
      // This gives us the sorted list of values without the indices
      _sortableRows = indexedList.map((entry) => entry.value).toList();
    } else {
      _sortableRows = UnmodifiableListView(_originalRows);
    }
    _rowsView = UnmodifiableListView(_sortableRows);
    if (notify) {
      notifyListeners();
    }
  }

  /// Function to realize the multi sort.
  int _compoundSort(DATA rowA, int indexA, DATA rowB, int indexB) {
    int r = 0;
    for (final DaviColumn<DATA> column in sortedColumns) {
      final DaviSortDirection? direction = column.sortDirection;
      if (direction != null) {
        final DaviComparator<DATA> dataComparator = column.dataComparator;

        dynamic cellValueA, cellValueB;
        if (column.cellValue != null) {
          cellValueA = column.cellValue!(rowA, indexA);
          cellValueB = column.cellValue!(rowB, indexB);
        } else if (column.cellBarValue != null) {
          cellValueA = column.cellBarValue!(rowA, indexA);
          cellValueB = column.cellBarValue!(rowB, indexB);
        } else if (column.cellIcon != null) {
          cellValueA = column.cellIcon!(rowA, indexA);
          cellValueB = column.cellIcon!(rowB, indexB);
        }

        if (direction == DaviSortDirection.descending) {
          r = dataComparator(cellValueB, cellValueA, rowB, rowA);
        } else {
          r = dataComparator(cellValueA, cellValueB, rowA, rowB);
        }
        if (r != 0) {
          break;
        }
      }
    }
    return r;
  }
}
