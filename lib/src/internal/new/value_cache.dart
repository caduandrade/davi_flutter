import 'dart:collection';

import 'package:davi/davi.dart';
import 'package:meta/meta.dart';

@internal
class ValueCache<DATA> {
  final _Cache<String> _stringsCache = _Cache();
  final _NullValueCache _nullValueCache = _NullValueCache();

  String? getString({required int rowIndex, required int columnIndex}) {
    return _stringsCache.get(rowIndex: rowIndex, columnIndex: columnIndex);
  }

  bool isNull({required int rowIndex, required int columnIndex}) {
    return _nullValueCache.isNull(rowIndex: rowIndex, columnIndex: columnIndex);
  }

  void load(
      {required DaviModel<DATA>? model,
      required int rowIndex,
      required int columnIndex}) {
    if (model != null && rowIndex < model.rowsLength) {
      final DaviColumn<DATA> column = model.columnAt(columnIndex);
      final DATA data = model.rowAt(rowIndex);

      if (column.stringValueMapper != null) {
        final String? value = column.stringValueMapper!(data);
        _registerString(
            rowIndex: rowIndex, columnIndex: columnIndex, value: value);
      } else if (column.intValueMapper != null) {
        final String? value = column.intValueMapper!(data)?.toString();
        _registerString(
            rowIndex: rowIndex, columnIndex: columnIndex, value: value);
      } else if (column.doubleValueMapper != null) {
        final double? doubleValue = column.doubleValueMapper!(data);
        String? value;
        if (doubleValue != null) {
          if (column.fractionDigits != null) {
            value = doubleValue.toStringAsFixed(column.fractionDigits!);
          } else {
            value = doubleValue.toString();
          }
        }
        _registerString(
            rowIndex: rowIndex, columnIndex: columnIndex, value: value);
      } else if (column.objectValueMapper != null) {
        final String? value = column.objectValueMapper!(data)?.toString();
        _registerString(
            rowIndex: rowIndex, columnIndex: columnIndex, value: value);
      }
    }
  }

  void _registerString(
      {required int rowIndex,
      required int columnIndex,
      required String? value}) {
    _stringsCache.put(
        rowIndex: rowIndex, columnIndex: columnIndex, value: value);
    if (value == null) {
      _nullValueCache.set(rowIndex: rowIndex, columnIndex: columnIndex);
    }
  }
}

class _Cache<VALUE> {
  final Map<int, Map<int, VALUE?>> _cache = {};

  VALUE? get({required int rowIndex, required int columnIndex}) {
    Map<int, VALUE?>? rows = _cache[rowIndex];
    return rows?[columnIndex];
  }

  void put(
      {required int rowIndex,
      required int columnIndex,
      required VALUE? value}) {
    Map<int, VALUE?>? rows = _cache[rowIndex];
    if (rows == null) {
      rows = {};
      _cache[rowIndex] = rows;
    }
    rows[columnIndex] = value;
  }
}

class _NullValueCache {
  final Map<int, HashSet<int>> _cache = {};

  bool isNull({required int rowIndex, required int columnIndex}) {
    HashSet<int>? rows = _cache[rowIndex];
    if (rows != null) {
      return rows.contains(columnIndex);
    }
    return false;
  }

  void set({required int rowIndex, required int columnIndex}) {
    HashSet<int>? rows = _cache[rowIndex];
    if (rows == null) {
      rows = HashSet();
      _cache[rowIndex] = rows;
    }
    rows.add(columnIndex);
  }
}
