import 'package:flutter/material.dart';

/// The [EasyTable] cell header theme.
/// Defines the configuration of the overall visual [HeaderCellThemeData] for a widget subtree within the app.
class HeaderCellThemeData {
  //TODO avoid negative values
  /// Builds a theme data.
  const HeaderCellThemeData(
      {this.textStyle = HeaderCellThemeDataDefaults.textStyle,
      this.padding = HeaderCellThemeDataDefaults.padding,
      this.alignment = HeaderCellThemeDataDefaults.alignment,
      this.ascendingIcon = HeaderCellThemeDataDefaults.ascendingIcon,
      this.descendingIcon = HeaderCellThemeDataDefaults.descendingIcon,
      this.sortIconColor = HeaderCellThemeDataDefaults.sortIconColor,
      this.sortIconSize = HeaderCellThemeDataDefaults.sortIconSize,
      this.resizeAreaWidth = HeaderCellThemeDataDefaults.resizeAreaWidth,
      this.resizeAreaHoverColor =
          HeaderCellThemeDataDefaults.resizeAreaHoverColor});

  /// Defines the text style.
  final TextStyle? textStyle;

  final EdgeInsets? padding;

  final AlignmentGeometry alignment;

  final IconData ascendingIcon;
  final IconData descendingIcon;
  final Color sortIconColor;
  final double sortIconSize;

  final double resizeAreaWidth;
  final Color? resizeAreaHoverColor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeaderCellThemeData &&
          runtimeType == other.runtimeType &&
          textStyle == other.textStyle &&
          padding == other.padding &&
          alignment == other.alignment &&
          ascendingIcon == other.ascendingIcon &&
          descendingIcon == other.descendingIcon &&
          sortIconColor == other.sortIconColor &&
          sortIconSize == other.sortIconSize &&
          resizeAreaWidth == other.resizeAreaWidth &&
          resizeAreaHoverColor == other.resizeAreaHoverColor;

  @override
  int get hashCode =>
      textStyle.hashCode ^
      padding.hashCode ^
      alignment.hashCode ^
      ascendingIcon.hashCode ^
      descendingIcon.hashCode ^
      sortIconColor.hashCode ^
      sortIconSize.hashCode ^
      resizeAreaWidth.hashCode ^
      resizeAreaHoverColor.hashCode;
}

class HeaderCellThemeDataDefaults {
  static const TextStyle textStyle = TextStyle(fontWeight: FontWeight.bold);
  static const EdgeInsets padding = EdgeInsets.all(8);
  static const AlignmentGeometry alignment = Alignment.centerLeft;

  static const IconData ascendingIcon = Icons.arrow_downward;
  static const IconData descendingIcon = Icons.arrow_upward;
  static const Color sortIconColor = Colors.black;
  static const double sortIconSize = 16;

  static const double resizeAreaWidth = 8;
  static const Color resizeAreaHoverColor = Color.fromRGBO(200, 200, 200, 0.5);
}
