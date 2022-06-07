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

  final List<_ColumnSort<ROW>> _sortedColumns = [];
  List<ColumnSort> get sortedColumns {
    List<ColumnSort> list = [];
    for (_ColumnSort<ROW> c in _sortedColumns) {
      int index = _columns.indexOf(c.column);
      list.add(ColumnSort(columnIndex: index, sortType: c.sortType));
    }
    return list;
  }

  List<ROW> _visibleRows;

  bool get _visibleRowsModifiable => _visibleRows is! UnmodifiableListView;

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

  _ColumnSort<ROW>? _getColumnSort(EasyTableColumn<ROW> column) {
    for (int i = 0; i < _sortedColumns.length; i++) {
      _ColumnSort<ROW> columnSort = _sortedColumns[i];
      if (columnSort.column == column) {
        return columnSort;
      }
    }
    return null;
  }

  EasyTableSortType? getSortType(EasyTableColumn<ROW> column) {
    _ColumnSort<ROW>? columnSort = _getColumnSort(column);
    return columnSort?.sortType;
  }

  bool get isSorted => _sortedColumns.isNotEmpty;

  ROW visibleRowAt(int index) => _visibleRows[index];

  void addRow(ROW row) {
    _originalRows.add(row);
    if (_visibleRowsModifiable) {
      _visibleRows.add(row);
      _resort(notify: false);
    }
    notifyListeners();
  }

  void addRows(Iterable<ROW> rows) {
    _originalRows.addAll(rows);
    if (_visibleRowsModifiable) {
      _visibleRows.addAll(rows);
    } else {
      _visibleRows = UnmodifiableListView(_originalRows);
    }
    _resort(notify: false);
    notifyListeners();
  }

  void removeRows() {
    _originalRows.clear();
    if (_visibleRowsModifiable) {
      _visibleRows.clear();
    }
    notifyListeners();
  }

  void replaceRows(Iterable<ROW> rows) {
    _originalRows.clear();
    _originalRows.addAll(rows);
    if (_visibleRowsModifiable) {
      _visibleRows.clear();
      _visibleRows.addAll(rows);
    } else {
      _visibleRows = UnmodifiableListView(_originalRows);
    }
    _resort(notify: false);
    notifyListeners();
  }

  void removeVisibleRowAt(int index) {
    if (_visibleRowsModifiable) {
      ROW row = _visibleRows.removeAt(index);
      _originalRows.remove(row);
    } else {
      _originalRows.removeAt(index);
    }
    notifyListeners();
  }

  void removeRow(ROW row) {
    _originalRows.remove(row);
    if (_visibleRowsModifiable) {
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

  void removeColumns() {
    _columns.clear();
    _sortedColumns.clear();
    _columnInResizing = null;
    notifyListeners();
  }

  void removeColumnAt(int index) {
    EasyTableColumn<ROW> column = _columns.removeAt(index);
    removeColumn(column);
  }

  void removeColumn(EasyTableColumn<ROW> column) {
    _columns.remove(column);
    if (_columnInResizing == column) {
      _columnInResizing = null;
    }
    _ColumnSort<ROW>? columnSort = _getColumnSort(column);
    if (columnSort != null) {
      _sortedColumns.remove(columnSort);
      _visibleRows = UnmodifiableListView(_originalRows);
      _resort(notify: false);
    }
    column.removeListener(notifyListeners);
    notifyListeners();
  }

  double get columnsWeight {
    double w = 0;
    for (EasyTableColumn column in _columns) {
      w += column.weight;
    }
    return w;
  }

  double get pinnedColumnsWidth {
    double w = 0;
    for (EasyTableColumn column in _columns) {
      if (column.pinned) {
        w += column.width;
      }
    }
    return w;
  }

  double get unpinnedColumnsWidth {
    double w = 0;
    for (EasyTableColumn column in _columns) {
      if (!column.pinned) {
        w += column.width;
      }
    }
    return w;
  }

  double get allColumnsWidth {
    double w = 0;
    for (EasyTableColumn column in _columns) {
      w += column.width;
    }
    return w;
  }

  int get unpinnedColumnsLength {
    int v = 0;
    for (EasyTableColumn column in _columns) {
      if (!column.pinned) {
        v++;
      }
    }
    return v;
  }

  int get pinnedColumnsLength {
    int v = 0;
    for (EasyTableColumn column in _columns) {
      if (column.pinned) {
        v++;
      }
    }
    return v;
  }

  /// Revert to original sort order
  void clearSort() {
    if (_sortedColumns.isNotEmpty) {
      _sortedColumns.clear();
      _visibleRows = UnmodifiableListView(_originalRows);
      notifyListeners();
    }
  }

  void sort(List<ColumnSort> columnSorts) {
    _sortedColumns.clear();
    for (ColumnSort columnSort in columnSorts) {
      EasyTableColumn<ROW> column = _columns[columnSort.columnIndex];
      if (column.sort != null) {
        _sortedColumns.add(
            _ColumnSort<ROW>(column: column, sortType: columnSort.sortType));
      }
    }
    _resort(notify: true);
  }

  /// Updates the multi sort given a column.
  void multiSortByColumn(EasyTableColumn<ROW> column) {
    if (_columns.contains(column) == false) {
      return;
    }
    int? columnSortIndex;
    for (int i = 0; i < _sortedColumns.length; i++) {
      _ColumnSort<ROW> columnSort = _sortedColumns[i];
      if (columnSort.column == column) {
        columnSortIndex = i;
        break;
      }
    }
    if (columnSortIndex == null) {
      _sortedColumns.add(
          _ColumnSort(column: column, sortType: EasyTableSortType.ascending));
    } else if (columnSortIndex == _sortedColumns.length - 1) {
      // last
      _ColumnSort<ROW> lastColumnSort = _sortedColumns.removeLast();
      if (lastColumnSort.sortType == EasyTableSortType.ascending) {
        lastColumnSort = _ColumnSort<ROW>(
            column: lastColumnSort.column,
            sortType: EasyTableSortType.descending);
        _sortedColumns.add(lastColumnSort);
      }
    } else {
      _sortedColumns.removeAt(columnSortIndex);
    }
    if (isSorted == false) {
      _visibleRows = UnmodifiableListView(_originalRows);
      notifyListeners();
    }
    _resort(notify: true);
  }

  void sortByColumnIndex(
      {required int columnIndex, required EasyTableSortType sortType}) {
    sortByColumn(column: _columns[columnIndex], sortType: sortType);
  }

  void sortByColumn(
      {required EasyTableColumn<ROW> column,
      required EasyTableSortType sortType}) {
    if (column.sort != null && _columns.contains(column)) {
      _sortedColumns.clear();
      _sortedColumns.add(_ColumnSort<ROW>(column: column, sortType: sortType));
      _resort(notify: true);
    }
  }

  /// Notifies any row data update by calling all the registered listeners.
  void notifyUpdate() {
    notifyListeners();
  }

  void _resort({required bool notify}) {
    if (_sortedColumns.isNotEmpty) {
      List<ROW> list = List.from(_originalRows);
      list.sort(_compoundSort);
      _visibleRows = list;
      if (notify) {
        notifyListeners();
      }
    }
  }

  int _compoundSort(ROW a, ROW b) {
    int r = 0;
    for (int i = 0; i < _sortedColumns.length; i++) {
      final EasyTableColumnSort<ROW> sort = _sortedColumns[i].column.sort!;
      final EasyTableSortType sortType = _sortedColumns[i].sortType;

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

class _ColumnSort<ROW> {
  _ColumnSort({required this.column, required this.sortType}) {
    if (column.sort == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('Null sort'),
        ErrorDescription('EasyTableColumn sort can not be null.')
      ]);
    }
  }

  final EasyTableColumn<ROW> column;
  final EasyTableSortType sortType;
}
