import 'dart:collection';

import 'package:easy_table/src/easy_table_column.dart';
import 'package:easy_table/src/easy_table_sort_type.dart';
import 'package:flutter/widgets.dart';

/// The [EasyTable] model.
///
/// The type [ROW] represents the data of each row.
class EasyTableModel<ROW> extends ChangeNotifier {
  factory EasyTableModel(
      {List<ROW> rows = const [],
      List<EasyTableColumn<ROW>> columns = const []}) {
    EasyTableModel<ROW> model =
        EasyTableModel._(rows, UnmodifiableListView(rows));
    for (EasyTableColumn<ROW> column in columns) {
      model.addColumn(column);
    }
    return model;
  }

  EasyTableModel._(this._originalRows, this._visibleRows);

  final List<EasyTableColumn<ROW>> _columns = [];
  final List<ROW> _originalRows;

  List<ROW> _visibleRows;
  _ColumnSort<ROW>? _columnSort;

  EasyTableColumn<ROW>? get sortedColumn =>
      _columnSort != null ? _columnSort!.column : null;
  EasyTableSortType? get sortType =>
      _columnSort != null ? _columnSort!.sortType : null;

  bool get _visibleRowsModifiable => _visibleRows is! UnmodifiableListView;

  int get rowsLength => _originalRows.length;
  bool get isRowsEmpty => _originalRows.isEmpty;
  bool get isRowsNotEmpty => _originalRows.isNotEmpty;

  int get columnsLength => _columns.length;
  bool get isColumnsEmpty => _columns.isEmpty;
  bool get isColumnsNotEmpty => _columns.isNotEmpty;

  EasyTableColumn<ROW>? _columnInResizing;
  EasyTableColumn<ROW>? get columnInResizing => _columnInResizing;
  set columnInResizing(EasyTableColumn<ROW>? column) {
    _columnInResizing = column;
    notifyListeners();
  }

  ROW visibleRowAt(int index) => _visibleRows[index];

  void addRow(ROW row) {
    _originalRows.add(row);
    if (_visibleRowsModifiable) {
      _visibleRows.add(row);
      _resort();
    }
    notifyListeners();
  }

  void addRows(List<ROW> rows) {
    _originalRows.addAll(rows);
    if (_visibleRowsModifiable) {
      _visibleRows.addAll(rows);
      _resort();
    }
    notifyListeners();
  }

  void removeRows() {
    _originalRows.clear();
    if (_visibleRowsModifiable) {
      _visibleRows.clear();
    }
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

  void addColumns(List<EasyTableColumn<ROW>> columns) {
    for (EasyTableColumn<ROW> column in columns) {
      _columns.add(column);
      column.addListener(notifyListeners);
    }
    notifyListeners();
  }

  void removeColumns() {
    _columns.clear();
    _columnSort = null;
    _columnInResizing = null;
    notifyListeners();
  }

  void removeColumnAt(int index) {
    EasyTableColumn<ROW> column = _columns.removeAt(index);
    if (_columnInResizing == column) {
      _columnInResizing = null;
    }
    if (_columnSort?.column == column) {
      _columnSort = null;
      _visibleRows = UnmodifiableListView(_originalRows);
    }
    notifyListeners();
  }

  void removeColumn(EasyTableColumn<ROW> column) {
    _columns.remove(column);
    if (_columnInResizing == column) {
      _columnInResizing = null;
    }
    if (_columnSort?.column == column) {
      _columnSort = null;
      _visibleRows = UnmodifiableListView(_originalRows);
    }
    column.removeListener(notifyListeners);
    notifyListeners();
  }

  double get columnsWidth {
    double w = 0;
    for (EasyTableColumn column in _columns) {
      w += column.width;
    }
    return w;
  }

  /// Revert to original sort order
  void removeColumnSort() {
    if (_columnSort != null) {
      _columnSort = null;
      _visibleRows = UnmodifiableListView(_originalRows);
      notifyListeners();
    }
  }

  void sortByColumn(
      {required EasyTableColumn<ROW> column,
      required EasyTableSortType sortType}) {
    _columnSort = _ColumnSort(column, sortType);
    _resort();
  }

  void _resort() {
    if (_columnSort != null && _columnSort!.column.sort != null) {
      List<ROW> list = List.from(_originalRows);
      EasyTableColumnSort<ROW> sortFunction = _columnSort!.column.sort!;
      if (sortType == EasyTableSortType.descending) {
        list.sort((a, b) => sortFunction(b, a));
      } else {
        list.sort(sortFunction);
      }
      _visibleRows = list;
      notifyListeners();
    }
  }
}

class _ColumnSort<ROW> {
  _ColumnSort(this.column, this.sortType);

  final EasyTableColumn<ROW> column;
  final EasyTableSortType sortType;

  @override
  String toString() {
    return '_ColumnSort{column: $column, sortType: $sortType}';
  }
}
