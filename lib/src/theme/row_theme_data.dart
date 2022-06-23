import 'package:easy_table/src/theme/theme_row_color.dart';
import 'package:flutter/material.dart';

/// The [EasyTable] row theme.
/// Defines the configuration of the overall visual [RowThemeData] for a widget subtree within the app.
class RowThemeData {
  /// Builds a row theme data.
  const RowThemeData(
      {this.color,
      this.lastDividerVisible = RowThemeDataDefaults.lastDividerVisible,
      this.hoverBackground,
      this.hoverForeground,
      this.dividerThickness = RowThemeDataDefaults.dividerThickness,
      this.dividerColor = RowThemeDataDefaults.dividerColor,
      this.fillHeight = RowThemeDataDefaults.fillHeight});

  final ThemeRowColor? color;
  final ThemeRowColor? hoverBackground;
  final ThemeRowColor? hoverForeground;
  final double dividerThickness;
  final Color? dividerColor;
  final bool lastDividerVisible;
  final bool fillHeight;

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
          lastDividerVisible == other.lastDividerVisible &&
          fillHeight == other.fillHeight;

  @override
  int get hashCode =>
      color.hashCode ^
      hoverBackground.hashCode ^
      hoverForeground.hashCode ^
      dividerThickness.hashCode ^
      dividerColor.hashCode ^
      lastDividerVisible.hashCode ^
      fillHeight.hashCode;

  static ThemeRowColor zebraColor(
      {Color? evenColor = const Color(0xFFF5F5F5),
      Color? oddColor = Colors.white}) {
    return (rowIndex) {
      return rowIndex.isOdd ? evenColor : oddColor;
    };
  }
}

/// Defines the [RowThemeData] default values.
class RowThemeDataDefaults {
  static const bool fillHeight = false;
  static const Color dividerColor = Colors.grey;
  static const double dividerThickness = 1;
  static const bool lastDividerVisible = true;
}
