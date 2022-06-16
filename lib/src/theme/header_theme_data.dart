import 'package:flutter/material.dart';

/// The [EasyTable] header theme.
/// Defines the configuration of the overall visual [HeaderThemeData] for a widget subtree within the app.
class HeaderThemeData {
  /// Builds a theme data.
  const HeaderThemeData({
    this.visible = HeaderThemeDataDefaults.visible,
    this.bottomBorderHeight = HeaderThemeDataDefaults.bottomBorderHeight,
    this.bottomBorderColor = HeaderThemeDataDefaults.bottomBorderColor,
    this.columnDividerColor = HeaderThemeDataDefaults.columnDividerColor,
  });

  final bool visible;
  final double bottomBorderHeight;
  final Color? bottomBorderColor;
  final Color? columnDividerColor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeaderThemeData &&
          runtimeType == other.runtimeType &&
          visible == other.visible &&
          bottomBorderHeight == other.bottomBorderHeight &&
          bottomBorderColor == other.bottomBorderColor &&
          columnDividerColor == other.columnDividerColor;

  @override
  int get hashCode =>
      visible.hashCode ^
      bottomBorderHeight.hashCode ^
      bottomBorderColor.hashCode ^
      columnDividerColor.hashCode;
}

class HeaderThemeDataDefaults {
  static const bool visible = true;
  static const double bottomBorderHeight = 1;
  static const Color bottomBorderColor = Colors.grey;
  static const Color columnDividerColor = Colors.grey;
}
