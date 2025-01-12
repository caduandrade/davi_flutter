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
      this.cellBarValueStringify,
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
  final CellBarValueMapper<DATA>? cellBarValue;

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

  /// A function to convert the cell bar value into a String representation.
  ///
  /// This function is used to customize how the bar value of a cell is converted
  /// to a String.
  final CellBarStringify<DATA>? cellBarValueStringify;

  /// Cell icon mapper for each row in that column.
  final CellIconMapper<DATA>? cellIcon;

  /// Custom painting function for rendering cell content.
  ///
  /// Allows drawing custom visuals for cells in this column using a Canvas.
  final CellPainter<DATA>? cellPainter;

  /// Cell widget mapper for each row in that column.
  final CellWidgetBuilder<DATA>? cellWidget;

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

SemanticsProperties _defaultSemanticsBuilder(SemanticsBuilderParams params) {
  return const SemanticsProperties(enabled: true, label: 'cell');
}

/// Signature for sort column function.
typedef DaviComparator<DATA> = int Function(
    dynamic cellValueA, dynamic cellValueB, DATA rowA, DATA rowB);

int _defaultSpanProvider(SpanParams params) => 1;

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

/// A typedef for a function that converts a dynamic value into a String.
///
/// This function is used to convert any dynamic value returned by the `cellValue`
/// function defined for a column into its string representation. The `dynamic value`
/// will never be `null` when passed to this function. If the value for a cell is null,
/// the cell will be rendered without calling this function, and no string conversion will
/// occur (the cell will typically be empty, such as an empty string).
typedef CellValueStringify = String Function(dynamic value);

/// A function type that maps a row's data to a value for display or processing in a table cell.
///
/// This typedef is used to define how a value is derived from a row in the model to be displayed
/// or processed in a table cell. The function takes a single parameter, `ValueMapperParams`,
/// which encapsulates the row's data and its index.
///
/// Parameters:
/// - `params`: An instance of `ValueMapperParams` containing the data for the entire row, its index,
///   and any additional contextual information that may be added in the future.
///
/// Return value:
/// - A value of any type (`dynamic`) that will be used in the table cell. The returned value
///   can represent anything such as a string, number, or other data derived from the row's model.
///
/// Example usage:
/// ```dart
/// CellValueMapper<MyDataModel> valueMapper = (params) {
///   return params.data.name; // Map the row's model to a specific property
/// };
/// ```
typedef CellValueMapper<DATA> = dynamic Function(
  ValueMapperParams<DATA> params,
);

/// Parameters passed to the [CellValueMapper] function.
///
/// This class encapsulates the necessary information to determine the value
/// for a specific table cell. It includes the data for the entire row and its index.
///
/// Fields:
/// - `data`: The row's data, representing the model or structure for the entire row.
/// - `rowIndex`: The index of the current row, starting from 0.
///
/// Example:
/// ```dart
/// ValueMapperParams<MyDataModel> params = ValueMapperParams(
///   data: myDataRow,
///   rowIndex: 0,
/// );
/// ```
class ValueMapperParams<DATA> extends CellBaseParams<DATA> {
  ValueMapperParams({
    required DATA data,
    required int rowIndex,
  }) : super(data: data, rowIndex: rowIndex);
}

/// A function type that maps a row's data to an icon representation for a table cell.
///
/// This typedef is used to define how an icon is derived from a row in the model to be displayed
/// in a table cell. The function takes a single parameter, `IconMapperParams`,
/// which encapsulates the row's data and its index.
///
/// Parameters:
/// - `params`: An instance of `IconMapperParams` containing the data for the entire row, its index,
///   and any additional contextual information that may be added in the future.
///
/// Return value:
/// - A `CellIcon` instance that will be displayed in the cell. If the function returns `null`,
///   no icon will be displayed in that cell.
///
/// Example usage:
/// ```dart
/// CellIconMapper<MyData> iconMapper = (params) {
///   // Display a star icon for rows with a specific condition
///   if (params.data.isFavorite) {
///     return CellIcon(Icons.star, size: 30.0, color: Colors.yellow);
///   }
///   return null; // No icon for rows that are not marked as favorite
/// };
/// ```
typedef CellIconMapper<DATA> = CellIcon? Function(
  IconMapperParams<DATA> params,
);

