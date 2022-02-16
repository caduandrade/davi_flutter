import 'package:flutter/material.dart';

/// The [EasyTable] header theme.
/// Defines the configuration of the overall visual [HeaderThemeData] for a widget subtree within the app.
class HeaderThemeData {
  /// Builds a theme data.
  const HeaderThemeData(
      {this.height = HeaderThemeDataDefaults.height,
      this.bottomBorderHeight = HeaderThemeDataDefaults.bottomBorderHeight,
      this.bottomBorderColor = HeaderThemeDataDefaults.bottomBorderColor});

  final double height;
  final double bottomBorderHeight;
  final Color? bottomBorderColor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeaderThemeData &&
          runtimeType == other.runtimeType &&
          height == other.height &&
          bottomBorderHeight == other.bottomBorderHeight &&
          bottomBorderColor == other.bottomBorderColor;

  @override
  int get hashCode =>
      height.hashCode ^
      bottomBorderHeight.hashCode ^
      bottomBorderColor.hashCode;
}

class HeaderThemeDataDefaults {
  static const double height = 32;
  static const double bottomBorderHeight = 1;
  static const Color bottomBorderColor = Colors.grey;
}
