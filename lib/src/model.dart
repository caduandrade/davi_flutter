import 'package:collection/collection.dart';
import 'package:davi/src/column.dart';
import 'package:davi/src/sort.dart';
import 'package:davi/src/sort_callback_typedef.dart';
import 'package:davi/src/sort_direction.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// The [Davi] model.
///
/// The type [DATA] represents the data of each row.
class DaviModel<DATA> extends ChangeNotifier {
  DaviModel(
      {List<DATA> rows = const [],
      List<DaviColumn<DATA>> columns = const [],
      this.ignoreSortFunctions = false,
      this.alwaysSorted = false,
      this.multiSortEnabled = false,
      this.onSort}) {
    _originalRows = List.from(rows);
    addColumns(columns);
    _updateRows(notify: false);
  }

  /// The event that will be triggered at each sorting.
  OnSortCallback<DATA>? onSort;

  final bool multiSortEnabled;

  final List<DaviColumn<DATA>> _columns = [];
  late final List<DATA> _originalRows;

  /// Gets the sorted columns.
  List<DaviColumn<DATA>> get sortedColumns {
    List<DaviColumn<DATA>> list =
        _columns.where((column) => column.isSorted).toList();
    list.sort((a, b) => a.sortPriority!.compareTo(b.sortPriority!));
    return UnmodifiableListView(list);
  }

  late List<DATA> _rows;

  /// Ignore column sorting functions to maintain the natural order of the data.
  ///
  /// Allows the header to be sortable if the column is also sortable.
  final bool ignoreSortFunctions;

  /// Defines if there will always be some sorted column.
  final bool alwaysSorted;

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
  bool get isSorted => alwaysSorted ||
          _columns.firstWhereOrNull((column) => column.isSorted) != null
      ? true
      : false;

  /// Indicates whether the model is sorted by multiple columns.
  bool get isMultiSorted {
    int count = 0;
    for (DaviColumn column in _columns) {
      if (column.isSorted) {
        count++;
      }
      if (count > 1) {
        return true;
      }
    }
    return false;
  }

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
    column.clearSortData();
    _columns.add(column);
    column.addListener(notifyListeners);
    _ensureSortIfNeeded();
    notifyListeners();
  }

  void addColumns(Iterable<DaviColumn<DATA>> columns) {
    for (DaviColumn<DATA> column in columns) {
      column.clearSortData();
      _columns.add(column);
      column.addListener(notifyListeners);
    }
    _ensureSortIfNeeded();
    notifyListeners();
  }

  /// Remove all columns.
  void removeColumns() {
    _columns.clear();
    _columnInResizing = null;
    _updateRows(notify: true);
  }

  void _updateSortPriorities() {
    int priority = 1;
    for (DaviColumn<DATA> column in _columns) {
      if (column.isSorted) {
        column.sortPriority = priority++;
      }
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
      if (column.isSorted) {
        column.clearSortData();
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
    _clearColumnsSortData();
    _ensureSortIfNeeded();
    _updateRows(notify: true);
    _notifyOnSort();
  }

  void _clearColumnsSortData() {
    for (DaviColumn<DATA> column in _columns) {
      column.clearSortData();
    }
  }

  /// Defines the columns that will be used in sorting.
  ///
  /// If multi sorting is disabled, only the first one in the list will be used.
  void sort(List<DaviSort> sortList) {
    _clearColumnsSortData();
    int priority = 1;
    for (DaviSort sort in sortList) {
      DaviColumn<DATA>? column = getColumn(sort.id);
      if (column != null &&
          column.sortable &&
          (column.sort != null || ignoreSortFunctions)) {
        column.sortDirection = sort.direction;
        column.sortPriority = priority++;
        if (!multiSortEnabled) {
          // ignoring other columns
          break;
        }
      }
    }
    _ensureSortIfNeeded();
    _updateRows(notify: true);
    _notifyOnSort();
  }

  void _ensureSortIfNeeded() {
    if (alwaysSorted && _columns.isNotEmpty) {
      DaviColumn? firstSortedColumn =
          _columns.firstWhereOrNull((column) => column.isSorted);
      if (firstSortedColumn == null) {
        DaviColumn column = _columns.first;
        column.sortDirection = DaviSortDirection.ascending;
        column.sortPriority = 1;
      }
    }
  }

  /// Notifies any data update by calling all the registered listeners.
  void notifyUpdate() {
    notifyListeners();
  }

  /// Updates the visible rows given the sorts and filters.
  void _updateRows({required bool notify}) {
    if (isSorted && !ignoreSortFunctions) {
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
    for (final DaviColumn<DATA> column in sortedColumns) {
      if (column.sort != null && column.sortDirection != null) {
        final DaviDataComparator<DATA> sort = column.sort!;
        final DaviSortDirection direction = column.sortDirection!;

        if (direction == DaviSortDirection.descending) {
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

  int? _sortPriority;
  @internal
  set sortPriority(int? value) {
    _sortPriority=value;
  }
  int? get sortPriority => _sortPriority;
  
  DaviSortDirection? _sortDirection;
  @internal
  set sortDirection(DaviSortDirection? value){
    _sortDirection=value;
  }
  DaviSortDirection? get sortDirection => _sortDirection;

  bool get isSorted => _sortDirection != null && _sortPriority != null;

  @internal
  void clearSortData() {
    _sortPriority = null;
    _sortDirection = null;
  }

  
}
