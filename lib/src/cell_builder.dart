import 'package:davi/src/cell.dart';
import 'package:flutter/widgets.dart';

/// A function signature for creating a [CellValue] instance.
///
/// This builder is used to construct the value of a cell in a table. The function
/// receives the row data and the row index and returns a [CellValue] instance to represent
/// the content of the cell.
///
/// The [CellValue] may contain a string value or other types of content that are displayed
/// in the cell.
///
/// ## Parameters:
/// - [data]: The row data that will be used to construct the cell's value.
/// - [rowIndex]: The index of the row in the table.
///
/// ## Returns:
/// - A [CellValue] instance that defines the content of the cell.
///
/// ## Example:
/// ```dart
/// CellValueBuilder<MyData> myCellValueBuilder = (data, rowIndex) {
///   return CellValue(value: data.name);
/// };
/// ```
typedef CellValueBuilder<DATA> = CellValue Function(
  DATA data,
  int rowIndex,
);

/// A function signature for creating a [CellIcon] instance.
///
/// This builder is used to construct a [CellIcon] cell in a table. The function
/// receives the row data, the row index, and returns a [CellIcon] instance to represent
/// the cell's content, which is an icon with optional styling.
///
/// The [CellIcon] may include properties like the icon, size, and color to display an icon
/// in the cell.
///
/// ## Parameters:
/// - [data]: The row data that will be used to determine which icon to display.
/// - [rowIndex]: The index of the row in the table.
///
/// ## Returns:
/// - A [CellIcon] instance that defines the icon and other properties for the cell.
///
/// ## Example:
/// ```dart
/// CellIconBuilder<MyData> myCellIconBuilder = (data, rowIndex) {
///   return CellIcon(icon: Icons.star, size: 16.0, color: Colors.yellow);
/// };
/// ```
typedef CellIconBuilder<DATA> = CellIcon Function(
  DATA data,
  int rowIndex,
);

/// A function signature for creating a [CellWidget] instance.
///
/// This builder is used to create a [CellWidget] for a table cell. It provides a custom
/// widget as the content of the cell. The builder receives the [BuildContext], row data,
/// and row index, and returns a [CellWidget] instance containing the widget to be displayed
/// in the cell.
///
/// The widget can be any valid Flutter widget, such as a `Container`, `Text`, `Image`, etc.
///
/// ## Parameters:
/// - [context]: The build context that can be used for widget-specific operations.
/// - [data]: The row data that may influence the widget being displayed.
/// - [rowIndex]: The index of the row in the table.
///
/// ## Returns:
/// - A [CellWidget] instance that contains the widget to be displayed in the cell.
///
/// ## Example:
/// ```dart
/// CellWidgetBuilder<MyData> myCellWidgetBuilder = (context, data, rowIndex) {
///   return CellWidget(widget: Text(data.name));
/// };
/// ```
typedef CellWidgetBuilder<DATA> = CellWidget Function(
  BuildContext context,
  DATA data,
  int rowIndex,
);
