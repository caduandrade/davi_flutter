import 'package:davi/src/theme/theme_row_color.dart';
import 'package:flutter/material.dart';

/// The [Davi] row theme.
/// Defines the configuration of the overall visual [RowThemeData] for a widget subtree within the app.
class RowThemeData {
  /// Builds a row theme data.
  const RowThemeData(
      {this.color,
      this.hoverBackground,
      this.hoverForeground,
      this.dividerThickness = RowThemeDataDefaults.dividerThickness,
      this.dividerColor = RowThemeDataDefaults.dividerColor,
      this.fillHeight = RowThemeDataDefaults.fillHeight,
      this.callbackCursor = RowThemeDataDefaults.callbackCursor});

  /// The bottom row color.
  ///
  /// See also:
  ///
  ///   * [RowThemeData.zebraColor]
  final ThemeRowColor? color;

  /// The row background color when it's hovered.
  ///
  /// It's will be painted above the [color] and under column and cell colors.
  final ThemeRowColor? hoverBackground;

  /// The row foreground color when it's hovered.
  ///
  /// It's will be painted above all.
  final ThemeRowColor? hoverForeground;
  final double dividerThickness;
  final Color? dividerColor;

  /// Indicates whether to fill the entire height by painting
  /// the color of the rows.
  final bool fillHeight;

  final MouseCursor callbackCursor;

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
          fillHeight == other.fillHeight &&
          callbackCursor == other.callbackCursor;

  @override
  int get hashCode =>
      color.hashCode ^
      hoverBackground.hashCode ^
      hoverForeground.hashCode ^
      dividerThickness.hashCode ^
      dividerColor.hashCode ^
      fillHeight.hashCode ^
      callbackCursor.hashCode;

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
  static const MouseCursor callbackCursor = SystemMouseCursors.click;
}
