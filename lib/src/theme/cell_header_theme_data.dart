import 'package:easy_table/easy_table.dart';
import 'package:flutter/material.dart';

/// The [EasyTable] cell header theme.
/// Defines the configuration of the overall visual [CellHeaderThemeData] for a widget subtree within the app.
class CellHeaderThemeData {
  /// Builds a theme data.
  const CellHeaderThemeData(
      {this.textStyle = CellHeaderThemeDataDefaults.textStyle});

  /// Defines the text style.
  final TextStyle? textStyle;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellHeaderThemeData &&
          runtimeType == other.runtimeType &&
          textStyle == other.textStyle;

  @override
  int get hashCode => textStyle.hashCode;
}

class CellHeaderThemeDataDefaults {
  static const TextStyle textStyle = TextStyle(fontWeight: FontWeight.bold);
}
