import 'dart:math' as math;

import 'package:davi/davi.dart';
import 'package:davi/src/cell_semantics_builder.dart';
import 'package:davi/src/span_provider.dart';
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
      this.cellValue,
      this.cellIcon,
      this.cellWidget,
      this.cellPainter,
      this.cellBarStyle,
      this.cellBarValue,
      this.rowSpan = _defaultSpanProvider,
      this.columnSpan = _defaultSpanProvider,
      this.cellValueStringify = _defaultCellValueStringify,
      this.leading,
      DaviComparator<DATA>? dataComparator,
      this.pinStatus = PinStatus.none,
      this.summary,
      this.resizable = true,
      this.cellClip = true,
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
  final CellTextStyleBuilder<DATA>? cellTextStyle;
  final TextStyle? headerTextStyle;

  final PinStatus pinStatus;

  /// Cell value mapper for each row in that column.
  final CellValueMapper<DATA>? cellValue;

  /// Represents the function that calculates the value for the cell's bar.
  ///
  /// The function must return a value between 0.0 (0%) and 1.0 (100%),
  /// or `null` if no progress bar should be displayed.
  final CellBarValue<DATA>? cellBarValue;

  /// The style configuration for the cell's progress bar.
  ///
  /// This defines how the progress bar will appear, including the background color,
  /// foreground color (based on progress), text color, and text size. If `null`,
  /// the default style will be used.
  final CellBarStyle? cellBarStyle;

  /// A function to convert the cell value into a String representation.
  ///
  /// This function is used to customize how the value of a cell is converted
  /// to a String. It will receive the dynamic value of the
  /// cell (as returned by `cellValue`) and return its string representation.
  final CellValueStringify cellValueStringify;

  /// Cell icon mapper for each row in that column.
  final CellIconMapper<DATA>? cellIcon;

  /// Custom painting function for rendering cell content.
  ///
  /// Allows drawing custom visuals for cells in this column using a Canvas.
  final CellPainter<DATA>? cellPainter;

  /// Cell widget mapper for each row in that column.
  final CellWidgetMapper<DATA>? cellWidget;

  final SpanProvider<DATA> rowSpan;

  final SpanProvider<DATA> columnSpan;

  /// Function used to sort the column. If not defined, it can be created
  /// according to value mappings.
  final DaviComparator<DATA> dataComparator;

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
typedef DaviComparator<DATA> = int Function(
    dynamic cellValueA, dynamic cellValueB, DATA rowA, DATA rowB);

int _defaultSpanProvider(dynamic data, rowIndex) => 1;

String _defaultCellValueStringify(dynamic value) => value.toString();

int _defaultDataComparator<DATA>(
    dynamic cellValueA, dynamic cellValueB, DATA rowA, DATA rowB) {
  // Check if both values are null
  if (cellValueA == null && cellValueB == null) {
    // They are equal
    return 0;
  }
  if (cellValueA == null) {
    // 'a' is null, so 'b' is considered greater
    return -1;
  }
  if (cellValueB == null) {
    // 'b' is null, so 'a' is considered greater
    return 1;
  }

  if (cellValueA is String && cellValueB is String) {
    if (cellValueA == cellValueB) {
      return 0;
    }
    // String comparison is lexicographic
    return cellValueA.compareTo(cellValueB);
  }

  // Comparison when both values are not null
  if (cellValueA is int && cellValueB is int) {
    if (cellValueA > cellValueB) {
      return 1;
    }
    if (cellValueA < cellValueB) {
      return -1;
    }
  }

  if (cellValueA is double && cellValueB is double) {
    if (cellValueA > cellValueB) {
      return 1;
    }
    if (cellValueA < cellValueB) {
      return -1;
    }
  }

  return cellValueA.compareTo(cellValueB);
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
