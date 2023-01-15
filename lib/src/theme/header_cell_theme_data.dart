import 'package:flutter/material.dart';

/// The [Davi] cell header theme.
/// Defines the configuration of the overall visual [HeaderCellThemeData] for a widget subtree within the app.
class HeaderCellThemeData {
  //TODO avoid negative values
  /// Builds a theme data.
  const HeaderCellThemeData(
      {this.textStyle = HeaderCellThemeDataDefaults.textStyle,
      this.height = HeaderCellThemeDataDefaults.height,
      this.padding = HeaderCellThemeDataDefaults.padding,
      this.alignment = HeaderCellThemeDataDefaults.alignment,
      this.ascendingIcon = HeaderCellThemeDataDefaults.ascendingIcon,
      this.descendingIcon = HeaderCellThemeDataDefaults.descendingIcon,
      this.sortIconColor = HeaderCellThemeDataDefaults.sortIconColor,
      this.sortIconSize = HeaderCellThemeDataDefaults.sortIconSize,
      this.sortOrderSize = HeaderCellThemeDataDefaults.sortOrderSize,
      this.resizeAreaWidth = HeaderCellThemeDataDefaults.resizeAreaWidth,
      this.resizeAreaHoverColor =
          HeaderCellThemeDataDefaults.resizeAreaHoverColor,
      this.expandableName = HeaderCellThemeDataDefaults.expandableName});

  /// Defines the text style.
  final TextStyle? textStyle;
  final EdgeInsets? padding;
  final Alignment alignment;
  final IconData ascendingIcon;
  final IconData descendingIcon;
  final Color sortIconColor;
  final double sortIconSize;
  final double sortOrderSize;
  final double height;
  final double resizeAreaWidth;
  final Color? resizeAreaHoverColor;
  final bool expandableName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeaderCellThemeData &&
          runtimeType == other.runtimeType &&
          textStyle == other.textStyle &&
          padding == other.padding &&
          height == other.height &&
          alignment == other.alignment &&
          ascendingIcon == other.ascendingIcon &&
          descendingIcon == other.descendingIcon &&
          sortIconColor == other.sortIconColor &&
          sortIconSize == other.sortIconSize &&
          sortOrderSize == other.sortOrderSize &&
          resizeAreaWidth == other.resizeAreaWidth &&
          resizeAreaHoverColor == other.resizeAreaHoverColor &&
          expandableName == other.expandableName;

  @override
  int get hashCode =>
      textStyle.hashCode ^
      padding.hashCode ^
      alignment.hashCode ^
      ascendingIcon.hashCode ^
      descendingIcon.hashCode ^
      sortIconColor.hashCode ^
      sortIconSize.hashCode ^
      sortOrderSize.hashCode ^
      height.hashCode ^
      resizeAreaWidth.hashCode ^
      resizeAreaHoverColor.hashCode ^
      expandableName.hashCode;
}

class HeaderCellThemeDataDefaults {
  static const double height = 28;
  static const TextStyle textStyle = TextStyle(fontWeight: FontWeight.bold);
  static const EdgeInsets padding = EdgeInsets.fromLTRB(8, 4, 8, 4);
  static const Alignment alignment = Alignment.centerLeft;

  static const IconData ascendingIcon = Icons.arrow_downward;
  static const IconData descendingIcon = Icons.arrow_upward;
  static const Color sortIconColor = Colors.black;
  static const double sortIconSize = 16;
  static const double sortOrderSize = 12;

  static const double resizeAreaWidth = 8;
  static const Color resizeAreaHoverColor = Color.fromRGBO(200, 200, 200, 0.5);

  static const bool expandableName = true;
}
