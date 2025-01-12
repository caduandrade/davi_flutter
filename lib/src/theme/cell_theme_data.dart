import 'package:davi/src/column.dart';
import 'package:davi/src/theme/cell_null_color.dart';
import 'package:flutter/material.dart';

/// The [Davi] cell theme.
/// Defines the configuration of the overall visual [CellThemeData] for a widget subtree within the app.
class CellThemeData {
  /// Builds a theme data.
  const CellThemeData(
      {this.textStyle,
      this.nullValueColor,
      this.background,
      this.contentHeight = CellThemeDataDefaults.contentHeight,
      this.alignment = CellThemeDataDefaults.alignment,
      this.padding = CellThemeDataDefaults.padding,
      this.barStyle = CellThemeDataDefaults.cellBarStyle,
      this.overrideInputDecoration =
          CellThemeDataDefaults.overrideInputDecoration});

  /// Defines the text style.
  final TextStyle? textStyle;

  /// The cell padding.
  /// The default value is defined by [CellThemeDataDefaults.padding].
  final EdgeInsets? padding;

  /// Height of cell content. Mandatory due to performance.
  final double contentHeight;

  /// The alignment of the content within the cell.
  final Alignment alignment;

  /// Defines a background.
  final Color? background;

  /// Defines a background when the cell value is null.
  final CellNullColor? nullValueColor;

  /// If [TRUE], overrides the [InputDecorationTheme] by setting it to dense
  /// and removing the border.
  final bool overrideInputDecoration;

  /// The style of the progress bar within the cell.
  final CellBarStyle barStyle;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellThemeData &&
          runtimeType == other.runtimeType &&
          textStyle == other.textStyle &&
          padding == other.padding &&
          barStyle == other.barStyle &&
          contentHeight == other.contentHeight &&
          alignment == other.alignment &&
          background == other.background &&
          nullValueColor == other.nullValueColor &&
          overrideInputDecoration == other.overrideInputDecoration;

  @override
  int get hashCode =>
      textStyle.hashCode ^
      padding.hashCode ^
      barStyle.hashCode ^
      contentHeight.hashCode ^
      alignment.hashCode ^
      background.hashCode ^
      nullValueColor.hashCode ^
      overrideInputDecoration.hashCode;
}

/// All default theme values.
class CellThemeDataDefaults {
  static const double contentHeight = 32;
  static const EdgeInsets padding = EdgeInsets.only(left: 8, right: 8);
  static const Alignment alignment = Alignment.centerLeft;
  static const bool overrideInputDecoration = true;
  static const CellBarStyle cellBarStyle = CellBarStyle(
      barBackground: Color(0xFFE0E0E0),
      barForeground: _barForeground,
      textSize: 14,
      textColor: _textColor);

  static Color _barForeground(double value) => Colors.grey;
  static Color _textColor(double value) => Colors.black;
}
