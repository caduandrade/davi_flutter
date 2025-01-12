import 'package:flutter/material.dart';

/// The [Davi] header theme.
/// Defines the configuration of the overall visual [HeaderThemeData] for a widget subtree within the app.
class HeaderThemeData {
  /// Builds a theme data.
  const HeaderThemeData({
    this.color,
    this.visible = HeaderThemeDataDefaults.visible,
    this.bottomBorderThickness = HeaderThemeDataDefaults.bottomBorderThickness,
    this.bottomBorderColor = HeaderThemeDataDefaults.bottomBorderColor,
    this.columnDividerColor = HeaderThemeDataDefaults.columnDividerColor,
  });

  final bool visible;
  final Color? color;
  final double bottomBorderThickness;
  final Color? bottomBorderColor;
  final Color? columnDividerColor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeaderThemeData &&
          runtimeType == other.runtimeType &&
          visible == other.visible &&
          color == other.color &&
          bottomBorderThickness == other.bottomBorderThickness &&
          bottomBorderColor == other.bottomBorderColor &&
          columnDividerColor == other.columnDividerColor;

  @override
  int get hashCode =>
      visible.hashCode ^
      color.hashCode ^
      bottomBorderThickness.hashCode ^
      bottomBorderColor.hashCode ^
      columnDividerColor.hashCode;
}

class HeaderThemeDataDefaults {
  static const bool visible = true;
  static const double bottomBorderThickness = 1;
  static const Color bottomBorderColor = Colors.grey;
  static const Color columnDividerColor = Colors.grey;
}
