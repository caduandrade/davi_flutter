import 'package:easy_table/easy_table.dart';
import 'package:flutter/material.dart';

/// The [EasyTable] cell theme.
/// Defines the configuration of the overall visual [CellThemeData] for a widget subtree within the app.
class CellThemeData {
  /// Builds a theme data.
  const CellThemeData({this.textStyle});

  /// Defines the text style.
  final TextStyle? textStyle;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellThemeData &&
          runtimeType == other.runtimeType &&
          textStyle == other.textStyle;

  @override
  int get hashCode => textStyle.hashCode;
}
