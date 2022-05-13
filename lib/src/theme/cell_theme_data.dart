import 'package:easy_table/src/theme/row_color.dart';
import 'package:flutter/material.dart';

/// The [EasyTable] cell theme.
/// Defines the configuration of the overall visual [CellThemeData] for a widget subtree within the app.
class CellThemeData {
  /// Builds a theme data.
  const CellThemeData(
      {this.textStyle,
      this.nullValueColor,
      this.alignment = CellThemeDataDefaults.alignment,
      this.padding = CellThemeDataDefaults.padding});

  /// Defines the text style.
  final TextStyle? textStyle;

  /// The cell padding.
  /// The default value is defined by [CellThemeDataDefaults.padding].
  final EdgeInsets? padding;

  final AlignmentGeometry alignment;

  final EasyTableRowColor? nullValueColor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellThemeData &&
          runtimeType == other.runtimeType &&
          textStyle == other.textStyle &&
          padding == other.padding &&
          alignment == other.alignment &&
          nullValueColor == other.nullValueColor;

  @override
  int get hashCode =>
      textStyle.hashCode ^
      padding.hashCode ^
      alignment.hashCode ^
      nullValueColor.hashCode;
}

class CellThemeDataDefaults {
  static const EdgeInsets padding = EdgeInsets.only(left: 8, right: 8);
  static const AlignmentGeometry alignment = Alignment.centerLeft;
}
