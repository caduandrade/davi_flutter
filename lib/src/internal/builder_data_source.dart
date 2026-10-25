import 'package:davi/src/column.dart';
import 'package:davi/src/controller.dart';
import 'package:davi/src/data_source.dart';
import 'package:davi/src/sort.dart';
import 'package:davi/src/sort_callback_typedef.dart';
import 'package:davi/src/sorting_mode.dart';
import 'package:flutter/foundation.dart';

/// Adapts a [DaviController] plus the row data given to `Davi.builder` to
/// the [DaviDataSource] contract used internally by [Davi].
///
/// Kept alive across rebuilds by `Davi`'s state (mirroring how a
/// [DaviModel] instance is normally kept alive by whoever owns it), so its
/// identity - and therefore listener registrations made against it by
/// internal widgets - stays stable while only [rows] and [onSort] change.
@internal
class BuilderDataSource<DATA> implements DaviDataSource<DATA> {
  BuilderDataSource(
      {required this.controller,
      required Iterable<DATA> rows,
      OnSortCallback<DATA>? onSort})
      : _rows = rows is List<DATA> ? rows : List<DATA>.of(rows),
        _onSort = onSort;

  final DaviController<DATA> controller;

  List<DATA> _rows;

  /// Reuses [rows] as-is when it's already a [List] (the common case
  /// with immutable state coming from a Bloc/ChangeNotifier/etc.),
  /// otherwise materializes it once.
  ///
  /// Like `ListView.builder`'s `itemCount`/`itemBuilder`, the given
  /// `rows` must not be mutated in place without also rebuilding
  /// `Davi.builder` with the updated data: internal render objects can
  /// read [rowAt]/[rowsLength] between rebuilds (e.g. on a repaint
  /// triggered by column resize, hover or scroll), so a list that
  /// changed size behind their back could make them read an
  /// out-of-range index. Always pass a new/updated list (or a copy)
  /// when the data changes, never mutate the same instance in place.
  void updateRows(Iterable<DATA> rows) {
    _rows = rows is List<DATA> ? rows : List<DATA>.of(rows);
  }

  OnSortCallback<DATA>? _onSort;

  set onSort(OnSortCallback<DATA>? value) => _onSort = value;

  @override
  DATA rowAt(int index) => _rows[index];

  @override
  int get rowsLength => _rows.length;

  @override
  bool get isRowsEmpty => _rows.isEmpty;

  @override
  bool get isRowsNotEmpty => _rows.isNotEmpty;

  @override
  DaviColumn<DATA> columnAt(int index) => controller.columnAt(index);

  @override
  int get columnsLength => controller.columnsLength;

  @override
  bool get isColumnsEmpty => controller.isColumnsEmpty;

  @override
  bool get hasSummary => controller.hasSummary;

  /// Without an `onSort` callback nobody would ever apply the requested
  /// order, so sorting is treated as disabled: no clickable header state,
  /// no arrows, rows are shown exactly as given.
  @override
  SortingMode get sortingMode =>
      _onSort == null ? SortingMode.disabled : controller.sortingMode;

  @override
  bool get multiSortEnabled => controller.multiSortEnabled;

  @override
  bool get isMultiSorted => controller.isMultiSorted;

  @override
  List<DaviSort> get sortList => controller.sortList;

  @override
  void sort(List<DaviSort> newSortList) {
    final OnSortCallback<DATA>? onSort = _onSort;
    if (onSort == null) {
      return;
    }
    controller.applySort(newSortList);
    onSort(controller.sortedColumns);
  }

  @override
  void addListener(VoidCallback listener) => controller.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      controller.removeListener(listener);
}
