import 'package:easy_table/src/theme/row_color.dart';
import 'package:flutter/material.dart';

/// The [EasyTable] row theme.
/// Defines the configuration of the overall visual [RowThemeData] for a widget subtree within the app.
class RowThemeData {
  /// Builds a theme data.
  const RowThemeData({
    this.color,
    this.lastDividerVisible = RowThemeDataDefaults.lastDividerVisible,
    this.hoverBackground,
    this.hoverForeground,
    this.dividerThickness = RowThemeDataDefaults.dividerThickness,
    this.dividerColor = RowThemeDataDefaults.dividerColor,
  });

  final EasyTableRowColor? color;
  final EasyTableRowColor? hoverBackground;
  final EasyTableRowColor? hoverForeground;
  final double dividerThickness;
  final Color? dividerColor;
  final bool lastDividerVisible;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RowThemeData &&
          runtimeType == other.runtimeType &&
          color == other.color &&
          hoverBackground == other.hoverBackground &&
          hoverForeground == other.hoverForeground &&
          dividerThickness == other.dividerThickness &&
          dividerColor == other.dividerColor &&
          lastDividerVisible == other.lastDividerVisible;

  @override
  int get hashCode =>
      color.hashCode ^
      hoverBackground.hashCode ^
      hoverForeground.hashCode ^
      dividerThickness.hashCode ^
      dividerColor.hashCode ^
      lastDividerVisible.hashCode;

  static EasyTableRowColor zebraColor(
      {Color? evenColor = const Color(0xFFF5F5F5),
      Color? oddColor = Colors.white}) {
    return (rowIndex) {
      return rowIndex.isOdd ? evenColor : oddColor;
    };
  }
}

class RowThemeDataDefaults {
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const double dividerThickness = 10;
  static const bool lastDividerVisible = true;
}
