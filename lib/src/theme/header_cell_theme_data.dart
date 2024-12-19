import 'package:davi/src/theme/sort_icon_builder.dart';
import 'package:davi/src/theme/sort_icon_builders.dart';
import 'package:davi/src/theme/sort_icon_colors.dart';
import 'package:flutter/material.dart';

/// The [Davi] cell header theme.
/// Defines the configuration of the overall visual [HeaderCellThemeData] for a widget subtree within the app.
class HeaderCellThemeData {
  //TODO avoid negative values
  /// Builds a theme data.
  const HeaderCellThemeData(
      {this.sortIconBuilder = SortIconBuilders.size16Short,
      this.textStyle = HeaderCellThemeDataDefaults.textStyle,
      this.height = HeaderCellThemeDataDefaults.height,
      this.padding = HeaderCellThemeDataDefaults.padding,
      this.alignment = HeaderCellThemeDataDefaults.alignment,
      this.sortIconColors = HeaderCellThemeDataDefaults.sortIconColors,
      this.sortPriorityColor = HeaderCellThemeDataDefaults.sortPriorityColor,
      this.sortPrioritySize = HeaderCellThemeDataDefaults.sortPrioritySize,
      this.sortPriorityGap = HeaderCellThemeDataDefaults.sortPriorityGap,
      this.resizeAreaWidth = HeaderCellThemeDataDefaults.resizeAreaWidth,
      this.resizeAreaHoverColor =
          HeaderCellThemeDataDefaults.resizeAreaHoverColor,
      this.expandableName = HeaderCellThemeDataDefaults.expandableName});

  /// Defines the text style.
  final TextStyle? textStyle;
  final EdgeInsets? padding;
  final Alignment alignment;

  final SortIconColors sortIconColors;
  final SortIconBuilder sortIconBuilder;

  final Color sortPriorityColor;
  final double sortPrioritySize;

  /// The gap between the sort icon and priority text.
  final double? sortPriorityGap;
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
          alignment == other.alignment &&
          sortIconColors == other.sortIconColors &&
          sortIconBuilder == other.sortIconBuilder &&
          sortPriorityColor == other.sortPriorityColor &&
          sortPrioritySize == other.sortPrioritySize &&
          sortPriorityGap == other.sortPriorityGap &&
          height == other.height &&
          resizeAreaWidth == other.resizeAreaWidth &&
          resizeAreaHoverColor == other.resizeAreaHoverColor &&
          expandableName == other.expandableName;

  @override
  int get hashCode =>
      textStyle.hashCode ^
      padding.hashCode ^
      alignment.hashCode ^
      sortIconColors.hashCode ^
      sortIconBuilder.hashCode ^
      sortPriorityColor.hashCode ^
      sortPrioritySize.hashCode ^
      sortPriorityGap.hashCode ^
      height.hashCode ^
      resizeAreaWidth.hashCode ^
      resizeAreaHoverColor.hashCode ^
      expandableName.hashCode;
}

class HeaderCellThemeDataDefaults {
  static const double height = 32;
  static const TextStyle textStyle = TextStyle(fontWeight: FontWeight.bold);
  static const EdgeInsets padding = EdgeInsets.fromLTRB(8, 4, 8, 4);
  static const Alignment alignment = Alignment.centerLeft;

  static const Color sortIconColor = Color(0xFF424242);

  static const SortIconColors sortIconColors = SortIconColors(
      ascending: HeaderCellThemeDataDefaults.sortIconColor,
      descending: HeaderCellThemeDataDefaults.sortIconColor);

  static const Color sortPriorityColor = Color(0xFF424242);
  static const double sortPrioritySize = 12;
  static const double sortPriorityGap = 2;

  static const double resizeAreaWidth = 8;
  static const Color resizeAreaHoverColor = Color.fromRGBO(200, 200, 200, 0.5);

  static const bool expandableName = true;
}
