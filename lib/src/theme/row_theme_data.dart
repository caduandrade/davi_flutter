import 'package:easy_table/src/theme/row_color.dart';
import 'package:flutter/material.dart';

/// The [EasyTable] row theme.
/// Defines the configuration of the overall visual [RowThemeData] for a widget subtree within the app.
class RowThemeData {
  /// Builds a theme data.
  const RowThemeData({
    this.color,
    this.hoveredColor,
    this.columnDividerColor = RowThemeDataDefaults.columnDividerColor,
  });

  final EasyTableRowColor? color;
  final EasyTableRowColor? hoveredColor;
  final Color? columnDividerColor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RowThemeData &&
          runtimeType == other.runtimeType &&
          color == other.color &&
          hoveredColor == other.hoveredColor &&
          columnDividerColor == other.columnDividerColor;

  @override
  int get hashCode =>
      color.hashCode ^ hoveredColor.hashCode ^ columnDividerColor.hashCode;
}

class RowThemeDataDefaults {
  static const Color columnDividerColor = Colors.grey;
}