import 'package:flutter/material.dart';

/// The [Davi] header theme.
/// Defines the configuration of the overall visual [HeaderThemeData] for a widget subtree within the app.
class HeaderThemeData {
  /// Builds a theme data.
  const HeaderThemeData({
    this.color,
    this.visible = HeaderThemeDataDefaults.visible,
    this.bottomBorderHeight = HeaderThemeDataDefaults.bottomBorderHeight,
    this.bottomBorderColor = HeaderThemeDataDefaults.bottomBorderColor,
    this.columnDividerColor = HeaderThemeDataDefaults.columnDividerColor,
  });

  final bool visible;
  final Color? color;
  final double bottomBorderHeight;
  final Color? bottomBorderColor;
  final Color? columnDividerColor;

  /// Creates a copy of this theme but with the given fields replaced with
  /// the new values.
  HeaderThemeData copyWith(
      {bool? visible,
      Color? color,
      double? bottomBorderHeight,
      Color? bottomBorderColor,
      Color? columnDividerColor}) {
    return HeaderThemeData(
        visible: visible ?? this.visible,
        color: color ?? this.color,
        bottomBorderHeight: bottomBorderHeight ?? this.bottomBorderHeight,
        bottomBorderColor: bottomBorderColor ?? this.bottomBorderColor,
        columnDividerColor: columnDividerColor ?? this.columnDividerColor);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeaderThemeData &&
          runtimeType == other.runtimeType &&
          visible == other.visible &&
          color == other.color &&
          bottomBorderHeight == other.bottomBorderHeight &&
          bottomBorderColor == other.bottomBorderColor &&
          columnDividerColor == other.columnDividerColor;

  @override
  int get hashCode =>
      visible.hashCode ^
      color.hashCode ^
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
