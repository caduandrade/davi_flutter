import 'package:easy_table/src/theme/row_color.dart';
import 'package:flutter/material.dart';

class TablePaintSettings {
  TablePaintSettings(
      {this.debugAreas = false,
      required this.hoveredRowIndex,
      required this.hoveredColor,
      required this.columnDividerColor});

  final bool debugAreas;
  final int? hoveredRowIndex;
  final EasyTableRowColor? hoveredColor;
  final Color? columnDividerColor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TablePaintSettings &&
          runtimeType == other.runtimeType &&
          debugAreas == other.debugAreas &&
          hoveredRowIndex == other.hoveredRowIndex &&
          hoveredColor == other.hoveredColor &&
          columnDividerColor == other.columnDividerColor;

  @override
  int get hashCode =>
      debugAreas.hashCode ^
      hoveredRowIndex.hashCode ^
      hoveredColor.hashCode ^
      columnDividerColor.hashCode;
}
