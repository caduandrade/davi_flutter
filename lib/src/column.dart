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
      this.cellListenable,
      this.rowSpan = _defaultSpanProvider,
      this.columnSpan = _defaultSpanProvider,
      this.cellValueStringify = _defaultCellValueStringify,
      this.leading,
      DaviComparator<DATA>? dataComparator,
      this.pinStatus = PinStatus.none,
      DaviSortDirection? sortDirection,
      int sortPriority = 1,
      this.summary,
      this.resizable = true,
      this.cellClip = true,
      this.sortable = true,
      this.semanticsBuilder = _defaultSemanticsBuilder})
      : id = id ?? DaviColumnId(),
        _sortDirection = sortDirection,
        _sortPriority = math.max(1, sortPriority),
        _width = width,
        _grow = grow != null ? math.max(1, grow) : null,
        dataComparator = dataComparator ?? _defaultDataComparator {
    int count = 0;
    if (cellValue != null) count++;
    if (cellIcon != null) count++;
    if (cellWidget != null) count++;
    if (cellPainter != null) count++;
    if (cellBarValue != null) count++;
    if (count > 1) {
      throw ArgumentError(
        'Conflict detected: Only one of "cellValue", "cellIcon", "cellWidget", '
        '"cellPainter", or "cellBarValue" can be used at a time. '
        'Ensure that only one attribute is set to avoid this error.',
      );
    }
  }

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

  /// A builder function that provides a [Listenable] for a specific cell in this column.
  /// When the returned [Listenable] notifies listeners, the corresponding cell will be rebuilt.
  /// This allows dynamic updates of cell content based on external changes.
  ///
  /// The builder receives the row's data ([DATA]) and its index ([rowIndex]) to determine
  /// the appropriate [Listenable] for each cell.
  final DaviCellListenableBuilder<DATA>? cellListenable;

  /// Defines the row span.
  final SpanProvider<DATA> rowSpan;

  /// Defines the column span.
  final SpanProvider<DATA> columnSpan;

  /// Function used to sort the column. If not defined, it can be created
  /// according to value mappings.
  final DaviComparator<DATA> dataComparator;

  /// Defines the column summary.
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

  DaviSortDirection? _sortDirection;

  /// Defines the sorting order, either ascending or descending.
  DaviSortDirection? get sortDirection => _sortDirection;

  int _sortPriority = 1;

  /// Defines the priority for sorting when multiple columns are ordered.
  int get sortPriority => _sortPriority;

  final DaviCellSemanticsBuilder<DATA>? semanticsBuilder;

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

  if (cellValueA.runtimeType == cellValueB.runtimeType &&
      cellValueA is Comparable &&
      cellValueB is Comparable) {
    return cellValueA.compareTo(cellValueB);
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

  static void setSort(
      {required DaviColumn column,
      required DaviSortDirection direction,
      required int priority}) {
    if (!column.sortable) {
      throw ArgumentError('Column is not sortable.');
    }
    column._sortDirection = direction;
    column._sortPriority = math.max(priority, 1);
  }

  static bool setSortPriority(
      {required DaviColumn column, required int priority}) {
    if (column._sortDirection != null) {
      column._sortPriority = math.max(priority, 1);
      return true;
    }
    return false;
  }

  static void clearSort({required DaviColumn column}) {
    column._sortDirection = null;
    column._sortPriority = 1;
  }
}
