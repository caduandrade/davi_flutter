import 'package:easy_table/easy_table.dart';
import 'package:flutter/material.dart';

/// The [EasyTable] cell header theme.
/// Defines the configuration of the overall visual [HeaderCellThemeData] for a widget subtree within the app.
class HeaderCellThemeData {
  /// Builds a theme data.
  const HeaderCellThemeData(
      {this.textStyle = HeaderCellThemeDataDefaults.textStyle,
      this.padding = HeaderCellThemeDataDefaults.padding});

  /// Defines the text style.
  final TextStyle? textStyle;

  final EdgeInsetsGeometry? padding;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeaderCellThemeData &&
          runtimeType == other.runtimeType &&
          textStyle == other.textStyle;

  @override
  int get hashCode => textStyle.hashCode;
}

class HeaderCellThemeDataDefaults {
  static const TextStyle textStyle = TextStyle(fontWeight: FontWeight.bold);
  static const EdgeInsetsGeometry? padding = EdgeInsets.all(8);
}
