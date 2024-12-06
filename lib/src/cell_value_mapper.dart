import 'package:davi/src/cell_icon.dart';
import 'package:flutter/widgets.dart';

/// A function type that maps a given row's data to a value for display in a table cell.
///
/// This typedef is used to define how a string value is derived from the row's data for display
/// in the corresponding table cell. The function takes the row's data and index, and returns
/// an optional string that will be shown in the cell.
///
/// Parameters:
/// - `data`: The data of the row, representing the model or structure for that row.
/// - `rowIndex`: The index of the current row, starting from 0.
///
/// Return value:
/// - A value that will be displayed in the cell. If the function returns `null`,
///   no text will be shown in that cell.
typedef CellValueMapper<DATA> = dynamic Function(
  DATA data,
  int rowIndex,
);

/// A function type that maps a given row's data to a `CellIcon` for display in a table cell.
///
/// This typedef is used to define how a `CellIcon` is created for a given row of data.
/// The function takes the row's data and index, and returns an optional `CellIcon`
/// that will be displayed in the corresponding cell of the table.
///
/// Parameters:
/// - `data`: The data of the row, representing the model or structure for that row.
/// - `rowIndex`: The index of the current row, starting from 0.
///
/// Return value:
/// - A `CellIcon` instance that will be displayed in the cell. If the function returns `null`,
///   no icon will be displayed in that cell.
///
/// Example usage:
/// ```dart
/// CellIconMapper<MyData> iconMapper = (data, rowIndex) {
///   // Display a star icon for rows with a specific condition
///   if (data.isFavorite) {
///     return CellIcon(Icons.star, size: 30.0, color: Colors.yellow);
///   }
///   return null; // No icon for rows that are not marked as favorite
/// };
/// ```
typedef CellIconMapper<DATA> = CellIcon? Function(
  DATA data,
  int rowIndex,
);

/// A function type that maps a given row's data to a widget for display in a table cell.
///
/// This typedef is used to define how a `Widget` is created based on the row's data to be displayed
/// in the corresponding table cell. The function takes the row's data, its index, and the `BuildContext`,
/// and returns an optional `Widget` that will be displayed in the cell.
///
/// Parameters:
/// - `context`: The `BuildContext` in which the widget will be built. This provides access to the
///   widget tree and other necessary context-related information.
/// - `data`: The data of the row, representing the model or structure for that row.
/// - `rowIndex`: The index of the current row, starting from 0.
///
/// Return value:
/// - A `Widget` that will be displayed in the cell. If the function returns `null`,
///   no widget will be shown in that cell.
///
/// Example usage:
/// ```dart
/// CellWidgetMapper<MyData> widgetMapper = (context, data, rowIndex) {
///   // Return a custom widget for each row based on some condition
///   if (data.isActive) {
///     return Text('active');
///   }
///   return null; // No widget for inactive rows
/// };
/// ```
typedef CellWidgetMapper<DATA> = Widget? Function(
  BuildContext context,
  DATA data,
  int rowIndex,
);
