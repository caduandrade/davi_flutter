import 'package:davi/src/theme/cell_null_color.dart';
import 'package:flutter/material.dart';

/// The [Davi] cell theme.
/// Defines the configuration of the overall visual [CellThemeData] for a widget subtree within the app.
class CellThemeData {
  /// Builds a theme data.
  const CellThemeData(
      {this.textStyle,
      this.nullValueColor,
      this.contentHeight = CellThemeDataDefaults.contentHeight,
      this.overflow = CellThemeDataDefaults.overflow,
      this.alignment = CellThemeDataDefaults.alignment,
      this.padding = CellThemeDataDefaults.padding,
      this.overrideInputDecoration =
          CellThemeDataDefaults.overrideInputDecoration});

  /// Defines the text style.
  final TextStyle? textStyle;

  /// The cell padding.
  /// The default value is defined by [CellThemeDataDefaults.padding].
  final EdgeInsets? padding;

  /// Height of cell content. Mandatory due to performance.
  final double contentHeight;

  final Alignment alignment;

  final TextOverflow? overflow;

  /// Defines a background when the cell value is null.
  final CellNullColor? nullValueColor;

  /// If [TRUE], overrides the [InputDecorationTheme] by setting it to dense
  /// and removing the border.
  final bool overrideInputDecoration;

  /// Creates a copy of this theme but with the given fields replaced with
  /// the new values.
  CellThemeData copyWith(
      {TextStyle? textStyle,
      EdgeInsets? padding,
      double? contentHeight,
      Alignment? alignment,
      TextOverflow? overflow,
      CellNullColor? nullValueColor,
      bool? overrideInputDecoration}) {
    return CellThemeData(
        textStyle: textStyle ?? this.textStyle,
        padding: padding ?? this.padding,
        contentHeight: contentHeight ?? this.contentHeight,
        alignment: alignment ?? this.alignment,
        overflow: overflow ?? this.overflow,
        nullValueColor: nullValueColor ?? this.nullValueColor,
        overrideInputDecoration:
            overrideInputDecoration ?? this.overrideInputDecoration);
  }

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
          nullValueColor == other.nullValueColor &&
          overrideInputDecoration == other.overrideInputDecoration;

  @override
  int get hashCode =>
      textStyle.hashCode ^
      padding.hashCode ^
      contentHeight.hashCode ^
      alignment.hashCode ^
      overflow.hashCode ^
      nullValueColor.hashCode ^
      overrideInputDecoration.hashCode;
}

class CellThemeDataDefaults {
  static const double contentHeight = 32;
  static const TextOverflow overflow = TextOverflow.ellipsis;
  static const EdgeInsets padding = EdgeInsets.only(left: 8, right: 8);
  static const Alignment alignment = Alignment.centerLeft;
  static const bool overrideInputDecoration = true;
}
