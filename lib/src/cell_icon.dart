import 'package:flutter/material.dart';

/// A class representing an icon used as a value in a cell of the table.
///
/// The `CellIcon` class allows you to display an icon in a table cell, with customizable
/// properties such as the icon size and color.
///
/// The constructor requires the `icon` parameter, which defines the icon to be displayed,
/// and it also allows optional customization of the `size` and `color` of the icon.
///
/// Example usage:
/// ```dart
/// CellIcon myIcon = CellIcon(
///   Icons.star, // Icon to display
///   size: 30.0, // Optional: custom size
///   color: Colors.yellow, // Optional: custom color
/// );
/// ```
class CellIcon implements Comparable<CellIcon> {
  const CellIcon(
    this.icon, {
    this.size = 24.0,
    this.color = Colors.black,
  });

  /// The [IconData] representing the icon to be displayed in the cell.
  ///
  /// This is a required parameter, and it determines which icon is shown in the table cell.
  final IconData icon;

  /// The size of the icon, in logical pixels.
  ///
  /// This is an optional parameter. The default value is `24.0`.
  final double size;

  /// The color of the icon.
  ///
  /// This is an optional parameter. The default value is `Colors.black`.
  final Color color;

  @override
  int compareTo(CellIcon other) =>
      icon.codePoint.compareTo(other.icon.codePoint);
}
