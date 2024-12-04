import 'dart:collection';
import 'dart:math' as math;
import 'package:collection/collection.dart';
import 'package:davi/src/column.dart';
import 'package:davi/src/max_span_behavior.dart';
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
      this.maxSpanBehavior = MaxSpanBehavior.throwException})
      : maxRowSpan = math.max(maxRowSpan, 1),
        maxColumnSpan = math.max(maxColumnSpan, 1) {
    _originalRows = List.from(rows);
    addColumns(columns);
    _updateRows(notify: false);
  }

  late List<DATA> _rows;
  final List<DaviColumn<DATA>> _columns = [];
  late final List<DATA> _originalRows;

  /// The event that will be triggered at each sorting.
  OnSortCallback<DATA>? onSort;

  final bool multiSortEnabled;

  bool _hasSummary = false;
  bool get hasSummary => _hasSummary;

  /// Gets the sorted columns.
  List<DaviColumn<DATA>> get sortedColumns {
    List<DaviColumn<DATA>> list =
        _columns.where((column) => column.sort != null).toList();
    list.sort((a, b) => a.sortPriority!.compareTo(b.sortPriority!));
    return list;
  }

  /// The list of sorts. The list is sorted by priority.
  List<DaviSort> get sortList {
    List<DaviSort> list = [];
    for (DaviColumn<DATA> column in sortedColumns) {
      final DaviSort? sort = column.sort;
      if (sort == null) {
        throw StateError('Column sort should not be null.');
      }
      list.add(sort);
    }
    return list;
  }

  /// Ignore column [dataComparator] to maintain the natural order of the data.
  final bool ignoreDataComparators;

  /// Defines if there will always be some sorted column.
  ///
  /// The column must be sortable.
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

  /// Indicates whether the model is sorted.
  ///
  /// The model will be sorted if it has at least one sorted column.
  bool get isSorted =>
      _columns.firstWhereOrNull((column) => column.sort != null) != null
          ? true
          : false;

  /// Indicates whether the model is sorted by multiple columns.
  bool get isMultiSorted {
    int count = 0;
    for (DaviColumn column in _columns) {
      if (column.sort != null) {
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
    column.clearSort();
    _columns.add(column);
    _checkColumnIdCollision();
    _checkSummary();
    column.addListener(notifyListeners);
    _ensureSort();
    notifyListeners();
  }

  void addColumns(Iterable<DaviColumn<DATA>> columns) {
    for (DaviColumn<DATA> column in columns) {
      column.clearSort();
      _columns.add(column);
      column.addListener(notifyListeners);
    }
    _checkColumnIdCollision();
    _checkSummary();
    _ensureSort();
    notifyListeners();
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
      if (column.sort != null) {
        column.clearSort();
        int priority = 1;
        for (DaviColumn<DATA> otherColumn in _columns) {
          if (otherColumn.setSortPriority(priority)) {
            priority++;
          }
        }
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
      column.clearSort();
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
        column.setSort(sort, priority++);
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
          if (column.sort != null) {
            // It's already sorted.
            return;
          }
          firstNonSortedColumn ??= column;
        }
      }
      // No sorted columns. Let's order the first one available.
      if (firstNonSortedColumn != null) {
        firstNonSortedColumn.setSort(
            DaviSort(firstNonSortedColumn.id, DaviSortDirection.ascending), 1);
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
      if (column.sort != null) {
        final DaviDataComparator<DATA> dataComparator = column.dataComparator;
        final DaviSortDirection direction = column.sort!.direction;

        if (direction == DaviSortDirection.descending) {
          r = dataComparator(b, a, column);
        } else {
          r = dataComparator(a, b, column);
        }
        if (r != 0) {
          break;
        }
      }
    }
    return r;
  }
}