/// Parameters passed to the [CellIconMapper] function.
///
/// This class encapsulates the necessary information to determine the icon
/// for a specific table cell. It includes the data for the entire row and its index.
///
/// Fields:
/// - `data`: The row's data, representing the model or structure for the entire row.
/// - `rowIndex`: The index of the current row, starting from 0.
///
/// Example:
/// ```dart
/// IconMapperParams<MyDataModel> params = IconMapperParams(
///   data: myDataRow,
///   rowIndex: 0,
/// );
/// ```
class IconMapperParams<DATA> extends CellBaseParams<DATA> {
  IconMapperParams({
    required DATA data,
    required int rowIndex,
  }) : super(data: data, rowIndex: rowIndex);
}

/// A function type that maps a given row's data to a widget for display in a table cell.
///
/// This typedef is used to define how a `Widget` is created based on the row's data to be displayed
/// in the corresponding table cell.
///
/// Example usage:
/// ```dart
/// CellWidgetMapper<MyData> widgetMapper = (params) {
///   // Return a custom widget for each row based on some condition
///   if (params.data.isActive) {
///     return Text('active');
///   }
///   return null; // No widget for inactive rows
/// };
/// ```
typedef CellWidgetBuilder<DATA> = Widget? Function(
    WidgetBuilderParams<DATA> params);

/// A class that encapsulates the parameters needed to build a widget for a cell.
class WidgetBuilderParams<DATA> extends CellBaseParams<DATA> {
  WidgetBuilderParams(
      {required this.buildContext,
      required DATA data,
      required int rowIndex,
      required this.rebuildCallback,
      required this.columnIndex})
      : super(data: data, rowIndex: rowIndex);

  /// The Flutter BuildContext for rendering.
  final BuildContext buildContext;

  /// The index of the column.
  final int columnIndex;

  /// Callback for triggering rebuilds.
  final VoidCallback rebuildCallback;

  PositionKey get localKey =>
      PositionKey(rowIndex: rowIndex, columnIndex: columnIndex);
}

class PositionKey extends LocalKey {
  const PositionKey({required this.rowIndex, required this.columnIndex});

  final int rowIndex;
  final int columnIndex;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PositionKey &&
          runtimeType == other.runtimeType &&
          rowIndex == other.rowIndex &&
          columnIndex == other.columnIndex;

  @override
  int get hashCode => rowIndex.hashCode ^ columnIndex.hashCode;
}

/// Represents the style configuration for a cell bar value.
///
/// This class is used to customize the appearance of the bar, including
/// the background, foreground, text color, and text size.
class CellBarStyle {
  /// The background color of the bar.
  ///
  /// This color represents the portion of the bar that is not filled, indicating
  /// the remaining progress.
  final Color? barBackground;

  /// A function that returns a color for the bar's foreground based on
  /// the current progress value (ranging from 0.0 to 1.0).
  ///
  /// This determines the color of the filled portion of the bar, reflecting the value.
  final CellBarColor? barForeground;

  /// A function that returns the color for the text displayed on the progress bar
  /// based on the current progress value.
  ///
  /// This allows for dynamic text color changes as the progress changes.
  final CellBarColor? textColor;

  /// The size of the text displayed.
  final double? textSize;

