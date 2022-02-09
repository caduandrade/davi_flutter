import 'package:easy_table/easy_table.dart';
import 'package:easy_table/src/theme/cell_theme_data.dart';
import 'package:flutter/material.dart';

/// The [EasyTable] theme.
/// Defines the configuration of the overall visual [EasyTableThemeData] for a widget subtree within the app.
class EasyTableThemeData {
  /// Builds a theme data.
  const EasyTableThemeData(
      {this.tableDecoration = EasyTableThemeDataDefaults.tableDecoration,
      this.cell = const CellThemeData(),
      this.header = const HeaderThemeData(),
      this.cellHeader = const CellHeaderThemeData()});

  final BoxDecoration? tableDecoration;

  final CellThemeData cell;
  final HeaderThemeData header;
  final CellHeaderThemeData cellHeader;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EasyTableThemeData &&
          runtimeType == other.runtimeType &&
          tableDecoration == other.tableDecoration &&
          cell == other.cell &&
          header == other.header &&
          cellHeader == other.cellHeader;

  @override
  int get hashCode =>
      tableDecoration.hashCode ^
      cell.hashCode ^
      header.hashCode ^
      cellHeader.hashCode;
}

class EasyTableThemeDataDefaults {
  static const BoxDecoration tableDecoration = BoxDecoration(
      border: Border(
          bottom: BorderSide(color: Colors.grey),
          top: BorderSide(color: Colors.grey),
          left: BorderSide(color: Colors.grey),
          right: BorderSide(color: Colors.grey)));
}
