import 'package:easy_table/easy_table.dart';
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
      this.cell = const CellThemeData(),
      this.header = const HeaderThemeData(),
      this.cellHeader = const CellHeaderThemeData()});

  final double columnGap;
  final double rowGap;
  final BoxDecoration? decoration;

  final CellThemeData cell;
  final HeaderThemeData header;
  final CellHeaderThemeData cellHeader;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EasyTableThemeData &&
          runtimeType == other.runtimeType &&
          columnGap == other.columnGap &&
          rowGap == other.rowGap &&
          decoration == other.decoration &&
          cell == other.cell &&
          header == other.header &&
          cellHeader == other.cellHeader;

  @override
  int get hashCode =>
      columnGap.hashCode ^
      rowGap.hashCode ^
      decoration.hashCode ^
      cell.hashCode ^
      header.hashCode ^
      cellHeader.hashCode;
}

class EasyTableThemeDataDefaults {
  static const double columnGap = 4;
  static const double rowGap = 0;
  static const BoxDecoration tableDecoration = BoxDecoration(
      border: Border(
          bottom: BorderSide(color: Colors.grey),
          top: BorderSide(color: Colors.grey),
          left: BorderSide(color: Colors.grey),
          right: BorderSide(color: Colors.grey)));
}
