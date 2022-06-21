import 'dart:collection';

import 'package:easy_table/src/column.dart';
import 'package:easy_table/src/column_sort.dart';
import 'package:easy_table/src/sort_order.dart';
import 'package:flutter/widgets.dart';

/// The [EasyTable] model.
///
/// The type [ROW] represents the data of each row.
class EasyTableModel<ROW> extends ChangeNotifier {
  factory EasyTableModel(
      {List<ROW> rows = const [],
      List<EasyTableColumn<ROW>> columns = const []}) {
    List<ROW> cloneList = List.from(rows);
    EasyTableModel<ROW> model =
        EasyTableModel._(cloneList, UnmodifiableListView(cloneList));
    for (EasyTableColumn<ROW> column in columns) {
      model.addColumn(column);
    }
    return model;
  }

  EasyTableModel._(this._originalRows, this._rows);

  final List<EasyTableColumn<ROW>> _columns = [];
  final List<ROW> _originalRows;

  final List<EasyTableColumn<ROW>> _sortedColumns = [];

  /// Gets the sorted columns.
  List<EasyTableColumn<ROW>> get sortedColumns =>
      UnmodifiableListView(_sortedColumns);

  List<ROW> _rows;

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

  EasyTableColumn<ROW>? _columnInResizing;

  EasyTableColumn<ROW>? get columnInResizing => _columnInResizing;

  set columnInResizing(EasyTableColumn<ROW>? column) {
    _columnInResizing = column;
    notifyListeners();
  }

  /// Indicates whether the model is sorted.
  bool get isSorted => _sortedColumns.isNotEmpty;

  /// Indicates whether the model is sorted by multiple columns.
  bool get isMultiSorted => _sortedColumns.length > 1;

  ROW rowAt(int index) => _rows[index];

  void addRow(ROW row) {
    _originalRows.add(row);
    _updateRows(notify: true);
  }

  void addRows(Iterable<ROW> rows) {
    _originalRows.addAll(rows);
    _updateRows(notify: true);
  }

  /// Remove all rows.
  void removeRows() {
    _originalRows.clear();
    _updateRows(notify: true);
  }

  void replaceRows(Iterable<ROW> rows) {
    _originalRows.clear();
    _originalRows.addAll(rows);
    _updateRows(notify: true);
  }

  void removeRowAt(int index) {
    if (_isRowsModifiable) {
      ROW row = _rows.removeAt(index);
      _originalRows.remove(row);
    } else {
      _originalRows.removeAt(index);
    }
    notifyListeners();
  }

  void removeRow(ROW row) {
    _originalRows.remove(row);
    if (_isRowsModifiable) {
      _rows.remove(row);
    }
    notifyListeners();
  }

  EasyTableColumn<ROW> columnAt(int index) => _columns[index];

  void addColumn(EasyTableColumn<ROW> column) {
    _columns.add(column);
    column.addListener(notifyListeners);
    notifyListeners();
  }

  void addColumns(Iterable<EasyTableColumn<ROW>> columns) {
    for (EasyTableColumn<ROW> column in columns) {
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
    for (EasyTableColumn<ROW> column in _sortedColumns) {
      column._priority = priority++;
    }
  }

  void removeColumnAt(int index) {
    EasyTableColumn<ROW> column = _columns[index];
    removeColumn(column);
  }

  void removeColumn(EasyTableColumn<ROW> column) {
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

  double get columnsWeight {
    double w = 0;
    for (EasyTableColumn column in _columns) {
      w += column.weight;
    }
    return w;
  }

  /// Revert to original sort order
  void clearSort() {
    _sortedColumns.clear();
    _clearColumnsSortData();
    _updateRows(notify: true);
  }

  void _clearColumnsSortData() {
    for (EasyTableColumn<ROW> column in _columns) {
      column._clearSortData();
    }
  }

  /// Defines the columns that will be used in sorting.
  void sort(List<ColumnSort> columnSorts) {
    _sortedColumns.clear();
    _clearColumnsSortData();
    for (ColumnSort columnSort in columnSorts) {
      EasyTableColumn<ROW> column = _columns[columnSort.columnIndex];
      if (column.sort != null) {
        column._order = columnSort.order;
        _sortedColumns.add(column);
      }
    }
    _updateSortPriorities();
    _updateRows(notify: true);
  }

  /// Updates the multi sort given a column.
  void multiSortByColumn(EasyTableColumn<ROW> column) {
    if (_columns.contains(column) == false || column.sort == null) {
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
  }

  /// Sort given a column index.
  void sortByColumnIndex(
      {required int columnIndex, required TableSortOrder sortOrder}) {
    sortByColumn(column: _columns[columnIndex], sortOrder: sortOrder);
  }

  /// Sort given a column.
  void sortByColumn(
      {required EasyTableColumn<ROW> column,
      required TableSortOrder sortOrder}) {
    if (column.sort != null && _columns.contains(column)) {
      _sortedColumns.clear();
      _clearColumnsSortData();
      column._priority = 1;
      column._order = sortOrder;
      _sortedColumns.add(column);
      _updateRows(notify: true);
    }
  }

  /// Notifies any row data update by calling all the registered listeners.
  void notifyUpdate() {
    notifyListeners();
  }

  /// Updates the visible rows given the sorts and filters.
  void _updateRows({required bool notify}) {
    if (isSorted) {
      List<ROW> list = List.from(_originalRows);
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
  int _compoundSort(ROW a, ROW b) {
    int r = 0;
    for (int i = 0; i < _sortedColumns.length; i++) {
      final EasyTableColumnSort<ROW> sort = _sortedColumns[i].sort!;
      final TableSortOrder order = _sortedColumns[i].order!;

      if (order == TableSortOrder.descending) {
        r = sort(b, a);
      } else {
        r = sort(a, b);
      }
      if (r != 0) {
        break;
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
