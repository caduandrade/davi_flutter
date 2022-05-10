import 'package:flutter/material.dart';

/// The [EasyTable] scroll theme.
/// Defines the configuration of the overall visual [TableScrollThemeData] for a widget subtree within the app.
class TableScrollThemeData {
  /// Builds a theme data.
  const TableScrollThemeData(
      {this.radius,
      this.margin = TableScrollThemeDataDefaults.margin,
      this.thickness = TableScrollThemeDataDefaults.thickness,
      this.verticalBorderColor =
          TableScrollThemeDataDefaults.verticalBorderColor,
      this.verticalColor = TableScrollThemeDataDefaults.verticalColor,
      this.pinnedHorizontalBorderColor =
          TableScrollThemeDataDefaults.pinnedHorizontalBorderColor,
      this.pinnedHorizontalColor =
          TableScrollThemeDataDefaults.pinnedHorizontalColor,
      this.unpinnedHorizontalBorderColor =
          TableScrollThemeDataDefaults.unpinnedHorizontalBorderColor,
      this.unpinnedHorizontalColor =
          TableScrollThemeDataDefaults.unpinnedHorizontalColor,
      this.thumbColor = TableScrollThemeDataDefaults.thumbColor});

  final Radius? radius;
  final double margin;
  final double thickness;
  final Color verticalBorderColor;
  final Color verticalColor;
  final Color pinnedHorizontalBorderColor;
  final Color pinnedHorizontalColor;
  final Color unpinnedHorizontalBorderColor;
  final Color unpinnedHorizontalColor;
  final Color thumbColor;
}

class TableScrollThemeDataDefaults {
  static const double margin = 0;
  static const double thickness = 10;
  static const Color verticalBorderColor = Colors.grey;
  static const Color verticalColor = Color(0xFFE0E0E0);
  static const Color unpinnedHorizontalBorderColor = Colors.grey;
  static const Color unpinnedHorizontalColor = Color(0xFFE0E0E0);
  static const Color pinnedHorizontalBorderColor = Colors.grey;
  static const Color pinnedHorizontalColor = Color(0xFFE0E0E0);
  static const Color thumbColor = Color(0xFF616161);
}
