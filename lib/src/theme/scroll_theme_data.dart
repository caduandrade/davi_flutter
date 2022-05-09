import 'package:flutter/material.dart';

/// The [EasyTable] scroll theme.
/// Defines the configuration of the overall visual [TableScrollThemeData] for a widget subtree within the app.
class TableScrollThemeData {
  /// Builds a theme data.
  const TableScrollThemeData(
      {this.radius,
      this.margin = TableScrollThemeDataDefaults.margin,
      this.thickness = TableScrollThemeDataDefaults.thickness,
      this.verticalDecoration = TableScrollThemeDataDefaults.verticalDecoration,
      this.pinnedHorizontalDecoration =
          TableScrollThemeDataDefaults.pinnedHorizontalDecoration,
      this.unpinnedHorizontalDecoration =
          TableScrollThemeDataDefaults.unpinnedHorizontalDecoration,
      this.thumbColor = TableScrollThemeDataDefaults.thumbColor});

  final Radius? radius;
  final double margin;
  final double thickness;
  final BoxDecoration? verticalDecoration;
  final BoxDecoration? pinnedHorizontalDecoration;
  final BoxDecoration? unpinnedHorizontalDecoration;
  final Color thumbColor;
}

class TableScrollThemeDataDefaults {
  static const double margin = 0;
  static const double thickness = 10;
  static const BoxDecoration verticalDecoration = BoxDecoration(
      color: Color(0xFFE0E0E0),
      border: Border(left: BorderSide(color: Colors.grey)));
  static const BoxDecoration pinnedHorizontalDecoration = BoxDecoration(
      color: Color(0xFFE0E0E0),
      border: Border(
        top: BorderSide(color: Colors.grey),
        // right: BorderSide(color: Colors.grey)
      ));
  static const BoxDecoration unpinnedHorizontalDecoration = BoxDecoration(
      color: Color(0xFFE0E0E0),
      border: Border(top: BorderSide(color: Colors.grey)
          //  ,left: BorderSide(color: Colors.grey)
          ));
  static const Color thumbColor = Color(0xFF616161);
}
