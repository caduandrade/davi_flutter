import 'dart:collection';

import 'package:easy_table/src/column.dart';
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

  double get columnsWeight {
    double w = 0;
    for (EasyTableColumn column in _columns) {
      w += column.weight;
    }
    return w;
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
    _resort(notify: true);
  }

  void _resort({required bool notify}) {
    if (_columnSort != null && _columnSort!.column.sort != null) {
      List<ROW> list = List.from(_originalRows);
      EasyTableColumnSort<ROW> sortFunction = _columnSort!.column.sort!;
      if (sortType == EasyTableSortType.descending) {
        list.sort((a, b) => sortFunction(b, a));
      } else {
        list.sort(sortFunction);
      }
      _visibleRows = list;
      if (notify) {
        notifyListeners();
      }
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
