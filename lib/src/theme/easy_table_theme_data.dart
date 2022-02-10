import 'package:easy_table/src/easy_table_row_color.dart';
import 'package:easy_table/src/theme/cell_theme_data.dart';
import 'package:easy_table/src/theme/header_cell_theme_data.dart';
import 'package:easy_table/src/theme/header_theme_data.dart';
import 'package:flutter/material.dart';

//TODO handle negative values
/// The [EasyTable] theme.
/// Defines the configuration of the overall visual [EasyTableThemeData] for a widget subtree within the app.
class EasyTableThemeData {
  /// Builds a theme data.
  const EasyTableThemeData(
      {this.columnGap = EasyTableThemeDataDefaults.columnGap,
      this.rowGap = EasyTableThemeDataDefaults.rowGap,
      this.decoration = EasyTableThemeDataDefaults.tableDecoration,
      this.rowColor,
      this.cell = const CellThemeData(),
      this.header = const HeaderThemeData(),
      this.headerCell = const HeaderCellThemeData()});

  final double columnGap;
  final double rowGap;
  final BoxDecoration? decoration;
  final EasyTableRowColor? rowColor;

  final CellThemeData cell;
  final HeaderThemeData header;
  final HeaderCellThemeData headerCell;
}

class EasyTableThemeDataDefaults {
  static EasyTableRowColor rowZebraColor({Color? evenColor, Color? oddColor}) {
    return (rowIndex) {
      return rowIndex.isOdd ? evenColor : oddColor;
    };
  }

  static Color? _rowWhiteGreyColor(int rowIndex) {
    return rowIndex.isOdd ? Colors.white : Colors.grey[100];
  }

  static const EasyTableRowColor rowWhiteGreyColor = _rowWhiteGreyColor;

  static const double columnGap = 4;
  static const double rowGap = 0;
  static const BoxDecoration tableDecoration = BoxDecoration(
      border: Border(
          bottom: BorderSide(color: Colors.grey),
          top: BorderSide(color: Colors.grey),
          left: BorderSide(color: Colors.grey),
          right: BorderSide(color: Colors.grey)));
}
