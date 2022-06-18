import 'dart:collection';

import 'package:easy_table/src/column.dart';
import 'package:easy_table/src/column_sort.dart';
import 'package:easy_table/src/sort_type.dart';
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

  EasyTableModel._(this._originalRows, this._visibleRows);

  final List<EasyTableColumn<ROW>> _columns = [];
  final List<ROW> _originalRows;

  final List<EasyTableColumn<ROW>> _sortedColumns = [];

  /// Gets the sorted columns.
  List<EasyTableColumn<ROW>> get sortedColumns =>
      UnmodifiableListView(_sortedColumns);

  List<ROW> _visibleRows;

  bool get _isVisibleRowsModifiable => _visibleRows is! UnmodifiableListView;

  int get rowsLength => _originalRows.length;

  bool get isRowsEmpty => _originalRows.isEmpty;

  bool get isRowsNotEmpty => _originalRows.isNotEmpty;

  int get visibleRowsLength => _visibleRows.length;

  bool get isVisibleRowsEmpty => _visibleRows.isEmpty;

  bool get isVisibleRowsNotEmpty => _visibleRows.isNotEmpty;

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

  ROW visibleRowAt(int index) => _visibleRows[index];

  void addRow(ROW row) {
    _originalRows.add(row);
    _updateVisibleRows(notify: true);
  }

  void addRows(Iterable<ROW> rows) {
    _originalRows.addAll(rows);
    _updateVisibleRows(notify: true);
  }

  /// Remove all rows.
  void removeRows() {
    _originalRows.clear();
    _updateVisibleRows(notify: true);
  }

  void replaceRows(Iterable<ROW> rows) {
    _originalRows.clear();
    _originalRows.addAll(rows);
    _updateVisibleRows(notify: true);
  }

  void removeVisibleRowAt(int index) {
    if (_isVisibleRowsModifiable) {
      ROW row = _visibleRows.removeAt(index);
      _originalRows.remove(row);
    } else {
      _originalRows.removeAt(index);
    }
    notifyListeners();
  }

  void removeRow(ROW row) {
    _originalRows.remove(row);
    if (_isVisibleRowsModifiable) {
      _visibleRows.remove(row);
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
    _updateVisibleRows(notify: true);
  }

  void _updateSortOrders() {
    int order = 1;
    for (EasyTableColumn<ROW> column in _sortedColumns) {
      column._sortOrder = order++;
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
        _updateSortOrders();
        _updateVisibleRows(notify: false);
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
    _updateVisibleRows(notify: true);
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
        column._sortType = columnSort.sortType;
        _sortedColumns.add(column);
      }
    }
    _updateSortOrders();
    _updateVisibleRows(notify: true);
  }

  /// Updates the multi sort given a column.
  void multiSortByColumn(EasyTableColumn<ROW> column) {
    if (_columns.contains(column) == false || column.sort == null) {
      return;
    }
    int columnSortIndex = _sortedColumns.indexOf(column);
    if (columnSortIndex == -1) {
      column._sortType = EasyTableSortType.ascending;
      _sortedColumns.add(column);
    } else if (columnSortIndex == _sortedColumns.length - 1) {
      // last
      if (_sortedColumns.last.sortType == EasyTableSortType.ascending) {
        _sortedColumns.last._sortType = EasyTableSortType.descending;
      } else {
        _sortedColumns.removeAt(columnSortIndex)._clearSortData();
      }
    } else {
      _sortedColumns.removeAt(columnSortIndex)._clearSortData();
    }
    _updateSortOrders();
    _updateVisibleRows(notify: true);
  }

  /// Sort given a column index.
  void sortByColumnIndex(
      {required int columnIndex, required EasyTableSortType sortType}) {
    sortByColumn(column: _columns[columnIndex], sortType: sortType);
  }

  /// Sort given a column.
  void sortByColumn(
      {required EasyTableColumn<ROW> column,
      required EasyTableSortType sortType}) {
    if (column.sort != null && _columns.contains(column)) {
      _sortedColumns.clear();
      _clearColumnsSortData();
      column._sortOrder = 1;
      column._sortType = sortType;
      _sortedColumns.add(column);
      _updateVisibleRows(notify: true);
    }
  }

  /// Notifies any row data update by calling all the registered listeners.
  void notifyUpdate() {
    notifyListeners();
  }

  /// Updates the visible rows given the sorts and filters.
  void _updateVisibleRows({required bool notify}) {
    if (isSorted) {
      List<ROW> list = List.from(_originalRows);
      list.sort(_compoundSort);
      _visibleRows = list;
    } else {
      _visibleRows = UnmodifiableListView(_originalRows);
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
      final EasyTableSortType sortType = _sortedColumns[i].sortType!;

      if (sortType == EasyTableSortType.descending) {
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
  int? _sortOrder;
  int? get sortOrder => _sortOrder;
  EasyTableSortType? _sortType;
  EasyTableSortType? get sortType => _sortType;
  void _clearSortData() {
    _sortOrder = null;
    _sortType = null;
  }

  bool get isSorted => _sortType != null;
}
