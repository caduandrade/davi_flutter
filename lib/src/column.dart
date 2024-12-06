import 'dart:math' as math;

import 'package:davi/src/cell_background.dart';
import 'package:davi/src/cell_value_mapper.dart';
import 'package:davi/src/cell_semantics_builder.dart';
import 'package:davi/src/cell_value_stringify.dart';
import 'package:davi/src/column_id.dart';
import 'package:davi/src/pin_status.dart';
import 'package:davi/src/sort.dart';
import 'package:davi/src/span_provider.dart';
import 'package:davi/src/summary_builder.dart';
import 'package:flutter/semantics.dart';
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
      this.cellValue,
      this.cellIcon,
      this.cellWidget,
      this.rowSpan = _defaultSpanProvider,
      this.columnSpan = _defaultSpanProvider,
      this.cellValueStringify = _defaultCellValueStringify,
      this.leading,
      DaviDataComparator<DATA>? dataComparator,
      this.pinStatus = PinStatus.none,
      this.summary,
      this.resizable = true,
      this.cellClip = false,
      this.sortable = true,
      this.semanticsBuilder = _defaultSemanticsBuilder})
      : id = id ?? DaviColumnId(),
        _width = width,
        _grow = grow != null ? math.max(1, grow) : null,
        dataComparator = dataComparator ?? _defaultDataComparator;

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

  /// Cell value mapper for each row in that column.
  final CellValueMapper<DATA>? cellValue;

  /// A function to convert the cell value into a String representation.
  ///
  /// This function is used to customize how the value of a cell is converted
  /// to a String. It will receive the dynamic value of the
  /// cell (as returned by `cellValue`) and return its string representation.
  final CellValueStringify cellValueStringify;

  /// Cell icon mapper for each row in that column.
  final CellIconMapper<DATA>? cellIcon;

  /// Cell widget mapper for each row in that column.
  final CellWidgetMapper<DATA>? cellWidget;

  final SpanProvider<DATA> rowSpan;

  final SpanProvider<DATA> columnSpan;

  /// Function used to sort the column. If not defined, it can be created
  /// according to value mappings.
  final DaviDataComparator<DATA> dataComparator;

  final SummaryBuilder? summary;

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

  /// Indicates whether the layout process has been executed at least once
  /// for this column. If true, disable grow in
  /// [ColumnWidthBehavior.scrollable] mode.
  bool _layoutPerformed = false;

  bool resizable;

  DaviSort? _sort;

  DaviSort? get sort => _sort;
  int? _sortPriority;

  int? get sortPriority => _sortPriority;

  final DaviCellSemanticsBuilder<DATA>? semanticsBuilder;

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
}

SemanticsProperties _defaultSemanticsBuilder(
    BuildContext context, dynamic data, int index, bool hovered) {
  return const SemanticsProperties(enabled: true, label: 'cell');
}

/// Signature for sort column function.
typedef DaviDataComparator<DATA> = int Function(
    dynamic a, dynamic b, DaviColumn<DATA> column);

int _defaultSpanProvider(dynamic data, rowIndex) => 1;

String _defaultCellValueStringify(dynamic value) => value.toString();

int _defaultDataComparator<DATA>(
    dynamic a, dynamic b, DaviColumn<DATA> column) {
  // Check if both values are null
  if (a == null && b == null) return 0; // They are equal
  if (a == null) return -1; // 'a' is null, so 'b' is considered greater
  if (b == null) return 1; // 'b' is null, so 'a' is considered greater

  if (a is String && b is String) {
    if (a == b) return 0;
    return a.compareTo(b); // String comparison is lexicographic
  }

  // Comparison when both values are not null
  if (a is int && b is int) {
    if (a > b) return 1;
    if (a < b) return -1;
  }

  if (a is double && b is double) {
    if (a > b) return 1;
    if (a < b) return -1;
  }

  return 0;
}

@internal
class DaviColumnHelper {
  static void performLayout(
      {required DaviColumn column, required double layoutWidth}) {
    column._layoutPerformed = true;
    if (column._grow != null) {
      column._width = layoutWidth;
    }
  }

  static bool isLayoutPerformed({required DaviColumn column}) =>
      column._layoutPerformed;
}
