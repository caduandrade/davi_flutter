import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:davi/src/column.dart';
import 'package:davi/src/sort.dart';
import 'package:davi/src/sort_direction.dart';
import 'package:davi/src/sorting_mode.dart';
import 'package:flutter/widgets.dart';

/// The controller used by `Davi.builder` (the builder mode of [Davi]).
///
/// Unlike [DaviModel], it never holds row data. It only keeps the state of
/// the columns: their order, size and current sort configuration. Row data
/// is passed directly to `Davi.builder` and is expected to come from, and
/// be ordered by, an external source (a Bloc, a ChangeNotifier, etc.).
///
/// The type [DATA] represents the data of each row.
class DaviController<DATA> extends ChangeNotifier {
  DaviController(
      {List<DaviColumn<DATA>> columns = const [],
      this.multiSortEnabled = false,
      SortingMode sortingMode = SortingMode.interactive})
      : _sortingMode = sortingMode {
    _addColumns(columns, false);
  }

  final List<DaviColumn<DATA>> _columns = [];

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

  /// Specifies the sorting mode used to decide how a header tap cycles the
  /// column's sort state. Unlike [DaviModel.sortingMode], this never sorts
  /// row data by itself: it only affects the visual sort state kept here,
  /// which is reported through `Davi.builder`'s `onSort` callback.
  SortingMode _sortingMode;
  SortingMode get sortingMode => _sortingMode;
  set sortingMode(SortingMode value) {
    if (_sortingMode != value) {
      _sortingMode = value;
      notifyListeners();
    }
  }

  int get columnsLength => _columns.length;

  bool get isColumnsEmpty => _columns.isEmpty;

  bool get isColumnsNotEmpty => _columns.isNotEmpty;

  /// Indicates whether the controller is sorted.
  bool get isSorted =>
      _columns.firstWhereOrNull((column) => column.sortDirection != null) !=
              null
          ? true
          : false;

  /// Indicates whether the controller is sorted by multiple columns.
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

  DaviColumn<DATA> columnAt(int index) => _columns[index];

  /// Gets a column given an [id]. If [id] is `NULL`, no columns are returned.
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
    notifyListeners();
  }

  /// Adds new columns to the controller.
  void addColumns(Iterable<DaviColumn<DATA>> columns) {
    _addColumns(columns, true);
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
    if (notify) {
      notifyListeners();
    }
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

  /// Adjusts the width of the resizable columns to fit their content: the
  /// header and only the cells of the rows visible in the viewport at the
  /// moment (rows outside the scroll area are not measured). The width is
  /// limited by [DaviColumn.maxAutoSizeWidth].
  ///
  /// It has the same effect as double clicking the resize area of each
  /// column header. Only works with [ColumnWidthBehavior.scrollable].
  void autoSizeColumns() {
    for (DaviColumn<DATA> column in _columns) {
      if (column.resizable) {
        DaviColumnHelper.requestAutoSize(column: column);
      }
    }
  }

  /// Remove all columns.
  void removeColumns() {
    _columns.clear();
    _hasSummary = false;
    notifyListeners();
  }

  /// Removes a column from a given index.
  void removeColumnAt(int index) {
    DaviColumn<DATA> column = _columns[index];
    removeColumn(column);
  }

  /// Removes a column.
  void removeColumn(DaviColumn<DATA> column) {
    if (_columns.remove(column)) {
      column.removeListener(notifyListeners);
      if (column.sortDirection != null) {
        DaviColumnHelper.clearSort(column: column);
        _fixSortPriorities();
      }
      _checkSummary();
      notifyListeners();
    }
  }

  void _checkSummary() {
    _hasSummary = _columns.any((column) => column.summary != null);
  }

  /// Reverts the columns to their unsorted (natural) visual state.
  void clearSort() {
    _clearColumnsSortData();
    notifyListeners();
  }

  void _clearColumnsSortData() {
    for (DaviColumn<DATA> column in _columns) {
      DaviColumnHelper.clearSort(column: column);
    }
  }

  /// Applies [newSortList] to the columns, updating only the visual sort
  /// state (arrow/priority) kept by this controller. It never touches row
  /// data - that stays the responsibility of whoever owns it, typically in
  /// response to `Davi.builder`'s `onSort` callback.
  ///
  /// Use this both to reflect the outcome of a header tap and to let the
  /// external state re-sync the visual sort explicitly (e.g. when it is
  /// changed programmatically, or when a requested sort is rejected).
  void applySort(List<DaviSort> newSortList) {
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
    notifyListeners();
  }
}
