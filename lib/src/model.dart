import 'dart:collection';

import 'package:davi/src/column.dart';
import 'package:davi/src/column_sort.dart';
import 'package:davi/src/sort_callback_typedef.dart';
import 'package:davi/src/sort_order.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// The [Davi] model.
///
/// The type [DATA] represents the data of each row.
class DaviModel<DATA> extends ChangeNotifier {
  factory DaviModel(
      {List<DATA> rows = const [],
      List<DaviColumn<DATA>> columns = const [],
      bool ignoreSort = false,
      OnSortCallback<DATA>? onSort}) {
    List<DATA> cloneList = List.from(rows);
    DaviModel<DATA> model = DaviModel._(
        cloneList, UnmodifiableListView(cloneList), ignoreSort, onSort);
    model.addColumns(columns);
    return model;
  }

  DaviModel._(this._originalRows, this._rows, this.ignoreSort, this.onSort);

  /// The event that will be triggered at each sorting.
  OnSortCallback<DATA>? onSort;

  final List<DaviColumn<DATA>> _columns = [];
  final List<DATA> _originalRows;

  final List<DaviColumn<DATA>> _sortedColumns = [];

  /// Gets the sorted columns.
  List<DaviColumn<DATA>> get sortedColumns =>
      UnmodifiableListView(_sortedColumns);

  List<DATA> _rows;

  /// Ignore column sorting functions to maintain the natural order of the data.
  ///
  /// Allows the header to be sortable if the column is also sortable.
  final bool ignoreSort;

  bool get _isRowsModifiable => _rows is! UnmodifiableListView;

  int get originalRowsLength => _originalRows.length;

  bool get isOriginalRowsEmpty => _originalRows.isEmpty;

  bool get isOriginalRowsNotEmpty => _originalRows.isNotEmpty;

  int get rowsLength => _rows.length;

  bool get isRowsEmpty => _rows.isEmpty;

  bool get isRowsNotEmpty => _rows.isNotEmpty;

  int get columnsLength => _columns.length;

  bool get isColumnsEmpty => _columns.isEmpty;

  bool get isColumnsNotEmpty => _columns.isNotEmpty;

  DaviColumn<DATA>? _columnInResizing;

  DaviColumn<DATA>? get columnInResizing => _columnInResizing;

  @internal
  set columnInResizing(DaviColumn<DATA>? column) {
    _columnInResizing = column;
    notifyListeners();
  }

  /// Indicates whether the model is sorted.
  bool get isSorted => _sortedColumns.isNotEmpty;

  /// Indicates whether the model is sorted by multiple columns.
  bool get isMultiSorted => _sortedColumns.length > 1;

