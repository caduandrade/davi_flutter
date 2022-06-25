import 'package:easy_table/src/theme/cell_theme_data.dart';
import 'package:easy_table/src/theme/header_cell_theme_data.dart';
import 'package:easy_table/src/theme/header_theme_data.dart';
import 'package:easy_table/src/theme/row_theme_data.dart';
import 'package:easy_table/src/theme/scrollbar_theme_data.dart';
import 'package:flutter/material.dart';

//TODO handle negative values
/// The [EasyTable] theme.
/// Defines the configuration of the overall visual [EasyTableThemeData] for a widget subtree within the app.
class EasyTableThemeData {
  /// Builds a theme data.
  const EasyTableThemeData(
      {this.columnDividerFillHeight =
          EasyTableThemeDataDefaults.columnDividerFillHeight,
      this.columnDividerThickness =
          EasyTableThemeDataDefaults.columnDividerThickness,
      this.columnDividerColor = EasyTableThemeDataDefaults.columnDividerColor,
      this.decoration = EasyTableThemeDataDefaults.tableDecoration,
      this.topCornerBorderColor =
          EasyTableThemeDataDefaults.topCornerBorderColor,
      this.topCornerColor = EasyTableThemeDataDefaults.topCornerColor,
      this.bottomCornerBorderColor =
          EasyTableThemeDataDefaults.bottomCornerBorderColor,
      this.bottomCornerColor = EasyTableThemeDataDefaults.bottomCornerColor,
      this.row = const RowThemeData(),
      this.cell = const CellThemeData(),
      this.header = const HeaderThemeData(),
      this.headerCell = const HeaderCellThemeData(),
      this.scrollbar = const TableScrollbarThemeData()});

  final bool columnDividerFillHeight;
  final double columnDividerThickness;
  final Color? columnDividerColor;
  final BoxDecoration? decoration;
  final CellThemeData cell;
  final HeaderThemeData header;
  final HeaderCellThemeData headerCell;
  final RowThemeData row;
  final TableScrollbarThemeData scrollbar;
  final Color topCornerBorderColor;
  final Color topCornerColor;
  final Color bottomCornerBorderColor;
  final Color bottomCornerColor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EasyTableThemeData &&
          runtimeType == other.runtimeType &&
          columnDividerFillHeight == other.columnDividerFillHeight &&
          columnDividerThickness == other.columnDividerThickness &&
          columnDividerColor == other.columnDividerColor &&
          decoration == other.decoration &&
          cell == other.cell &&
          header == other.header &&
          headerCell == other.headerCell &&
          row == other.row &&
          scrollbar == other.scrollbar &&
          topCornerBorderColor == other.topCornerBorderColor &&
          topCornerColor == other.topCornerColor &&
          bottomCornerBorderColor == other.bottomCornerBorderColor &&
          bottomCornerColor == other.bottomCornerColor;

  @override
  int get hashCode =>
      columnDividerThickness.hashCode ^
      columnDividerFillHeight.hashCode ^
      columnDividerColor.hashCode ^
      decoration.hashCode ^
      cell.hashCode ^
      header.hashCode ^
      headerCell.hashCode ^
      row.hashCode ^
      scrollbar.hashCode ^
      topCornerBorderColor.hashCode ^
      topCornerColor.hashCode ^
      bottomCornerBorderColor.hashCode ^
      bottomCornerColor.hashCode;
}

class EasyTableThemeDataDefaults {
  static const bool columnDividerFillHeight = true;
  static const double columnDividerThickness = 1;
  static const BoxDecoration tableDecoration = BoxDecoration(
      border: Border(
          bottom: BorderSide(color: Colors.grey),
          top: BorderSide(color: Colors.grey),
          left: BorderSide(color: Colors.grey),
          right: BorderSide(color: Colors.grey)));
  static const BoxDecoration topRightCornerDecoration = BoxDecoration(
      color: Color(0xFFE0E0E0),
      border: Border(
          left: BorderSide(color: Colors.grey),
          bottom: BorderSide(color: Colors.grey)));

  static const Color bottomCornerColor = Color(0xFFE0E0E0);
  static const Color bottomCornerBorderColor = Colors.grey;
  static const Color topCornerColor = Color(0xFFE0E0E0);
  static const Color topCornerBorderColor = Colors.grey;
  static const Color columnDividerColor = Colors.grey;
}
