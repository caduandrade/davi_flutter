import 'package:easy_table/easy_table.dart';
import 'package:flutter/material.dart';

/// The [EasyTable] theme.
/// Defines the configuration of the overall visual [EasyTableThemeData] for a widget subtree within the app.
class EasyTableThemeData {
  /// Builds a theme data.
  const EasyTableThemeData(
      {this.cellTextStyle,
      this.cellHeaderTextStyle =
          EasyTableThemeDataDefaults.cellHeaderTextStyle});

  /// Defines the text style for the cell.
  final TextStyle? cellTextStyle;

  /// Defines the text style for the cell header.
  final TextStyle? cellHeaderTextStyle;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EasyTableThemeData &&
          runtimeType == other.runtimeType &&
          cellTextStyle == other.cellTextStyle &&
          cellHeaderTextStyle == other.cellHeaderTextStyle;

  @override
  int get hashCode => cellTextStyle.hashCode ^ cellHeaderTextStyle.hashCode;
}

class EasyTableThemeDataDefaults {
  static const TextStyle cellHeaderTextStyle =
      TextStyle(fontWeight: FontWeight.bold);
}
