import 'package:flutter/material.dart';

/// The base class for defining the configuration of a cell in a table.
///
/// `DaviCell` serves as a parent class for all types of table cells,
/// providing common attributes for row and column spanning.
///
/// ## Attributes:
/// - [columnSpan]: The number of columns this cell should span. Defaults to `null`,
///   which indicates no column spanning.
/// - [rowSpan]: The number of rows this cell should span. Defaults to `null`,
///   which indicates no row spanning.
///
/// ## Note:
/// Subclasses of `DaviCell` should define the specific content and behavior
/// of the cell, such as text, icons, or custom widgets.
abstract class DaviCell {
  /// Creates a `DaviCell` with optional row and column spanning.
  const DaviCell({this.columnSpan, this.rowSpan});

  /// The number of columns this cell spans.
  ///
  /// If null, the cell spans only its own column.
  final int? columnSpan;

  /// The number of rows this cell spans.
  ///
  /// If null, the cell spans only its own row.
  final int? rowSpan;
}

/// Represents the textual value of a cell within a table.
///
/// `CellValue` is a concrete implementation of `DaviCell` designed for cells
/// that display text content. It inherits the spanning behavior from its parent class.
///
/// ## Attributes:
/// - [value]: The content of the cell as a [String]. Use this for simple text.
/// - [columnSpan]: (Inherited) The number of columns this cell should span.
/// - [rowSpan]: (Inherited) The number of rows this cell should span.
class CellValue extends DaviCell {
  /// Creates a `CellValue` with the given text content and optional spanning.
  const CellValue(this.value, {int? columnSpan, int? rowSpan})
      : super(columnSpan: columnSpan, rowSpan: rowSpan);

  /// The text content of the cell.
  ///
  /// This value is typically displayed as the cell's text.
  final String? value;
}

/// Represents a cell containing an icon within a table.
///
/// `CellIcon` is a concrete implementation of `DaviCell` designed for cells
/// that display an icon. It inherits the spanning behavior from its parent class.
///
/// ## Attributes:
/// - [icon]: The [IconData] representing the icon to be displayed in the cell.
/// - [size]: The size of the icon. Defaults to `24.0`.
/// - [color]: The color of the icon. Defaults to [Colors.black].
/// - [columnSpan]: (Inherited) The number of columns this cell should span.
/// - [rowSpan]: (Inherited) The number of rows this cell should span.
class CellIcon extends DaviCell {
  /// Creates a `CellIcon` with the given icon properties and optional spanning.
  ///
  /// - [icon]: The icon to display. If null, the cell will be empty.
  /// - [size]: The size of the icon. Defaults to `12.0`.
  /// - [color]: The color of the icon. Defaults to [Colors.black].
  const CellIcon(
    this.icon, {
    this.size = 24.0,
    this.color = Colors.black,
    int? columnSpan,
    int? rowSpan,
  }) : super(columnSpan: columnSpan, rowSpan: rowSpan);

  /// The icon to display in the cell.
  ///
  /// This defines the visual representation of the cell.
  final IconData? icon;

  /// The size of the icon.
  ///
  /// Defaults to `24.0`.
  final double? size;

  /// The color of the icon.
  ///
  /// Defaults to [Colors.black].
  final Color? color;
}

/// Represents a cell containing a custom widget within a table.
///
/// `CellWidget` is a concrete implementation of `DaviCell` designed for cells
/// that display a Flutter widget. It inherits the spanning behavior from its parent class.
///
/// ## Attributes:
/// - [widget]: The custom [Widget] to be displayed in the cell. Can be any Flutter widget.
/// - [columnSpan]: (Inherited) The number of columns this cell should span.
/// - [rowSpan]: (Inherited) The number of rows this cell should span.
class CellWidget extends DaviCell {
  /// Creates a `CellWidget` with the given widget and optional spanning.
  ///
  /// - [widget]: The custom widget to display. Required.
  const CellWidget(
    this.widget, {
    int? columnSpan,
    int? rowSpan,
  }) : super(columnSpan: columnSpan, rowSpan: rowSpan);

  /// The custom widget to display in the cell.
  ///
  /// This can be any Flutter widget, such as `Text`, `Container`, or a custom widget.
  final Widget? widget;
}