  /// Creates a [CellBarStyle] object with the given properties.
  ///
  /// [barBackground] specifies the background color of the bar.
  /// [barForeground] defines the color of the foreground based on the value.
  /// [textColor] determines the color of the text based on the value.
  /// [textSize] defines the size of the text.
  const CellBarStyle({
    this.barBackground,
    this.barForeground,
    this.textColor,
    this.textSize,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellBarStyle &&
          runtimeType == other.runtimeType &&
          barBackground == other.barBackground &&
          barForeground == other.barForeground &&
          textColor == other.textColor &&
          textSize == other.textSize;

  @override
  int get hashCode =>
      barBackground.hashCode ^
      barForeground.hashCode ^
      textColor.hashCode ^
      textSize.hashCode;
}

/// A function type that takes a [double] value (representing value, between 0.0 and 1.0)
/// and returns a [Color] value.
///
/// This function is used to dynamically determine the color of the foreground or text
/// based on the current value.
typedef CellBarColor = Color Function(double value);

/// A function type that calculates the value for a progress bar in a table cell,
/// based on the provided row data.
///
/// This typedef is used to define how a progress bar's value is derived from a row's data.
/// The function takes a single parameter, `BarValueMapperParams`, which encapsulates
/// the row's data and its index.
///
/// Parameters:
/// - `params`: An instance of `BarValueMapperParams` containing the data for the entire row
///   and its index.
///
/// Return value:
/// - A `double` value between `0.0` and `1.0` representing the percentage of the bar's value.
///   If the function returns `null`, no progress bar will be displayed for that cell.
///
/// Example usage:
/// ```dart
/// CellBarValueMapper<MyDataModel> barValueMapper = (params) {
///   return params.data.progress / 100.0; // Map progress to a percentage (0.0 to 1.0)
/// };
/// ```
typedef CellBarValueMapper<DATA> = double? Function(
  BarValueMapperParams<DATA> params,
);

/// A typedef for a function that converts a bar value into a String.
///
/// This function is used to convert any bar value returned by the `cellBarValue`
/// function defined for a column into its string representation.
typedef CellBarStringify<DATA> = String Function(
    BarValueMapperParams<DATA> params);

/// Parameters passed to the [CellBarValueMapper] function.
///
/// This class encapsulates the necessary information to determine the progress bar value
/// for a specific table cell. It includes the data for the entire row and its index.
///
/// Fields:
/// - `data`: The row's data, representing the model or structure for the entire row.
/// - `rowIndex`: The index of the current row, starting from 0.
///
/// Example:
/// ```dart
/// BarValueMapperParams<MyDataModel> params = BarValueMapperParams(
///   data: myDataRow,
///   rowIndex: 0,
/// );
/// ```
class BarValueMapperParams<DATA> extends CellBaseParams<DATA> {
  BarValueMapperParams({
    required DATA data,
    required int rowIndex,
  }) : super(data: data, rowIndex: rowIndex);
}

/// A base class that encapsulates common parameters for mappers, such as the row's data and index.
///
/// This class can be extended by other parameter classes like `ValueMapperParams`, `IconMapperParams`,
/// and `BarValueMapperParams` to avoid duplication of common fields.
///
/// Fields:
/// - `data`: The row's data, representing the model or structure for the entire row.
/// - `rowIndex`: The index of the current row, starting from 0.
class CellBaseParams<DATA> {
  CellBaseParams({
    required DATA data,
    required int rowIndex,
  })  : _data = data,
        _rowIndex = rowIndex;

  /// The model data representing the entire row.
  DATA get data => _data;
  DATA _data;

  /// The index of the current row.
  int get rowIndex => _rowIndex;
  int _rowIndex;
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

  static ValueMapperParams<DATA> valueParams<DATA>(
      {required ValueMapperParams<DATA>? params,
      required DATA data,
      required int rowIndex}) {
    if (params == null) {
      params = ValueMapperParams(data: data, rowIndex: rowIndex);
    } else {
      params._data = data;
      params._rowIndex = rowIndex;
    }
    return params;
  }

  static BarValueMapperParams<DATA> barValueParams<DATA>(
      {required BarValueMapperParams<DATA>? params,
      required DATA data,
      required int rowIndex}) {
    if (params == null) {
      params = BarValueMapperParams(data: data, rowIndex: rowIndex);
    } else {
      params._data = data;
      params._rowIndex = rowIndex;
    }
    return params;
  }

  static IconMapperParams<DATA> iconParams<DATA>(
      {required IconMapperParams<DATA>? params,
      required DATA data,
      required int rowIndex}) {
    if (params == null) {
      params = IconMapperParams(data: data, rowIndex: rowIndex);
    } else {
      params._data = data;
      params._rowIndex = rowIndex;
    }
    return params;
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
