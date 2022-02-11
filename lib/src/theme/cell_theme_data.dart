import 'package:flutter/material.dart';

/// The [EasyTable] cell theme.
/// Defines the configuration of the overall visual [CellThemeData] for a widget subtree within the app.
class CellThemeData {
  /// Builds a theme data.
  const CellThemeData(
      {this.textStyle,
      this.alignment = Alignment.centerLeft,
      this.padding = CellThemeDataDefaults.padding,
      this.contentHeight = CellThemeDataDefaults.contentHeight});

  /// Defines the text style.
  final TextStyle? textStyle;

  /// The cell padding.
  /// The default value is defined by [CellThemeDataDefaults.padding].
  final EdgeInsetsGeometry? padding;

  /// The cell content height.
  /// The default value is defined by [CellThemeDataDefaults.contentHeight].
  final double contentHeight;

  final AlignmentGeometry alignment;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellThemeData &&
          runtimeType == other.runtimeType &&
          textStyle == other.textStyle &&
          padding == other.padding &&
          contentHeight == other.contentHeight;

  @override
  int get hashCode =>
      textStyle.hashCode ^ padding.hashCode ^ contentHeight.hashCode;
}

class CellThemeDataDefaults {
  static const double contentHeight = 32;
  static const EdgeInsetsGeometry? padding = EdgeInsets.only(left: 8, right: 8);
}
