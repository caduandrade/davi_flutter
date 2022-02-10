import 'package:flutter/material.dart';

/// The [EasyTable] header theme.
/// Defines the configuration of the overall visual [HeaderThemeData] for a widget subtree within the app.
class HeaderThemeData {
  /// Builds a theme data.
  const HeaderThemeData(
      {this.bottomBorder = HeaderThemeDataDefaults.bottomBorder});

  final BorderSide? bottomBorder;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeaderThemeData &&
          runtimeType == other.runtimeType &&
          bottomBorder == other.bottomBorder;

  @override
  int get hashCode => bottomBorder.hashCode;
}

class HeaderThemeDataDefaults {
  static const BorderSide bottomBorder =
      BorderSide(width: 1, color: Colors.grey);
}
