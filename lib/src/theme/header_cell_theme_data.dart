import 'package:flutter/material.dart';

/// The [EasyTable] cell header theme.
/// Defines the configuration of the overall visual [HeaderCellThemeData] for a widget subtree within the app.
class HeaderCellThemeData {
  /// Builds a theme data.
  const HeaderCellThemeData(
      {this.textStyle = HeaderCellThemeDataDefaults.textStyle,
      this.padding = HeaderCellThemeDataDefaults.padding,
      this.alignment = HeaderCellThemeDataDefaults.alignment});

  /// Defines the text style.
  final TextStyle? textStyle;

  final EdgeInsetsGeometry? padding;

  final AlignmentGeometry alignment;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeaderCellThemeData &&
          runtimeType == other.runtimeType &&
          textStyle == other.textStyle &&
          padding == other.padding;

  @override
  int get hashCode => textStyle.hashCode ^ padding.hashCode;
}

class HeaderCellThemeDataDefaults {
  static const TextStyle textStyle = TextStyle(fontWeight: FontWeight.bold);
  static const EdgeInsetsGeometry padding = EdgeInsets.all(8);
  static const AlignmentGeometry alignment = Alignment.centerLeft;
}
