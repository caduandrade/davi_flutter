import 'package:davi/src/column.dart';
import 'package:davi/src/sort.dart';
import 'package:davi/src/sorting_mode.dart';
import 'package:flutter/foundation.dart';

/// Internal read contract shared by [DaviModel] (model mode) and the
/// adapter used internally by `Davi.builder` (builder mode), so that the
/// widgets under [Davi] don't need to know which mode they're running in.
///
/// Anything about owning or mutating row data stays exclusive to each mode
/// and is intentionally left out of this contract.
@internal
abstract class DaviDataSource<DATA> implements Listenable {
  DATA rowAt(int index);

  int get rowsLength;

  bool get isRowsEmpty;

  bool get isRowsNotEmpty;

  DaviColumn<DATA> columnAt(int index);

  int get columnsLength;

  bool get isColumnsEmpty;

  bool get hasSummary;

  SortingMode get sortingMode;

  bool get multiSortEnabled;

  bool get isMultiSorted;

  List<DaviSort> get sortList;

  /// Requests a new sort configuration, typically triggered by a header tap.
  void sort(List<DaviSort> newSortList);
}
