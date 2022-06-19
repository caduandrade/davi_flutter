import 'package:easy_table/src/theme/cell_null_color.dart';
import 'package:flutter/material.dart';

/// The [EasyTable] cell theme.
/// Defines the configuration of the overall visual [CellThemeData] for a widget subtree within the app.
class CellThemeData {
  /// Builds a theme data.
  const CellThemeData(
      {this.textStyle,
      this.nullValueColor,
      this.contentHeight = CellThemeDataDefaults.contentHeight,
      this.overflow = CellThemeDataDefaults.overflow,
      this.alignment = CellThemeDataDefaults.alignment,
      this.padding = CellThemeDataDefaults.padding});

  /// Defines the text style.
  final TextStyle? textStyle;

  /// The cell padding.
  /// The default value is defined by [CellThemeDataDefaults.padding].
  final EdgeInsets? padding;

  final double contentHeight;

  final Alignment alignment;

  final TextOverflow? overflow;

  /// Defines a background when the cell value is null.
  final CellNullColor? nullValueColor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellThemeData &&
          runtimeType == other.runtimeType &&
          textStyle == other.textStyle &&
          padding == other.padding &&
          contentHeight == other.contentHeight &&
          alignment == other.alignment &&
          overflow == other.overflow &&
          nullValueColor == other.nullValueColor;

  @override
  int get hashCode =>
      textStyle.hashCode ^
      padding.hashCode ^
      contentHeight.hashCode ^
      alignment.hashCode ^
      overflow.hashCode ^
      nullValueColor.hashCode;
}

class CellThemeDataDefaults {
  static const double contentHeight = 32;
  static const TextOverflow overflow = TextOverflow.ellipsis;
  static const EdgeInsets padding = EdgeInsets.only(left: 8, right: 8);
  static const Alignment alignment = Alignment.centerLeft;
}
