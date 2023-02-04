import 'dart:math' as math;

import 'package:davi/src/cell_background.dart';
import 'package:davi/src/cell_builder.dart';
import 'package:davi/src/cell_style.dart';
import 'package:davi/src/column_id.dart';
import 'package:davi/src/pin_status.dart';
import 'package:davi/src/sort.dart';
import 'package:davi/src/value_mapper.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// The [Davi] column.
///
/// The optional value mappings [intValue], [doubleValue], [stringValue],
/// [iconValue] and [objectValue] allows automatic cell configuration
/// by identifying and displaying data types in the row object.
class DaviColumn<DATA> extends ChangeNotifier {
  DaviColumn(
      {dynamic id,
      double width = 100,
      double? grow,
      this.name,
      this.headerPadding,
      this.cellPadding,
      this.headerAlignment,
      this.cellAlignment,
      this.cellBackground,
      this.headerTextStyle,
      this.cellTextStyle,
      this.cellOverflow,
      this.fractionDigits,
      this.cellBuilder,
      this.leading,
      DaviDataComparator<DATA>? dataComparator,
      this.pinStatus = PinStatus.none,
      DaviIntValueMapper<DATA>? intValue,
      DaviDoubleValueMapper<DATA>? doubleValue,
      DaviStringValueMapper<DATA>? stringValue,
      DaviIconValueMapper<DATA>? iconValue,
      DaviObjectValueMapper<DATA>? objectValue,
      this.resizable = true,
      this.cellClip = false,
      this.sortable = true,
      this.cellStyleBuilder})
      : id = id ?? DaviColumnId(),
        _width = width,
        _grow = grow != null ? math.max(1, grow) : null,
        stringValueMapper = stringValue,
        intValueMapper = intValue,
        iconValueMapper = iconValue,
        doubleValueMapper = doubleValue,
        objectValueMapper = objectValue,
        dataComparator = dataComparator ??
            _buildDataComparator(
                intValue, doubleValue, stringValue, iconValue, objectValue);

  /// Identifier that can be assigned to this column.
  ///
  /// If none is defined, a [DaviColumnId] will be created;
  final dynamic id;

  /// Optional column name. Displayed by default in the cell header widget.
  final String? name;

  final Widget? leading;
  final EdgeInsets? cellPadding;

  /// Padding for the header widget.
  final EdgeInsets? headerPadding;

  final Alignment? headerAlignment;
  final Alignment? cellAlignment;
  final TextOverflow? cellOverflow;
  final CellBackgroundBuilder<DATA>? cellBackground;
  final TextStyle? cellTextStyle;
  final TextStyle? headerTextStyle;

  /// The optional decimal-point string-representation used by the
  /// default cell width when the [doubleValue] is set.
  final int? fractionDigits;

  final PinStatus pinStatus;

  /// Cell widget builder for each row in that column.
  final DaviCellBuilder<DATA>? cellBuilder;

  /// Function used to sort the column. If not defined, it can be created
  /// according to value mappings.
  final DaviDataComparator<DATA> dataComparator;

  final DaviIntValueMapper<DATA>? intValueMapper;
  final DaviDoubleValueMapper<DATA>? doubleValueMapper;
  final DaviStringValueMapper<DATA>? stringValueMapper;
  final DaviObjectValueMapper<DATA>? objectValueMapper;
  final DaviIconValueMapper<DATA>? iconValueMapper;
  final CellStyleBuilder<DATA>? cellStyleBuilder;

  /// Indicates whether the cell widget should be clipped.
  final bool cellClip;

  /// Indicates whether this column allows sorting events.
  final bool sortable;

  double _width;
  double? _grow;

  /// The grow factor to use for this column.
  ///
  /// Can be positive or null.
  /// See [ColumnWidthBehavior] for more details.
  double? get grow => _grow;

  set grow(double? value) {
    if (value != null) {
      value = math.max(1, value);
    }
    if (_grow != value) {
      _grow = value;
      notifyListeners();
    }
  }

  double get width => _width;

  set width(double value) {
    value = math.max(16, value);
    if (_width != value) {
      _width = value;
      notifyListeners();
    }
  }

  bool resizable;

  DaviSort? _sort;

  DaviSort? get sort => _sort;
  int? _sortPriority;

  int? get sortPriority => _sortPriority;

  @internal
  void setSort(DaviSort sort, int priority) {
    if (sort.columnId != id) {
      throw ArgumentError.value(sort.columnId, null,
          'The columnId does not have the same value as the column identifier.');
    }
    if (!sortable) {
      throw ArgumentError('Column is not sortable.');
    }
    _sort = sort;
    _sortPriority = priority;
  }

  @internal
  bool setSortPriority(int value) {
    if (_sort != null) {
      _sortPriority = value;
      return true;
    }
    return false;
  }

  @internal
  void clearSort() {
    _sort = null;
    _sortPriority = null;
  }

  @override
  String toString() {
    return 'DaviColumn{name: $name}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DaviColumn && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// Builds a default sort
  static DaviDataComparator _buildDataComparator<DATA>(
      DaviIntValueMapper<DATA>? intValue,
      DaviDoubleValueMapper<DATA>? doubleValue,
      DaviStringValueMapper<DATA>? stringValue,
      DaviIconValueMapper<DATA>? iconValue,
      DaviObjectValueMapper<DATA>? objectValue) {
    if (intValue != null) {
      return (a, b, column) {
        int? v1 = intValue(a);
        int? v2 = intValue(b);
        if (v1 == null && v2 == null) {
          return 0;
        }
        if (v1 == null) {
          return -1;
        }
        if (v2 == null) {
          return 1;
        }
        return v1.compareTo(v2);
      };
    } else if (doubleValue != null) {
      return (a, b, column) {
        double? v1 = doubleValue(a);
        double? v2 = doubleValue(b);
        if (v1 == null && v2 == null) {
          return 0;
        }
        if (v1 == null) {
          return -1;
        }
        if (v2 == null) {
          return 1;
        }
        return v1.compareTo(v2);
      };
    } else if (stringValue != null) {
      return (a, b, column) {
        String? v1 = stringValue(a);
        String? v2 = stringValue(b);
        if (v1 == null && v2 == null) {
          return 0;
        }
        if (v1 == null) {
          return -1;
        }
        if (v2 == null) {
          return 1;
        }
        return v1.compareTo(v2);
      };
    } else if (objectValue != null) {
      return (a, b, column) {
        Object? v1 = objectValue(a);
        Object? v2 = objectValue(b);
        if (v1 == null && v2 == null) {
          return 0;
        }
        if (v1 == null) {
          return -1;
        }
        if (v2 == null) {
          return 1;
        }
        if (a is Comparable && b is Comparable) {
          return a.compareTo(b);
        }
        return 0;
      };
    }
    return _defaultDataComparator;
  }
}

/// Signature for sort column function.
typedef DaviDataComparator<DATA> = int Function(
    DATA a, DATA b, DaviColumn<DATA> column);

int _defaultDataComparator<DATA>(DATA a, DATA b, DaviColumn<DATA> column) => 0;