  DATA rowAt(int index) => _rows[index];

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
      DATA row = _rows.removeAt(index);
      _originalRows.remove(row);
    } else {
      _originalRows.removeAt(index);
    }
    notifyListeners();
  }

  void removeRow(DATA row) {
    _originalRows.remove(row);
    if (_isRowsModifiable) {
      _rows.remove(row);
    }
    notifyListeners();
  }

  DaviColumn<DATA> columnAt(int index) => _columns[index];

  void addColumn(DaviColumn<DATA> column) {
    _columns.add(column);
    column.addListener(notifyListeners);
    notifyListeners();
  }

  void addColumns(Iterable<DaviColumn<DATA>> columns) {
    for (DaviColumn<DATA> column in columns) {
      _columns.add(column);
      column.addListener(notifyListeners);
    }
    notifyListeners();
  }

  /// Remove all columns.
  void removeColumns() {
    _columns.clear();
    _sortedColumns.clear();
    _columnInResizing = null;
    _updateRows(notify: true);
  }

  void _updateSortPriorities() {
    int priority = 1;
    for (DaviColumn<DATA> column in _sortedColumns) {
      column._priority = priority++;
    }
  }

  void removeColumnAt(int index) {
    DaviColumn<DATA> column = _columns[index];
    removeColumn(column);
  }

  void removeColumn(DaviColumn<DATA> column) {
    if (_columns.remove(column)) {
      column.removeListener(notifyListeners);
      if (_columnInResizing == column) {
        _columnInResizing = null;
      }
      if (_sortedColumns.remove(column)) {
        column._clearSortData();
        _updateSortPriorities();
        _updateRows(notify: false);
      }
      notifyListeners();
    }
  }

  void _notifyOnSort() {
    if (onSort != null) {
      onSort!(sortedColumns);
    }
  }

  /// Revert to original sort order
  void clearSort() {
    _sortedColumns.clear();
    _clearColumnsSortData();
    _updateRows(notify: true);
    _notifyOnSort();
  }

  void _clearColumnsSortData() {
    for (DaviColumn<DATA> column in _columns) {
      column._clearSortData();
    }
  }

  /// Defines the columns that will be used in sorting.
  void sort(List<ColumnSort> columnSorts) {
    _sortedColumns.clear();
    _clearColumnsSortData();
    for (ColumnSort columnSort in columnSorts) {
      DaviColumn<DATA> column = _columns[columnSort.columnIndex];
      if (column.sortable && (column.sort != null || ignoreSort)) {
        column._order = columnSort.order;
        _sortedColumns.add(column);
      }
    }
    _updateSortPriorities();
    _updateRows(notify: true);
    _notifyOnSort();
  }

  /// Updates the multi sort given a column.
  void multiSortByColumn(DaviColumn<DATA> column) {
    if (_columns.contains(column) == false ||
        !column.sortable ||
        (column.sort == null && !ignoreSort)) {
      return;
    }
    int columnSortIndex = _sortedColumns.indexOf(column);
    if (columnSortIndex == -1) {
      column._order = TableSortOrder.ascending;
      _sortedColumns.add(column);
    } else if (columnSortIndex == _sortedColumns.length - 1) {
      // last
      if (_sortedColumns.last.order == TableSortOrder.ascending) {
        _sortedColumns.last._order = TableSortOrder.descending;
      } else {
        _sortedColumns.removeAt(columnSortIndex)._clearSortData();
      }
    } else {
      _sortedColumns.removeAt(columnSortIndex)._clearSortData();
    }
    _updateSortPriorities();
    _updateRows(notify: true);
    _notifyOnSort();
  }

  /// Sort given a column index.
  void sortByColumnIndex(
      {required int columnIndex, required TableSortOrder sortOrder}) {
    sortByColumn(column: _columns[columnIndex], sortOrder: sortOrder);
  }

  /// Sort given a column.
  void sortByColumn(
      {required DaviColumn<DATA> column, required TableSortOrder sortOrder}) {
    if (column.sortable &&
        (column.sort != null || ignoreSort) &&
        _columns.contains(column)) {
      _sortedColumns.clear();
      _clearColumnsSortData();
      column._priority = 1;
      column._order = sortOrder;
      _sortedColumns.add(column);
      _updateRows(notify: true);
      _notifyOnSort();
    }
  }

  /// Notifies any data update by calling all the registered listeners.
  void notifyUpdate() {
    notifyListeners();
  }

  /// Updates the visible rows given the sorts and filters.
  void _updateRows({required bool notify}) {
    if (isSorted && !ignoreSort) {
      List<DATA> list = List.from(_originalRows);
      list.sort(_compoundSort);
      _rows = list;
    } else {
      _rows = UnmodifiableListView(_originalRows);
    }
    if (notify) {
      notifyListeners();
    }
  }

  /// Function to realize the multi sort.
  int _compoundSort(DATA a, DATA b) {
    int r = 0;
    for (int i = 0; i < _sortedColumns.length; i++) {
      final DaviColumn<DATA> column = _sortedColumns[i];
      if (column.sort != null && column.order != null) {
        final DaviColumnSort<DATA> sort = column.sort!;
        final TableSortOrder order = column.order!;

        if (order == TableSortOrder.descending) {
          r = sort(b, a, column);
        } else {
          r = sort(a, b, column);
        }
        if (r != 0) {
          break;
        }
      }
    }
    return r;
  }
}

mixin ColumnSortMixin {
  int? _priority;

  int? get priority => _priority;
  TableSortOrder? _order;

  TableSortOrder? get order => _order;

  void _clearSortData() {
    _priority = null;
    _order = null;
  }

  bool get isSorted => _order != null;
}
