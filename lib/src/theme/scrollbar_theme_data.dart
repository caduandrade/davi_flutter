import 'package:flutter/material.dart';

/// The [EasyTable] scroll theme.
/// Defines the configuration of the overall visual [TableScrollbarThemeData] for a widget subtree within the app.
class TableScrollbarThemeData {
  /// Builds a theme data.
  const TableScrollbarThemeData({
    this.radius,
    this.margin = TableScrollbarThemeDataDefaults.margin,
    this.thickness = TableScrollbarThemeDataDefaults.thickness,
    this.verticalBorderColor =
        TableScrollbarThemeDataDefaults.verticalBorderColor,
    this.verticalColor = TableScrollbarThemeDataDefaults.verticalColor,
    this.pinnedHorizontalBorderColor =
        TableScrollbarThemeDataDefaults.pinnedHorizontalBorderColor,
    this.pinnedHorizontalColor =
        TableScrollbarThemeDataDefaults.pinnedHorizontalColor,
    this.unpinnedHorizontalBorderColor =
        TableScrollbarThemeDataDefaults.unpinnedHorizontalBorderColor,
    this.unpinnedHorizontalColor =
        TableScrollbarThemeDataDefaults.unpinnedHorizontalColor,
    this.thumbColor = TableScrollbarThemeDataDefaults.thumbColor,
    this.horizontalOnlyWhenNeeded =
        TableScrollbarThemeDataDefaults.horizontalOnlyWhenNeeded,
    this.columnDividerColor =
        TableScrollbarThemeDataDefaults.columnDividerColor,
  });

  final Radius? radius;
  final double margin;
  final double thickness;
  final double borderThickness = 1;
  final Color verticalBorderColor;
  final Color verticalColor;
  final Color pinnedHorizontalBorderColor;
  final Color pinnedHorizontalColor;
  final Color unpinnedHorizontalBorderColor;
  final Color unpinnedHorizontalColor;
  final Color thumbColor;
  final bool horizontalOnlyWhenNeeded;
  final Color? columnDividerColor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TableScrollbarThemeData &&
          runtimeType == other.runtimeType &&
          radius == other.radius &&
          margin == other.margin &&
          thickness == other.thickness &&
          verticalBorderColor == other.verticalBorderColor &&
          verticalColor == other.verticalColor &&
          pinnedHorizontalBorderColor == other.pinnedHorizontalBorderColor &&
          pinnedHorizontalColor == other.pinnedHorizontalColor &&
          unpinnedHorizontalBorderColor ==
              other.unpinnedHorizontalBorderColor &&
          unpinnedHorizontalColor == other.unpinnedHorizontalColor &&
          thumbColor == other.thumbColor &&
          horizontalOnlyWhenNeeded == other.horizontalOnlyWhenNeeded &&
          columnDividerColor == other.columnDividerColor;

  @override
  int get hashCode =>
      radius.hashCode ^
      margin.hashCode ^
      thickness.hashCode ^
      verticalBorderColor.hashCode ^
      verticalColor.hashCode ^
      pinnedHorizontalBorderColor.hashCode ^
      pinnedHorizontalColor.hashCode ^
      unpinnedHorizontalBorderColor.hashCode ^
      unpinnedHorizontalColor.hashCode ^
      thumbColor.hashCode ^
      horizontalOnlyWhenNeeded.hashCode ^
      columnDividerColor.hashCode;
}

class TableScrollbarThemeDataDefaults {
  static const horizontalOnlyWhenNeeded = false;
  static const double margin = 0;
  static const double thickness = 10;
  static const Color verticalBorderColor = Colors.grey;
  static const Color verticalColor = Color(0xFFE0E0E0);
  static const Color unpinnedHorizontalBorderColor = Colors.grey;
  static const Color unpinnedHorizontalColor = Color(0xFFE0E0E0);
  static const Color pinnedHorizontalBorderColor = Colors.grey;
  static const Color pinnedHorizontalColor = Color(0xFFE0E0E0);
  static const Color thumbColor = Color(0xFF616161);
  static const Color columnDividerColor = Colors.grey;
}
